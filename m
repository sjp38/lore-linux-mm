Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3BA1260021B
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 01:27:51 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB86RmjV020967
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 8 Dec 2009 15:27:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E1A3D45DE4F
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 15:27:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B40C445DE51
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 15:27:47 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 864A81DB803C
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 15:27:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2F3C71DB8043
	for <linux-mm@kvack.org>; Tue,  8 Dec 2009 15:27:47 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [early RFC][PATCH 8/7] vmscan: Don't deactivate many touched page
In-Reply-To: <4B1D4513.1020206@redhat.com>
References: <20091207203427.E955.A69D9226@jp.fujitsu.com> <4B1D4513.1020206@redhat.com>
Message-Id: <20091208093134.B578.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Tue,  8 Dec 2009 15:27:46 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

> On 12/07/2009 06:36 AM, KOSAKI Motohiro wrote:
> >
> > Andrea, Can you please try following patch on your workload?
> >
> >
> >  From a7758c66d36a136d5fbbcf0b042839445f0ca522 Mon Sep 17 00:00:00 2001
> > From: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> > Date: Mon, 7 Dec 2009 18:37:20 +0900
> > Subject: [PATCH] [RFC] vmscan: Don't deactivate many touched page
> >
> > Changelog
> >   o from andrea's original patch
> >     - Rebase topon my patches.
> >     - Use list_cut_position/list_splice_tail pair instead
> >       list_del/list_add to make pte scan fairness.
> >     - Only use max young threshold when soft_try is true.
> >       It avoid wrong OOM sideeffect.
> >     - Return SWAP_AGAIN instead successful result if max
> >       young threshold exceed. It prevent the pages without clear
> >       pte young bit will be deactivated wrongly.
> >     - Add to treat ksm page logic
> 
> I like the concept and your changes, and really only
> have a few small nitpicks :)
> 
> First, the VM uses a mix of "referenced", "accessed" and
> "young".  We should probably avoid adding "active" to that
> mix, and may even want to think about moving to just one
> or two terms :)

Ah yes, certainly.


> > +#define MAX_YOUNG_BIT_CLEARED 64
> > +/*
> > + * if VM pressure is low and the page have too many active mappings, there isn't
> > + * any reason to continue clear young bit of other ptes. Otherwise,
> > + *  - Makes meaningless cpu wasting, many touched page sholdn't be reclaimed.
> > + *  - Makes lots IPI for pte change and it might cause another sadly lock
> > + *    contention.
> > + */
> 
> If VM pressure is low and the page has lots of active users, we only
> clear up to MAX_YOUNG_BIT_CLEARED accessed bits at a time.  Clearing
> accessed bits takes CPU time, needs TLB invalidate IPIs and could
> cause lock contention.  Since a heavily shared page is very likely
> to be used again soon, the cost outweighs the benefit of making such
> a heavily shared page a candidate for eviction.

Thanks. Will fix.


> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index cfda0a0..f4517f3 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -473,6 +473,21 @@ static int wipe_page_reference_anon(struct page *page,
> >   		ret = wipe_page_reference_one(page, refctx, vma, address);
> >   		if (ret != SWAP_SUCCESS)
> >   			break;
> > +		if (too_many_young_bit_found(refctx)) {
> > +			LIST_HEAD(tmp_list);
> > +
> > +			/*
> > +			 * The scanned ptes move to list tail. it help every ptes
> > +			 * on this page will be tested by ptep_clear_young().
> > +			 * Otherwise, this shortcut makes unfair thing.
> > +			 */
> > +			list_cut_position(&tmp_list,
> > +					&vma->anon_vma_node,
> > +					&anon_vma->head);
> > +			list_splice_tail(&tmp_list,&vma->anon_vma_node);
> > +			ret = SWAP_AGAIN;
> > +			break;
> > +		}
> 
> I do not understand the unfairness here, since all a page needs
> to stay on the active list is >64 referenced PTEs.  It does not
> matter which of the PTEs mapping the page were recently referenced.
> 
> However, rotating the anon vmas around may help spread out lock
> pressure in the VM and help things that way, so the code looks
> useful to me.

agreed. I have to rewrite the comment.


> In short, you can give the next version of this patch my
> 
> Reviewed-by: Rik van Riel <riel@redhat.com>
> 
> All I have are comment nitpicks :)

No. It's really worth.

Thank you.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
