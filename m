Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 78299600309
	for <linux-mm@kvack.org>; Mon, 30 Nov 2009 12:22:48 -0500 (EST)
Date: Mon, 30 Nov 2009 18:22:44 +0100
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] mm: don't discard unused swap slots by default
Message-ID: <20091130172243.GA30779@lst.de>
References: <20091030065102.GA2896@lst.de> <Pine.LNX.4.64.0910301629030.4106@sister.anvils> <20091118171232.GB25541@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091118171232.GB25541@lst.de>
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Jens Axboe <jens.axboe@oracle.com>, Matthew Wilcox <matthew@wil.cx>, linux-mm@kvack.org, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Current TRIM/UNMAP/etc implementation are slow enough that discarding
small chunk during run time is a bad idea.  So only discard the whole
swap space on swapon by default, but require the admin to enable it
for run-time discards using the new vm.discard_swapspace sysctl.


Signed-off-by: Christoph Hellwig <hch@lst.de>

Index: linux-2.6/include/linux/swap.h
===================================================================
--- linux-2.6.orig/include/linux/swap.h	2009-11-27 11:50:47.319003920 +0100
+++ linux-2.6/include/linux/swap.h	2009-11-27 11:51:55.617286868 +0100
@@ -247,6 +247,7 @@ extern unsigned long mem_cgroup_shrink_n
 extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
+extern int vm_discard_swapspace;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern long vm_total_pages;
 
Index: linux-2.6/kernel/sysctl.c
===================================================================
--- linux-2.6.orig/kernel/sysctl.c	2009-11-27 11:49:02.935254088 +0100
+++ linux-2.6/kernel/sysctl.c	2009-11-27 11:53:10.333006621 +0100
@@ -1163,6 +1163,16 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+	{
+		.ctl_name	= CTL_UNNUMBERED,
+		.procname	= "discard_swapspace",
+		.data		= &vm_discard_swapspace,
+		.maxlen		= sizeof(vm_discard_swapspace),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
 #ifdef CONFIG_HUGETLB_PAGE
 	 {
 		.procname	= "nr_hugepages",
Index: linux-2.6/mm/swapfile.c
===================================================================
--- linux-2.6.orig/mm/swapfile.c	2009-11-27 11:53:19.449254088 +0100
+++ linux-2.6/mm/swapfile.c	2009-11-27 11:54:07.883255931 +0100
@@ -41,6 +41,7 @@ long nr_swap_pages;
 long total_swap_pages;
 static int swap_overflow;
 static int least_priority;
+int vm_discard_swapspace;
 
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
@@ -1978,7 +1979,7 @@ SYSCALL_DEFINE2(swapon, const char __use
 			p->flags |= SWP_SOLIDSTATE;
 			p->cluster_next = 1 + (random32() % p->highest_bit);
 		}
-		if (discard_swap(p) == 0)
+		if (discard_swap(p) == 0 && vm_discard_swapspace)
 			p->flags |= SWP_DISCARDABLE;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
