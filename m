Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F3111C10F00
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AFAD820663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AFAD820663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81C588E0010; Wed,  6 Mar 2019 10:51:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7CC108E0002; Wed,  6 Mar 2019 10:51:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E2248E0010; Wed,  6 Mar 2019 10:51:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 471CF8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:24 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id q15so10234191qki.14
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:24 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=SDAjsyepZLh/WZox/FRYNcXV19MUoD/4Bc1Xd7DSs80=;
        b=kflVS+woggRErKvrLrreCdiUfXiajwZBZrZKppaSp//KlxmK3NuAsdiD9bIXDm0Cik
         Yb4YRajJGNAlkmpk7YeTtwHtcATSZImlrLrRQqHA+Il4PSAkzTPWJb9cAGGES1NzlhsF
         4n1Q+UtRg3HAPkLBDoUYBwecPbfBODdHjnQAjUTyQuqXK8okWd6k2mn96nob+8XVqunL
         xMTZOK7lQvbbSLSpf0zs/devezXEvOcnBPcBcJ58WCrJgmha95KlV40Guqy9ZQ6NEW95
         dV8IZ5OG8j2VBY4Xb3lOiE6R+WvqgBB346JTfED2ORsj8P3p+2DSWSlbWw0p62/tUSa5
         lG+A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXG+NcY1ZzIqCDFQ9M6cgrISfTvF5UoGKl7itv9dVW6hSyD0Xp2
	fvU/yWTAMMosAfyPK3W/QsC85ndIKNLXlriarJURligWfK8QyVsRe5a8B6meWcAFf5wQgzexvw2
	0vMcM+RO7LGMUs1iiXI13slndAn11IgKTYuVWXMYIPALa9yqKv9QhzOpms3o5c1J+TQ==
X-Received: by 2002:ac8:354e:: with SMTP id z14mr6311197qtb.131.1551887484039;
        Wed, 06 Mar 2019 07:51:24 -0800 (PST)
X-Google-Smtp-Source: APXvYqytAXwmHRh/fweBXs7WJD/2jD1mDQ2lOv9c3bbRci/RsB9E7KvPiEg39oXY1XHE6tgXBhSx
X-Received: by 2002:ac8:354e:: with SMTP id z14mr6311101qtb.131.1551887482637;
        Wed, 06 Mar 2019 07:51:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887482; cv=none;
        d=google.com; s=arc-20160816;
        b=NGczrPDzdXiajXhS0aCa9j056soMxENqD6aTRiDZAyhoWvAk9ms4SfN5o/cInJxrJ8
         ehLe2kFtFmA8hcEq+2++2YiBeGUspk8JHNmB0jar0wuasX8qXnZsKB7IJ1HAhUsZGx85
         8sjPRhoGivsuErDZtsFp6QOuiIXpebetKnSnixfvwfwHhNkAS25VYXHCcoF5rRejRx+7
         PzvCm/RkEvdfLOLw1OPQ+t3rY8p2E0M2evqUOq8t6GaCJlJjlqBWLl2CNE1f8NrRqn60
         ZWtxOusLrYLnHDnRGG6vYJtJlWJ2gV2pz17nd4Mc3sm+jRwTzX2mT917e0gL7r2ywKl0
         M0sA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=SDAjsyepZLh/WZox/FRYNcXV19MUoD/4Bc1Xd7DSs80=;
        b=H92iy6w702tmADOpOFOV652eov1+4ayf7dwgCd4EYnIyEoGVsVxQqNbKKjHbP9Mt+T
         5aneesuJ+WAEW2EA81IuOmFNo/0QqYdDbluQc19aT1bUv9Ktq4/TpKJt7pwQwibMCHFB
         UElPQMqUHqRQnRFwie+ANmfVbfwts1/ZSjPGFffD43Mib0qufJqoplbjwCdmGe5u/6TR
         69BrmkYfe1hd4daLQxs7/6N4kA5AsNcbG4TTCd0tjiWzpiIhOoIP8+P1eXr0HaGc+Ol/
         iCqFxpzPQ7nOvCmBYVtPL+09wfPd/Gppj88ciWdZrqCi6D5VWMny/mNVQHFOGgg2O7GH
         3LOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id y23si887879qve.20.2019.03.06.07.51.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:22 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AA96A308FED5;
	Wed,  6 Mar 2019 15:51:21 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id F3D551001DCE;
	Wed,  6 Mar 2019 15:51:14 +0000 (UTC)
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
Subject: [RFC][Patch v9 3/6] KVM: Enables the kernel to report isolated pages
Date: Wed,  6 Mar 2019 10:50:45 -0500
Message-Id: <20190306155048.12868-4-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-1-nitesh@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Wed, 06 Mar 2019 15:51:21 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables the kernel to report the isolated pages
to the host via virtio balloon driver.
In order to do so a new virtuqeue (hinting_vq) is added to the
virtio balloon driver. As the host responds back after freeing
the pages, all the isolated pages are returned back to the buddy
via __free_one_page().

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 drivers/virtio/virtio_balloon.c     | 72 ++++++++++++++++++++++++++++-
 include/linux/page_hinting.h        |  4 ++
 include/uapi/linux/virtio_balloon.h |  8 ++++
 virt/kvm/page_hinting.c             | 18 ++++++--
 4 files changed, 98 insertions(+), 4 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 728ecd1eea30..cfe7574b5204 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -57,13 +57,15 @@ enum virtio_balloon_vq {
 	VIRTIO_BALLOON_VQ_INFLATE,
 	VIRTIO_BALLOON_VQ_DEFLATE,
 	VIRTIO_BALLOON_VQ_STATS,
+	VIRTIO_BALLOON_VQ_HINTING,
 	VIRTIO_BALLOON_VQ_FREE_PAGE,
 	VIRTIO_BALLOON_VQ_MAX
 };
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *free_page_vq,
+								*hinting_vq;
 
 	/* Balloon's own wq for cpu-intensive work items */
 	struct workqueue_struct *balloon_wq;
