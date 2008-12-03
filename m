Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB34rd6G022827
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 3 Dec 2008 13:53:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BD9AD45DD7C
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:53:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 95AE445DD78
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:53:38 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 833611DB8040
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:53:38 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 309D31DB803A
	for <linux-mm@kvack.org>; Wed,  3 Dec 2008 13:53:38 +0900 (JST)
Date: Wed, 3 Dec 2008 13:52:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH  4/21] memcg-swapout-refcnt-fix.patch
Message-Id: <20081203135249.d599a93a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081203134718.6b60986f.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, lizf@cn.fujitsu.com, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Fix for memcg-memswap-controller-core.patch

css's refcnt is dropped before end of following access.
Hold it until end of access.

Reported-by: Li Zefan <lizf@cn.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/memcontrol.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

Index: mmotm-2.6.28-Dec01-2/mm/memcontrol.c
===================================================================
--- mmotm-2.6.28-Dec01-2.orig/mm/memcontrol.c
+++ mmotm-2.6.28-Dec01-2/mm/memcontrol.c
@@ -1171,7 +1171,9 @@ __mem_cgroup_uncharge_common(struct page
 	mz = page_cgroup_zoneinfo(pc);
 	unlock_page_cgroup(pc);
 
-	css_put(&mem->css);
+	/* at swapout, this memcg will be accessed to record to swap */
+	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
+		css_put(&mem->css);
 
 	return mem;
 
@@ -1212,6 +1214,8 @@ void mem_cgroup_uncharge_swapcache(struc
 		swap_cgroup_record(ent, memcg);
 		mem_cgroup_get(memcg);
 	}
+	if (memcg)
+		css_put(&memcg->css);
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
