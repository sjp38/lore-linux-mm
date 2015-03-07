Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 926F76B0038
	for <linux-mm@kvack.org>; Sat,  7 Mar 2015 15:56:22 -0500 (EST)
Received: by wevm14 with SMTP id m14so66191022wev.13
        for <linux-mm@kvack.org>; Sat, 07 Mar 2015 12:56:22 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z5si26884898wjz.64.2015.03.07.12.56.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 07 Mar 2015 12:56:21 -0800 (PST)
Date: Sat, 7 Mar 2015 20:56:16 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/4] mm: thp: Return the correct value for change_huge_pmd
Message-ID: <20150307205616.GZ3087@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
 <1425741651-29152-2-git-send-email-mgorman@suse.de>
 <CA+55aFyCgzNGU-VAaKvwTYFhtJc_ugLK6hRzZBCxMYdAt5TVuA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFyCgzNGU-VAaKvwTYFhtJc_ugLK6hRzZBCxMYdAt5TVuA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sat, Mar 07, 2015 at 12:31:03PM -0800, Linus Torvalds wrote:
> On Sat, Mar 7, 2015 at 7:20 AM, Mel Gorman <mgorman@suse.de> wrote:
> >
> >                 if (!prot_numa || !pmd_protnone(*pmd)) {
> > -                       ret = 1;
> >                         entry = pmdp_get_and_clear_notify(mm, addr, pmd);
> >                         entry = pmd_modify(entry, newprot);
> >                         ret = HPAGE_PMD_NR;
> 
> Hmm. I know I acked this already, but the return value - which correct
> - is still potentially something we could improve upon.
> 
> In particular, we don't need to flush the TLB's if the old entry was
> not present. Sadly, we don't have a helper function for that.
> 
> But the code *could* do something like
> 
>     entry = pmdp_get_and_clear_notify(mm, addr, pmd);
>     ret = pmd_tlb_cacheable(entry) ? HPAGE_PMD_NR : 1;
>     entry = pmd_modify(entry, newprot);
> 
> where pmd_tlb_cacheable() on x86 would test if _PAGE_PRESENT (bit #0) is set.
> 

I agree with you in principle. pmd_tlb_cacheable looks and sounds very
similar to pte_accessible().

> In particular, that would mean that as we change *from* a protnone
> (whether NUMA or really protnone) we wouldn't need to flush the TLB.
> 
> In fact, we could make it even more aggressive: it's not just an old
> non-present TLB entry that doesn't need flushing - we can avoid the
> flushing whenever we strictly increase the access rigths. So we could
> have something that takes the old entry _and_ the new protections into
> account, and avoids the TLB flush if the new entry is strictly more
> permissive.
> 
> This doesn't explain the extra TLB flushes Dave sees, though, because
> the old code didn't make those kinds of optimizations either. But
> maybe something like this is worth doing.
> 

I think it is worth doing although it'll be after LSF/MM before I do it. I
severely doubt this is what Dave is seeing because the vmstats indicated
there was no THP activity but it's still a good idea.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
