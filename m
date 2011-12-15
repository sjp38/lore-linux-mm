Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id E03636B0201
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 01:01:31 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 2E60D3EE0BC
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:01:30 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 107A045DF00
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:01:30 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC65145DE66
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:01:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDE931DB8047
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:01:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 939FD1DB804A
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 15:01:29 +0900 (JST)
Date: Thu, 15 Dec 2011 15:00:10 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [Experimental] [PATCH 0/5] page_cgroup->flags diet.
Message-Id: <20111215150010.2b124270.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>

For reducing size of page_cgroup, we need to reduce flags.

This patch is a trial to remove flags based on

linux-next + 
memcg-add-mem_cgroup_replace_page_cache-to-fix-lru-issue.patch +
4 patches for 'simplify LRU handling' I posted.

So, I don't ask anyone to test this but want to hear another idea
or comments on implemenation.

After this patch series, page_cgroup flags are 

enum {
        /* flags for mem_cgroup */
        PCG_LOCK,  /* Lock for pc->mem_cgroup and following bits. */
        PCG_USED, /* this object is in use. */
        PCG_MIGRATION, /* under page migration */
        __NR_PCG_FLAGS,
};

3bits. I thought I could remove PCG_MIGRATION ....but failed.

BTW, because of kmalloc()'s alignment, low 3bits of pc->mem_cgroup must be 0.
So, we can move these flags to low bits in pc->mem_cgroup...I guess.

(But in another thoughts, we need to track blkio per page finally. So, I'm
 not sure whether we can remove page_cgroup at the end.)

Anyway, I dump a current trial series. Please comment when you have time.
I'm not in hurry and will not be able to make a quick response.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
