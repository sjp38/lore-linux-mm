Date: Fri, 19 Sep 2008 21:59:00 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH -rc6][BUGFIX] memcg: check under limit at shrink_usage
Message-Id: <20080919215900.c28d1aef.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Balbir Singh <balbir@in.ibm.com>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

Current memory cgroup(both in mainline and -mm) doesn't account swap caches
as memory(swap cache support is dropped temporarily now).

So try_to_free_mem_cgroup_pages doesn't reflect the count of pages
that have been moved to swap cache.

But this makes mem_cgroup_shrink_usage fail easily if most of the pages
are anon/shmem, and then shmem_getpage returns -ENOMEM and the process
will be killed.

This patch adds res_counter_check_under_limit to avoid these cases.

BTW, even if swap cache support is enabled again, if a process is
moved to another cgroup, which has been just made, between precharge
and shrink_usage in shmem_getpage, shrink_usage may fail just because
there is no pages to reclaim.

So this change would make sense anyway.


Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0f1f7a7..c0500e4 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -806,6 +806,7 @@ int mem_cgroup_shrink_usage(struct mm_struct *mm, gfp_t gfp_mask)

        do {
                progress = try_to_free_mem_cgroup_pages(mem, gfp_mask);
+               progress += res_counter_check_under_limit(&mem->res);
        } while (!progress && --retry);

        css_put(&mem->css);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
