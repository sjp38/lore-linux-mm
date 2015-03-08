Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id 9FA916B0032
	for <linux-mm@kvack.org>; Sun,  8 Mar 2015 16:41:02 -0400 (EDT)
Received: by wghl2 with SMTP id l2so27055409wgh.8
        for <linux-mm@kvack.org>; Sun, 08 Mar 2015 13:41:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wt7si31708587wjc.159.2015.03.08.13.41.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 08 Mar 2015 13:41:00 -0700 (PDT)
Date: Sun, 8 Mar 2015 20:40:25 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: numa: Slow PTE scan rate if migration failures
 occur
Message-ID: <20150308203145.GA4038@suse.de>
References: <1425741651-29152-1-git-send-email-mgorman@suse.de>
 <1425741651-29152-5-git-send-email-mgorman@suse.de>
 <20150307163657.GA9702@gmail.com>
 <CA+55aFwDuzpL-k8LsV3touhNLh+TFSLKP8+-nPwMXkWXDYPhrg@mail.gmail.com>
 <20150308100223.GC15487@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150308100223.GC15487@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, xfs@oss.sgi.com, ppc-dev <linuxppc-dev@lists.ozlabs.org>

On Sun, Mar 08, 2015 at 11:02:23AM +0100, Ingo Molnar wrote:
> 
> * Linus Torvalds <torvalds@linux-foundation.org> wrote:
> 
> > On Sat, Mar 7, 2015 at 8:36 AM, Ingo Molnar <mingo@kernel.org> wrote:
> > >
> > > And the patch Dave bisected to is a relatively simple patch. Why 
> > > not simply revert it to see whether that cures much of the 
> > > problem?
> > 
> > So the problem with that is that "pmd_set_numa()" and friends simply 
> > no longer exist. So we can't just revert that one patch, it's the 
> > whole series, and the whole point of the series.
> 
> Yeah.
> 
> > What confuses me is that the only real change that I can see in that 
> > patch is the change to "change_huge_pmd()". Everything else is 
> > pretty much a 100% equivalent transformation, afaik. Of course, I 
> > may be wrong about that, and missing something silly.
> 
> Well, there's a difference in what we write to the pte:
> 
>  #define _PAGE_BIT_NUMA          (_PAGE_BIT_GLOBAL+1)
>  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
> 
> and our expectation was that the two should be equivalent methods from 
> the POV of the NUMA balancing code, right?
> 

Functionally yes but performance-wise no. We are now using the global bit
for NUMA faults at the very least.

> > And the changes to "change_huge_pmd()" were basically re-done
> > differently by subsequent patches anyway.
> > 
> > The *only* change I see remaining is that change_huge_pmd() now does
> > 
> >    entry = pmdp_get_and_clear_notify(mm, addr, pmd);
> >    entry = pmd_modify(entry, newprot);
> >    set_pmd_at(mm, addr, pmd, entry);
> > 
> > for all changes. It used to do that "pmdp_set_numa()" for the
> > prot_numa case, which did just
> > 
> >    pmd_t pmd = *pmdp;
> >    pmd = pmd_mknuma(pmd);
> >    set_pmd_at(mm, addr, pmdp, pmd);
> > 
> > instead.
> > 
> > I don't like the old pmdp_set_numa() because it can drop dirty bits,
> > so I think the old code was actively buggy.
> 
> Could we, as a silly testing hack not to be applied, write a 
> hack-patch that re-introduces the racy way of setting the NUMA bit, to 
> confirm that it is indeed this difference that changes pte visibility 
> across CPUs enough to create so many more faults?
> 

This was already done and tested by Dave but while it helped, it was
not enough.  As the approach was inherently unsafe it was dropped and the
throttling approach taken. However, the fact it made little difference
may indicate that this is somehow related to the global bit being used.

> Because if the answer is 'yes', then we can safely say: 'we regressed 
> performance because correctness [not dropping dirty bits] comes before 
> performance'.
> 
> If the answer is 'no', then we still have a mystery (and a regression) 
> to track down.
> 
> As a second hack (not to be applied), could we change:
> 
>  #define _PAGE_BIT_PROTNONE      _PAGE_BIT_GLOBAL
> 
> to:
> 
>  #define _PAGE_BIT_PROTNONE      (_PAGE_BIT_GLOBAL+1)
> 

In itself, that's not enough. The SWP_OFFSET_SHIFT would also need updating
as a partial revert of 21d9ee3eda7792c45880b2f11bff8e95c9a061fb but it
can be done.

> to double check that the position of the bit does not matter?
> 

It's worth checking in case it's a case of how the global bit is
treated. However, note that Dave is currently travelling for LSF/MM in
Boston and there is a chance he cannot test this week at all. I'm just
after landing in the hotel myself. I'll try find time during during one
of the breaks tomorrow but if the wireless is too crap then accessing the
test machine remotely might be an issue.

> I don't think we've exhaused all avenues of analysis here.
> 

True.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
