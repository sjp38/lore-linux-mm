Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2E6DFC28CC6
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:04:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DC7E9274B0
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 17:04:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DC7E9274B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 862F56B0284; Mon,  3 Jun 2019 13:04:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EC0F6B0286; Mon,  3 Jun 2019 13:04:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 666A46B0287; Mon,  3 Jun 2019 13:04:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3D4456B0284
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 13:04:17 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id 5so5452507oix.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 10:04:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iAVJ7RlF1BhJM+W0IG8SEOeAkDoHCeR7KzJbXzqzq0Y=;
        b=RWWB6DIX1tWTJAUbuh5jAGB5OIhqTvWo1XJQkOnfm16UbpjisGAELETZjS4cfGtUXB
         HEzDJVAO7Mi3iE/7XZGGN+xuRMJIwEEnXeJAKTi5ZdZPZruXhJu8ly1pDAUDXUSaovmO
         jAsK9HnV+yi0T2xeGnIfB+G3YqosJ6PxlABFnuDw4Qgt5XmE8c/3ikvNSJPtGbX+Pth3
         XTZAV4eIghcSHQSL8Ja0H5H2ZHK88a2EmsYRJ/thwQ3NKom2t3IuuOuhaRVPIJ/xWYLm
         ycZfDnvQUIhc3ON5kbcbtE0RYAt50Kw3dekPu0ZLdpKSDxhGb5jhIerPLan8fetAzzYd
         dkEQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWj07HIHgucj5U+WlP8yOZNq3q97118mSZR2Ty4nsWsJXeurmzw
	S+aU2nE5Nz5IfT19Q0VnfOiaHuAvVQfDBFVz+Ap9rs2rGQtkKYTXDh+ttlARaTkz1TVX9K1KoM1
	Sw9Z+vW+vx2yFQWH0XNJ1V/ySW2DlpHdvvxxBVcmKpA0w1oLg31esKwTkZQLEPb1oow==
X-Received: by 2002:aca:5c1:: with SMTP id 184mr145158oif.92.1559581456901;
        Mon, 03 Jun 2019 10:04:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzj/X/IfNJV4QM3lLQQqvqH8rwIOLfr8uM2K0b3eaGnJqBDho7vKvsRlZGne0EgiKQcEi0Y
X-Received: by 2002:aca:5c1:: with SMTP id 184mr145095oif.92.1559581456031;
        Mon, 03 Jun 2019 10:04:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559581456; cv=none;
        d=google.com; s=arc-20160816;
        b=KPbyuZ4BaIVPpzo54L6HNRESCJOZxNTvsTJ1aFs5Qw+AXDvqsRXK9Mrqnox+ScPFyf
         eueK1k/PNITLJeA2dTLYo03RNNK6DjdZ7CJfoeaZ0exOqTKGXiwMg43hypHHIObT/LyS
         kNb3pdPfWwHMjcq4DwyTrz9YC7wHxFiajrX3Z3qtr1UFbFR/5b9URw+/7hADJuPIndGn
         qAuiGVITrrXDva9uqvG6e7eVTl2LLftdobInpk27x8C32Stq09+sUzXfwMQld2z4OoDm
         KtJxX/TiiX5K14NenU6Zz0JjUVliWiX1L+M6otUUtcGRR8rF8KS0yv5xFo/VlZQB0GxQ
         idlw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from;
        bh=iAVJ7RlF1BhJM+W0IG8SEOeAkDoHCeR7KzJbXzqzq0Y=;
        b=H4LS8pJs3hr5BcYMiIC0cHlrDjPAjgKa9YcoujHsc9T0+rUENyE2zs5n5axlqspUjB
         8Snf40sdc7uYSu+4Q7ncXl7lG73wGgkEYapI3AtyPwcYXACSKRY0A0neq+HRhfz6az1U
         psJtMR0oa3pjL1+v5Ikh8LYp9YC8Re1CE3OpLkM9FiQcKL6SjS5KrAUTabXrLXF6+kNI
         p7lukAXf+VnN5jwkuMQX2BnXsjocF/CK7pH+Jv6vT3yysWLlseUz7WLxFlJnQ9Wkfuz3
         wYvHnGmng0fO1SBB9NBHH26iLnjliUvBE3kFhlAfi4fjsA4c4pFwPm141kMsmIBfRerF
         g9MQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m30si9042128otj.199.2019.06.03.10.04.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 10:04:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E3EA481E0C;
	Mon,  3 Jun 2019 17:04:14 +0000 (UTC)
