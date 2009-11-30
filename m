Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E7B63600309
	for <linux-mm@kvack.org>; Sun, 29 Nov 2009 19:49:17 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAU0nCo4004722
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 30 Nov 2009 09:49:13 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D3E545DE4E
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:49:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4383A45DE55
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:49:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id E00E1E78003
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:49:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8CE53EF8003
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 09:49:11 +0900 (JST)
Date: Mon, 30 Nov 2009 09:46:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-Id: <20091130094616.8f3d94a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0911241640590.25288@sister.anvils>
References: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
	<Pine.LNX.4.64.0911241640590.25288@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Nov 2009 16:42:15 +0000 (GMT)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:
> +int page_referenced_ksm(struct page *page, struct mem_cgroup *memcg,
> +			unsigned long *vm_flags)
> +{
> +	struct stable_node *stable_node;
> +	struct rmap_item *rmap_item;
> +	struct hlist_node *hlist;
> +	unsigned int mapcount = page_mapcount(page);
> +	int referenced = 0;
> +	struct vm_area_struct *vma;
> +
> +	VM_BUG_ON(!PageKsm(page));
> +	VM_BUG_ON(!PageLocked(page));
> +
> +	stable_node = page_stable_node(page);
> +	if (!stable_node)
> +		return 0;
> +

Hmm. I'm not sure how many pages are shared in a system but
can't we add some threshold for avoidng too much scan against shared pages ?
(in vmscan.c)
like..
      
       if (page_mapcount(page) > (XXXX >> scan_priority))
		return 1;

I saw terrible slow downs in shmem-swap-out in old RHELs (at user support).
(Added kosaki to CC.)

After this patch, the number of shared swappable page will be unlimited.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
