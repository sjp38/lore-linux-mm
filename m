Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D048C6B01E3
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 22:52:41 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH] virtio: Fix GFP flags passed from the virtio balloon driver
Date: Thu, 22 Apr 2010 12:22:34 +0930
References: <20100421190704.GK3994@balbir.in.ibm.com>
In-Reply-To: <20100421190704.GK3994@balbir.in.ibm.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201004221222.36014.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, kvm <kvm@vger.kernel.org>, Avi Kivity <avi@qumranet.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, virtualization@lists.linux-foundation.org
List-ID: <linux-mm.kvack.org>

From: Balbir Singh <balbir@linux.vnet.ibm.com>

The virtio balloon driver can dig into the reservation pools
of the OS to satisfy a balloon request. This is not advisable
and other balloon drivers (drivers/xen/balloon.c) avoid this
as well. The patch also adds changes to avoid printing a warning
if allocation fails, since we retry after sometime anyway.

Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
Cc: kvm <kvm@vger.kernel.org>
Cc: stable@kernel.org
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
