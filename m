Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7FE106B0038
	for <linux-mm@kvack.org>; Sat, 11 Feb 2017 14:50:07 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id r18so23914010wmd.1
        for <linux-mm@kvack.org>; Sat, 11 Feb 2017 11:50:07 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id p12si7104930wrd.158.2017.02.11.11.50.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Feb 2017 11:50:06 -0800 (PST)
Date: Sat, 11 Feb 2017 20:49:43 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 3/5] x86/mm: fix 32-bit mmap() for 64-bit ELF
In-Reply-To: <20170130120432.6716-4-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1702111513460.3734@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-4-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On Mon, 30 Jan 2017, Dmitry Safonov wrote:

> Fix 32-bit compat_sys_mmap() mapping VMA over 4Gb in 64-bit binaries
> and 64-bit sys_mmap() mapping VMA only under 4Gb in 32-bit binaries.
> Introduced new bases for compat syscalls in mm_struct:
> mmap_compat_base and mmap_compat_legacy_base for top-down and
> bottom-up allocations accordingly.
> Taught arch_get_unmapped_area{,_topdown}() to use the new mmap_bases
> in compat syscalls for high/low limits in vm_unmapped_area().
> 
> I discovered that bug on ZDTM tests for compat 32-bit C/R.
> Working compat sys_mmap() in 64-bit binaries is really needed for that
> purpose, as 32-bit applications are restored from 64-bit CRIU binary.

Again that changelog sucks.

Explain the problem/bug first. Then explain the way to fix it and do not
tell fairy tales about what you did without explaing the bug in the first
place.

Documentation....SubittingPatches explains that very well.


> +config HAVE_ARCH_COMPAT_MMAP_BASES
> +	bool
> +	help
> +	  If this is set, one program can do native and compatible syscall
> +	  mmap() on architecture. Thus kernel has different bases to
> +	  compute high and low virtual address limits for allocation.

Sigh. How is a user supposed to decode this?

	  This allows 64bit applications to invoke syscalls in 64bit and
	  32bit mode. Required for ....

>  
> @@ -113,10 +114,19 @@ static void find_start_end(unsigned long flags, unsigned long *begin,
>  		if (current->flags & PF_RANDOMIZE) {
>  			*begin = randomize_page(*begin, 0x02000000);
>  		}
> -	} else {
> -		*begin = current->mm->mmap_legacy_base;
> -		*end = TASK_SIZE;
> +		return;
>  	}
> +
> +#ifdef CONFIG_COMPAT

Can you please find a solution which does not create that ifdef horror in
the code? Just a few accessors to those compat fields are required to do
that.

> +
> +#ifdef CONFIG_COMPAT
> +	arch_pick_mmap_base(&mm->mmap_compat_base, &mm->mmap_compat_legacy_base,
> +			arch_compat_rnd(), IA32_PAGE_OFFSET);
> +#endif

Ditto

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
