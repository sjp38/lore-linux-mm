Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 904FC6B0253
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 09:10:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id i83so1248899wma.4
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 06:10:44 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n17si1509432wmd.273.2017.12.13.06.10.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Dec 2017 06:10:41 -0800 (PST)
Date: Wed, 13 Dec 2017 15:10:39 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171213141039.GL25185@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <20171213120733.umeb7rylswl7chi5@node.shutemov.name>
 <20171213121703.GD25185@dhcp22.suse.cz>
 <20171213124731.hmg4r5m3efybgjtx@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213124731.hmg4r5m3efybgjtx@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 13-12-17 15:47:31, Kirill A. Shutemov wrote:
> On Wed, Dec 13, 2017 at 01:17:03PM +0100, Michal Hocko wrote:
> > On Wed 13-12-17 15:07:33, Kirill A. Shutemov wrote:
> > [...]
> > > The approach looks fine to me.
> > > 
> > > But patch is rather large and hard to review. And how git mixed add/remove
> > > lines doesn't help too. Any chance to split it up further?
> > 
> > I was trying to do that but this is a drop in replacement so it is quite
> > hard to do in smaller pieces. I've already put the allocation callback
> > cleanup into a separate one but this is about all that I figured how to
> > split. If you have any suggestions I am willing to try them out.
> 
> "git diff --patience" seems generate more readable output for the patch.

Hmm, I wasn't aware of this option. Are you suggesting I should use it
to general the patch to send?

> > > One nitpick: I don't think 'chunk' terminology should go away with the
> > > patch.
> > 
> > Not sure what you mean here. I have kept chunk_start, chunk_node, so I
> > am not really changing that terminology
> 
> We don't really have chunks anymore, right? We still *may* have per-node
> batching, but..
> 
> Maybe just 'start' and 'current_node'?

Ohh, I've read your response that you want to preserve the naming. I can
certainly do the rename.
---
diff --git a/mm/migrate.c b/mm/migrate.c
index 9d7252ea2acd..5491045b60f9 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1556,14 +1556,14 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			 const int __user *nodes,
 			 int __user *status, int flags)
 {
-	int chunk_node = NUMA_NO_NODE;
+	int current_node = NUMA_NO_NODE;
 	LIST_HEAD(pagelist);
-	int chunk_start, i;
+	int start, i;
 	int err = 0, err1;
 
 	migrate_prep();
 
-	for (i = chunk_start = 0; i < nr_pages; i++) {
+	for (i = start = 0; i < nr_pages; i++) {
 		const void __user *p;
 		unsigned long addr;
 		int node;
@@ -1585,25 +1585,25 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (!node_isset(node, task_nodes))
 			goto out_flush;
 
-		if (chunk_node == NUMA_NO_NODE) {
-			chunk_node = node;
-			chunk_start = i;
-		} else if (node != chunk_node) {
-			err = do_move_pages_to_node(mm, &pagelist, chunk_node);
+		if (current_node == NUMA_NO_NODE) {
+			current_node = node;
+			start = i;
+		} else if (node != current_node) {
+			err = do_move_pages_to_node(mm, &pagelist, current_node);
 			if (err)
 				goto out;
-			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
+			err = store_status(status, start, current_node, i - start);
 			if (err)
 				goto out;
-			chunk_start = i;
-			chunk_node = node;
+			start = i;
+			current_node = node;
 		}
 
 		/*
 		 * Errors in the page lookup or isolation are not fatal and we simply
 		 * report them via status
 		 */
-		err = add_page_for_migration(mm, addr, chunk_node,
+		err = add_page_for_migration(mm, addr, current_node,
 				&pagelist, flags & MPOL_MF_MOVE_ALL);
 		if (!err)
 			continue;
@@ -1612,22 +1612,22 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (err)
 			goto out_flush;
 
-		err = do_move_pages_to_node(mm, &pagelist, chunk_node);
+		err = do_move_pages_to_node(mm, &pagelist, current_node);
 		if (err)
 			goto out;
-		if (i > chunk_start) {
-			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
+		if (i > start) {
+			err = store_status(status, start, current_node, i - start);
 			if (err)
 				goto out;
 		}
-		chunk_node = NUMA_NO_NODE;
+		current_node = NUMA_NO_NODE;
 	}
 	err = 0;
 out_flush:
 	/* Make sure we do not overwrite the existing error */
-	err1 = do_move_pages_to_node(mm, &pagelist, chunk_node);
+	err1 = do_move_pages_to_node(mm, &pagelist, current_node);
 	if (!err1)
-		err1 = store_status(status, chunk_start, chunk_node, i - chunk_start);
+		err1 = store_status(status, start, current_node, i - start);
 	if (!err)
 		err = err1;
 out:
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
