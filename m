Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id EBBF36B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 02:20:28 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so45533366wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 23:20:28 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id b1si8728384wiy.63.2015.09.25.23.20.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Sep 2015 23:20:27 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so42953258wic.1
        for <linux-mm@kvack.org>; Fri, 25 Sep 2015 23:20:26 -0700 (PDT)
Date: Sat, 26 Sep 2015 08:20:23 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH 10/26] x86, pkeys: notify userspace about protection key
 faults
Message-ID: <20150926062023.GB27841@gmail.com>
References: <20150916174903.E112E464@viggo.jf.intel.com>
 <20150916174906.51062FBC@viggo.jf.intel.com>
 <20150924092320.GA26876@gmail.com>
 <20150924093026.GA29699@gmail.com>
 <560435B4.1010603@sr71.net>
 <20150925071119.GB15753@gmail.com>
 <5605D660.8000009@sr71.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5605D660.8000009@sr71.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Thomas Gleixner <tglx@linutronix.de>


* Dave Hansen <dave@sr71.net> wrote:

> On 09/25/2015 12:11 AM, Ingo Molnar wrote:
> >>> > > Btw., how does pkey support interact with hugepages?
> >> > 
> >> > Surprisingly little.  I've made sure that everything works with huge pages and 
> >> > that the (huge) PTEs and VMAs get set up correctly, but I'm not sure I had to 
> >> > touch the huge page code at all.  I have test code to ensure that it works the 
> >> > same as with small pages, but everything worked pretty naturally.
> > Yeah, so the reason I'm asking about expectations is that this code:
> > 
> > +       follow_ret = follow_pte(tsk->mm, address, &ptep, &ptl);
> > +       if (!follow_ret) {
> > +               /*
> > +                * On a successful follow, make sure to
> > +                * drop the lock.
> > +                */
> > +               pte = *ptep;
> > +               pte_unmap_unlock(ptep, ptl);
> > +               ret = pte_pkey(pte);
> > 
> > is visibly hugepage-unsafe: if a vma is hugepage mapped, there are no ptes, only 
> > pmds - and the protection key index lives in the pmd. We don't seem to recover 
> > that information properly.
> 
> You got me on this one.  I assumed that follow_pte() handled huge pages.
>  It does not.
> 
> But, the code still worked.  Since follow_pte() fails for all huge
> pages, it just falls back to pulling the protection key out of the VMA,
> which _does_ work for huge pages.

That might be true for explicit hugetlb vmas, but what about transparent hugepages 
that can show up in regular vmas?

> I've actually removed the PTE walking and I just now use the VMA directly.  I 
> don't see a ton of additional value from walking the page tables when we can get 
> what we need from the VMA.

That's actually good, because it's also cheap, especially if we can get rid of the 
extra find_vma().

and we (thankfully) have no non-linear vmas to worry about anymore.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
