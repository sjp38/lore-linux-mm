Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 202626B0033
	for <linux-mm@kvack.org>; Fri, 24 Nov 2017 02:33:43 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id a63so13063203wrc.1
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 23:33:43 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l76sor7608157wrc.36.2017.11.23.23.33.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 23:33:41 -0800 (PST)
Date: Fri, 24 Nov 2017 08:33:38 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 00/23] [v4] KAISER: unmap most of the kernel from
 userspace page tables
Message-ID: <20171124073338.4petx4rxiwwb5bxu@gmail.com>
References: <20171123003438.48A0EEDE@viggo.jf.intel.com>
 <c55957c0-cf1a-eb8d-c37a-c2b69ada2312@linux.intel.com>
 <20171124063514.36xlqnh5seszy4nu@gmail.com>
 <132d8ad8-a85f-5184-2dee-39a47e22e1ff@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <132d8ad8-a85f-5184-2dee-39a47e22e1ff@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, moritz.lipp@iaik.tugraz.at, daniel.gruss@iaik.tugraz.at, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, x86@kernel.org, jgross@suse.com


* Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 11/23/2017 10:35 PM, Ingo Molnar wrote:
> > So the pteval_t changes break the build on most non-x86 architectures (alpha, arm, 
> > arm64, etc.), because most of them don't have an asm/pgtable_types.h file.
> > 
> > pteval_t is an x86-ism.
> > 
> > So I left out the changes below.
> 
> There was a warning on the non-PAE 32-bit builds saying that there was a
> shift larger than the type.  I assumed this was because of a reference
> to _PAGE_NX, and thus we needed a change to pteval_t.
> 
> But, now that I think about it more, that doesn't make sense since
> _PAGE_NX should be #defined down to a 0 on those configs unless
> something is wrong.

If pte flags need to be passed around then the canonical way to do it is to pass 
around a pte_t, and use pte_val() on it and such.

But please investigate the warning.

One other detail: I see you fixed some of the commit titles to use standard x86 
tags - could you please also capitalize sentences? I.e.:

  - x86/mm/kaiser: allow flushing for future ASID switches
  + x86/mm/kaiser: Allow flushing for future ASID switches

Could you please also double-check whether the merges I did in the latest 
WIP.x86/mm branch are OK? Andy changed the entry stack code a bit under Kaiser, 
which created about 3 new conflicts.

The key resolutions that I did were:

        .macro interrupt func
        cld

        testb   $3, CS-ORIG_RAX(%rsp)
        jz      1f
        SWAPGS
        SWITCH_TO_KERNEL_CR3 scratch_reg=%rax
        call    switch_to_thread_stack
1:

Plus I also dropped the extra switch_to_thread_stack call done in:

  x86/mm/kaiser: Prepare assembly for entry/exit CR3 switching

Because Andy's latest preparatory patch does it now:

  x86/entry/64: Use a percpu trampoline stack for IDT entries

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
