Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 85ED6600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 04:15:52 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAU9Fn4f029597
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 30 Nov 2009 18:15:50 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AA91845DE55
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:15:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8279145DE4E
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:15:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 486E4E78001
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:15:49 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E6E621DB8041
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 18:15:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
In-Reply-To: <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
References: <Pine.LNX.4.64.0911241640590.25288@sister.anvils> <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
Message-Id: <20091130180452.5BF6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon, 30 Nov 2009 18:15:44 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue, 24 Nov 2009 16:42:15 +0000 (GMT)
> Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> > +int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
> > +			unsigned long *vm_flags)
> > +{
> > +	struct stable_node *stable_node;
> > +	struct rmap_item *rmap_item;
> > +	struct hlist_node *hlist;
> > +	unsigned int mapcount = page_mapcount(page);
> > +	int referenced = 0;
> > +	struct vm_area_struct *vma;
> > +
> > +	VM_BUG_ON(!PageKsm(page));
> > +	VM_BUG_ON(!PageLocked(page));
> > +
> > +	stable_node = page_stable_node(page);
> > +	if (!stable_node)
> > +		return 0;
> > +
> 
> Hmm. I'm not sure how many pages are shared in a system but
> can't we add some threshold for avoidng too much scan against shared pages ?
> (in vmscan.c)
> like..
>       
>        if (page_mapcount(page) > (XXXX >> scan_priority))
> 		return 1;
> 
> I saw terrible slow downs in shmem-swap-out in old RHELs (at user support).
> (Added kosaki to CC.)
> 
> After this patch, the number of shared swappable page will be unlimited.

Probably, it doesn't matter. I mean

  - KSM sharing and Shmem sharing are almost same performance characteristics.
  - if memroy pressure is low, SplitLRU VM doesn't scan anon list so much.

if ksm swap is too costly, we need to improve anon list scanning generically.


btw, I'm not sure why bellow kmem_cache_zalloc() is necessary. Why can't we
use stack?

----------------------------
+	/*
+	 * Temporary hack: really we need anon_vma in rmap_item, to
+	 * provide the correct vma, and to find recently forked instances.
+	 * Use zalloc to avoid weirdness if any other fields are involved.
+	 */
+	vma = kmem_cache_zalloc(vm_area_cachep, GFP_ATOMIC);
+	if (!vma) {
+		spin_lock(&ksm_fallback_vma_lock);
+		vma = &ksm_fallback_vma;
+	}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
