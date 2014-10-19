Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f178.google.com (mail-lb0-f178.google.com [209.85.217.178])
	by kanga.kvack.org (Postfix) with ESMTP id 386CC6B0070
	for <linux-mm@kvack.org>; Sun, 19 Oct 2014 11:32:27 -0400 (EDT)
Received: by mail-lb0-f178.google.com with SMTP id w7so2692371lbi.23
        for <linux-mm@kvack.org>; Sun, 19 Oct 2014 08:32:26 -0700 (PDT)
Received: from asavdk4.altibox.net (asavdk4.altibox.net. [109.247.116.15])
        by mx.google.com with ESMTPS id g8si10638847lae.48.2014.10.19.08.32.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 19 Oct 2014 08:32:25 -0700 (PDT)
Date: Sun, 19 Oct 2014 17:32:20 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: unaligned accesses in SLAB etc.
Message-ID: <20141019153219.GA10644@ravnborg.org>
References: <20141016.165017.1151349565275102498.davem@davemloft.net>
 <alpine.LRH.2.11.1410171410210.25429@adalberg.ut.ee>
 <20141018.135907.356113264227709132.davem@davemloft.net>
 <20141018.142335.1935310766779155342.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141018.142335.1935310766779155342.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: mroos@linux.ee, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, sparclinux@vger.kernel.org

On Sat, Oct 18, 2014 at 02:23:35PM -0400, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Sat, 18 Oct 2014 13:59:07 -0400 (EDT)
> 
> > I don't want to define the array size of the fpregs save area
> > explicitly and thereby placing an artificial limit there.
> 
> Nevermind, it seems we have a hard limit of 7 FPU save areas anyways.
> 
> Meelis, please try this patch:
> 
> diff --git a/arch/sparc/include/asm/thread_info_64.h b/arch/sparc/include/asm/thread_info_64.h
> index f85dc85..cc6275c 100644
> --- a/arch/sparc/include/asm/thread_info_64.h
> +++ b/arch/sparc/include/asm/thread_info_64.h
> @@ -63,7 +63,8 @@ struct thread_info {
>  	struct pt_regs		*kern_una_regs;
>  	unsigned int		kern_una_insn;
>  
> -	unsigned long		fpregs[0] __attribute__ ((aligned(64)));
> +	unsigned long		fpregs[(7 * 256) / sizeof(unsigned long)]

This part:

> +		__attribute__ ((aligned(64)));

Could be written as __aligned(64)

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
