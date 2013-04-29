Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id EBB2D6B0070
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 11:47:57 -0400 (EDT)
Received: by mail-wg0-f45.google.com with SMTP id l18so3857145wgh.12
        for <linux-mm@kvack.org>; Mon, 29 Apr 2013 08:47:56 -0700 (PDT)
Date: Mon, 29 Apr 2013 16:47:49 +0100
From: Steve Capper <steve.capper@linaro.org>
Subject: Re: [RFC PATCH 1/2] mm: hugetlb: Copy huge_pmd_share from x86 to
 mm.
Message-ID: <20130429154748.GA11915@linaro.org>
References: <1367247356-11246-1-git-send-email-steve.capper@linaro.org>
 <1367247356-11246-2-git-send-email-steve.capper@linaro.org>
 <20130429152641.GC12884@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130429152641.GC12884@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>

On Mon, Apr 29, 2013 at 04:26:41PM +0100, Catalin Marinas wrote:
> Steve,

Hi Catalin,

> 
> On Mon, Apr 29, 2013 at 03:55:55PM +0100, Steve Capper wrote:
> > Under x86, multiple puds can be made to reference the same bank of
> > huge pmds provided that they represent a full PUD_SIZE of shared
> > huge memory that is aligned to a PUD_SIZE boundary.
> > 
> > The code to share pmds does not require any architecture specific
> > knowledge other than the fact that pmds can be indexed, thus can
> > be beneficial to some other architectures.
> > 
> > This patch copies the huge pmd sharing (and unsharing) logic from
> > x86/ to mm/ and introduces a new config option to activate it:
> > CONFIG_ARCH_WANTS_HUGE_PMD_SHARE.
> 
> Just wondering whether more of it could be shared. The following look
> pretty close to what you'd write for arm64:
> 
> - huge_pte_alloc()
> - huge_pte_offset() (there is a pud_large macro on x86 which checks for
>   present & huge, we can replace it with just pud_huge in this function
>   as it already checks for present)
> - follow_huge_pud()
> - follow_huge_pmd()

I did do something like this initially, then reined it back a bit
as it placed implicit restrictions on x86 and arm64.

If we enable 64K pages on arm64 for instance, we obviate the need
to share pmds (pmd_index doesn't exist for 64K pages). So I have a
slightly different huge_pte_alloc function to account for this.

I would be happy to move more code from x86 to mm though, as my
huge_pte_offset and follow_huge_p[mu]d functions are pretty much
identical to the x86 ones. This patch, I thought, was the most I
could get away with :-).

Cheers,
-- 
Steve

> 
> Of course, arch-specific macros like pud_huge, pmd_huge would have to go
> in a header file.
> 
> -- 
> Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
