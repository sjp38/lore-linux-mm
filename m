Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id C00BC6B025E
	for <linux-mm@kvack.org>; Tue, 10 May 2016 12:08:10 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id e63so40015946iod.2
        for <linux-mm@kvack.org>; Tue, 10 May 2016 09:08:10 -0700 (PDT)
Received: from mail-oi0-x22d.google.com (mail-oi0-x22d.google.com. [2607:f8b0:4003:c06::22d])
        by mx.google.com with ESMTPS id i20si1007872otd.58.2016.05.10.09.08.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 May 2016 09:08:09 -0700 (PDT)
Received: by mail-oi0-x22d.google.com with SMTP id k142so23299705oib.1
        for <linux-mm@kvack.org>; Tue, 10 May 2016 09:08:09 -0700 (PDT)
MIME-Version: 1.0
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 10 May 2016 09:07:49 -0700
Message-ID: <CALCETrWWZy0hngPU8MCiQvnH+s0awpFE8wNBrYsf_c+nz6ZsDg@mail.gmail.com>
Subject: Getting rid of dynamic TASK_SIZE (on x86, at least)
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <0x7f454c46@gmail.com>, Ruslan Kabatsayev <b7.10110111@gmail.com>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Borislav Petkov <bp@alien8.de>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Oleg Nesterov <oleg@redhat.com>

Hi all-

I'm trying to get rid of x86's dynamic TASK_SIZE and just redefine it
to TASK_SIZE_MAX.  So far, these are the TASK_SIZE users that actually
seem to care about the task in question:

get_unmapped_area.  This is used by mmap, mremap, exec, uprobe XOL,
and maybe some other things.

 - mmap, mremap, etc: IMO this should check in_compat_syscall, not
TIF_ADDR32.  If a 64-bit task does an explicit 32-bit mmap (using int
$0x80, for example), it should get a 32-bit address back.

 - xol_add_vma: This one is weird: uprobes really is doing something
behind the task's back, and the addresses need to be consistent with
the address width.  I'm not quite sure what to do here.

 - exec.  This wants to set up mappings that are appropriate for the new task.

My inclination would be add a new 'limit' parameter to all the
get_unmapped_area variants and possible to vm_brk and friends and to
thus push the decision into the callers.  For the syscalls, we could
add:

static inline unsigned long this_syscall_addr_limit(void) { return TASK_SIZE; }

and override it on x86.

I'm not super excited to write that patch, though...

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
