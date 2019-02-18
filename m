Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33C5EC4360F
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E737121872
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 21:07:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E737121872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=collabora.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 989028E0009; Mon, 18 Feb 2019 16:07:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 95EB78E0002; Mon, 18 Feb 2019 16:07:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8752C8E0009; Mon, 18 Feb 2019 16:07:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 339D08E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 16:07:45 -0500 (EST)
Received: by mail-wr1-f69.google.com with SMTP id e14so8084896wrt.12
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 13:07:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ot08kmA/prmR/f55o4kl+bDhF7HacSvMwQbe1YSXEVc=;
        b=AhuGm4Au5yKHDh33MqZGNlE6NNvOCfqX4IXodTQPJHxGf/dVSVpCHheMpr5dp5ptO6
         7d9NfUF09lyD/mnlHFPah2vafJOKsa9akhTATecSw+sEyETSXUZ3aSMk3/jAHRk6qXxJ
         Heo3Yi6YV7gWZqSEeWc45CacuAVmogJldHEm/HsFzPtU1U7bXAVvElzJ+eYK0wfKjdZZ
         +KQ4FgUIMmnU1CgPyofi4bgxkpx+UtleWRHs2Z3jTRr2AWdEmfOoCoY0pVs8nVFC5MuU
         EyK4NP4r/bqRaPI+6hDy8cKUGPPZBVALEShPEtardVLxylWXv/Bm0GdJVqvWTyvRpMHp
         Edxw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
X-Gm-Message-State: AHQUAuaecYpBvJ62yig0TiqCtnpFlh2WI2iBrAsCeMToOeJS9gpHZNfx
	cO5KiL6yzkQSq6lzsC8rMcsb3RnGx5I+x/THDD3IlIWY+BpnAII41ezNCJI74ZR1Xvoh/t1O0cp
	8im4EqqN0xelIb+Cw0+rAMvJ/oczQbiyjCxjtKzRmOGCDajKx6I4nGCfy7N7qWq2vcA==
X-Received: by 2002:a5d:4804:: with SMTP id l4mr18657928wrq.177.1550524064723;
        Mon, 18 Feb 2019 13:07:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYUmnWcBopepE5FJHeyjydJ86CJSNoe3P4i1eB4iYTSRafY5hxMaKSFMbRL+Umk9fKTPln2
X-Received: by 2002:a5d:4804:: with SMTP id l4mr18657892wrq.177.1550524063604;
        Mon, 18 Feb 2019 13:07:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550524063; cv=none;
        d=google.com; s=arc-20160816;
        b=WrX2tuQNf2/zkATyMXMNNYrP8qp2TCfD/cBfnfKA2KP8JdpmwbeDJSkJ4ziKTQoKW7
         5j0BWKcuJYhuSQKw9IjcMXmGmkHQVLWeV6ZxG7SmTlHNgUdnMTOs+hO1+3IidaVlPVWk
         f/OUQt8Q/nWxw30D1fFsnXOgKF208cRzU8Mvo74/zF03crcRC4HhBGdJYcYBO3xqGzuW
         QpDX99FsNqh2I2F+nhAVdtYJHQ7l8KBJwyR5hC8HDZp0qWB/ZF+/GRRmroXhcLb6gRQR
         4ce2E19+tsbT7GxwQCAM4St7MUVLJHe7wNgeZAWxFWueqsla7ExJ0OjEC89kqm+JbJXp
         AdrA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ot08kmA/prmR/f55o4kl+bDhF7HacSvMwQbe1YSXEVc=;
        b=Bowcyg+8ry+8hxSnhhSLK6t9KK/nL/iM+srDKq1GkndCxNhHy1mEmlX0MMqak70b9c
         KSI3IvPRb6ZTeEFp1rSeGvqmpga/mY+W2TIx8aHnCMm4QwjG7TAcfDKtPaa9ARFK8onr
         bReyVlQg/MhCoH16iEcgR8QlyTnupj8K0sNfUz5MRK8sKq+MeGNdmkIGmiRlD9GZW4jz
         LWNF6mtXsxuBll4qTHbO4ETtewCj83mUywzUAYxBaNS3e4Vrh++osvjXRPBMbrKi6J3S
         JT9xQnX/oV+4ZGm/Z6QbqFWEjpo5r9qhv7BU8Mqw70Nu3HzI6k03JqqEbhaYKwQ3+ui2
         FU0A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from bhuna.collabora.co.uk (bhuna.collabora.co.uk. [46.235.227.227])
        by mx.google.com with ESMTPS id y9si10172692wro.150.2019.02.18.13.07.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 18 Feb 2019 13:07:43 -0800 (PST)
