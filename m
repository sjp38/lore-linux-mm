Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9AB4CC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:45:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3EB38206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:45:33 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M384t4Ol"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3EB38206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E360F6B0003; Thu,  1 Aug 2019 18:45:32 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DE6A46B0005; Thu,  1 Aug 2019 18:45:32 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CD6356B0006; Thu,  1 Aug 2019 18:45:32 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9818E6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:45:32 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so46765411pfd.3
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:45:32 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=h4Lsi1VTaoGLd9Bw8oLt6c4OkNupffkTaep31hzlwMM=;
        b=Q4BWdBR0yowZac3xdGGECY5ximOyvAB1AXa7QWsRFlncE/9xJHLIKyKwAOQu8zG1LZ
         Tu34NeTeVcog1lnyyRW0uFFXvvgi5/+xJs4sVHNMLUkGncxbGLFrZc3jCY2dnaZJoNyi
         ToxoSjY2/arhstFtMI60z14fyItw9qvwUSmfj+lMLG/p1mVImTdSTrF5i0H1zAOaryNp
         2RSpYXdCkAcn8zgKIXH447N8eCBHxXJjBYUOIpMXpzIxt9UVvxyzofPXUc3Qy9VkV6PF
         v/exUrdpHTM6n20Nt71pJmTXVRaVwi+E78yyJdaacI52dNoZmlAW+caPfQpppAZX3Xqb
         GqAA==
X-Gm-Message-State: APjAAAVJR9OFT4M3QI0mKnDDZEsQm+eYvz1xQlDioxBIOFXfRIQCnpB6
	oEZQTcwkEaj6vFcpT+kNbu3Sc7ZAXcL6ZUH0ExNeLxVPq9V42bJMFFqdGzQhwyIsn6wM149qMu3
	ieUZqs4HdOgWv17KCsk1/jl0DCvxs55Qr6cYkO7wdpUZFA3vcEabT+AJyD2vyMzVjFQ==
X-Received: by 2002:a17:90a:30e4:: with SMTP id h91mr1074052pjb.37.1564699532281;
        Thu, 01 Aug 2019 15:45:32 -0700 (PDT)
X-Received: by 2002:a17:90a:30e4:: with SMTP id h91mr1073974pjb.37.1564699531308;
        Thu, 01 Aug 2019 15:45:31 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564699531; cv=none;
        d=google.com; s=arc-20160816;
        b=Op7r7/C/Cici5oB+kz2FUmSDX+JivGwDIFPC84QZibCsfCIAZlSNGqEHLe15DHmT99
         Ygda6fl8EI0r/49jLEjPWd/HTELBP+HfYSQ8c5WNgu0Hewf22ZnJcufdys+DhBjF5nkK
         Z/O5GB5FfhtyRrWcM3+OZJ4vBnm8x7kHUl51IJA+yNiONZhDzt/uO/LehNlDdVZjCMWh
         amppJcCIZFuu02QYAEk6Y4+iStvpV9dgdo0XY1Sp46YrG+xhbFMwFFpqur4pt88pzImU
         tItwui8TsqiVkAl45eX7UF8d0tUw7RosebjjgJM4JiLqwLY8O5B/exa8yErDRkrlZMys
         CSPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=h4Lsi1VTaoGLd9Bw8oLt6c4OkNupffkTaep31hzlwMM=;
        b=mlvBIIjY3DZzKIKZHb/a6KhElcpyr1MkQVEG1ibspxq/6z5QHj7w1i4rdql4cbFGda
         WpblTGVNTayZD/U8amIZvPTQTpmN4mWwiilIKM1eWX+aRXYLFMVsILohl2DCkJpqsUkx
         m7ltkImdLGBZ9xyF7C4kXx42yK61L/xD+1UDHaQ9xvS3LOeU77m2bN3QGCPvaKNo+eGJ
         9Ne2AS1+kp3ooWkUQjyLG2wyGJIVMOJbaFPwRC+dw4o1eGfW4oBAIyjTFolzTGlWNpci
         Nng/erM1QuWt7MHCFAQ0Ym0ape0Svy2EpgK6sshU0wXHcDg2vkAWsg/uvpsMiKDYV+zc
         IlRg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M384t4Ol;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t128sor42301025pgt.34.2019.08.01.15.45.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:45:31 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M384t4Ol;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=h4Lsi1VTaoGLd9Bw8oLt6c4OkNupffkTaep31hzlwMM=;
        b=M384t4OlaDXvg1lPsygHOKvaElm2HsKjGFlhzQAy4dzxFhUFdWc/vJfNtCCQyJIRpL
         gfDPhk1zlFMDSxz6Yc24dnOGHTUjZq6XU2eUQo+nAYTOWoSP9Ok+dGeubnB1CFE+gz2R
         mzdRGGMmoq6P3HQD4uG+R1i3OvX5sozoWrGV0i24+lRVYiWk04iFlIpYmf0KLgYtulIm
         AgbTtnTwOHxHf+PE0/UuBODabrJyJBoJpVO+PThbyWbsDlNOA2qgGx6xSr5MwMadQTGq
         eitYB8gSKPufZk6i5/+ISCqbhwW0nsLbYubHPRWNJgBe5xo8KxSJezbdiDGc4PbxRFln
         T2+w==
