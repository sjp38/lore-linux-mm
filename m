Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 630356B005C
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 23:05:15 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C6CE63EE0C8
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 13:05:11 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A858645DE5E
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 13:05:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FFD945DE58
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 13:05:11 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C88FE08004
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 13:05:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C6921DB8044
	for <linux-mm@kvack.org>; Thu, 19 Jan 2012 13:05:11 +0900 (JST)
Date: Thu, 19 Jan 2012 13:03:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUG] kernel BUG at mm/memcontrol.c:1074!
Message-Id: <20120119130353.0ca97435.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.LSU.2.00.1201181932040.2287@eggly.anvils>
References: <1326949826.5016.5.camel@lappy>
	<20120119122354.66eb9820.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LSU.2.00.1201181932040.2287@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, hannes <hannes@cmpxchg.org>, mhocko@suse.cz, bsingharora@gmail.com, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Wed, 18 Jan 2012 19:41:44 -0800 (PST)
Hugh Dickins <hughd@google.com> wrote:

> On Thu, 19 Jan 2012, KAMEZAWA Hiroyuki wrote:
> > On Thu, 19 Jan 2012 07:10:26 +0200
> > Sasha Levin <levinsasha928@gmail.com> wrote:
> > 
> > > Hi all,
> > > 
> > > During testing, I have triggered the OOM killer by mmap()ing a large block of memory. The OOM kicked in and tried to kill the process:
> > > 
> > 
> > two questions.
> > 
> > 1. What is the kernel version  ?
> 
> It says 3.2.0-next-20120119-sasha #128
> 
> > 2. are you using memcg moutned ?
> 
> I notice that, unlike Linus's git, this linux-next still has
> mm-isolate-pages-for-immediate-reclaim-on-their-own-lru.patch in.
> 
> I think that was well capable of oopsing in mem_cgroup_lru_del_list(),
> since it didn't always know which lru a page belongs to.
> 
> I'm going to be optimistic and assume that was the cause.
> 
Hmm, because the log hits !memcg at lru "del", the page should be added
to LRU somewhere and the lru must be determined by pc->mem_cgroup.

Once set, pc->mem_cgroup is not cleared, just overwritten. AFAIK, there is
only one chance to set pc->mem_cgroup as NULL... initalization.
I wonder why it hits lru_del() rather than lru_add()...
................

Ahhhh, ok, it seems you are right. the patch has following kinds of codes
==
+static void pagevec_putback_immediate_fn(struct page *page, void *arg)
+{
+       struct zone *zone = page_zone(page);
+
+       if (PageLRU(page)) {
+               enum lru_list lru = page_lru(page);
+               list_move(&page->lru, &zone->lru[lru].list);
+       }
+}
==
..this will bypass mem_cgroup_lru_add(), and we can see bug in lru_del()
rather than lru_add()..

Another question is who pushes pages to LRU before setting pc->mem_cgroup..
Anyway, I think we need to fix memcg to be LRU_IMMEDIATE aware.

Thanks,
-Kmae




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
