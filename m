Date: Mon, 6 Mar 2006 09:37:29 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: numa_maps update
In-Reply-To: <20060304122618.7867267a.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0603060935300.24016@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0603030846170.13932@schroedinger.engr.sgi.com>
 <20060304010708.31697f71.akpm@osdl.org> <200603040559.16666.ak@suse.de>
 <Pine.LNX.4.64.0603041206260.18435@schroedinger.engr.sgi.com>
 <20060304122618.7867267a.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: ak@suse.de, hugh@veritas.com, linux-mm@kvack.org, mtk-manpages@gmx.net
List-ID: <linux-mm.kvack.org>

1. Remove pagelocked display. Worked only sporadically for page 
   migration.

2. Add writeback display as requested by Andrew

3. Escape some more characters when displaying filenames so that a program
   can parse or skip the filename in a reasonable way.

Andi: will try to get you a manpage later today to be included in the 
numactl package.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc5-mm2/mm/mempolicy.c
===================================================================
--- linux-2.6.16-rc5-mm2.orig/mm/mempolicy.c	2006-03-06 09:10:13.000000000 -0800
+++ linux-2.6.16-rc5-mm2/mm/mempolicy.c	2006-03-06 09:12:50.000000000 -0800
@@ -1786,7 +1786,7 @@ struct numa_maps {
 	unsigned long pages;
 	unsigned long anon;
 	unsigned long active;
-	unsigned long locked;
+	unsigned long writeback;
 	unsigned long mapcount_max;
 	unsigned long dirty;
 	unsigned long swapcache;
@@ -1808,8 +1808,8 @@ static void gather_stats(struct page *pa
 	if (PageActive(page))
 		md->active++;
 
-	if (PageLocked(page))
-		md->locked++;
+	if (PageWriteback(page))
+		md->writeback++;
 
 	if (PageAnon(page))
 		md->anon++;
@@ -1871,7 +1871,7 @@ int show_numa_map(struct seq_file *m, vo
 
 	if (file) {
 		seq_printf(m, " file=");
-		seq_path(m, file->f_vfsmnt, file->f_dentry, "\n\t");
+		seq_path(m, file->f_vfsmnt, file->f_dentry, "\n\t= ");
 	} else if (vma->vm_start <= mm->brk && vma->vm_end >= mm->start_brk) {
 		seq_printf(m, " heap");
 	} else if (vma->vm_start <= mm->start_stack &&
@@ -1908,8 +1908,8 @@ int show_numa_map(struct seq_file *m, vo
 	if (md->active < md->pages && !is_vm_hugetlb_page(vma))
 		seq_printf(m," active=%lu", md->active);
 
-	if (md->locked)
-		seq_printf(m," locked=%lu", md->locked);
+	if (md->writeback)
+		seq_printf(m," writeback=%lu", md->writeback);
 
 	for_each_online_node(n)
 		if (md->node[n])

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
