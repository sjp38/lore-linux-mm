Message-ID: <44345742.8070109@redhat.com>
Date: Wed, 05 Apr 2006 19:48:18 -0400
From: Hideo AOKI <haoki@redhat.com>
MIME-Version: 1.0
Subject: [patch 3/3] mm: An enhancement of OVERCOMMIT_GUESS
Content-Type: multipart/mixed;
 boundary="------------020305010509000208030303"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020305010509000208030303
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

There is a copy of __vm_enough_memory() in mm/nommu.c. I believe that
this enhancement is useful for nommu environment too.

---
Hideo Aoki, Hitachi Computer Products (America) Inc.

--------------020305010509000208030303
Content-Type: text/x-patch;
 name="mm-consider_rsvpgs-nommu.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-consider_rsvpgs-nommu.patch"

This patch is an enhancement of OVERCOMMIT_GUESS algorithm in
__vm_enough_memory() in mm/nommu.c.

When the OVERCOMMIT_GUESS algorithm calculates the number of free
pages, the algorithm subtracts the number of reserved pages from
the result nr_free_pages().

Signed-off-by: Hideo Aoki <haoki@redhat.com>
---

 nommu.c |   18 +++++++++++++++---
 1 files changed, 15 insertions(+), 3 deletions(-)

diff -purN linux-2.6.17-rc1-mm1/mm/nommu.c linux-2.6.17-rc1-mm1-idea6/mm/nommu.c
--- linux-2.6.17-rc1-mm1/mm/nommu.c	2006-04-04 10:43:30.000000000 -0400
+++ linux-2.6.17-rc1-mm1-idea6/mm/nommu.c	2006-04-04 15:09:24.000000000 -0400
@@ -1147,14 +1147,26 @@ int __vm_enough_memory(long pages, int c
 		 * only call if we're about to fail.
 		 */
 		n = nr_free_pages();
+
+		/*
+		 * Leave reserved pages. The pages are not for anonymous pages.
+		 */
+		if (n <= totalreserve_pages)
+			goto error;
+		else
+			n -= totalreserve_pages;
+
+		/*
+		 * Leave the last 3% for root
+		 */
 		if (!cap_sys_admin)
 			n -= n / 32;
 		free += n;
 
 		if (free > pages)
 			return 0;
-		vm_unacct_memory(pages);
-		return -ENOMEM;
+
+		goto error;
 	}
 
 	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
@@ -1175,7 +1187,7 @@ int __vm_enough_memory(long pages, int c
 	 */
 	if (atomic_read(&vm_committed_space) < (long)allowed)
 		return 0;
-
+error:
 	vm_unacct_memory(pages);
 
 	return -ENOMEM;

--------------020305010509000208030303--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
