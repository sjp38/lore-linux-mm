Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 7271D6B004A
	for <linux-mm@kvack.org>; Wed, 15 Feb 2012 21:05:35 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id D9EF73EE0C2
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:05:33 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C32E745DE59
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:05:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id AC89645DE56
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:05:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A13E21DB804E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:05:33 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5CB271DB803F
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 11:05:33 +0900 (JST)
Date: Thu, 16 Feb 2012 11:04:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock
 splitting
Message-Id: <20120216110408.f35c3448.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20120215224221.22050.80605.stgit@zurg>
References: <20120215224221.22050.80605.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, 16 Feb 2012 02:57:04 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> There should be no logic changes in this patchset, this is only tossing bits around.
> [ This patchset is on top some memcg cleanup/rework patches,
>   which I sent to linux-mm@ today/yesterday ]
> 
> Most of things in this patchset are self-descriptive, so here brief plan:
> 

AFAIK, Hugh Dickins said he has per-zone-per-lru-lock and is testing it.
So, please CC him and Johannes, at least.


> * Transmute struct lruvec into struct book. Like real book this struct will
>   store set of pages for one zone. It will be working unit for reclaimer code.
> [ If memcg is disabled in config there will only one book embedded into struct zone ]
> 

Why you need to add new structure rahter than enhancing lruvec ?
"book" means a binder of pages ?


> * move page-lru counters to struct book
> [ this adds extra overhead in add_page_to_lru_list()/del_page_from_lru_list() for
>   non-memcg case, but I believe it will be invisible, only one non-atomic add/sub
>   in the same cacheline with lru list ]
> 

This seems straightforward.

> * unify inactive_list_is_low_global() and cleanup reclaimer code
> * replace struct mem_cgroup_zone with single pointer to struct book

Hm, ok.

> * optimize page to book translations, move it upper in the call stack,
>   replace some struct zone arguments with struct book pointer.
> 

a page->book transrater from patch 2/15

+struct book *page_book(struct page *page)
+{
+	struct mem_cgroup_per_zone *mz;
+	struct page_cgroup *pc;
+
+	if (mem_cgroup_disabled())
+		return &page_zone(page)->book;
+
+	pc = lookup_page_cgroup(page);
+	if (!PageCgroupUsed(pc))
+		return &page_zone(page)->book;
+	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
+	smp_rmb();
+	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
+			page_to_nid(page), page_zonenum(page));
+	return &mz->book;
+}

What happens when pc->mem_cgroup is rewritten by move_account() ?
Where is the guard for lockless access of this ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
