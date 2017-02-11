Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C444F6B0038
	for <linux-mm@kvack.org>; Sat, 11 Feb 2017 15:13:12 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id o16so21898322wra.2
        for <linux-mm@kvack.org>; Sat, 11 Feb 2017 12:13:12 -0800 (PST)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id r19si7158925wrc.146.2017.02.11.12.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Sat, 11 Feb 2017 12:13:11 -0800 (PST)
Date: Sat, 11 Feb 2017 21:13:01 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCHv4 4/5] x86/mm: check in_compat_syscall() instead TIF_ADDR32
 for mmap(MAP_32BIT)
In-Reply-To: <20170130120432.6716-5-dsafonov@virtuozzo.com>
Message-ID: <alpine.DEB.2.20.1702112107490.3734@nanos>
References: <20170130120432.6716-1-dsafonov@virtuozzo.com> <20170130120432.6716-5-dsafonov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Safonov <dsafonov@virtuozzo.com>
Cc: linux-kernel@vger.kernel.org, 0x7f454c46@gmail.com, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@suse.de>, x86@kernel.org, linux-mm@kvack.org

On Mon, 30 Jan 2017, Dmitry Safonov wrote:

> At this momet, logic in arch_get_unmapped_area{,_topdown} for mmaps with
> MAP_32BIT flag checks TIF_ADDR32 which means:
> o if 32-bit ELF changes mode to 64-bit on x86_64 and then tries to
>   mmap() with MAP_32BIT it'll result in addr over 4Gb (as default is
>   top-down allocation)
> o if 64-bit ELF changes mode to 32-bit and tries mmap() with MAP_32BIT,
>   it'll allocate only memory in 1GB space: [0x40000000, 0x80000000).
> 
> Fix it by handeling MAP_32BIT in 64-bit syscalls only.

I really have a hard time to understand what is fixed and how that is
related to the $subject.

Again. Please explain the problem first properly so one can understand the
issue immediately.

> As a little bonus it'll make thread flag a little less used.

I really do not understand the bonus part here. You replace the thread flag
check with a different one and AFAICT this looks like oart of the 'fix'.

Thanks,

	tglx

> @@ -101,7 +101,7 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
>  static void find_start_end(unsigned long flags, unsigned long *begin,
>  			   unsigned long *end)
>  {
> -	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT)) {
> +	if (!in_compat_syscall() && (flags & MAP_32BIT)) {
>  		/* This is usually used needed to map code in small
>  		   model, so it needs to be in the first 31bit. Limit
>  		   it to that.  This means we need to move the
> @@ -195,7 +195,7 @@ arch_get_unmapped_area_topdown(struct file *filp, const unsigned long addr0,
>  		return addr;
>  
>  	/* for MAP_32BIT mappings we force the legacy mmap base */
> -	if (!test_thread_flag(TIF_ADDR32) && (flags & MAP_32BIT))
> +	if (!in_compat_syscall() && (flags & MAP_32BIT))
>  		goto bottomup;
>  
>  	/* requesting a specific address */
> -- 
> 2.11.0
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
