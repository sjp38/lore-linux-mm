Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07DD7C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:40:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9C2E9206A2
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 22:40:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="PBkxxqkq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9C2E9206A2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C80F6B0003; Thu,  1 Aug 2019 18:40:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2521B6B0005; Thu,  1 Aug 2019 18:40:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0F2C96B0006; Thu,  1 Aug 2019 18:40:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id C82EE6B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 18:40:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id p29so37867962pgm.10
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 15:40:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=3HK7s8V9oToEwvd+cxmNBKqtwxYR1WNQK7rC8iWKNTA=;
        b=CAdJzk7wOn1PsLEpTPVpN+bi+HuLcOGgqY/VcwpfWSK7y2clVlF/41g5aJ6zoQf9eW
         MpopYKZdRQ7QekrlF8c5yq5si5NiZdeKQ/YtE/1X28EzubFsevG3Mok2DpdUbQTzRTSK
         nuc/sfeknKwePqcQYDZKd/tGSX5kfe5yiZrITFuYRV3rUdJwgGnXTw8CR8U0qm71dAwE
         gjd6K9X7u+nl2LinS5YhJyV5japTiS8uH8gIGA5PxkjKpORLSuHIP5BLZukr0THZKs3G
         5Nm1OykFnGrnmPrHz7yxJJ6AVGs9/KAytQWCiIL0EfMTqUHVKEUYKj+dTVGGkUhUF1H2
         04Tg==
X-Gm-Message-State: APjAAAUyJtYdPHOZ8VCrpQFg6g6s4CzQUIGiJxcH4WAsCh4dLWBl7YPJ
	TvbBbmJLRIGVWJ+PovSclyeA0xzmU+v0Sj+q+feYg4LKD9RTYaOMQzYSjpg+rsmVcC5XnKzKo1S
	atK6n3LSwujkS6Ti1YJ1vnwokpBo40OBdciwzi9l9NZEAZqJ6IrXjjji6JPHbX1LQ0w==
X-Received: by 2002:a17:90a:bb0c:: with SMTP id u12mr1130829pjr.132.1564699241464;
        Thu, 01 Aug 2019 15:40:41 -0700 (PDT)
X-Received: by 2002:a17:90a:bb0c:: with SMTP id u12mr1130782pjr.132.1564699240484;
        Thu, 01 Aug 2019 15:40:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564699240; cv=none;
        d=google.com; s=arc-20160816;
        b=MysqeWin82rzzAUKmg118NyU7rA5KxpSRUolv6NGinkMVnoM7IE8wrf2RsAm935JUl
         1FNjbzUSRK+3bbtrdc++YZyNn0M5LQ05OFY7GUnHfUHHjHFrOONYaFS9oVESx/gfH6TG
         jugVAax/EwD9NcBwosmTMr4yeHWcupJYw0lk33YW07lcOI0o+aZSl5StcOTtZdtc7lbe
         9n7Pz3zCDqKOEa4TBvficLcHdmPzAJvKEo2BBignGQPA/JvCiiZBGuqX2MEqKQkuLeYD
         V4UHD2vbmJT4/PhaVrGCIDy04Gmt7hfdfrRcbTKTRlUF5qWm+7QRurIGsZtn7BujB635
         P6PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=3HK7s8V9oToEwvd+cxmNBKqtwxYR1WNQK7rC8iWKNTA=;
        b=aXE4a34qRi4F+xS5xGvIjLgZA7DRhas21ofRvBxpDtc7GVWQCJeyIomCGcwhaQ4Ruw
         e5MdARfp0qrtyZUeuqt6mRXb+NkaOPtXqYmJDAliSIeBfh8zOefnMMTrV/GXV+zYc4Nh
         9E2ZVi44KEI+yh7fGYFf++mWJxAiMin+qZmQ6XlpBfxO2S95q3RbfevKLJFznObiSKOV
         dkbOdeJC5FRMO5eAHbDe36nyI2vUCma8ftmkMA0Uaa8+9oo9EtPqh2BEB/USFNngH5S7
         bTtfVJvck5QaVZD5MvkY6rAG/A0yRXJvke+xmSxgxHUBbTmw19Eq8buwuLynFmEsqn9V
         nZRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PBkxxqkq;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id go5sor87493257plb.37.2019.08.01.15.40.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 15:40:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=PBkxxqkq;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=3HK7s8V9oToEwvd+cxmNBKqtwxYR1WNQK7rC8iWKNTA=;
        b=PBkxxqkqhBjreAGB6z65259PHXpXjbB56D8LK6aUxC7WTe13WXQdOe0JObkGOxskaY
         uTAP+faUrKTLju60cWzKXlLRa4lAfZ7cGp7ygvI0Me5wvqZWEIb8xvtDdfQwsENAMttT
         p+sJhwkiTsZmw96ZOJIVXbMCFA7esE1vv6Y8e52MmBooVoM8hmu5Oiv5yVTPicdTZol3
         n+kslX7MyBeVvweojm/SWb1w4/geiOAkZkTUH1y7yiZADHuOFHzSnwiWhO6Pia/Q8wzw
         Lee8l4ZormBvYtwwkuX6m2S5YxqvoAZ4Mb9gtYAPYFR0D0pEOFeeT4wS2drToOZk8mBT
         WogA==
