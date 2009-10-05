Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6B31F6B005D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 03:20:34 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n957KVIq004390
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 5 Oct 2009 16:20:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7177F45DE51
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 16:20:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DD3F45DE4D
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 16:20:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EEAA41DB8037
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 16:20:30 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F8781DB803B
	for <linux-mm@kvack.org>; Mon,  5 Oct 2009 16:20:30 +0900 (JST)
Date: Mon, 5 Oct 2009 16:18:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/2] memcg: improving scalability by reducing lock
 contention at charge/uncharge
Message-Id: <20091005161808.fa5ab0c6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091002175310.0991139c.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091002135531.3b5abf5c.kamezawa.hiroyu@jp.fujitsu.com>
	<20091002175310.0991139c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009 17:53:10 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> > [After]
> >  Performance counter stats for './runpause.sh' (5 runs):
> > 
> >   474658.997489  task-clock-msecs         #      7.891 CPUs    ( +-   0.006% )
> >           10250  context-switches         #      0.000 M/sec   ( +-   0.020% )
> >              11  CPU-migrations           #      0.000 M/sec   ( +-   0.000% )
> >        33177858  page-faults              #      0.070 M/sec   ( +-   0.152% )
> >   1485264748476  cycles                   #   3129.120 M/sec   ( +-   0.021% )
> >    409847004519  instructions             #      0.276 IPC     ( +-   0.123% )
> >      3237478723  cache-references         #      6.821 M/sec   ( +-   0.574% )
> >      1182572827  cache-misses             #      2.491 M/sec   ( +-   0.179% )
> > 
> >    60.151786309  seconds time elapsed   ( +-   0.014% )
> > 
> BTW, this is a score in root cgroup.
> 
> 
>   473811.590852  task-clock-msecs         #      7.878 CPUs    ( +-   0.006% )
>           10257  context-switches         #      0.000 M/sec   ( +-   0.049% )
>              10  CPU-migrations           #      0.000 M/sec   ( +-   0.000% )
>        36418112  page-faults              #      0.077 M/sec   ( +-   0.195% )
>   1482880352588  cycles                   #   3129.684 M/sec   ( +-   0.011% )
>    410948762898  instructions             #      0.277 IPC     ( +-   0.123% )
>      3182986911  cache-references         #      6.718 M/sec   ( +-   0.555% )
>      1147144023  cache-misses             #      2.421 M/sec   ( +-   0.137% )
> 
> 
> Then,
>   36418112 x 100 / 33177858 = 109% slower in children cgroup.
> 

This is an additional patch now under testing.(just experimental)
result of above test:
==
[root cgroup]
      37062405  page-faults              #      0.078 M/sec   ( +-   0.156% )
[children]  
      35876894  page-faults              #      0.076 M/sec   ( +-   0.233% )
==
Near to my target....

This patch adds bulk_css_put() and coalesces css_put() in batched-uncharge path.
avoidng frequent calls css_put().

coalescing-uncharge patch, it reduces reference to res_counter
but css_put() per page is still called.
Of course, we can coalesce prural css_put() to a call of bulk_css_put().

This patch adds bulk_css_put() and reduces false-sharing and will have
good effects in scalability.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/cgroup.h |   10 ++++++++--
 kernel/cgroup.c        |    5 ++---
 mm/memcontrol.c        |   16 +++++++++++-----
 3 files changed, 21 insertions(+), 10 deletions(-)

Index: mmotm-2.6.31-Sep28/include/linux/cgroup.h
===================================================================
--- mmotm-2.6.31-Sep28.orig/include/linux/cgroup.h
+++ mmotm-2.6.31-Sep28/include/linux/cgroup.h
@@ -117,11 +117,17 @@ static inline bool css_tryget(struct cgr
  * css_get() or css_tryget()
  */
 
-extern void __css_put(struct cgroup_subsys_state *css);
+extern void __css_put(struct cgroup_subsys_state *css, int val);
 static inline void css_put(struct cgroup_subsys_state *css)
 {
 	if (!test_bit(CSS_ROOT, &css->flags))
-		__css_put(css);
+		__css_put(css, 1);
+}
+
+static inline void bulk_css_put(struct cgroup_subsys_state *css, int val)
+{
+	if (!test_bit(CSS_ROOT, &css->flags))
+		__css_put(css, val);
 }
 
 /* bits in struct cgroup flags field */
Index: mmotm-2.6.31-Sep28/kernel/cgroup.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/kernel/cgroup.c
+++ mmotm-2.6.31-Sep28/kernel/cgroup.c
@@ -3705,12 +3705,11 @@ static void check_for_release(struct cgr
 	}
 }
 
-void __css_put(struct cgroup_subsys_state *css)
+void __css_put(struct cgroup_subsys_state *css, int val)
 {
 	struct cgroup *cgrp = css->cgroup;
-	int val;
 	rcu_read_lock();
-	val = atomic_dec_return(&css->refcnt);
+	val = atomic_sub_return(val, &css->refcnt);
 	if (val == 1) {
 		if (notify_on_release(cgrp)) {
 			set_bit(CGRP_RELEASABLE, &cgrp->flags);
Index: mmotm-2.6.31-Sep28/mm/memcontrol.c
===================================================================
--- mmotm-2.6.31-Sep28.orig/mm/memcontrol.c
+++ mmotm-2.6.31-Sep28/mm/memcontrol.c
@@ -1977,8 +1977,14 @@ __do_uncharge(struct mem_cgroup *mem, co
 	return;
 direct_uncharge:
 	res_counter_uncharge(&mem->res, PAGE_SIZE);
-	if (uncharge_memsw)
+	if (uncharge_memsw) {
 		res_counter_uncharge(&mem->memsw, PAGE_SIZE);
+		/*
+		 * swapout-uncharge do css_put() by itself. then we do
+		 * css_put() only in this case.
+		 */
+		css_put(&mem->css);
+	}
 	return;
 }
 
@@ -2048,9 +2054,6 @@ __mem_cgroup_uncharge_common(struct page
 
 	if (mem_cgroup_soft_limit_check(mem))
 		mem_cgroup_update_tree(mem, page);
-	/* at swapout, this memcg will be accessed to record to swap */
-	if (ctype != MEM_CGROUP_CHARGE_TYPE_SWAPOUT)
-		css_put(&mem->css);
 
 	return mem;
 
@@ -2108,8 +2111,11 @@ void mem_cgroup_uncharge_end(void)
 	if (!mem)
 		return;
 	/* This "mem" is valid bacause we hide charges behind us. */
-	if (current->memcg_batch.pages)
+	if (current->memcg_batch.pages) {
 		res_counter_uncharge(&mem->res, current->memcg_batch.pages);
+		bulk_css_put(&mem->css,
+			current->memcg_batch.pages >> PAGE_SHIFT);
+	}
 	if (current->memcg_batch.memsw)
 		res_counter_uncharge(&mem->memsw, current->memcg_batch.memsw);
 	/* Not necessary. but forget this pointer */





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
