Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id E0C986B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 18:09:49 -0400 (EDT)
Subject: [RFC][PATCH] mm: percpu pages: up batch size to fix arithmetic?? errror
From: Dave Hansen <dave@sr71.net>
Date: Wed, 11 Sep 2013 15:08:59 -0700
Message-Id: <20130911220859.EB8204BB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cody P Schafer <cody@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux.com, Dave Hansen <dave@sr71.net>


I really don't know where the:

	batch /= 4;             /* We effectively *= 4 below */
	...
	batch = rounddown_pow_of_two(batch + batch/2) - 1;

came from.  The round down code at *MOST* does a *= 1.5, but
*averages* out to be just under 1.

On a system with 128GB in a zone, this means that we've got
(you can see in /proc/zoneinfo for yourself):

              high:  186 (744kB)
              batch: 31  (124kB)

That 124kB is almost precisely 1/4 of the "1/2 of a meg" that we
were shooting for.  We're under-sizing the batches by about 4x.
This patch kills the /=4.


---

 linux.git-davehans/mm/page_alloc.c |    1 -
 1 file changed, 1 deletion(-)

diff -puN mm/page_alloc.c~debug-pcp-sizes-1 mm/page_alloc.c
--- linux.git/mm/page_alloc.c~debug-pcp-sizes-1	2013-09-11 14:41:08.532445664 -0700
+++ linux.git-davehans/mm/page_alloc.c	2013-09-11 15:03:47.403912683 -0700
@@ -4103,7 +4103,6 @@ static int __meminit zone_batchsize(stru
 	batch = zone->managed_pages / 1024;
 	if (batch * PAGE_SIZE > 512 * 1024)
 		batch = (512 * 1024) / PAGE_SIZE;
-	batch /= 4;		/* We effectively *= 4 below */
 	if (batch < 1)
 		batch = 1;
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
