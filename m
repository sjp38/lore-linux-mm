Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E2FCE6B01F3
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 15:07:13 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id o3LJ77Ak014775
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 00:37:07 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3LJ77xO3453154
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 00:37:07 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3LJ77kn018367
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 05:07:07 +1000
Date: Thu, 22 Apr 2010 00:37:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: [PATCH][RESEND]Fix GFP flags passed from the virtio balloon driver
Message-ID: <20100421190704.GK3994@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: kvm <kvm@vger.kernel.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>, Avi Kivity <avi@qumranet.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Fix GFP flags passed from the virtio balloon driver

From: Balbir Singh <balbir@linux.vnet.ibm.com>

The virtio balloon driver can dig into the reservation pools
of the OS to satisfy a balloon request. This is not advisable
and other balloon drivers (drivers/xen/balloon.c) avoid this
as well. The patch also avoids printing a warning if allocation
fails.

Comments?

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
---

 drivers/virtio/virtio_balloon.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 369f2ee..f8ffe8c 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -102,7 +102,8 @@ static void fill_balloon(struct virtio_balloon *vb, size_t num)
 	num = min(num, ARRAY_SIZE(vb->pfns));
 
 	for (vb->num_pfns = 0; vb->num_pfns < num; vb->num_pfns++) {
-		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY);
+		struct page *page = alloc_page(GFP_HIGHUSER | __GFP_NORETRY |
+					__GFP_NOMEMALLOC | __GFP_NOWARN);
 		if (!page) {
 			if (printk_ratelimit())
 				dev_printk(KERN_INFO, &vb->vdev->dev,

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
