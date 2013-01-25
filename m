Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id AAAE46B0005
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 17:18:18 -0500 (EST)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] swap: fix "add per-partition lock for swapfile" for nommu
Date: Fri, 25 Jan 2013 22:18:07 +0000
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201301252218.07296.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fusionio.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-mm@kvack.org

The patch "swap: add per-partition lock for swapfile" made the
nr_swap_pages variable unaccessible but forgot to change the
mm/nommu.c file that uses it. This does the trivial conversion
to let us build nommu kernels again 

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/mm/nommu.c b/mm/nommu.c
index b7fdaa7..bf74898 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1906,7 +1906,7 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		 */
 		free -= global_page_state(NR_SHMEM);
 
-		free += nr_swap_pages;
+		free += get_nr_swap_pages();
 
 		/*
 		 * Any slabs which are created with the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
