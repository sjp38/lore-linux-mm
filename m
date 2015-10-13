Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8EE6B0253
	for <linux-mm@kvack.org>; Tue, 13 Oct 2015 12:07:22 -0400 (EDT)
Received: by wijq8 with SMTP id q8so38868016wij.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:07:21 -0700 (PDT)
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com. [209.85.212.180])
        by mx.google.com with ESMTPS id gl16si4794409wjc.187.2015.10.13.09.06.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Oct 2015 09:06:58 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so199418263wic.0
        for <linux-mm@kvack.org>; Tue, 13 Oct 2015 09:06:58 -0700 (PDT)
Date: Tue, 13 Oct 2015 19:06:56 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: pmd_modify() semantics
Message-ID: <20151013160656.GA14071@node>
References: <C2D7FE5348E1B147BCA15975FBA23075D781CC4F@IN01WEMBXB.internal.synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075D781CC4F@IN01WEMBXB.internal.synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Minchan Kim <minchan@kernel.org>

On Tue, Oct 13, 2015 at 01:58:39PM +0000, Vineet Gupta wrote:
> Hi Kirill,
> 
> I'm running LTP tests on the new ARC THP code and thp03 seems to be triggering mm
> spew.
> 
> --------------->8---------------------
> [ARCLinux]# ./ltp-thp03-extract
> PID 60
> bad pmd bf1c4600 be600231
> ../mm/pgtable-generic.c:34: bad pgd be600231.
> bad pmd bf1c4604 bd800231
> ../mm/pgtable-generic.c:34: bad pgd bd800231.
> BUG: Bad rss-counter state mm:bf12e900 idx:1 val:512
> BUG: non-zero nr_ptes on freeing mm: 2
> --------------->8---------------------
> 
> I know what exactly is happening and the likely fix, but would want to get some
> thoughts from you if possible.
> 
> background: ARC is software page walked with PGD -> PTE -> page for normal and PMD
> -> page for THP case. A vanilla PGD doesn't have any flags - only pointer to PTE
> 
> A reduced version of thp03 allocates a THP, dirties it, followed by
> mprotect(PROT_NONE).
> At the time of mprotect() -> change_huge_pmd() -> pmd_modify() needs to change
> some of the bits.
> 
> The issue is ARC implementation of pmd_modify() based on pte variant, which
> retains the soft pte bits (dirty and accessed).
> 
> static inline pmd_t pmd_modify(pmd_t pmd, pgprot_t newprot)
> {
>     return pte_pmd(pte_modify(pmd_pte(pmd), newprot));
> }
> 
> Obvious fix is to rewrite pmd_modify() so that it clears out all pte type flags
> but that assumes PMD is becoming PGD (a vanilla PGD on ARC doesn't have any
> flags). Can we have pmd_modify() ever be called for NOT splitting pmd e.g.
> mprotect Write to Read which won't split the THP like it does now and simply
> changes the prot flags. My proposed version of pmd_modify() will loose the dirty bit.

Hm? pmd_modify() is nothing to do with splitting. The mprotect() codepath
you've mentioned above calls pmd_modify() only if the THP is fully in
mprotect range.

> In short, what are the semantics of pmd_modify() - essentially does it imply pmd
> is being split so are free to make it like PGD.

No, pmd_modify() cannot make such assumption. That's just not true -- we
don't split PMD in such codepath. And even if we do, we construct new PMD
entry from scratch instead of modifying existing one.

So the semantics of pmd_modify(): you can assume that the entry is
pmd_large(), going to stay this way and you need to touch only
protection-related bit.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
