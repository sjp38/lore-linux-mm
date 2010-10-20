Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 941FB5F0048
	for <linux-mm@kvack.org>; Wed, 20 Oct 2010 00:44:51 -0400 (EDT)
Date: Wed, 20 Oct 2010 13:34:51 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH v3 11/11] memcg: check memcg dirty limits in page
 writeback
Message-Id: <20101020133451.93026a1b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20101020131857.cd0ecd38.kamezawa.hiroyu@jp.fujitsu.com>
References: <1287448784-25684-1-git-send-email-gthelen@google.com>
	<1287448784-25684-12-git-send-email-gthelen@google.com>
	<20101019100015.7a0d4695.kamezawa.hiroyu@jp.fujitsu.com>
	<20101020131857.cd0ecd38.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Greg Thelen <gthelen@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Minchan Kim <minchan.kim@gmail.com>, Ciju Rajan K <ciju@linux.vnet.ibm.com>, David Rientjes <rientjes@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 20 Oct 2010 13:18:57 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Tue, 19 Oct 2010 10:00:15 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Mon, 18 Oct 2010 17:39:44 -0700
> > Greg Thelen <gthelen@google.com> wrote:
> > 
> > > If the current process is in a non-root memcg, then
> > > global_dirty_limits() will consider the memcg dirty limit.
> > > This allows different cgroups to have distinct dirty limits
> > > which trigger direct and background writeback at different
> > > levels.
> > > 
> > > Signed-off-by: Andrea Righi <arighi@develer.com>
> > > Signed-off-by: Greg Thelen <gthelen@google.com>
> > 
> > Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> Why FREEPAGES in memcg is not counted as dirtyable ?
> 
It's counted as memcg_hierarchical_free_pages() in mem_cgroup_page_stat().
As for FREEPAGES, we should count ancestors, not children.

mem_cgroup_page_stat():
   1311         if (mem && !mem_cgroup_is_root(mem)) {
   1312                 /*
   1313                  * If we're looking for dirtyable pages we need to evaluate
   1314                  * free pages depending on the limit and usage of the parents
   1315                  * first of all.
   1316                  */
   1317                 if (item == MEMCG_NR_DIRTYABLE_PAGES)
   1318                         value = memcg_hierarchical_free_pages(mem);
   1319                 else
   1320                         value = 0;
   1321                 /*
   1322                  * Recursively evaluate page statistics against all cgroup
   1323                  * under hierarchy tree
   1324                  */
   1325                 for_each_mem_cgroup_tree(iter, mem)
   1326                         value += mem_cgroup_local_page_stat(iter, item);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
