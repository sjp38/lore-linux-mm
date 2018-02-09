Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 670E96B000E
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 07:11:53 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id y44so4367225wry.8
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 04:11:53 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e123si1512815wma.186.2018.02.09.04.11.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Feb 2018 04:11:51 -0800 (PST)
Subject: Re: [PATCH 00/31 v2] PTI support for x86_32
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
From: Juergen Gross <jgross@suse.com>
Message-ID: <35f19c79-7277-3ad8-50bf-8def929377b6@suse.com>
Date: Fri, 9 Feb 2018 13:11:42 +0100
MIME-Version: 1.0
In-Reply-To: <1518168340-9392-1-git-send-email-joro@8bytes.org>
Content-Type: text/plain; charset=utf-8
Content-Language: de-DE
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, jroedel@suse.de

On 09/02/18 10:25, Joerg Roedel wrote:
> Hi,
> 
> here is the second version of my PTI implementation for
> x86_32, based on tip/x86-pti-for-linus. It took a lot longer
> than I had hoped, but there have been a number of obstacles
> on the way. It also isn't the small patch-set anymore that v1
> was, but compared to it this one actually works :)
> 
> The biggest changes were necessary in the entry code, a lot
> of it is moving code around, but there are also significant
> changes to get all cases covered. This includes NMIs and
> exceptions on the kernel exit-path where we are already on
> the entry-stack. To make this work I decided to mostly split
> up the common kernel-exit path into a return-to-kernel,
> return-to-user and return-from-nmi part.
> 
> On the page-table side I had to do a lot of special cases
> for PAE because PAE paging is so, well, special. The biggest
> example here is the LDT mapping code, which needs to work on
> the PMD level instead of PGD when PAE is enabled.
> 
> During development I also experimented with unshared PMDs
> between the kernel and the user page-tables for PAE. It
> worked by allocating 8k PMDs and using the lower half for
> the kernel and the upper half for the user page-table. While
> this worked and allowed me to NX-protect the user-space
> address-range in the kernel page-table, it also required 5
> order-1 allocations in low-mem for each process. In my
> testing I got this to fail pretty quickly and trigger OOM,
> so I abandoned the approach for now.
> 
> Here is how I tested these patches:
> 
> 	* Booted on a real machine (4C/8T, 16GB RAM) and run
> 	  an overnight load-test with 'perf top' running
> 	  (for the NMIs), the ldt_gdt selftest running in a
> 	  loop (for more stress on the entry/exit path) and
> 	  a -j16 kernel compile also running in a loop. The
> 	  box survived the test, which ran for more than 18
> 	  hours.
> 
> 	* Tested most x86 selftests in the kernel on the
> 	  real machine. This showed no regressions. I did
> 	  not run the mpx and protection-key tests, as the
> 	  machine does not support these features, and I
> 	  also skipped the check_initial_reg_state test, as
> 	  it made problems while compiling and it didn't
> 	  seem relevant enough to fix that for this
> 	  patch-set.
> 
> 	* Boot tested all valid combinations of [NO]HIGHMEM* vs.
> 	  VMSPLIT* vs. PAE in KVM. All booted fine.
> 
> 	* Did compile-tests with various configs (allyes,
> 	  allmod, defconfig, ..., basically what I usually
> 	  use to test the iommu-tree as well). All compiled
> 	  fine.
> 
> 	* Some basic compile, boot and runtime testing of
> 	  64 bit to make sure I didn't break anything there.
> 
> I did not explicitly test wine and dosemu, but since the
> vm86 and the ldt_gdt self-tests all passed fine I am
> confident that those will also still work.
> 
> XENPV is also untested from my side, but I added checks to
> not do the stack switches in the entry-code when XENPV is
> enabled, so hopefully it works. But someone should test it,
> of course.

That's unfortunate. 32 bit XENPV kernel is vulnerable to Meltdown, too.
I'll have a look whether 32 bit XENPV is still working, though.

Adding support for KPTI with Xen PV should probably be done later. :-)


Juergen

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
