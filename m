Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 1F7D36B002B
	for <linux-mm@kvack.org>; Mon, 17 Dec 2012 11:32:06 -0500 (EST)
Date: Mon, 17 Dec 2012 17:32:03 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121217163203.GD25432@dhcp22.suse.cz>
References: <20121203151601.GA17093@dhcp22.suse.cz>
 <20121205023644.18C3006B@pobox.sk>
 <20121205141722.GA9714@dhcp22.suse.cz>
 <20121206012924.FE077FD7@pobox.sk>
 <20121206095423.GB10931@dhcp22.suse.cz>
 <20121210022038.E6570D37@pobox.sk>
 <20121210094318.GA6777@dhcp22.suse.cz>
 <20121210111817.F697F53E@pobox.sk>
 <20121210155205.GB6777@dhcp22.suse.cz>
 <20121217023430.5A390FD7@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121217023430.5A390FD7@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 17-12-12 02:34:30, azurIt wrote:
> >I would try to limit changes to minimum. So the original kernel you were
> >using + the first patch to prevent OOM from the write path + 2 debugging
> >patches.
> 
> 
> It didn't take off the whole system this time (but i was
> prepared to record a video of console ;) ), here it is:
> http://www.watchdog.sk/lkml/oom_mysqld4

[...]
[ 1248.059429] ------------[ cut here ]------------
[ 1248.059586] WARNING: at mm/memcontrol.c:2400 T.1146+0x2d9/0x610()
[ 1248.059723] Hardware name: S5000VSA
[ 1248.059855] gfp_mask:208 nr_pages:1 oom:0 ret:2

This is GFP_KERNEL allocation which is expected. It is also a simple
page which is not that expected because we shouldn't return ENOMEM on
those unless this was GFP_ATOMIC allocation (which it wasn't) or the
caller told us to not trigger OOM which is the case only for THP pages
(see mem_cgroup_charge_common). So the big question is how have we ended
up with oom=false here...

[Ohh, I am really an idiot. I screwed the first patch]
-       bool oom = true;
+       bool oom = !(gfp_mask | GFP_MEMCG_NO_OOM);

Which obviously doesn't work. It should read !(gfp_mask &GFP_MEMCG_NO_OOM).
  No idea how I could have missed that. I am really sorry about that.
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index c04676d..1f35a74 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2704,7 +2704,7 @@ static int mem_cgroup_charge_common(struct page *page, struct mm_struct *mm,
 	struct mem_cgroup *memcg = NULL;
 	unsigned int nr_pages = 1;
 	struct page_cgroup *pc;
-	bool oom = !(gfp_mask | GFP_MEMCG_NO_OOM);
+	bool oom = !(gfp_mask & GFP_MEMCG_NO_OOM);
 	int ret;
 
 	if (PageTransHuge(page)) {
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
