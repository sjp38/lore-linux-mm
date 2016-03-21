Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f52.google.com (mail-vk0-f52.google.com [209.85.213.52])
	by kanga.kvack.org (Postfix) with ESMTP id D82836B0005
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 16:12:23 -0400 (EDT)
Received: by mail-vk0-f52.google.com with SMTP id e185so228354452vkb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:12:23 -0700 (PDT)
Received: from mail-vk0-x232.google.com (mail-vk0-x232.google.com. [2607:f8b0:400c:c05::232])
        by mx.google.com with ESMTPS id 11si1072202uas.199.2016.03.21.13.12.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Mar 2016 13:12:22 -0700 (PDT)
Received: by mail-vk0-x232.google.com with SMTP id q138so136417097vkb.3
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 13:12:22 -0700 (PDT)
MIME-Version: 1.0
Date: Mon, 21 Mar 2016 13:12:21 -0700
Message-ID: <CAMbhsRQY-KifZdNfBS-=MbgbRBuHEWv-f+DB4OUkPH=pPrhpfw@mail.gmail.com>
Subject: VM_GROWSDOWN and fixed size stacks
From: Colin Cross <ccross@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
Cc: Android Kernel Team <kernel-team@android.com>

I recently came across some Android userspace code that jumps through
some strange hoops to produce a fixed size stack on the main stack
(https://android.googlesource.com/platform/art/+/db1f7dac02f6dcecac3e032f10abbcdbf3cf4331/runtime/thread.cc#543).
ART (the Android runtime) uses a unified stack for managed and native
code.  It installs its own guard pages at the bottom of the stack, and
converts stack overflow segfaults into the appropriate exceptions.  In
order to run the exception handling code, it unprotects some of the
guard pages and uses them as stack.

To get a fixed size stack, ART accessing every page in the desired
stack, starting from the current SP and moving down to the desired
guard page.  This method was determined empirically, and is required
by a strange combination of rules in arch/*/mm/fault.c and
check_stack_guard_page for VM_GROWSDOWN mappings.

On arm and arm64, fault.c will happily extend the stack as far as
necessary with a single read below the stack and above any other
mapping.  x86 fault.c places an additional restriction, the fault
address cannot be more than ~64kB below the current stack pointer (not
the bottom of the current stack mapping).  However, that stack pointer
restriction is not enforced by check_stack_guard_page, which will grow
the stack by 4kB for any access in the last page of the current stack
mapping, which is why the repeated reads in ART can work on x86.

On a pthread_create'd thread, mprotecting the bottom of the stack to
PROT_NONE would be sufficient.  For the VM_GROWSDOWN stack, manually
placing guard pages at the bottom of the desired stack without
expanding it doesn't work, because check_stack_guard_page will fault
one page before that.  In addition, other non-stack mappings might get
placed between the stack and the guard pages.

Manually mapping the entirety of the desired stack would work, but
causes confusing reporting in /proc/pid/maps.  The manual mapping
would not merge with the VM_GROWSDOWN mapping because of the mismatch
flags, resulting in a stack that spans two mappings, and only one of
them would get annotated with [stack].  There would also be a one page
gap shown in /proc/pid/maps, because task_mmu.c show_map_vma subtracts
off the virtual guard page, although since it is already mapped
accesses to the gap would not fault.

Hiding the stack guard page also causes incorrect reporting for the
current ART stack growing hack.  The code reads up to and including
the desired guard pages, and then mprotects them to PROT_NONE.  The
virtual guard page is one page below the last read, so there is a one
page VM_GROWSDOWN mapping located below the guard page.  When
show_map_vma subtracts a page it ends up showing a mapping whose start
and end addresses are the same:
7ff82c5000-7ff82c5000 rw-p 00000000 00:00 0
7ff82c5000-7ff82c6000 ---p 00000000 00:00 0
7ff82c6000-7ff8ac5000 rw-p 00000000 00:00 0                              [stack]

The hack that is in place now works, although it is a unnecessarily
slow.  We've recently restricted it to only running on the main
VM_GROWSDOWN thread and not every spawned thread by first checking if
mprotect PROT_NONE at the bottom of the stack works.  It seems like
there should be a better way to handle this though.  Switching to
another stack would work, but cleaning up and freeing the old stack
would be hard since the top of the stack generally contains TLS and
global getauxval storage.  If there were some way to disable the
VM_GROWSDOWN flag we could manually extend the stack without
introducing the /proc/pid/maps reporting problems.  Or if there was
some way to manually extend a  VM_GROWSDOWN stack we could get the
same behavior as today without faulting 2000 times and hoping that a
future kernel doesn't decide that a check_stack_guard_page far below
the current stack pointer is a segfault.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
