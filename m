Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 419FF6B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 09:39:20 -0400 (EDT)
Message-Id: <201203311339.q2VDdJMD006254@farm-0012.internal.tilera.com>
From: Chris Metcalf <cmetcalf@tilera.com>
Date: Fri, 30 Mar 2012 16:07:12 -0400
Subject: [PATCH v2] hugetlb: fix race condition in hugetlb_fault()
In-Reply-To: <CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com>
References: <CAJd=RBCoLNB+iRX1shKGAwSbE8PsZXyk9e3inPTREcm2kk3nXA@mail.gmail.com> <201203302018.q2UKIFH5020745@farm-0012.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Hillf Danton <dhillf@gmail.com>

The race is as follows.  Suppose a multi-threaded task forks a new
process, thus bumping up the ref count on all the pages.  While the fork
is occurring (and thus we have marked all the PTEs as read-only), another
thread in the original process tries to write to a huge page, taking an
access violation from the write-protect and calling hugetlb_cow().  Now,
suppose the fork() fails.  It will undo the COW and decrement the ref
count on the pages, so the ref count on the huge page drops back to 1.
Meanwhile hugetlb_cow() also decrements the ref count by one on the
original page, since the original address space doesn't need it any more,
having copied a new page to replace the original page.  This leaves the
ref count at zero, and when we call unlock_page(), we panic.

The solution is to take an extra reference to the page while we are
holding the lock on it.

Cc: stable@kernel.org
Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
This change incorporates Hillf Danton's suggestion to just unconditionally
get and put the page around the region of code in question.

 mm/hugetlb.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1871753..5f53d6b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -2701,6 +2701,7 @@ int hugetlb_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * so no worry about deadlock.
 	 */
 	page = pte_page(entry);
+	get_page(page);
 	if (page != pagecache_page)
 		lock_page(page);
 
@@ -2732,6 +2733,7 @@ out_page_table_lock:
 	}
 	if (page != pagecache_page)
 		unlock_page(page);
+	put_page(page);
 
 out_mutex:
 	mutex_unlock(&hugetlb_instantiation_mutex);
-- 
1.6.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