X-Google-Smtp-Source: APXvYqwoJCZIGbIQViC2MjQjTd24MGg+1FLC/h9IvYji19WP/MLyZg4rQys/cq+3O0XAf28YLIapHQ==
X-Received: by 2002:a17:902:fa2:: with SMTP id 31mr130436244plz.38.1564699239933;
        Thu, 01 Aug 2019 15:40:39 -0700 (PDT)
Received: from localhost.localdomain (50-39-177-61.bvtn.or.frontiernet.net. [50.39.177.61])
        by smtp.gmail.com with ESMTPSA id l31sm114821655pgm.63.2019.08.01.15.40.39
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 15:40:39 -0700 (PDT)
Subject: [PATCH v3 6/6] virtio-balloon: Add support for providing unused
 page reports to host
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 akpm@linux-foundation.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, willy@infradead.org, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, pbonzini@redhat.com,
 dan.j.williams@intel.com, alexander.h.duyck@linux.intel.com
Date: Thu, 01 Aug 2019 15:38:29 -0700
Message-ID: <20190801223829.22190.36831.stgit@localhost.localdomain>
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

Add support for the page reporting feature provided by virtio-balloon.
Reporting differs from the regular balloon functionality in that is is
much less durable than a standard memory balloon. Instead of creating a
list of pages that cannot be accessed the pages are only inaccessible
while they are being indicated to the virtio interface. Once the
interface has acknowledged them they are placed back into their respective
free lists and are once again accessible by the guest system.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/Kconfig              |    1 +
 drivers/virtio/virtio_balloon.c     |   56 +++++++++++++++++++++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 +
 3 files changed, 58 insertions(+)

diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index 078615cf2afc..4b2dd8259ff5 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -58,6 +58,7 @@ config VIRTIO_BALLOON
 	tristate "Virtio balloon driver"
 	depends on VIRTIO
 	select MEMORY_BALLOON
+	select PAGE_REPORTING
 	---help---
 	 This driver supports increasing and decreasing the amount
 	 of memory within a KVM guest.
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 2c19457ab573..971fe924e34f 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -19,6 +19,7 @@
 #include <linux/mount.h>
 #include <linux/magic.h>
 #include <linux/pseudo_fs.h>
+#include <linux/page_reporting.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -37,6 +38,9 @@
 #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
 	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
 
+/*  limit on the number of pages that can be on the reporting vq */
+#define VIRTIO_BALLOON_VRING_HINTS_MAX	16
+
 #ifdef CONFIG_BALLOON_COMPACTION
 static struct vfsmount *balloon_mnt;
 #endif