@@ -122,6 +124,56 @@ static struct virtio_device_id id_table[] = {
 	{ 0 },
 };
 
+#ifdef CONFIG_KVM_FREE_PAGE_HINTING
+int virtballoon_page_hinting(struct virtio_balloon *vb,
+			     void *hinting_req,
+			     int entries)
+{
+	struct scatterlist sg;
+	struct virtqueue *vq = vb->hinting_vq;
+	int err;
+	int unused;
+	struct virtio_balloon_hint_req *hint_req;
+	u64 gpaddr;
+
+	hint_req = kmalloc(sizeof(struct virtio_balloon_hint_req), GFP_KERNEL);
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	gpaddr = virt_to_phys(hinting_req);
+	hint_req->phys_addr = cpu_to_virtio64(vb->vdev, gpaddr);
+	hint_req->count = cpu_to_virtio32(vb->vdev, entries);
+	sg_init_one(&sg, hint_req, sizeof(struct virtio_balloon_hint_req));
+	err = virtqueue_add_outbuf(vq, &sg, 1, hint_req, GFP_KERNEL);
+	if (!err)
+		virtqueue_kick(vb->hinting_vq);
+	else
+		kfree(hint_req);
+	return err;
+}
+
+static void hinting_ack(struct virtqueue *vq)
+{
+	int len = sizeof(struct virtio_balloon_hint_req);
+	struct virtio_balloon_hint_req *hint_req = virtqueue_get_buf(vq, &len);
+	void *v_addr = phys_to_virt(hint_req->phys_addr);
+
+	release_buddy_pages(v_addr, hint_req->count);
+	kfree(hint_req);
+}
+
+static void enable_hinting(struct virtio_balloon *vb)
+{
+	request_hypercall = (void *)&virtballoon_page_hinting;
+	balloon_ptr = vb;
+}
+
+static void disable_hinting(void)
+{
+	balloon_ptr = NULL;
+}
+#endif
+
 static u32 page_to_balloon_pfn(struct page *page)
 {
 	unsigned long pfn = page_to_pfn(page);
@@ -481,6 +533,7 @@ static int init_vqs(struct virtio_balloon *vb)
 	names[VIRTIO_BALLOON_VQ_DEFLATE] = "deflate";
 	names[VIRTIO_BALLOON_VQ_STATS] = NULL;
 	names[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
+	names[VIRTIO_BALLOON_VQ_HINTING] = NULL;
 
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		names[VIRTIO_BALLOON_VQ_STATS] = "stats";
@@ -492,11 +545,18 @@ static int init_vqs(struct virtio_balloon *vb)
 		callbacks[VIRTIO_BALLOON_VQ_FREE_PAGE] = NULL;
 	}
 
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING)) {
+		names[VIRTIO_BALLOON_VQ_HINTING] = "hinting_vq";
+		callbacks[VIRTIO_BALLOON_VQ_HINTING] = hinting_ack;
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
@@ -908,6 +968,11 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		if (err)
 			goto out_del_balloon_wq;
 	}
