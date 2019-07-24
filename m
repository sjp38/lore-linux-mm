Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9F876C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:07:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 413A421873
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 17:07:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SuKKhppA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 413A421873
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF0FE8E0006; Wed, 24 Jul 2019 13:07:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CA2FD8E0005; Wed, 24 Jul 2019 13:07:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B91568E0006; Wed, 24 Jul 2019 13:07:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id 987508E0005
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 13:07:25 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id r27so51694338iob.14
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 10:07:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=FMuX0Oym74xCaSWPGFhC4FdIsHBrnIwQJ+1P4e5e/MM=;
        b=uJRwJvHAIv5bAalhrNM3lGPshcQfteVVBUGZWtPfyGrohtTpZzRhQQXNNQzvcLXgE7
         Je7NGQ/u6GZKOxff/HHzqNL5KSdlf7CDpdNBvjLASn0pOj7meOxAUZRcy64nPiDrfiQ5
         uge/sZBj6AL2FeGVa+KR5PSKQlLakSijibSsZYbSrN+HhHy8GjRvDmz324YS4Y9zODX8
         bXEAP1awplu7QnpRJOzmhDA2RyIZCMhATib5iJJVZ2Ilmd4+nNW5Ht86F84X3IHEo1MJ
         1d4dUUZlBpX/yeuClVKD4hYcGLuak/cEAFSV1Pdj0do6kMAuFK6D3pHvypTAbEJiKIzV
         eANg==
X-Gm-Message-State: APjAAAV03KHfQdVR33ucxfqjKrf416XAndQaGxQuz0+P9NJ7ZjEpMSeq
	xeq0BPhTaFwYwiNGul//cFJGA/+3UZKVUME1rHmgQGOZkbxUebi1ycggjv8HfkSvDTHQypb3/NJ
	7Pp+49vjBRy1vQTP2HonoP2V1UGBtz5ew6LAgRKsBIdXZaacRBu7aNbkE9ooqZTzhvw==
X-Received: by 2002:a6b:5a17:: with SMTP id o23mr72153667iob.41.1563988045394;
        Wed, 24 Jul 2019 10:07:25 -0700 (PDT)
X-Received: by 2002:a6b:5a17:: with SMTP id o23mr72153588iob.41.1563988044517;
        Wed, 24 Jul 2019 10:07:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563988044; cv=none;
        d=google.com; s=arc-20160816;
        b=eTbRHOwspSwI5cvYNnC6qDtrmwcA3WGmiOXjkstQp09IC1o29zzwpKrD2kpQm6FUh/
         Gx1v6asa41mtMuTP+qgcj/lyOlydcWUAxqPWtevB4hWsKUjFhyKhwpebuZD2PtQ3cxOI
         tLouEavI44HvpdTJa9ZuemmSl0PtTg1BvFXrKntdyr77nIdDbHoTY4cmEzGoNf3JBd06
         2z0wf68WGt/mzmlEbqnpLCDNBpMrAhsSCjoeIEOKbNwJMejPAbLSH5TI6CyBE3dFz+KE
         o6h5l2/ipugB+vIwRWIV3QssTZSUOXc2taqX3kay9IW6C5LeN52pimDyeoLNlsA/Th2V
         X4Hg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=FMuX0Oym74xCaSWPGFhC4FdIsHBrnIwQJ+1P4e5e/MM=;
        b=vF8j3DGoDSl0jstEKq4oImzr2apNQLxdi6hGimvommKaytVDEKQO/KnvAZvGdG77vR
         AbwKKsYRSTvEXaMdqYY9v01aPPCHYqjqhn/aET6MkWi3B+Q4RwFG5ISpCdkN5M4/Pq+j
         biTtqNHiOIR08ynSvlZPAnUn0+a3/fBzkJ3SyEAXGAHR8P2pA7Z7qkbSijHSWPLblnEa
         +RuD1J+ux3JUUhJZRMAHjHX/SQXE8H42rIGiqNLiRHUTeKqJO1pEq8hrFFPmByzfOgMH
         bBiciCAxIzkS23VqPOsmSFa8mptMCEVyA4xZjCnFtLQ0BME83i3EggCk13J21lQFeBCB
         HdyA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SuKKhppA;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s10sor31203080iob.50.2019.07.24.10.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 10:07:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=SuKKhppA;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=FMuX0Oym74xCaSWPGFhC4FdIsHBrnIwQJ+1P4e5e/MM=;
        b=SuKKhppAVNoQv+RiNYwWSYYmFjbIehqdAVmKv+DBxaGoeM8dyFmZcVLjCbLD5C2NSn
         VRZ2l1ChubLZL943RF6i+FOGqJrzJYNowJK5sSMOxhdnKnIagkm6tNc5Iygp3EptMJOY
         3OnbWNAOwHDsAQ16TEqtynLwPUHuA2mvFMh1x2W0xcL73pcrQ/0TFzWhurTyhPmczryv
         Y7xazqPs2k/EytYMzEOT99kKp07G2EuCNrG2fjCSlcKdzVgad9NoM+EsMjJmRoyxNUu8
         sh3iuEjpV2gdVJ271uL7OhBXRtBsqy+tqPsEFF1vb5qgwpyKnZBBXYpvbseakHe2zJhD
         ozIg==
X-Google-Smtp-Source: APXvYqyQVX8x9OWRNiHYpwDX440mJ3O8R16Hbv8NfiUZMuzD3UzsPyIWJX9LvTuqfqJZry1nQWTt7w==
X-Received: by 2002:a02:1607:: with SMTP id a7mr84040654jaa.123.1563988044110;
        Wed, 24 Jul 2019 10:07:24 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id n2sm48246215ioa.27.2019.07.24.10.07.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 10:07:23 -0700 (PDT)
