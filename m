Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D454C6B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 02:51:15 -0500 (EST)
Received: from kpbe13.cbf.corp.google.com (kpbe13.cbf.corp.google.com [172.25.105.77])
	by smtp-out.google.com with ESMTP id oAA7njBv029331
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 23:49:45 -0800
Received: from gxk21 (gxk21.prod.google.com [10.202.11.21])
	by kpbe13.cbf.corp.google.com with ESMTP id oAA7nfAW029561
	for <linux-mm@kvack.org>; Tue, 9 Nov 2010 23:49:43 -0800
Received: by gxk21 with SMTP id 21so179157gxk.29
        for <linux-mm@kvack.org>; Tue, 09 Nov 2010 23:49:41 -0800 (PST)
Date: Tue, 9 Nov 2010 23:49:30 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 43 of 66] don't leave orhpaned swap cache after ksm
 merging
In-Reply-To: <20101109214036.GE6809@random.random>
Message-ID: <alpine.LSU.2.00.1011092312360.6873@sister.anvils>
References: <patchbomb.1288798055@v2.random> <d5aefe85d1dab1bb7e99.1288798098@v2.random> <20101109120747.BC4B.A69D9226@jp.fujitsu.com> <20101109214036.GE6809@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Tue, 9 Nov 2010, Andrea Arcangeli wrote:
> On Tue, Nov 09, 2010 at 12:08:25PM +0900, KOSAKI Motohiro wrote:
> > > From: Andrea Arcangeli <aarcange@redhat.com>
> > > 
> > > When swapcache is replaced by a ksm page don't leave orhpaned swap cache.
> > > 
> > > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > > Reviewed-by: Rik van Riel <riel@redhat.com>
> > 
> > This explanation seems to tell this is bugfix. If so, please separate
> > this one from THP and will send mainline and -stable soon.
> 
> Right. I'm uncertain if this is so bad to require -stable I think, if
> it was more urgent I would have submitted already separately but it's
> true it's not THP specific.

Yes, we discussed this a few months ago: it's a welcome catch, but not
very serious, since it's normal for some pages to evade swap freeing,
then eventually memory pressure sorts it all out in __remove_mapping().

We did ask you back then to send in a fix separate from THP, but both
sides then forgot about it until recently.

We didn't agree on what the fix should look like.  You're keen to change
the page locking there, I didn't make a persuasive case for keeping it
as is, yet I can see no point whatever in changing it for this swap fix.
Could I persuade you to approve this simpler alternative?


[PATCH] ksm: free swap when swapcache page is replaced

When a swapcache page is replaced by a ksm page, it's best to free that
swap immediately.

Reported-by: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/ksm.c |    2 ++
 1 file changed, 2 insertions(+)

--- 2.6.37-rc1/mm/ksm.c	2010-10-20 13:30:22.000000000 -0700
+++ linux/mm/ksm.c	2010-11-09 23:01:24.000000000 -0800
@@ -800,6 +800,8 @@ static int replace_page(struct vm_area_s
 	set_pte_at_notify(mm, addr, ptep, mk_pte(kpage, vma->vm_page_prot));
 
 	page_remove_rmap(page);
+	if (!page_mapped(page))
+		try_to_free_swap(page);
 	put_page(page);
 
 	pte_unmap_unlock(ptep, ptl);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
