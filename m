Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 8DB9C6B0254
	for <linux-mm@kvack.org>; Tue, 26 Jan 2016 10:59:27 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id ho8so99325076pac.2
        for <linux-mm@kvack.org>; Tue, 26 Jan 2016 07:59:27 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q85si2721675pfq.247.2016.01.26.07.59.26
        for <linux-mm@kvack.org>;
        Tue, 26 Jan 2016 07:59:26 -0800 (PST)
Date: Tue, 26 Jan 2016 15:59:20 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v2 RESEND 1/2] arm, arm64: change_memory_common with
 numpages == 0 should be no-op.
Message-ID: <20160126155919.GA28238@arm.com>
References: <1453820393-31179-1-git-send-email-mika.penttila@nextfour.com>
 <1453820393-31179-2-git-send-email-mika.penttila@nextfour.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1453820393-31179-2-git-send-email-mika.penttila@nextfour.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mika.penttila@nextfour.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux@arm.linux.org.uk, catalin.marinas@arm.com

Hi Mika,

On Tue, Jan 26, 2016 at 04:59:52PM +0200, mika.penttila@nextfour.com wrote:
> From: Mika Penttila <mika.penttila@nextfour.com>
> 
> This makes the caller set_memory_xx() consistent with x86.
> 
> arm64 part is rebased on 4.5.0-rc1 with Ard's patch
>  lkml.kernel.org/g/<1453125665-26627-1-git-send-email-ard.biesheuvel@linaro.org>
> applied.
> 
> Signed-off-by: Mika Penttila mika.penttila@nextfour.com
> Reviewed-by: Laura Abbott <labbott@redhat.com>
> Acked-by: David Rientjes <rientjes@google.com>
> 
> ---
>  arch/arm/mm/pageattr.c   | 3 +++
>  arch/arm64/mm/pageattr.c | 3 +++
>  2 files changed, 6 insertions(+)
> 
> diff --git a/arch/arm/mm/pageattr.c b/arch/arm/mm/pageattr.c
> index cf30daf..d19b1ad 100644
> --- a/arch/arm/mm/pageattr.c
> +++ b/arch/arm/mm/pageattr.c
> @@ -49,6 +49,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>  		WARN_ON_ONCE(1);
>  	}
>  
> +	if (!numpages)
> +		return 0;
> +
>  	if (start < MODULES_VADDR || start >= MODULES_END)
>  		return -EINVAL;
>  
> diff --git a/arch/arm64/mm/pageattr.c b/arch/arm64/mm/pageattr.c
> index 1360a02..b582fc2 100644
> --- a/arch/arm64/mm/pageattr.c
> +++ b/arch/arm64/mm/pageattr.c
> @@ -53,6 +53,9 @@ static int change_memory_common(unsigned long addr, int numpages,
>  		WARN_ON_ONCE(1);
>  	}
>  
> +	if (!numpages)
> +		return 0;
> +

Thanks for this. I can reproduce the failure on my Juno board, so I'd
like to queue this for 4.5 since it fixes a real issue. I've taken the
liberty of rebasing the arm64 part to my fixes branch and writing a
commit message. Does the patch below look ok to you?

Will

--->8
