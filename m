Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 688006B0005
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 14:35:44 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id kq13so1618569pab.29
        for <linux-mm@kvack.org>; Thu, 04 Apr 2013 11:35:43 -0700 (PDT)
Date: Thu, 4 Apr 2013 11:35:10 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <alpine.LNX.2.00.1304041120510.26822@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Jakub Jelinek <jakub@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Ian Lance Taylor <iant@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Jan Stancek <jstancek@redhat.com>

find_vma() can be called by multiple threads with read lock
held on mm->mmap_sem and any of them can update mm->mmap_cache.
Prevent compiler from re-fetching mm->mmap_cache, because other
readers could update it in the meantime:

               thread 1                             thread 2
                                        |
  find_vma()                            |  find_vma()
    struct vm_area_struct *vma = NULL;  |
    vma = mm->mmap_cache;               |
    if (!(vma && vma->vm_end > addr     |
        && vma->vm_start <= addr)) {    |
                                        |    mm->mmap_cache = vma;
    return vma;                         |
     ^^ compiler may optimize this      |
        local variable out and re-read  |
        mm->mmap_cache                  |

This issue can be reproduced with gcc-4.8.0-1 on s390x by running
mallocstress testcase from LTP, which triggers:
  kernel BUG at mm/rmap.c:1088!
    Call Trace:
     ([<000003d100c57000>] 0x3d100c57000)
      [<000000000023a1c0>] do_wp_page+0x2fc/0xa88
      [<000000000023baae>] handle_pte_fault+0x41a/0xac8
      [<000000000023d832>] handle_mm_fault+0x17a/0x268
      [<000000000060507a>] do_protection_exception+0x1e2/0x394
      [<0000000000603a04>] pgm_check_handler+0x138/0x13c
      [<000003fffcf1f07a>] 0x3fffcf1f07a
    Last Breaking-Event-Address:
      [<000000000024755e>] page_add_new_anon_rmap+0xc2/0x168

Thanks to Jakub Jelinek for his insight on gcc and helping to
track this down.

Signed-off-by: Jan Stancek <jstancek@redhat.com>
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---
This is Jan's valuable patch, posted a couple of days ago, which then
triggered "some discussion" of ACCESS_ONCE() on linux-mm.  I've marked
it for stable: should go back years, but 3.5 changed the indentation.

 mm/mmap.c  |    2 +-
 mm/nommu.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index 6466699..0db0de1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1940,7 +1940,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 
 	/* Check the cache first. */
 	/* (Cache hit rate is typically around 35%.) */
-	vma = mm->mmap_cache;
+	vma = ACCESS_ONCE(mm->mmap_cache);
 	if (!(vma && vma->vm_end > addr && vma->vm_start <= addr)) {
 		struct rb_node *rb_node;
 
diff --git a/mm/nommu.c b/mm/nommu.c
index e193280..2f3ea74 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -821,7 +821,7 @@ struct vm_area_struct *find_vma(struct mm_struct *mm, unsigned long addr)
 	struct vm_area_struct *vma;
 
 	/* check the cache first */
-	vma = mm->mmap_cache;
+	vma = ACCESS_ONCE(mm->mmap_cache);
 	if (vma && vma->vm_start <= addr && vma->vm_end > addr)
 		return vma;
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
