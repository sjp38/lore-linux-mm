Date: Wed, 14 Jul 2004 23:06:25 +0900 (JST)
Message-Id: <20040714.230625.86985372.taka@valinux.co.jp>
Subject: [PATCH] memory hotremoval for linux-2.6.7 [14/16]
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <20040714.224138.95803956.taka@valinux.co.jp>
References: <20040714.224138.95803956.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, lhms-devel@lists.sourceforge.net
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--- linux-2.6.7.ORG/mm/page_alloc.c	Thu Jun 17 15:19:28 2032
+++ linux-2.6.7/mm/page_alloc.c	Thu Jun 17 15:26:37 2032
@@ -2386,6 +2386,8 @@ int lower_zone_protection_sysctl_handler
 }
 
 #ifdef CONFIG_MEMHOTPLUG
+extern int mhtest_hpage_read(char *p, int, int);
+
 static int mhtest_read(char *page, char **start, off_t off, int count,
     int *eof, void *data)
 {
@@ -2409,9 +2411,15 @@ static int mhtest_read(char *page, char 
 				/* skip empty zone */
 				continue;
 			len = sprintf(p,
-			    "\t%s[%d]: free %ld, active %ld, present %ld\n",
+			    "\t%s[%d]: free %ld, active %ld, present %ld",
 			    z->name, NODEZONE(i, j),
 			    z->free_pages, z->nr_active, z->present_pages);
+			p += len;
+#if defined(CONFIG_HUGETLB_PAGE) && defined(CONFIG_MEMHOTPLUG)
+			len = mhtest_hpage_read(p, i, j);
+			p += len;
+#endif
+			len = sprintf(p, "\n");
 			p += len;
 		}
 		*p++ = '\n';
--- linux-2.6.7.ORG/mm/hugetlb.c	Thu Jun 17 15:26:09 2032
+++ linux-2.6.7/mm/hugetlb.c	Thu Jun 17 15:26:37 2032
@@ -260,6 +260,24 @@ static unsigned long set_max_huge_pages(
 	return nr_huge_pages;
 }
 
+#ifdef CONFIG_MEMHOTPLUG
+int mhtest_hpage_read(char *p, int nodenum, int zonenum)
+{
+	struct page *page;
+	int total = 0;
+	int free = 0;
+	spin_lock(&hugetlb_lock);
+	list_for_each_entry(page, &hugepage_alllists[nodenum], lru) {
+		if (page_zonenum(page) == zonenum) total++;
+	}
+	list_for_each_entry(page, &hugepage_freelists[nodenum], lru) {
+		if (page_zonenum(page) == zonenum) free++;
+	}
+	spin_unlock(&hugetlb_lock);
+	return sprintf(p, " / HugePage free %d, total %d", free, total);
+}
+#endif
+
 #ifdef CONFIG_SYSCTL
 int hugetlb_sysctl_handler(struct ctl_table *table, int write,
 			   struct file *file, void __user *buffer,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