Received: from virtlab512.virt.lab.eng.bos.redhat.com (virtlab512.virt.lab.eng.bos.redhat.com [10.19.152.206])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 4410761983;
	Mon,  3 Jun 2019 17:04:07 +0000 (UTC)
From: Nitesh Narayan Lal <nitesh@redhat.com>
To: kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	pbonzini@redhat.com,
	lcapitulino@redhat.com,
	pagupta@redhat.com,
	wei.w.wang@intel.com,
	yang.zhang.wz@gmail.com,
	riel@surriel.com,
	david@redhat.com,
	mst@redhat.com,
	dodgen@google.com,
	konrad.wilk@oracle.com,
	dhildenb@redhat.com,
	aarcange@redhat.com,
	alexander.duyck@gmail.com
Subject: [RFC][Patch v10 2/2] virtio-balloon: page_hinting: reporting to the host
Date: Mon,  3 Jun 2019 13:03:06 -0400
Message-Id: <20190603170306.49099-3-nitesh@redhat.com>
In-Reply-To: <20190603170306.49099-1-nitesh@redhat.com>
References: <20190603170306.49099-1-nitesh@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.12
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Mon, 03 Jun 2019 17:04:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Enables the kernel to negotiate VIRTIO_BALLOON_F_HINTING feature with the
host. If it is available and page_hinting_flag is set to true, page_hinting
is enabled and its callbacks are configured along with the max_pages count
which indicates the maximum number of pages that can be isolated and hinted
at a time. Currently, only free pages of order >= (MAX_ORDER - 2) are
reported. To prevent any false OOM max_pages count is set to 16.

By default page_hinting feature is enabled and gets loaded as soon
as the virtio-balloon driver is loaded. However, it could be disabled
by writing the page_hinting_flag which is a virtio-balloon parameter.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 drivers/virtio/virtio_balloon.c     | 112 +++++++++++++++++++++++++++-
 include/uapi/linux/virtio_balloon.h |  14 ++++
 2 files changed, 125 insertions(+), 1 deletion(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f19061b585a4..40f09ea31643 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -31,6 +31,7 @@
 #include <linux/mm.h>
 #include <linux/mount.h>
 #include <linux/magic.h>
+#include <linux/page_hinting.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -48,6 +49,7 @@
 /* The size of a free page block in bytes */
 #define VIRTIO_BALLOON_FREE_PAGE_SIZE \
 	(1 << (VIRTIO_BALLOON_FREE_PAGE_ORDER + PAGE_SHIFT))
+#define VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES	16
 
 #ifdef CONFIG_BALLOON_COMPACTION
 static struct vfsmount *balloon_mnt;
@@ -58,6 +60,7 @@ enum virtio_balloon_vq {
 	VIRTIO_BALLOON_VQ_DEFLATE,
 	VIRTIO_BALLOON_VQ_STATS,
 	VIRTIO_BALLOON_VQ_FREE_PAGE,
+	VIRTIO_BALLOON_VQ_HINTING,
 	VIRTIO_BALLOON_VQ_MAX
 };
 
@@ -67,7 +70,8 @@ enum virtio_balloon_config_read {
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
+			 *hinting_vq;
 
 	/* Balloon's own wq for cpu-intensive work items */
 	struct workqueue_struct *balloon_wq;
@@ -125,6 +129,9 @@ struct virtio_balloon {
 
 	/* To register a shrinker to shrink memory upon memory pressure */
 	struct shrinker shrinker;
+
+	/* object pointing at the array of isolated pages ready for hinting */
+	struct hinting_data *hinting_arr;
 };
 
 static struct virtio_device_id id_table[] = {
@@ -132,6 +139,85 @@ static struct virtio_device_id id_table[] = {
 	{ 0 },
 };
 
+#ifdef CONFIG_PAGE_HINTING
+struct virtio_balloon *hvb;
+bool page_hinting_flag = true;
+module_param(page_hinting_flag, bool, 0444);
+MODULE_PARM_DESC(page_hinting_flag, "Enable page hinting");
+
+static bool virtqueue_kick_sync(struct virtqueue *vq)
+{
+	u32 len;
+
+	if (likely(virtqueue_kick(vq))) {
+		while (!virtqueue_get_buf(vq, &len) &&
+		       !virtqueue_is_broken(vq))
+			cpu_relax();
+		return true;
+	}
+	return false;
+}
+
+static void page_hinting_report(int entries)
+{
+	struct scatterlist sg;
+	struct virtqueue *vq = hvb->hinting_vq;
+	int err = 0;
+	struct hinting_data *hint_req;
+	u64 gpaddr;
+
+	hint_req = kmalloc(sizeof(*hint_req), GFP_KERNEL);
+	if (!hint_req)
+		return;
+	gpaddr = virt_to_phys(hvb->hinting_arr);
+	hint_req->phys_addr = cpu_to_virtio64(hvb->vdev, gpaddr);
+	hint_req->size = cpu_to_virtio32(hvb->vdev, entries);
+	sg_init_one(&sg, hint_req, sizeof(*hint_req));
+	err = virtqueue_add_outbuf(vq, &sg, 1, hint_req, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick_sync(hvb->hinting_vq);
+
+	kfree(hint_req);
+}
+
+int page_hinting_prepare(void)
+{
+	hvb->hinting_arr = kmalloc_array(VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES,
+					 sizeof(*hvb->hinting_arr), GFP_KERNEL);
+	if (!hvb->hinting_arr)
+		return -ENOMEM;
+	return 0;
+}
+
+void hint_pages(struct list_head *pages)
+{
+	struct page *page, *next;
+	unsigned long pfn;
+	int idx = 0, order;
+
+	list_for_each_entry_safe(page, next, pages, lru) {
+		pfn = page_to_pfn(page);
+		order = page_private(page);
+		hvb->hinting_arr[idx].phys_addr = pfn << PAGE_SHIFT;
+		hvb->hinting_arr[idx].size = (1 << order) * PAGE_SIZE;
+		idx++;
+	}
+	page_hinting_report(idx);
+}
+
+void page_hinting_cleanup(void)
+{
+	kfree(hvb->hinting_arr);
+}
+
+static const struct page_hinting_cb hcb = {
+	.prepare = page_hinting_prepare,
+	.hint_pages = hint_pages,
+	.cleanup = page_hinting_cleanup,
+	.max_pages = VIRTIO_BALLOON_PAGE_HINTING_MAX_PAGES,
+};
+#endif
+
 static u32 page_to_balloon_pfn(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
@@ -488,6 +574,7 @@ static int init_vqs(struct virtio_balloon *vb)
 	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
 	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
 	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
+	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
 
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
@@ -499,11 +586,18 @@ static int init_vqs(struct virtio_balloon *vb)
 		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
 	}
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
+		callbacks[VIRTIO_BALLOON_VQ_HINTING] = NULL;
+	}
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
@@ -942,6 +1036,14 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		if (err)
 			goto out_del_balloon_wq;
 	}
+
+#ifdef CONFIG_PAGE_HINTING
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING) &&
+	    page_hinting_flag) {
+		hvb = vb;
+		page_hinting_enable(&hcb);
+	}
+#endif
 	virtio_device_ready(vdev);
 
 	if (towards_target(vb))
