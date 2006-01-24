Received: from internal-mail-relay1.corp.sgi.com (internal-mail-relay1.corp.sgi.com [198.149.32.52])
	by omx2.sgi.com (8.12.11/8.12.9/linux-outbound_gateway-1.1) with ESMTP id k0OMJmCf015182
	for <linux-mm@kvack.org>; Tue, 24 Jan 2006 14:19:48 -0800
Received: from spindle.corp.sgi.com (spindle.corp.sgi.com [198.29.75.13])
	by internal-mail-relay1.corp.sgi.com (8.12.9/8.12.10/SGI_generic_relay-1.2) with ESMTP id k0OKMUtD97488027
	for <linux-mm@kvack.org>; Tue, 24 Jan 2006 12:22:30 -0800 (PST)
Received: from schroedinger.engr.sgi.com (schroedinger.engr.sgi.com [163.154.5.55])
	by spindle.corp.sgi.com (SGI-8.12.5/8.12.9/generic_config-1.2) with ESMTP id k0OKIjOT19908557
	for <linux-mm@kvack.org>; Tue, 24 Jan 2006 12:18:45 -0800 (PST)
Date: Tue, 24 Jan 2006 12:17:00 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] zone_reclaim: do not unmap file backed pages
Message-ID: <Pine.LNX.4.62.0601241214370.4967@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
ReSent-To: linux-mm@kvack.org
ReSent-Message-ID: <Pine.LNX.4.62.0601241218390.4986@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@vger.kernel.org
List-ID: <linux-mm.kvack.org>

zone_reclaim should leave that to the real swapper. We are only 
interested in evicting unmapped pages.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.16-rc1-mm2/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc1-mm2.orig/mm/vmscan.c	2006-01-23 10:02:23.000000000 -0800
+++ linux-2.6.16-rc1-mm2/mm/vmscan.c	2006-01-23 10:02:23.000000000 -0800
@@ -476,6 +476,12 @@ static int shrink_list(struct list_head 
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
+			/*
+			 * No unmapping if we do not swap
+			 */
+			if (!sc->may_swap)
+				goto keep_locked;
+
 			switch (try_to_unmap(page, 0)) {
 			case SWAP_FAIL:
 				goto activate_locked;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
