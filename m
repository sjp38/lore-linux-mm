Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id A6F2C6B00A1
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 04:31:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8P8VneH028071
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Sep 2009 17:31:49 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C87145DE55
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:31:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D365F45DE51
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:31:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AF8241DB803E
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:31:48 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6209B1DB803A
	for <linux-mm@kvack.org>; Fri, 25 Sep 2009 17:31:48 +0900 (JST)
Date: Fri, 25 Sep 2009 17:29:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 9/10] memcg: clean up perzone stat
Message-Id: <20090925172940.38f140bf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090925171721.b1bbbbe2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

This patch renames
  mem_cgroup_get_local_zonestat() to be
  mem_cgroup_get_lru_stat().

That "local" means "don't consider hierarchy" but ...ambiguous.
We all know lru is per memcg private, this name is better.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

Index: temp-mmotm/mm/memcontrol.c
===================================================================
--- temp-mmotm.orig/mm/memcontrol.c
+++ temp-mmotm/mm/memcontrol.c
@@ -488,7 +488,7 @@ unsigned long mem_cgroup_zone_nr_pages(s
 }
 
 
-static unsigned long mem_cgroup_get_local_zonestat(struct mem_cgroup *mem,
+static unsigned long mem_cgroup_get_lru_stat(struct mem_cgroup *mem,
 					enum lru_list idx)
 {
 	int nid, zid;
@@ -885,8 +885,8 @@ static int calc_inactive_ratio(struct me
 	unsigned long gb;
 	unsigned long inactive_ratio;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_ANON);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_ANON);
+	inactive = mem_cgroup_get_lru_stat(memcg, LRU_INACTIVE_ANON);
+	active = mem_cgroup_get_lru_stat(memcg, LRU_ACTIVE_ANON);
 
 	gb = (inactive + active) >> (30 - PAGE_SHIFT);
 	if (gb)
@@ -925,8 +925,8 @@ int mem_cgroup_inactive_file_is_low(stru
 	unsigned long active;
 	unsigned long inactive;
 
-	inactive = mem_cgroup_get_local_zonestat(memcg, LRU_INACTIVE_FILE);
-	active = mem_cgroup_get_local_zonestat(memcg, LRU_ACTIVE_FILE);
+	inactive = mem_cgroup_get_lru_stat(memcg, LRU_INACTIVE_FILE);
+	active = mem_cgroup_get_lru_stat(memcg, LRU_ACTIVE_FILE);
 
 	return (active > inactive);
 }
@@ -2779,15 +2779,15 @@ static int mem_cgroup_get_local_stat(str
 	}
 
 	/* per zone stat */
-	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_ANON);
+	val = mem_cgroup_get_lru_stat(mem, LRU_INACTIVE_ANON);
 	s->stat[MCS_INACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_ANON);
+	val = mem_cgroup_get_lru_stat(mem, LRU_ACTIVE_ANON);
 	s->stat[MCS_ACTIVE_ANON] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_INACTIVE_FILE);
+	val = mem_cgroup_get_lru_stat(mem, LRU_INACTIVE_FILE);
 	s->stat[MCS_INACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_ACTIVE_FILE);
+	val = mem_cgroup_get_lru_stat(mem, LRU_ACTIVE_FILE);
 	s->stat[MCS_ACTIVE_FILE] += val * PAGE_SIZE;
-	val = mem_cgroup_get_local_zonestat(mem, LRU_UNEVICTABLE);
+	val = mem_cgroup_get_lru_stat(mem, LRU_UNEVICTABLE);
 	s->stat[MCS_UNEVICTABLE] += val * PAGE_SIZE;
 	return 0;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
