Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CC8EA8D0039
	for <linux-mm@kvack.org>; Fri,  4 Feb 2011 04:27:03 -0500 (EST)
Date: Fri, 4 Feb 2011 10:26:50 +0100
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 1/5] memcg: no uncharged pages reach page_cgroup_zoneinfo
Message-ID: <20110204092650.GB2289@cmpxchg.org>
References: <1296743166-9412-1-git-send-email-hannes@cmpxchg.org>
 <1296743166-9412-2-git-send-email-hannes@cmpxchg.org>
 <20110204090145.7f1918fc.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110204090145.7f1918fc.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Feb 04, 2011 at 09:01:45AM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu,  3 Feb 2011 15:26:02 +0100
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > All callsites check PCG_USED before passing pc->mem_cgroup, so the
> > latter is never NULL.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Thank you!

> I want BUG_ON() here.

I thought about it too at first.  But look at the callsites, all but
one of them do not even expect this function to return NULL, so if
this condition had ever been true, we would have seen crashes in the
callsites.

The only caller that checks for NULL is
mem_cgroup_get_reclaim_stat_from_page() and I propose to remove that
as well; patch attached.

Do you insist on the BUG_ON?

---
Subject: memcg: page_cgroup_zoneinfo never returns NULL

For a page charged to a memcg, there is always valid memcg per-zone
info.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 4a4483d..5f974b3 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1017,9 +1017,6 @@ mem_cgroup_get_reclaim_stat_from_page(struct page *page)
 	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
 	smp_rmb();
 	mz = page_cgroup_zoneinfo(pc->mem_cgroup, page);
-	if (!mz)
-		return NULL;
-
 	return &mz->reclaim_stat;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
