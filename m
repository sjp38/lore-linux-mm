Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 98AAC6B004D
	for <linux-mm@kvack.org>; Wed, 28 Oct 2009 20:33:11 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9T0X9Un017297
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 29 Oct 2009 09:33:09 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DADF45DE4E
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:33:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2A4C345DE51
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:33:09 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 13BC01DB803A
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:33:09 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 845EB1DB8038
	for <linux-mm@kvack.org>; Thu, 29 Oct 2009 09:33:08 +0900 (JST)
Date: Thu, 29 Oct 2009 09:30:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX][PATCH] memcg: fix wrong pointer initialization at page
 migration when memcg is disabled.
Message-Id: <20091029093013.cd58f3a5.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, Lee.Schermerhorn@hp.com
List-ID: <linux-mm.kvack.org>


Lee Schermerhorn reported that he saw bad pointer dereference
in mem_cgroup_end_migration() when he disabled memcg by boot option.

memcg's page migration logic works as

	mem_cgroup_prepare_migration(page, &ptr);
	do page migration
	mem_cgroup_end_migration(page, ptr);

Now, ptr is not initialized in prepare_migration when memcg is disabled
by boot option. This causes panic in end_migration. This patch fixes it.

Reported-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Balbir Singh <balbir@in.ibm.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/memcontrol.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

Index: linux-2.6.32-rc5/mm/memcontrol.c
===================================================================
--- linux-2.6.32-rc5.orig/mm/memcontrol.c
+++ linux-2.6.32-rc5/mm/memcontrol.c
@@ -1990,7 +1990,8 @@ int mem_cgroup_prepare_migration(struct 
 	struct page_cgroup *pc;
 	struct mem_cgroup *mem = NULL;
 	int ret = 0;
-
+	/* this pointer will be checked at end_migration */
+	*ptr = NULL;
 	if (mem_cgroup_disabled())
 		return 0;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
