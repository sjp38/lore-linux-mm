Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D26EA6B004A
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 06:14:49 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8EAEkf7022457
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 14 Sep 2010 19:14:46 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 07ACF45DE58
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:14:46 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id CD3A145DE53
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:14:45 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AD52E1DB803C
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:14:45 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5110D1DB8040
	for <linux-mm@kvack.org>; Tue, 14 Sep 2010 19:14:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 05/10] vmscan: Synchrounous lumpy reclaim use lock_page() instead trylock_page()
In-Reply-To: <20100913091405.GB23508@csn.ul.ie>
References: <20100909182649.C94F.A69D9226@jp.fujitsu.com> <20100913091405.GB23508@csn.ul.ie>
Message-Id: <20100914191250.C9C7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 14 Sep 2010 19:14:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Linux Kernel List <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> > example, 
> > 
> > __do_fault()
> > {
> > (snip)
> >         if (unlikely(!(ret & VM_FAULT_LOCKED)))
> >                 lock_page(vmf.page);
> >         else
> >                 VM_BUG_ON(!PageLocked(vmf.page));
> > 
> >         /*
> >          * Should we do an early C-O-W break?
> >          */
> >         page = vmf.page;
> >         if (flags & FAULT_FLAG_WRITE) {
> >                 if (!(vma->vm_flags & VM_SHARED)) {
> >                         anon = 1;
> >                         if (unlikely(anon_vma_prepare(vma))) {
> >                                 ret = VM_FAULT_OOM;
> >                                 goto out;
> >                         }
> >                         page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
> >                                                 vma, address);
> > 
> 
> Correct, this is a problem. I already had dropped the patch but thanks for
> pointing out a deadlock because I was missing this case. Nothing stops the
> page being faulted being sent to shrink_page_list() when alloc_page_vma()
> is called. The deadlock might be hard to hit, but it's there.

Yup, unfortunatelly.



> > Afaik, detailed rule is,
> > 
> > o kswapd can call lock_page() because they never take page lock outside vmscan
> 
> lock_page_nosync as you point out in your next mail. While it can call
> it, kswapd shouldn't because normally it avoids stalls but it would not
> deadlock as a result of calling it.

Agreed.


> > o if try_lock() is successed, we can call lock_page_nosync() against its page after unlock.
> >   because the task have gurantee of no lock taken.
> > o otherwise, direct reclaimer can't call lock_page(). the task may have a lock already.
> > 
> 
> I think the safer bet is simply to say "direct reclaimers should not
> call lock_page() because the fault path could be holding a lock on that
> page already".

Yup, agreed.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
