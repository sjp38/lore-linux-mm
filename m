Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 3E2496B003D
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:28:45 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rp16so12585408pbb.34
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:28:44 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id zv1si9001204pac.119.2014.05.29.00.28.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 May 2014 00:28:44 -0700 (PDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: [PATCH 2/4] virtio_net: pass well-formed sg to virtqueue_add_inbuf()
Date: Thu, 29 May 2014 16:56:43 +0930
Message-Id: <1401348405-18614-3-git-send-email-rusty@rustcorp.com.au>
In-Reply-To: <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
References: <87oayh6s3s.fsf@rustcorp.com.au>
 <1401348405-18614-1-git-send-email-rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>

This is the only place which doesn't hand virtqueue_add_inbuf or
virtqueue_add_outbuf a well-formed, well-terminated sg.  Fix it,
so we can make virtio_add_* simpler.

Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
---
 drivers/net/virtio_net.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
index 8a852b5f215f..63299b04cdf2 100644
--- a/drivers/net/virtio_net.c
+++ b/drivers/net/virtio_net.c
@@ -590,6 +590,8 @@ static int add_recvbuf_big(struct receive_queue *rq, gfp_t gfp)
 	offset = sizeof(struct padded_vnet_hdr);
 	sg_set_buf(&rq->sg[1], p + offset, PAGE_SIZE - offset);
 
+	sg_mark_end(&rq->sg[MAX_SKB_FRAGS + 2 - 1]);
+
 	/* chain first in list head */
 	first->private = (unsigned long)list;
 	err = virtqueue_add_inbuf(rq->vq, rq->sg, MAX_SKB_FRAGS + 2,
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
