Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id BC6636B01A5
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:30 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Wed, 1 May 2013 18:17:29 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id AFC4738C801A
	for <linux-mm@kvack.org>; Wed,  1 May 2013 18:17:26 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r41MHQTZ339940
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:26 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r41MHQs8010510
	for <linux-mm@kvack.org>; Wed, 1 May 2013 18:17:26 -0400
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 1/4] mmzone: make holding lock_memory_hotplug() a requirement for updating pgdat size
Date: Wed,  1 May 2013 15:17:12 -0700
Message-Id: <1367446635-12856-2-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1367446635-12856-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Cody P Schafer <cody@linux.vnet.ibm.com>

All updaters of pgdat size (spanned_pages, start_pfn, and
present_pages) currently also hold lock_memory_hotplug() (in addition
to pgdat_resize_lock()).

Document this and make holding of that lock a requirement on the update
side for now, but keep the pgdat_resize_lock() around for readers that
can't lock a mutex.

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 include/linux/mmzone.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 5c76737..09ac172 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -716,6 +716,9 @@ typedef struct pglist_data {
 	 * or node_spanned_pages stay constant.  Holding this will also
 	 * guarantee that any pfn_valid() stays that way.
 	 *
+	 * Updaters of any of these fields also must hold
+	 * lock_memory_hotplug().
+	 *
 	 * Nests above zone->lock and zone->size_seqlock.
 	 */
 	spinlock_t node_size_lock;
-- 
1.8.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
