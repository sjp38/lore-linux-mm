Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A486C28CC2
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA9A426212
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cbR7FE1z"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA9A426212
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5CA9E6B027B; Thu, 30 May 2019 17:54:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 57ACC6B027C; Thu, 30 May 2019 17:54:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4427C6B027D; Thu, 30 May 2019 17:54:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 15F976B027B
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:52 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l12so2762413oii.10
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=/mUEYZKWYYcL2BHkb0DxPuaatZyzvoF9cSukuFqsj94=;
        b=nazV7d+winARXY+0pE/IdIoMmKZHP5OEYZNw9qx7Vk7Ebezy/taqwguezmujH2WpNS
         /B6t94vZFUgWdKLa3/nQ35BudOVRFscnbWizSdkRJUTTOO35J/IaNrmu8XFk1pHy0xpH
         eZbUIL2ofjiti3tiChn7tMYV3017q7BOhhi/GpzEDhEHTco4omELhHQVekFF0IXCmDoW
         Cd0iThBd54IojCK1+dCIIa5lRvIbcbGMrA0oCLLPmX+XyTMNZC1J0rgOcsPnjsKlWCLj
         ds4BUurrn3qDbcOAtjyyJtSRZHEcq1mD96vpgwe5i1dlwYaR3GJcNrITotMcQxYw/Gbl
         IuHw==
X-Gm-Message-State: APjAAAVjqDeZjRSrcnOEfH2mr3/9Yavs4qa8h/EwPssvtqISXKYfHmV/
	wmNYT6ZcZLYp0OG8aJyHDqlgoHneh8oa5s4RraCV0VsmEqeexMaERZVqFcP3saUCXsfz6uXJVB/
	1ol5UeJ87za9RnaDCLJExjaTAy5EKUVPTi2ldIb+6hilXKmHBrCMiYo+SkLLH4ePIxA==
X-Received: by 2002:a05:6830:209a:: with SMTP id y26mr4514099otq.232.1559253291777;
        Thu, 30 May 2019 14:54:51 -0700 (PDT)
X-Received: by 2002:a05:6830:209a:: with SMTP id y26mr4514055otq.232.1559253290981;
        Thu, 30 May 2019 14:54:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253290; cv=none;
        d=google.com; s=arc-20160816;
        b=IJcN+JAWy7DjKC4V3pwTMnA0pmBSmYxnoLLap7Khxc1eKSOpl0OYgPNY9V2FyAiIMH
         Q1ahMc8/TZrDW2PhuuYEAdQYigaKJxVeD7yLt03rOTt01ThZoPzLEt4asRG+w6E6Nb+Q
         zghWRXSy1bcFsLwKgJRfL3r9Hpr1WzMsVU4drJqMO+3zVU08yMoZjp4wSnje0S+dnSM7
         2udTyjVulp4FlMu2/YsSvSRVkLjln7yPXeHFcDkfFmnu07BRkUW97fC8u7r9sJ6Vpp2V
         M4MtXj+gzPPXT9ACgtpkNa1rW/oDcybsy/218GN38DjQB6rn7EH4+GZqN6m6Uvh3wnwJ
         HUzA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=/mUEYZKWYYcL2BHkb0DxPuaatZyzvoF9cSukuFqsj94=;
        b=NjyUFFEo4S2qPqlv/51+QZcWR0nF2sdnYfT+92of0pHW+bmfe/cCh6dCrgDH7swZUj
         ld7PCSKVdEeHOLO+9LLmplyZYkfo5vJyNocbEpCAP7klRKR4oz7b2aVyT38eQ9zNExGo
         kcAuK5bPB+zbME6+hvONTgFOXJYmkQdtKKGHLn4VU7pZz4f3dxjjIhbQOg7Zi70qfkhL
         FlgJyVjl4/OhXOa8E5PIdqdHIv/eGBRBU4uhBJV6Wf4uLWqHc+vtwNxsf3fEVKUCu096
         Gxn/0t8zIk11lcC8Ie8D3+KuOe+h9nLJD6UKHz9t783Pli7+KyEyTgw7rbweO6TVdBb3
         q9Gw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cbR7FE1z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p29sor1981499otf.15.2019.05.30.14.54.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:54:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=cbR7FE1z;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=/mUEYZKWYYcL2BHkb0DxPuaatZyzvoF9cSukuFqsj94=;
        b=cbR7FE1zdTHh1NeELi13nyRj1xb4yqLhmeuGlEbyivkZsLIB39JafRdCTyWZW4ufux
         df2TuWOVTJwY0SaSOo7mkmtztkSdvUnXcqR/MeoOGe42k0iFfT4bBFCPz0bxyURY7TUZ
         bhRHulEaACfjcyPUPtgEkThh7MyjbEWB2YIPTIEBYQmeZqG53q+hLORM9WmGLoudMFdL
         om1G4JzlXwN33wwnyKo34fnqr5EGubW3LDFIsN26NjyHtyi8wXc2VgvmiU+I8gU1ck9p
         3SqhZ6xJNojk92m6bkbBN9LZm78eARhs3gL4w27+beyXfel6y7AYi/KV+k8A1EsqYxBS
         LlFA==
X-Google-Smtp-Source: APXvYqx01mVsNW6pIQK0hwBzQcE1nW+e4GzPg6f2gyQVuJls5woMO9c9GDOi7DlASV/rWA1A7XKMvA==
X-Received: by 2002:a9d:378b:: with SMTP id x11mr3987037otb.184.1559253290577;
        Thu, 30 May 2019 14:54:50 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id u8sm1544640otk.53.2019.05.30.14.54.48
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:54:50 -0700 (PDT)
Subject: [RFC PATCH 10/11] virtio-balloon: Add support for aerating memory
 via bubble hinting
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:54:48 -0700
Message-ID: <20190530215448.13974.59362.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
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

