Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A614C6B0055
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 07:22:25 -0400 (EDT)
Date: Fri, 12 Jun 2009 13:22:58 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 1/5] HWPOISON: define VM_FAULT_HWPOISON to 0 when
	feature is disabled
Message-ID: <20090612112258.GA14123@elte.hu>
References: <20090611142239.192891591@intel.com> <20090611144430.414445947@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090611144430.414445947@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, "riel@redhat.com" <riel@redhat.com>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>


* Wu Fengguang <fengguang.wu@intel.com> wrote:

> So as to eliminate one #ifdef in the c source.
> 
> Proposed by Nick Piggin.
> 
> CC: Nick Piggin <npiggin@suse.de>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  arch/x86/mm/fault.c |    3 +--
>  include/linux/mm.h  |    7 ++++++-
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> --- sound-2.6.orig/arch/x86/mm/fault.c
> +++ sound-2.6/arch/x86/mm/fault.c
> @@ -819,14 +819,13 @@ do_sigbus(struct pt_regs *regs, unsigned
>  	tsk->thread.error_code	= error_code;
>  	tsk->thread.trap_no	= 14;
>  
> -#ifdef CONFIG_MEMORY_FAILURE
>  	if (fault & VM_FAULT_HWPOISON) {
>  		printk(KERN_ERR
>  	"MCE: Killing %s:%d due to hardware memory corruption fault at %lx\n",
>  			tsk->comm, tsk->pid, address);
>  		code = BUS_MCEERR_AR;
>  	}
> -#endif

Btw., anything like this should happen in close cooperation with the 
x86 tree, not as some pure MM feature. I dont see Cc:s and nothing 
that indicates that realization. What's going on here?

It is not at all clear to me whether propagating hardware failures 
this widely is desired from a general design POV. Most desktop 
hardware wont give a damn about this (and if a hardware fault 
happens you want to get as far from the crappy hardware as possible) 
so i'm not sure how relevant it is and how well tested it will 
become in practice.

I.e. really some wider discussion needs to happen on this.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