@@ -46,6 +50,7 @@ enum virtio_balloon_vq {
 	VIRTIO_BALLOON_VQ_DEFLATE,
 	VIRTIO_BALLOON_VQ_STATS,
 	VIRTIO_BALLOON_VQ_FREE_PAGE,
+	VIRTIO_BALLOON_VQ_REPORTING,
 	VIRTIO_BALLOON_VQ_MAX
 };
 
@@ -113,6 +118,10 @@ struct virtio_balloon {
 
 	/* To register a shrinker to shrink memory upon memory pressure */
 	struct shrinker shrinker;
+
+	/* Unused page reporting device */
+	struct virtqueue *reporting_vq;
+	struct page_reporting_dev_info ph_dev_info;
 };
 
 static struct virtio_device_id id_table[] = {
@@ -152,6 +161,23 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 
 }
 
+void virtballoon_unused_page_report(struct page_reporting_dev_info *ph_dev_info,
+				    unsigned int nents)
+{
+	struct virtio_balloon *vb =
+		container_of(ph_dev_info, struct virtio_balloon, ph_dev_info);
+	struct virtqueue *vq = vb->reporting_vq;
+	unsigned int unused;
+
+	/* We should always be able to add these buffers to an empty queue. */
+	virtqueue_add_inbuf(vq, ph_dev_info->sg, nents, vb,
+			    GFP_NOWAIT | __GFP_NOWARN);
+	virtqueue_kick(vq);
+
+	/* When host has read buffer, this completes via balloon_ack */
+	wait_event(vb->acked, virtqueue_get_buf(vq, &unused));
+}
+
 static void set_page_pfns(struct virtio_balloon *vb,
 			  __virtio32 pfns[], struct page *page)
 {
@@ -476,6 +502,7 @@ static int init_vqs(struct virtio_balloon *vb)
 	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
 	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
 	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
+	names[VIRTIO_BALLOON_VQ_REPORTING] = NULL;
 
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
@@ -487,11 +514,19 @@ static int init_vqs(struct virtio_balloon *vb)
 		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
 	}
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
+		names[VIRTIO_BALLOON_VQ_REPORTING] = "reporting_vq";
+		callbacks[VIRTIO_BALLOON_VQ_REPORTING] = balloon_ack;
+	}
+
 	err = vb->vdev->config->find_vqs(vb->vdev, VIRTIO_BALLOON_VQ_MAX,
 					 vqs, callbacks, names, NULL, NULL);
 	if (err)
 		return err;
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
+		vb->reporting_vq = vqs[VIRTIO_BALLOON_VQ_REPORTING];
+
 	vb->inflate_vq = vqs[VIRTIO_BALLOON_VQ_INFLATE];
 	vb->deflate_vq = vqs[VIRTIO_BALLOON_VQ_DEFLATE];
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
@@ -931,12 +966,30 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		if (err)
 			goto out_del_balloon_wq;
 	}
+
+	vb->ph_dev_info.report = virtballoon_unused_page_report;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING)) {
+		unsigned int capacity;
+
+		capacity = min_t(unsigned int,
+				 virtqueue_get_vring_size(vb->reporting_vq),
+				 VIRTIO_BALLOON_VRING_HINTS_MAX);
+		vb->ph_dev_info.capacity = capacity;
+
+		err = page_reporting_startup(&vb->ph_dev_info);
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
@@ -965,6 +1018,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_REPORTING))
+		page_reporting_shutdown(&vb->ph_dev_info);
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 		virtio_balloon_unregister_shrinker(vb);
 	spin_lock_irq(&vb->stop_update_lock);
@@ -1034,6 +1089,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 	VIRTIO_BALLOON_F_PAGE_POISON,
+	VIRTIO_BALLOON_F_REPORTING,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index a1966cd7b677..19974392d324 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -36,6 +36,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_REPORTING	5 /* Page reporting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12