Received-SPF: pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) client-ip=46.235.227.227;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of krisman@collabora.com designates 46.235.227.227 as permitted sender) smtp.mailfrom=krisman@collabora.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=collabora.com
Received: from [127.0.0.1] (localhost [127.0.0.1])
	(Authenticated sender: krisman)
	with ESMTPSA id 221F827FD47
From: Gabriel Krisman Bertazi <krisman@collabora.com>
To: linux-mm@kvack.org
Cc: labbott@redhat.com,
	kernel@collabora.com,
	gael.portay@collabora.com,
	mike.kravetz@oracle.com,
	m.szyprowski@samsung.com,
	Gabriel Krisman Bertazi <krisman@collabora.com>
Subject: [PATCH 6/6] cma: Isolate pageblocks speculatively during allocation
Date: Mon, 18 Feb 2019 16:07:15 -0500
Message-Id: <20190218210715.1066-7-krisman@collabora.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190218210715.1066-1-krisman@collabora.com>
References: <20190218210715.1066-1-krisman@collabora.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Holding the mutex when calling alloc_contig_range() is not essential
because of the bitmap reservation plus the implicit synchronization
mechanism inside start_isolate_page_range(), which prevents allocations
on the same pageblock.  It is still beneficial to perform some kind of
serialization on this path, though, to allow allocations on the same
pageblock, if possible, instead of immediately jumping to another
allocatable region.

Therefore, this patch, instead of serializing every CMA allocation,
speculatively try to do the allocation without acquiring the mutex.  If
we race with another thread allocating on the same pageblock, we can
retry on the same region, after waiting for the other colliding
allocations to finish.

The synchronization of aborted tasks is still done globaly for the CMA
allocator.  Ideally, the aborted allocation would wait only for the
migration of the colliding pageblock, but there is no easy way to track
each pageblock isolation in a non-racy way without adding more code
overhead.  Thus, I believe the mutex mechanism to be an acceptable
compromise, if it is not violating the mutex semantics too much.

Finally, some code paths like the writeback case, should not blindly
sleep waiting for the mutex, because of the possibility of deadlocking
if it is a dependency of another allocation thread that holds the mutex.
This exact scenario was observed by Gael Portay, with a GPU thread that
allocs CMA triggering a writeback, and a USB device in the ARM device
that tries to satisfy the writeback with a NOIO CMA allocation [1].  For
that reason, we restrict writeback threads from waiting on the
pageblock, and instead, we let them move on to a readily available
contiguous memory region, effectively preventing the issue reported in
[1].

[1] https://groups.google.com/a/lists.one-eyed-alien.net/forum/#!topic/usb-storage/BXpAsg-G1us

Signed-off-by: Gabriel Krisman Bertazi <krisman@collabora.com>
---
 mm/cma.c | 29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff --git a/mm/cma.c b/mm/cma.c
index 1dff74b1a8c5..ace978623b8d 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -411,6 +411,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 	void *kaddr;
 	struct page *page = NULL;
 	int ret = -ENOMEM;
+	bool has_lock = false;
 
 	/* Be noisy about caller asking for unsupported flags. */
 	WARN_ON(unlikely(!(gfp_mask & __GFP_DIRECT_RECLAIM) ||
@@ -451,17 +452,39 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 		mutex_unlock(&cma->lock);
 
 		pfn = cma->base_pfn + (bitmap_no << cma->order_per_bit);
-		mutex_lock(&cma_mutex);
+
+		/* Mutual exclusion inside alloc_contig_range() is not
+		 * strictly necessary, but it makes the allocation a
+		 * little more likely to succeed, because it serializes
+		 * simultaneous allocations on the same pageblock.  We
+		 * cannot sleep on all paths, though, so try to do the
+		 * allocation speculatively, if we identify another
+		 * thread using the same pageblock, fallback to the
+		 * serial path mutex, if possible, or try another
+		 * pageblock, otherwise.
+		 */
+		has_lock = mutex_trylock(&cma_mutex);
+retry:
 		ret = alloc_contig_range(pfn, pfn + count, MIGRATE_CMA,
 					 gfp_mask);
-		mutex_unlock(&cma_mutex);
+
+		if (ret == -EAGAIN && (gfp_mask & __GFP_IO)) {
+			if (!has_lock) {
+				mutex_lock(&cma_mutex);
+				has_lock = true;
+			}
+			goto retry;
+		}
+		if (has_lock)
+			mutex_unlock(&cma_mutex);
+
 		if (ret == 0) {
 			page = pfn_to_page(pfn);
 			break;
 		}
 
 		cma_clear_bitmap(cma, pfn, count);
-		if (ret != -EBUSY)
+		if (ret != -EBUSY && ret != -EAGAIN)
 			break;
 
 		pr_debug("%s(): memory range at %p is busy, retrying\n",
-- 
2.20.1