+
+#ifdef CONFIG_KVM_FREE_PAGE_HINTING
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
+		enable_hinting(vb);
+#endif
 	virtio_device_ready(vdev);
 
 	if (towards_target(vb))
@@ -950,6 +1015,10 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
+#ifdef CONFIG_KVM_FREE_PAGE_HINTING
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HINTING))
+		disable_hinting();
+#endif
 	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_FREE_PAGE_HINT)) {
 		cancel_work_sync(&vb->report_free_page_work);
 		destroy_workqueue(vb->balloon_wq);
@@ -1009,6 +1078,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_HINTING,
 	VIRTIO_BALLOON_F_FREE_PAGE_HINT,
 	VIRTIO_BALLOON_F_PAGE_POISON,
 };
diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
index d554a2581826..a32af8851081 100644
--- a/include/linux/page_hinting.h
+++ b/include/linux/page_hinting.h
@@ -11,6 +11,8 @@
 #define HINTING_THRESHOLD	128
 #define FREE_PAGE_HINTING_MIN_ORDER	(MAX_ORDER - 1)
 
+extern void *balloon_ptr;
+
 void guest_free_page_enqueue(struct page *page, int order);
 void guest_free_page_try_hinting(void);
 extern int __isolate_free_page(struct page *page, unsigned int order);
@@ -18,3 +20,5 @@ extern void __free_one_page(struct page *page, unsigned long pfn,
 			    struct zone *zone, unsigned int order,
 			    int migratetype);
 void release_buddy_pages(void *obj_to_free, int entries);
+extern int (*request_hypercall)(void *balloon_ptr,
+				void *hinting_req, int entries);
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index a1966cd7b677..a7e909d77447 100644
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
@@ -108,4 +110,10 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+#ifdef CONFIG_KVM_FREE_PAGE_HINTING
+struct virtio_balloon_hint_req {
+	__virtio64 phys_addr;
+	__virtio64 count;
+};
+#endif
 #endif /* _LINUX_VIRTIO_BALLOON_H */
diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
index 9885b372b5a9..eb0c0ddfe990 100644
--- a/virt/kvm/page_hinting.c
+++ b/virt/kvm/page_hinting.c
@@ -31,11 +31,16 @@ struct guest_isolated_pages {
 	unsigned int order;
 };
 
-void release_buddy_pages(void *obj_to_free, int entries)
+int (*request_hypercall)(void *balloon_ptr, void *hinting_req, int entries);
+EXPORT_SYMBOL(request_hypercall);
+void *balloon_ptr;
+EXPORT_SYMBOL(balloon_ptr);
+
+void release_buddy_pages(void *hinting_req, int entries)
 {
 	int i = 0;
 	int mt = 0;
-	struct guest_isolated_pages *isolated_pages_obj = obj_to_free;
+	struct guest_isolated_pages *isolated_pages_obj = hinting_req;
 
 	while (i < entries) {
 		struct page *page = pfn_to_page(isolated_pages_obj[i].pfn);
@@ -51,7 +56,14 @@ void release_buddy_pages(void *obj_to_free, int entries)
 void guest_free_page_report(struct guest_isolated_pages *isolated_pages_obj,
 			    int entries)
 {
-	release_buddy_pages(isolated_pages_obj, entries);
+	int err = 0;
+
+	if (balloon_ptr) {
+		err = request_hypercall(balloon_ptr, isolated_pages_obj,
+					entries);
+		if (err)
+			release_buddy_pages(isolated_pages_obj, entries);
+	}
 }
 
 static int sort_zonenum(const void *a1, const void *b1)
-- 
2.17.2

