Date: Thu, 7 Jun 2007 23:44:38 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: memory unplug v4 intro [1/6] migration without mm->sem
In-Reply-To: <20070608150602.78f07b34.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0706072344040.29301@schroedinger.engr.sgi.com>
References: <20070608143531.411c76df.kamezawa.hiroyu@jp.fujitsu.com>
 <20070608143844.569c2804.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072242500.28618@schroedinger.engr.sgi.com>
 <20070608145435.4fa7c9b6.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0706072254160.28618@schroedinger.engr.sgi.com>
 <20070608150602.78f07b34.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

I think what Hugh meant is someething like this:

---
 mm/migrate.c |   14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2007-06-07 23:27:07.000000000 -0700
+++ linux-2.6/mm/migrate.c	2007-06-07 23:40:25.000000000 -0700
@@ -209,10 +209,6 @@ static void remove_file_migration_ptes(s
 	spin_unlock(&mapping->i_mmap_lock);
 }
 
-/*
- * Must hold mmap_sem lock on at least one of the vmas containing
- * the page so that the anon_vma cannot vanish.
- */
 static void remove_anon_migration_ptes(struct page *old, struct page *new)
 {
 	struct anon_vma *anon_vma;
@@ -612,6 +608,7 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
+	struct vm_area_struct dummy_vma = { 0 };
 
 	if (!newpage)
 		return -ENOMEM;
@@ -634,6 +631,12 @@ static int unmap_and_move(new_page_t get
 	}
 
 	/*
+	 * Add dummy vma so that the vma cannot vanish under us
+	 */
+	if (PageAnon(page))
+		anon_vma_link(&dummy_vma);
+
+	/*
 	 * Establish migration ptes or remove ptes
 	 */
 	try_to_unmap(page, 1);
@@ -643,6 +646,9 @@ static int unmap_and_move(new_page_t get
 	if (rc)
 		remove_migration_ptes(page, page);
 
+	/* Remove dummy vma */
+	if (PageAnon(page))
+		anon_vma_unlink(&dummy_vma);
 unlock:
 	unlock_page(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