Subject: [PATCH v2 5/5] virtio-balloon: Add support for providing page hints
 to host
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Wed, 24 Jul 2019 10:05:14 -0700
Message-ID: <20190724170514.6685.17161.stgit@localhost.localdomain>
In-Reply-To: <20190724165158.6685.87228.stgit@localhost.localdomain>
References: <20190724165158.6685.87228.stgit@localhost.localdomain>
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

Add support for the page hinting feature provided by virtio-balloon.
Hinting differs from the regular balloon functionality in that is is
much less durable than a standard memory balloon. Instead of creating a
list of pages that cannot be accessed the pages are only inaccessible
while they are being indicated to the virtio interface. Once the
interface has acknowledged them they are placed back into their respective
free lists and are once again accessible by the guest system.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/Kconfig              |    1 +
 drivers/virtio/virtio_balloon.c     |   47 +++++++++++++++++++++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 +
 3 files changed, 49 insertions(+)

diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index 078615cf2afc..d45556ae1f81 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -58,6 +58,7 @@ config VIRTIO_BALLOON
 	tristate "Virtio balloon driver"
 	depends on VIRTIO
 	select MEMORY_BALLOON
+	select PAGE_HINTING
 	---help---
 	 This driver supports increasing and decreasing the amount
 	 of memory within a KVM guest.
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 226fbb995fb0..dee9f8f3ad09 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -19,6 +19,7 @@
 #include <linux/mount.h>
 #include <linux/magic.h>
 #include <linux/pseudo_fs.h>
+#include <linux/page_hinting.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -27,6 +28,7 @@
  */
 #define VIRTIO_BALLOON_PAGES_PER_PAGE (unsigned)(PAGE_SIZE >> VIRTIO_BALLOON_PFN_SHIFT)
 #define VIRTIO_BALLOON_ARRAY_PFNS_MAX 256
+#define VIRTIO_BALLOON_ARRAY_HINTS_MAX	32
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
 #define VIRTIO_BALLOON_FREE_PAGE_ALLOC_FLAG (__GFP_NORETRY | __GFP_NOWARN | \
@@ -46,6 +48,7 @@ enum virtio_balloon_vq {
 	VIRTIO_BALLOON_VQ_DEFLATE,
 	VIRTIO_BALLOON_VQ_STATS,
 	VIRTIO_BALLOON_VQ_FREE_PAGE,
+	VIRTIO_BALLOON_VQ_HINTING,
 	VIRTIO_BALLOON_VQ_MAX
 };
 
@@ -113,6 +116,10 @@ struct virtio_balloon {
 
 	/* To register a shrinker to shrink memory upon memory pressure */
 	struct shrinker shrinker;
+
+	/* Unused page hinting device */
+	struct virtqueue *hinting_vq;
+	struct page_hinting_dev_info ph_dev_info;
 };
 
 static struct virtio_device_id id_table[] = {
@@ -152,6 +159,22 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 
 }
 
+void virtballoon_page_hinting_react(struct page_hinting_dev_info *ph_dev_info,
+				    unsigned int num_hints)
+{
+	struct virtio_balloon *vb =
+		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
+	struct virtqueue *vq = vb->hinting_vq;
+	unsigned int unused;
+
+	/* We should always be able to add these buffers to an empty queue. */
+	virtqueue_add_inbuf(vq, ph_dev_info->sg, num_hints, vb, GFP_KERNEL);
+	virtqueue_kick(vq);
+
+	/* When host has read buffer, this completes via balloon_ack */
+	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
+}
+
 static void set_page_pfns(struct virtio_balloon *vb,
 			  __virtio32 pfns[], struct page *page)
 {
@@ -476,6 +499,7 @@ static int init_vqs(struct virtio_balloon *vb)
 	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
 	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
 	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
+	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
 
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
@@ -487,11 +511,19 @@ static int init_vqs(struct virtio_balloon *vb)
 		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
 	}
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
+		callbacks[VIRTIO_BALLOON_VQ_HINTING] = balloon_ack;
+	}
+
 	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
 					 vqs, callbacks, names, NULL, NULL);
 	if (err)
 		return err;
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
+		vb->hinting_vq = vqs[VIRTIO_BALLOON_VQ_HINTING];
+
 	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
 	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
@@ -924,12 +956,24 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		if (err)
 			goto out_del_balloon_wq;
 	}
+
+	vb->ph_dev_info.react = virtballoon_page_hinting_react;
+	vb->ph_dev_info.capacity = VIRTIO_BALLOON_ARRAY_HINTS_MAX;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		err = page_hinting_startup(&vb->ph_dev_info);
+		if (err)
+			goto out_unregister_shrinker;
+	}
+
 	virtio_device_ready(vdev);
 
 	if (towards_target(vb))
 		virtballoon_changed(vdev);
 	return 0;
 
+out_unregister_shrinker:
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
+		virtio_balloon_unregister_shrinker(vb);
 out_del_balloon_wq:
 	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT))
 		destroy_workqueue(vb->balloon_wq);
@@ -958,6 +1002,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
+		page_hinting_shutdown(&vb->ph_dev_info);
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 		virtio_balloon_unregister_shrinker(vb);
 	spin_lock_irq(&vb->stop_update_lock);
@@ -1027,6 +1073,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 	VIRTIO_BALLOON_F_PAGE_POISON,
+	VIRTIO_BALLOON_F_HINTING,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index a1966cd7b677..2b0f62814e22 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12

