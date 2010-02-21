Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 67F4D6B0078
	for <linux-mm@kvack.org>; Sat, 20 Feb 2010 22:09:30 -0500 (EST)
Date: Sun, 21 Feb 2010 11:09:12 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC PATCH -tip 0/2 v3] pagecache tracepoints proposal
Message-ID: <20100221030912.GA14056@localhost>
References: <4B6B7FBF.9090005@bx.jp.nec.com> <20100205072858.GC9320@elte.hu> <20100208155450.GA17055@localhost> <20100218143429.ddea9bb2.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100218143429.ddea9bb2.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Ingo Molnar <mingo@elte.hu>, Chris Frost <frost@cs.ucla.edu>, Steven Rostedt <rostedt@goodmis.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Keiichi KII <k-keiichi@bx.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>, Jason Baron <jbaron@redhat.com>, Hitoshi Mitake <mitake@dcl.info.waseda.ac.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Tom Zanussi <tzanussi@gmail.com>, "riel@redhat.com" <riel@redhat.com>, Munehiro Ikeda <m-ikeda@ds.jp.nec.com>, Atsushi Tsuji <a-tsuji@bk.jp.nec.com>
List-ID: <linux-mm.kvack.org>

Kame,

On Thu, Feb 18, 2010 at 01:34:29PM +0800, KAMEZAWA Hiroyuki wrote:

> Can we dump page's cgroup ? If so, I'm happy.

Good idea. page_cgroup is extended mem_map anyway.

> Maybe
> ==
>   struct page_cgroup *pc = lookup_page_cgroup(page);
>   struct mem_cgroup *mem = pc->mem_cgroup;
>   shodt mem_cgroup_id = mem->css.css_id;
> 
>   And statistics can be counted per css_id.
> 
> And then, some output like
> 
> dump_pagecache_range: index=0 len=1 flags=10000000000002c count=1 mapcount=0 file=XXX memcg=group_A:x,group_B:y

Is it possible for a page to be owned by two cgroups?
For hierarchical cgroups, it would be easier to report only the bottom level cgroup.

> Is it okay to add a new field after your work finish ?

Sure.

> If so, I'll think about some infrastructure to get above based on your patch.

Then you may want to include this patch (with modification),
if recording the css id as raw tracing data.

Thanks,
Fengguang
---
memcg: show memory.id in cgroupfs

The hwpoison test suite need to selectively inject hwpoison to some
targeted task pages, and must not kill important system processes
such as init.

The memory cgroup serves this purpose well. We can put the target
processes under the control of a memory cgroup, tell the hwpoison
injection code the id of that memory cgroup so that it will only
poison pages associated with it.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/memcontrol.c |   13 +++++++++++++
 1 file changed, 13 insertions(+)

--- linux-mm.orig/mm/memcontrol.c	2009-09-07 16:01:02.000000000 +0800
+++ linux-mm/mm/memcontrol.c	2009-09-11 18:20:55.000000000 +0800
@@ -2510,6 +2510,13 @@ mem_cgroup_get_recursive_idx_stat(struct
 	*val = d.val;
 }
 
+#ifdef CONFIG_HWPOISON_INJECT
+static u64 mem_cgroup_id_read(struct cgroup *cont, struct cftype *cft)
+{
+	return css_id(cgroup_subsys_state(cont, mem_cgroup_subsys_id));
+}
+#endif
+
 static u64 mem_cgroup_read(struct cgroup *cont, struct cftype *cft)
 {
 	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
@@ -2841,6 +2848,12 @@ static int mem_cgroup_swappiness_write(s
 
 
 static struct cftype mem_cgroup_files[] = {
+#ifdef CONFIG_HWPOISON_INJECT /* for now, only user is hwpoison testing */
+	{
+		.name = "id",
+		.read_u64 = mem_cgroup_id_read,
+	},
+#endif
 	{
 		.name = "usage_in_bytes",
 		.private = MEMFILE_PRIVATE(_MEM, RES_USAGE),

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