Add support for aerating memory using the bubble hinting feature provided
by virtio-balloon. Bubble hinting differs from the regular balloon
functionality in that is is much less durable than a standard memory
balloon. Instead of creating a list of pages that cannot be accessed the
pages are only inaccessible while they are being indicated to the virtio
interface. Once the interface has acknowledged them they are placed back
into their respective free lists and are once again accessible by the guest
system.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 drivers/virtio/Kconfig              |    1 
 drivers/virtio/virtio_balloon.c     |   89 +++++++++++++++++++++++++++++++++++
 include/uapi/linux/virtio_balloon.h |    1 
 3 files changed, 90 insertions(+), 1 deletion(-)

diff --git a/drivers/virtio/Kconfig b/drivers/virtio/Kconfig
index 023fc3bc01c6..9cdaccf92c3a 100644
--- a/drivers/virtio/Kconfig
+++ b/drivers/virtio/Kconfig
@@ -47,6 +47,7 @@ config VIRTIO_BALLOON
 	tristate "Virtio balloon driver"
 	depends on VIRTIO
 	select MEMORY_BALLOON
+	select AERATION
 	---help---
 	 This driver supports increasing and decreasing the amount
 	 of memory within a KVM guest.
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 44339fc87cc7..e1399991bc1f 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -18,6 +18,7 @@
 #include <linux/mm.h>
 #include <linux/mount.h>
 #include <linux/magic.h>
+#include <linux/memory_aeration.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -45,6 +46,7 @@ enum virtio_balloon_vq {
 	VIRTIO_BALLOON_VQ_DEFLATE,
 	VIRTIO_BALLOON_VQ_STATS,
 	VIRTIO_BALLOON_VQ_FREE_PAGE,
+	VIRTIO_BALLOON_VQ_HINTING,
 	VIRTIO_BALLOON_VQ_MAX
 };
 
@@ -52,9 +54,16 @@ enum virtio_balloon_config_read {
 	VIRTIO_BALLOON_CONFIG_READ_CMD_ID = 0,
 };
 
+#define VIRTIO_BUBBLE_ARRAY_HINTS_MAX	32
+struct virtio_bubble_page_hint {
+	__virtio32 pfn;
+	__virtio32 size;
+};
+
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
+								*hinting_vq;
 
 	/* Balloon's own wq for cpu-intensive work items */
 	struct workqueue_struct *balloon_wq;
@@ -107,6 +116,11 @@ struct virtio_balloon {
 	unsigned int num_pfns;
 	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
 
+	/* The array of PFNs we are hinting on */
+	unsigned int num_hints;
+	struct virtio_bubble_page_hint hints[VIRTIO_BUBBLE_ARRAY_HINTS_MAX];
+	struct aerator_dev_info a_dev_info;
+
 	/* Memory statistics */
 	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
 
@@ -151,6 +165,54 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 
 }
 
+void virtballoon_aerator_react(struct aerator_dev_info *a_dev_info)
+{
+	struct virtio_balloon *vb = container_of(a_dev_info,
+						struct virtio_balloon,
+						a_dev_info);
+	struct virtqueue *vq = vb->hinting_vq;
+	struct scatterlist sg;
+	unsigned int unused;
+	struct page *page;
+
+	vb->num_hints = 0;
+
+	list_for_each_entry(page, &a_dev_info->batch_reactor, lru) {
+		struct virtio_bubble_page_hint *hint;
+		unsigned int size;
+
+		hint = &vb->hints[vb->num_hints++];
+		hint->pfn = cpu_to_virtio32(vb->vdev,
+					    page_to_balloon_pfn(page));
+		size = VIRTIO_BALLOON_PAGES_PER_PAGE << page_private(page);
+		hint->size = cpu_to_virtio32(vb->vdev, size);
+	}
+
+	/* We shouldn't have been called if there is nothing to process */
+	if (WARN_ON(vb->num_hints == 0))
+		return;
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	sg_init_one(&sg, vb->hints,
+		    sizeof(vb->hints[0]) * vb->num_hints);
+
+	/*
+	 * We should always be able to add one buffer to an
+	 * empty queue.
+	 */
+	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
+	virtqueue_kick(vq);
+}
+
+static void aerator_settled(struct virtqueue *vq)
+{
+	/* Drain the current aerator contents, refill, and start next cycle */
+	aerator_cycle();
+}
+
 static void set_page_pfns(struct virtio_balloon *vb,
 			  __virtio32 pfns[], struct page *page)
 {
@@ -475,6 +537,7 @@ static int init_vqs(struct virtio_balloon *vb)
 	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
 	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
 	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
+	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
 
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
@@ -486,11 +549,19 @@ static int init_vqs(struct virtio_balloon *vb)
 		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
 	}
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
+		callbacks[VIRTIO_BALLOON_VQ_HINTING] = aerator_settled;
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
@@ -929,12 +1000,25 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		if (err)
 			goto out_del_balloon_wq;
 	}
+
+	vb->a_dev_info.react = virtballoon_aerator_react;
+	vb->a_dev_info.capacity = VIRTIO_BUBBLE_ARRAY_HINTS_MAX;
+	INIT_LIST_HEAD(&vb->a_dev_info.batch_reactor);
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		err = aerator_startup(&vb->a_dev_info);
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
@@ -963,6 +1047,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
+		aerator_shutdown();
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 		virtio_balloon_unregister_shrinker(vb);
 	spin_lock_irq(&vb->stop_update_lock);
@@ -1032,6 +1118,7 @@ static int virtballoon_validate(struct virtio_device *vdev)
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

