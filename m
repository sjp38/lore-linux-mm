Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 031F06B020D
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 21:41:03 -0400 (EDT)
Date: Tue, 30 Mar 2010 10:32:36 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [PATCH(v2) -mmotm 1/2] memcg move charge of file cache at task
 migration
Message-Id: <20100330103236.83b319ce.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100329131541.7cdc1744.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100329120243.af6bfeac.nishimura@mxp.nes.nec.co.jp>
	<20100329120321.bb6e65fe.nishimura@mxp.nes.nec.co.jp>
	<20100329131541.7cdc1744.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 29 Mar 2010 13:15:41 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 29 Mar 2010 12:03:21 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > This patch adds support for moving charge of file cache. It's enabled by setting
> > bit 1 of <target cgroup>/memory.move_charge_at_immigrate.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> >  Documentation/cgroups/memory.txt |    6 ++++--
> >  mm/memcontrol.c                  |   14 +++++++++++---
> >  2 files changed, 15 insertions(+), 5 deletions(-)
> > 
> > diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> > index 1b5bd04..f53d220 100644
> > --- a/Documentation/cgroups/memory.txt
> > +++ b/Documentation/cgroups/memory.txt
> > @@ -461,10 +461,12 @@ charges should be moved.
> >     0  | A charge of an anonymous page(or swap of it) used by the target task.
> >        | Those pages and swaps must be used only by the target task. You must
> >        | enable Swap Extension(see 2.4) to enable move of swap charges.
> > + -----+------------------------------------------------------------------------
> > +   1  | A charge of file cache mmap'ed by the target task. Those pages must be
> > +      | mmap'ed only by the target task.
> 
> Hmm..my English is not good but..
> ==
> A charge of a page cache mapped by the target task. Pages mapped by multiple processes
> will not be moved. This "page cache" doesn't include tmpfs.
> ==
> 
This is more accurate than mine.

> Hmm, "a page mapped only by target task but belongs to other cgroup" will be moved ?
> The answer is "NO.".
> 
> The code itself seems to work well. So, could you update Documentation ?
> 
Thank you for your advice.

This is the updated version.

===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

This patch adds support for moving charge of file cache. It's enabled by setting
bit 1 of <target cgroup>/memory.move_charge_at_immigrate.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
v1->v2
  - update a documentation.

 Documentation/cgroups/memory.txt |    7 +++++--
 mm/memcontrol.c                  |   14 +++++++++++---
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
index 1b5bd04..c624cd2 100644
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -461,10 +461,13 @@ charges should be moved.
    0  | A charge of an anonymous page(or swap of it) used by the target task.
       | Those pages and swaps must be used only by the target task. You must
       | enable Swap Extension(see 2.4) to enable move of swap charges.
+ -----+------------------------------------------------------------------------
+   1  | A charge of page cache mapped by the target task. Pages mapped by
+      | multiple processes will not be moved. This "page cache" doesn't include
+      | tmpfs.
 
 Note: Those pages and swaps must be charged to the old cgroup.
-Note: More type of pages(e.g. file cache, shmem,) will be supported by other
-      bits in future.
+Note: More type of pages(e.g. shmem) will be supported by other bits in future.
 
 8.3 TODO
 
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index f6c9d42..66d2704 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -250,6 +250,7 @@ struct mem_cgroup {
  */
 enum move_type {
 	MOVE_CHARGE_TYPE_ANON,	/* private anonymous page and swap of it */
+	MOVE_CHARGE_TYPE_FILE,	/* private file caches */
 	NR_MOVE_TYPE,
 };
 
@@ -4192,6 +4193,8 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 	int usage_count = 0;
 	bool move_anon = test_bit(MOVE_CHARGE_TYPE_ANON,
 					&mc.to->move_charge_at_immigrate);
+	bool move_file = test_bit(MOVE_CHARGE_TYPE_FILE,
+					&mc.to->move_charge_at_immigrate);
 
 	if (!pte_present(ptent)) {
 		/* TODO: handle swap of shmes/tmpfs */
@@ -4208,10 +4211,15 @@ static int is_target_pte_for_mc(struct vm_area_struct *vma,
 		if (!page || !page_mapped(page))
 			return 0;
 		/*
-		 * TODO: We don't move charges of file(including shmem/tmpfs)
-		 * pages for now.
+		 * TODO: We don't move charges of shmem/tmpfs pages for now.
 		 */
-		if (!move_anon || !PageAnon(page))
+		if (PageAnon(page)) {
+			if (!move_anon)
+				return 0;
+		} else if (page_is_file_cache(page)) {
+			if (!move_file)
+				return 0;
+		} else
 			return 0;
 		if (!get_page_unless_zero(page))
 			return 0;
-- 
1.6.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
