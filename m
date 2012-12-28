Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 4CE636B002B
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 11:22:13 -0500 (EST)
Date: Fri, 28 Dec 2012 17:22:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH for 3.2.34] memcg: do not trigger OOM from
 add_to_page_cache_locked
Message-ID: <20121228162209.GA1455@dhcp22.suse.cz>
References: <20121210094318.GA6777@dhcp22.suse.cz>
 <20121210111817.F697F53E@pobox.sk>
 <20121210155205.GB6777@dhcp22.suse.cz>
 <20121217023430.5A390FD7@pobox.sk>
 <20121217163203.GD25432@dhcp22.suse.cz>
 <20121217192301.829A7020@pobox.sk>
 <20121217195510.GA16375@dhcp22.suse.cz>
 <20121218152223.6912832C@pobox.sk>
 <20121218152004.GA25208@dhcp22.suse.cz>
 <20121224142526.020165D3@pobox.sk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121224142526.020165D3@pobox.sk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: azurIt <azurit@pobox.sk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups mailinglist <cgroups@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>

On Mon 24-12-12 14:25:26, azurIt wrote:
> >OK, good to hear and fingers crossed. I will try to get back to the
> >original problem and a better solution sometimes early next year when
> >all the things settle a bit.
> 
> 
> Michal, problem, unfortunately, happened again :( twice. When it
> happened first time (two days ago) i don't want to believe it so i
> recompiled the kernel and boot it again to be sure i really used your
> patch. Today it happened again, here is report:
> http://watchdog.sk/lkml/memcg-bug-3.tar.gz

Hmm, 1356352982/1507/stack says
[<ffffffff8110a971>] mem_cgroup_handle_oom+0x241/0x3b0
[<ffffffff8110b55b>] T.1147+0x5ab/0x5c0
[<ffffffff8110c1de>] mem_cgroup_cache_charge+0xbe/0xe0
[<ffffffff810ca20f>] add_to_page_cache_locked+0x4f/0x140
[<ffffffff810ca322>] add_to_page_cache_lru+0x22/0x50
[<ffffffff810cac53>] find_or_create_page+0x73/0xb0
[<ffffffff8114340a>] __getblk+0xea/0x2c0
[<ffffffff811921ab>] ext3_getblk+0xeb/0x240
[<ffffffff81192319>] ext3_bread+0x19/0x90
[<ffffffff811967e3>] ext3_dx_find_entry+0x83/0x1e0
[<ffffffff81196c24>] ext3_find_entry+0x2e4/0x480
[<ffffffff8119750d>] ext3_lookup+0x4d/0x120
[<ffffffff8111cff5>] d_alloc_and_lookup+0x45/0x90
[<ffffffff8111d598>] do_lookup+0x278/0x390
[<ffffffff8111f11e>] path_lookupat+0xae/0x7e0
[<ffffffff8111f885>] do_path_lookup+0x35/0xe0
[<ffffffff8111fa19>] user_path_at_empty+0x59/0xb0
[<ffffffff8111fa81>] user_path_at+0x11/0x20
[<ffffffff811164d7>] vfs_fstatat+0x47/0x80
[<ffffffff8111657e>] vfs_lstat+0x1e/0x20
[<ffffffff811165a4>] sys_newlstat+0x24/0x50
[<ffffffff815b5a66>] system_call_fastpath+0x18/0x1d
[<ffffffffffffffff>] 0xffffffffffffffff

which suggests that the patch is incomplete and that I am blind :/
mem_cgroup_cache_charge calls __mem_cgroup_try_charge for the page cache
and that one doesn't check GFP_MEMCG_NO_OOM. So you need the following
follow-up patch on top of the one you already have (which should catch
all the remaining cases).
Sorry about that...
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 89997ac..559a54d 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2779,6 +2779,7 @@ __mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *memcg,
 int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 				gfp_t gfp_mask)
 {
+	bool oom = !(gfp_mask & GFP_MEMCG_NO_OOM);
 	struct mem_cgroup *memcg = NULL;
 	int ret;
 
@@ -2791,7 +2792,7 @@ int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 		mm = &init_mm;
 
 	if (page_is_file_cache(page)) {
-		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, true);
+		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &memcg, oom);
 		if (ret || !memcg)
 			return ret;
 
@@ -2827,6 +2828,7 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 				 struct page *page,
 				 gfp_t mask, struct mem_cgroup **ptr)
 {
+	bool oom = !(mask & GFP_MEMCG_NO_OOM);
 	struct mem_cgroup *memcg;
 	int ret;
 
@@ -2849,13 +2851,13 @@ int mem_cgroup_try_charge_swapin(struct mm_struct *mm,
 	if (!memcg)
 		goto charge_cur_mm;
 	*ptr = memcg;
-	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr, true);
+	ret = __mem_cgroup_try_charge(NULL, mask, 1, ptr, oom);
 	css_put(&memcg->css);
 	return ret;
 charge_cur_mm:
 	if (unlikely(!mm))
 		mm = &init_mm;
-	return __mem_cgroup_try_charge(mm, mask, 1, ptr, true);
+	return __mem_cgroup_try_charge(mm, mask, 1, ptr, oom);
 }
 
 static void
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
