Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 5D6916B0072
	for <linux-mm@kvack.org>; Mon, 29 Apr 2013 12:07:11 -0400 (EDT)
Date: Mon, 29 Apr 2013 17:07:01 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH 1/2] mm: hugetlb: Copy huge_pmd_share from x86 to
 mm.
Message-ID: <20130429160701.GD12884@arm.com>
References: <1367247356-11246-1-git-send-email-steve.capper@linaro.org>
 <1367247356-11246-2-git-send-email-steve.capper@linaro.org>
 <20130429152641.GC12884@arm.com>
 <20130429154748.GA11915@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130429154748.GA11915@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Ken Chen <kenchen@google.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <Will.Deacon@arm.com>

On Mon, Apr 29, 2013 at 04:47:49PM +0100, Steve Capper wrote:
> On Mon, Apr 29, 2013 at 04:26:41PM +0100, Catalin Marinas wrote:
> > On Mon, Apr 29, 2013 at 03:55:55PM +0100, Steve Capper wrote:
> > > Under x86, multiple puds can be made to reference the same bank of
> > > huge pmds provided that they represent a full PUD_SIZE of shared
> > > huge memory that is aligned to a PUD_SIZE boundary.
> > > 
> > > The code to share pmds does not require any architecture specific
> > > knowledge other than the fact that pmds can be indexed, thus can
> > > be beneficial to some other architectures.
> > > 
> > > This patch copies the huge pmd sharing (and unsharing) logic from
> > > x86/ to mm/ and introduces a new config option to activate it:
> > > CONFIG_ARCH_WANTS_HUGE_PMD_SHARE.
> > 
> > Just wondering whether more of it could be shared. The following look
> > pretty close to what you'd write for arm64:
> > 
> > - huge_pte_alloc()
> > - huge_pte_offset() (there is a pud_large macro on x86 which checks for
> >   present & huge, we can replace it with just pud_huge in this function
> >   as it already checks for present)
> > - follow_huge_pud()
> > - follow_huge_pmd()
> 
> I did do something like this initially, then reined it back a bit
> as it placed implicit restrictions on x86 and arm64.
> 
> If we enable 64K pages on arm64 for instance, we obviate the need
> to share pmds (pmd_index doesn't exist for 64K pages). So I have a
> slightly different huge_pte_alloc function to account for this.

I guess with 64K pages on arm64 (two levels of page tables), you can't
share the pmds anyway. pud_none() is defined as 0 in pgtable-nopmd.h.
huge_pte_alloc() can probably be the same with 64K pages since pud_alloc
always succeeds (pmd/pud/pgd are all the same).

So with some #ifdef __PAGETABLE_PMD_FOLDED (not nice but it allows for
some more code sharing) you can add empty (NULL-returning)
huge_pmd_share/huge_pmd_unshare functions and avoid the compiler error
for pmd_index.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