X-Google-Smtp-Source: APXvYqw+uCbcsMTjyxZ8I73mi5tg5khzikhQYSiawwErq1bl1de5is5NJKQJ5oo+e0HH1j5hPBG7rg==
X-Received: by 2002:a63:593:: with SMTP id 141mr118691441pgf.78.1564699530624;
        Thu, 01 Aug 2019 15:45:30 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id f32sm5383901pgb.21.2019.08.01.15.45.29
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:45:30 -0700 (PDT)
Subject: [PATCH v3 QEMU 2/2] virtio-balloon: Provide a interface for unused
 page reporting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:43:20 -0700
Message-ID: <20190801224320.24744.16673.stgit@localhost.localdomain>
In-Reply-To: <20190801222158.22190.96964.stgit@localhost.localdomain>
References: <20190801222158.22190.96964.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add support for what I am referring to as "unused page reporting".
Basically the idea is to function very similar to how the balloon works
in that we basically end up madvising the page as not being used. However
we don't really need to bother with any deflate type logic since the page
will be faulted back into the guest when it is read or written to.

This is meant to be a simplification of the existing balloon interface
to use for providing hints to what memory needs to be freed. I am assuming
this is safe to do as the deflate logic does not actually appear to do very
much other than tracking what subpages have been released and which ones
haven't.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 hw/virtio/virtio-balloon.c                      |   46 ++++++++++++++++++++++-
 include/hw/virtio/virtio-balloon.h              |    2 +
 include/standard-headers/linux/virtio_balloon.h |    1 +
 3 files changed, 46 insertions(+), 3 deletions(-)

diff --git a/hw/virtio/virtio-balloon.c b/hw/virtio/virtio-balloon.c
index 003b3ebcfdfb..7a30df63bc77 100644
--- a/hw/virtio/virtio-balloon.c
+++ b/hw/virtio/virtio-balloon.c
@@ -320,6 +320,40 @@ static void balloon_stats_set_poll_interval(Object *obj, Visitor *v,
     balloon_stats_change_timer(s, 0);
 }
 
