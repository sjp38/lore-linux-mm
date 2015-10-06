Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 459FB6B026F
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 13:12:03 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so216036662pac.0
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 10:12:03 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id yd7si50294538pab.46.2015.10.06.10.12.02
        for <linux-mm@kvack.org>;
        Tue, 06 Oct 2015 10:12:02 -0700 (PDT)
Date: Tue, 6 Oct 2015 18:11:40 +0100
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [PATCH V4 2/3] arm64: support initrd outside kernel linear map
Message-ID: <20151006171140.GE26433@leverpostej>
References: <1439830867-14935-1-git-send-email-msalter@redhat.com>
 <1439830867-14935-3-git-send-email-msalter@redhat.com>
 <20150908113113.GA20562@leverpostej>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150908113113.GA20562@leverpostej>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "msalter@redhat.com" <msalter@redhat.com>
Cc: "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Catalin Marinas <Catalin.Marinas@arm.com>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Tue, Sep 08, 2015 at 12:31:13PM +0100, Mark Rutland wrote:
> Hi Mark,
> 
> On Mon, Aug 17, 2015 at 06:01:06PM +0100, Mark Salter wrote:
> > The use of mem= could leave part or all of the initrd outside of
> > the kernel linear map. This will lead to an error when unpacking
> > the initrd and a probable failure to boot. This patch catches that
> > situation and relocates the initrd to be fully within the linear
> > map.
> 
> With next-20150908, this patch results in a confusing message at boot when not
> using an initrd:
> 
> Moving initrd from [4080000000-407fffffff] to [9fff49000-9fff48fff]
> 
> I think that can be solved by folding in the diff below.

Mark, it looks like this fell by the wayside.

Do you have any objection to this? I'll promote this to it's own patch
if not.

Mark.

> 
> Thanks,
> Mark.
> 
> diff --git a/arch/arm64/kernel/setup.c b/arch/arm64/kernel/setup.c
> index 6bab21f..2322479 100644
> --- a/arch/arm64/kernel/setup.c
> +++ b/arch/arm64/kernel/setup.c
> @@ -364,6 +364,8 @@ static void __init relocate_initrd(void)
>                 to_free = ram_end - orig_start;
>  
>         size = orig_end - orig_start;
> +       if (!size)
> +               return;
>  
>         /* initrd needs to be relocated completely inside linear mapping */
>         new_start = memblock_find_in_range(0, PFN_PHYS(max_pfn),
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
