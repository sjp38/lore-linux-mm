Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 814796B0005
	for <linux-mm@kvack.org>; Wed, 10 Apr 2013 05:10:23 -0400 (EDT)
Received: from epcpsbgm2.samsung.com (epcpsbgm2 [203.254.230.27])
 by mailout2.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0ML100HNX84VJLB0@mailout2.samsung.com> for
 linux-mm@kvack.org; Wed, 10 Apr 2013 18:10:19 +0900 (KST)
From: Chanho Park <chanho61.park@samsusng.com>
References: <1360890012-4684-1-git-send-email-chanho61.park@samsung.com>
 <20130405111158.GA13428@e103986-lin>
 <00a201ce35bd$5626fd90$0274f8b0$@samsusng.com>
 <20130410082059.GA12296@e103986-lin>
In-reply-to: <20130410082059.GA12296@e103986-lin>
Subject: RE: [PATCH] arm: mm: lockless get_user_pages_fast
Date: Wed, 10 Apr 2013 18:10:18 +0900
Message-id: <00bc01ce35cb$38b9ffb0$aa2dff10$@samsusng.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
Content-language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Steve Capper' <steve.capper@arm.com>
Cc: 'Chanho Park' <chanho61.park@samsung.com>, linux@arm.linux.org.uk, 'Catalin Marinas' <Catalin.Marinas@arm.com>, 'Inki Dae' <inki.dae@samsung.com>, linux-mm@kvack.org, 'Kyungmin Park' <kyungmin.park@samsung.com>, 'Myungjoo Ham' <myungjoo.ham@samsung.com>, linux-arm-kernel@lists.infradead.org, 'Grazvydas Ignotas' <notasas@gmail.com>

> From: Steve Capper [mailto:steve.capper@arm.com]
> Sent: Wednesday, April 10, 2013 5:21 PM
> To: Chanho Park
> Cc: Steve Capper; 'Chanho Park'; linux@arm.linux.org.uk; Catalin Marinas;
> 'Inki Dae'; linux-mm@kvack.org; 'Kyungmin Park'; 'Myungjoo Ham'; linux-
> arm-kernel@lists.infradead.org; 'Grazvydas Ignotas'
> Subject: Re: [PATCH] arm: mm: lockless get_user_pages_fast
> 
> On Wed, Apr 10, 2013 at 08:30:54AM +0100, Chanho Park wrote:
> > > Apologies for the tardy response, this patch slipped past me.
> >
> > Never mind.
> >
> > > I've tested this patch out, unfortunately it treats huge pmds as
> > > regular pmds and attempts to traverse them rather than fall back to a
> slow path.
> > > The fix for this is very minor, please see my suggestion below.
> > OK. I'll fix it.
> >
> > >
> > > As an aside, I would like to extend this fast_gup to include full
> > > huge page support and include a __get_user_pages_fast
> > > implementation. This will hopefully fix a problem that was brought
> > > to my attention by Grazvydas Ignotas whereby a FUTEX_WAIT on a THP
> > > tail page will cause an infinite loop due to the stock
> > > implementation of __get_user_pages_fast always returning 0.
> >
> > I'll add the __get_user_pages_fast implementation. BTW, HugeTLB on ARM
> > wasn't supported yet. There is no problem to add gup_huge_pmd. But I
> > think it need a test for hugepages.
> >
> 
> Thanks, that would be helpful. My plan was to then put the huge page
> specific bits in, with another patch. That way I can test it all out here.

Can I see the patch? I think it will be helpful to implement the
gup_huge_pmd.
Or how about you think except gup_huge_pmd in this patch?
IMO it will be added easily after hugetlb on arm is merged.

> 
> > > I would suggest:
> > > 		if (pmd_none(*pmdp) || pmd_bad(*pmdp))
> > > 			return 0;
> > > as this will pick up pmds that can't be traversed, and fall back to
> > > the slow path.
> >
> > Thanks for your suggestion.
> > I'll prepare the v2 patch.
> >
> 
> Also, just one more thing. In your gup_pte_range function there is an
> smp_rmb() just after the pte is dereferenced. I don't understand why
> though?

I think it would be needed for 64 bit machine. A pte of 64bit machine
consists of low and high value. In this version, there is no need to add it.
I'll remove it. Thanks.

Best regards,
Chanho Park

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