+static void virtio_balloon_handle_report(VirtIODevice *vdev, VirtQueue *vq)
+{
+    VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
+    VirtQueueElement *elem;
+
+    while ((elem = virtqueue_pop(vq, sizeof(VirtQueueElement)))) {
+    	unsigned int i;
+
+        for (i = 0; i < elem->in_num; i++) {
+            void *addr = elem->in_sg[i].iov_base;
+            size_t size = elem->in_sg[i].iov_len;
+            ram_addr_t ram_offset;
+            size_t rb_page_size;
+            RAMBlock *rb;
+
+            if (qemu_balloon_is_inhibited() || dev->poison_val)
+                continue;
+
+            rb = qemu_ram_block_from_host(addr, false, &ram_offset);
+            rb_page_size = qemu_ram_pagesize(rb);
+
+            /* For now we will simply ignore unaligned memory regions */
+            if ((ram_offset | size) & (rb_page_size - 1))
+                continue;
+
+            ram_block_discard_range(rb, ram_offset, size);
+        }
+
+        virtqueue_push(vq, elem, 0);
+        virtio_notify(vdev, vq);
+        g_free(elem);
+    }
+}
+
 static void virtio_balloon_handle_output(VirtIODevice *vdev, VirtQueue *vq)
 {
     VirtIOBalloon *s = VIRTIO_BALLOON(vdev);
@@ -627,7 +661,8 @@ static size_t virtio_balloon_config_size(VirtIOBalloon *s)
         return sizeof(struct virtio_balloon_config);
     }
     if (virtio_has_feature(features, VIRTIO_BALLOON_F_PAGE_POISON) ||
-        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+        virtio_has_feature(features, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
+        virtio_has_feature(features, VIRTIO_BALLOON_F_REPORTING)) {
         return sizeof(struct virtio_balloon_config);
     }
     return offsetof(struct virtio_balloon_config, free_page_report_cmd_id);
@@ -715,7 +750,8 @@ static uint64_t virtio_balloon_get_features(VirtIODevice *vdev, uint64_t f,
     VirtIOBalloon *dev = VIRTIO_BALLOON(vdev);
     f |= dev->host_features;
     virtio_add_feature(&f, VIRTIO_BALLOON_F_STATS_VQ);
-    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
+    if (virtio_has_feature(f, VIRTIO_BALLOON_F_FREE_PAGE_HINT) ||
+        virtio_has_feature(f, VIRTIO_BALLOON_F_REPORTING)) {
         virtio_add_feature(&f, VIRTIO_BALLOON_F_PAGE_POISON);
     }
 
@@ -805,6 +841,10 @@ static void virtio_balloon_device_realize(DeviceState *dev, Error **errp)
     s->dvq = virtio_add_queue(vdev, 128, virtio_balloon_handle_output);
     s->svq = virtio_add_queue(vdev, 128, virtio_balloon_receive_stats);
 
+    if (virtio_has_feature(s->host_features, VIRTIO_BALLOON_F_REPORTING)) {
+        s->rvq = virtio_add_queue(vdev, 32, virtio_balloon_handle_report);
+    }
+
     if (virtio_has_feature(s->host_features,
                            VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
         s->free_page_vq = virtio_add_queue(vdev, VIRTQUEUE_MAX_SIZE,
@@ -931,6 +971,8 @@ static Property virtio_balloon_properties[] = {
      */
     DEFINE_PROP_BOOL("qemu-4-0-config-size", VirtIOBalloon,
                      qemu_4_0_config_size, false),
+    DEFINE_PROP_BIT("unused-page-reporting", VirtIOBalloon, host_features,
+                    VIRTIO_BALLOON_F_REPORTING, true),
     DEFINE_PROP_LINK("iothread", VirtIOBalloon, iothread, TYPE_IOTHREAD,
                      IOThread *),
     DEFINE_PROP_END_OF_LIST(),
diff --git a/include/hw/virtio/virtio-balloon.h b/include/hw/virtio/virtio-balloon.h
index 7fe78e5c14d7..db5bf7127112 100644
--- a/include/hw/virtio/virtio-balloon.h
+++ b/include/hw/virtio/virtio-balloon.h
@@ -42,7 +42,7 @@ enum virtio_balloon_free_page_report_status {
 
 typedef struct VirtIOBalloon {
     VirtIODevice parent_obj;
-    VirtQueue *ivq, *dvq, *svq, *free_page_vq;
+    VirtQueue *ivq, *dvq, *svq, *free_page_vq, *rvq;
     uint32_t free_page_report_status;
     uint32_t num_pages;
     uint32_t actual;
diff --git a/include/standard-headers/linux/virtio_balloon.h b/include/standard-headers/linux/virtio_balloon.h
index 9375ca2a70de..1c5f6d6f2de6 100644
--- a/include/standard-headers/linux/virtio_balloon.h
+++ b/include/standard-headers/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12