@@ -989,6 +1091,12 @@ static void virtballoon_remove(struct virtio_device *vdev)
 		destroy_workqueue(vb->balloon_wq);
 	}
 
+#ifdef CONFIG_PAGE_HINTING
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		hvb = NULL;
+		page_hinting_disable();
+	}
+#endif
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
 	if (vb->vb_dev_info.inode)
@@ -1043,8 +1151,10 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_HINTING,
 	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 	VIRTIO_BALLOON_F_PAGE_POISON,
+	VIRTIO_BALLOON_F_HINTING,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index a1966cd7b677..25e4f817c660 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -29,6 +29,7 @@
 #include <linux/virtio_types.h>
 #include <linux/virtio_ids.h>
 #include <linux/virtio_config.h>
+#include <linux/page_hinting.h>
 
 /* The feature bitmap for virtio balloon */
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
@@ -36,6 +37,7 @@
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_FREE_PAGE_HINT	3 /* VQ to report free pages */
 #define VIRTIO_BALLOON_F_PAGE_POISON	4 /* Guest is using page poisoning */
+#define VIRTIO_BALLOON_F_HINTING	5 /* Page hinting virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -108,4 +110,16 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+#ifdef CONFIG_PAGE_HINTING
+/*
+ * struct hinting_data- holds the information associated with hinting.
+ * @phys_add:	physical address associated with a page or the array holding
+ *		the array of isolated pages.
+ * @size:	total size associated with the phys_addr.
+ */
+struct hinting_data {
+	__virtio64 phys_addr;
+	__virtio32 size;
+};
+#endif
 #endif /* _LINUX_VIRTIO_BALLOON_H */
-- 
2.21.0

