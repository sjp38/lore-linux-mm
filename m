Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E66486B007D
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 00:48:18 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8F4mFkQ021309
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 15 Sep 2010 13:48:16 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C35643268A6
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:48:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F44345DE4F
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:48:15 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 73EB61DB8038
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:48:15 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id EBDE1E18001
	for <linux-mm@kvack.org>; Wed, 15 Sep 2010 13:48:11 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH v2] After swapout/swapin private dirty mappings are reported clean in smaps
In-Reply-To: <201009151008.05129.knikanth@suse.de>
References: <20100915092504.C9DC.A69D9226@jp.fujitsu.com> <201009151008.05129.knikanth@suse.de>
Message-Id: <20100915134724.C9EE.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 15 Sep 2010 13:48:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Nikanth Karthikesan <knikanth@suse.de>
Cc: kosaki.motohiro@jp.fujitsu.com, Richard Guenther <rguenther@suse.de>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, balbir@linux.vnet.ibm.com, Michael Matz <matz@novell.com>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> On Wednesday 15 September 2010 05:56:36 KOSAKI Motohiro wrote:
> > > diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> > > index 439fc1f..06fc468 100644
> > > --- a/fs/proc/task_mmu.c
> > > +++ b/fs/proc/task_mmu.c
> > > @@ -368,7 +368,11 @@ static int smaps_pte_range(pmd_t *pmd, unsigned long
> > > addr, unsigned long end, mss->shared_clean += PAGE_SIZE;
> > >  			mss->pss += (PAGE_SIZE << PSS_SHIFT) / mapcount;
> > >  		} else {
> > > -			if (pte_dirty(ptent))
> > > +			/*
> > > +			 * File-backed pages, now anonymous are dirty
> > > +			 * with respect to the file.
> > > +			 */
> > > +			if (pte_dirty(ptent) || (vma->vm_file && PageAnon(page)))
> > >  				mss->private_dirty += PAGE_SIZE;
> > >  			else
> > >  				mss->private_clean += PAGE_SIZE;
> > 
> > This is risky than v1. number of dirties are used a lot of application.
> > 
> 
> This is exactly to help those applications, as currently after swap-out and 
> swap-in, the same pages are accounted as "Private_Clean:" instead of 
> "Private_Dirty:".

I don't think so. incorrect infomation bring a lot of confusion rather than its worth.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
