Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C7A19C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8443720663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:51:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8443720663
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D23E58E0016; Wed,  6 Mar 2019 10:51:33 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD3F48E0002; Wed,  6 Mar 2019 10:51:33 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BE9DB8E0016; Wed,  6 Mar 2019 10:51:33 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9864F8E0002
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:33 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b40so11944223qte.1
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to
         :subject:date:message-id:in-reply-to:references;
        bh=MTISLY++cJpy++1Y25bwY/90Kxy/5fYxVtCkkdd/HMY=;
        b=gVXNBw063k0PGY1JePWC4zXyOmj8Z241n6ovRFWcKhwDUrIYHOmVY2qDysXInaTSWs
         pMrD5bPRTeunj1TIgUz5xo463p8jrmeaj5qcumi1Mwx7a8rZtYk3sYyz4wuapuz8ofT1
         qjSQ3o5HGVc/VhAHrmBAoTJLqMCqVgxC8K/emvkWSnjlgLJSP1wxZidBjeZ9Ed/4v4ap
         Negamrfdtd9s9V/C3TiG4h4jfVekOMVggiv+9AVWtnzMXfBOrIeuBl/hBoMYX/Xu3Xc6
         pK8jb8wtQVGxxBoWKgF+DuevUowYdM9Mm/73+0kakaelAUk3I/Km5mel1V8DSQndu3K6
         l8WQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXSwmfmpuvViAOOHroRNVOUZtJVNqPH3F6UuNOKL1/tZalj3K7j
	gb/rUHKTdaPM/lY+UUrYFICmOtVG3+k9JC9pophMD/4Ei7tapAu3LbwY7Kp+206/uJFNEsA45Ut
	qbuglrjyscATBzyX0C5/LJRIVrP/EZgmL72kPh9GrTw2Lgu8oL3536+BZDisScq+BRQ==
X-Received: by 2002:a0c:93ab:: with SMTP id f40mr6854401qvf.59.1551887493354;
        Wed, 06 Mar 2019 07:51:33 -0800 (PST)
X-Google-Smtp-Source: APXvYqz1iEQAN2BH2moxe9lhTXRD8WobFRYb+cv73xRi5icPumJQN7pcRC1o7XFjzKbXvyga24fH
X-Received: by 2002:a0c:93ab:: with SMTP id f40mr6854315qvf.59.1551887491923;
        Wed, 06 Mar 2019 07:51:31 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887491; cv=none;
        d=google.com; s=arc-20160816;
        b=y16NDm/NNQgRYrb7fgpLoEL7UlBulG3riPrZ3tUlyKRFw/dH0vzuld8lNlOv01k5Kw
         VVFS7wjoyQdHNPyob8w21LXzTew8K4fia8zPi+DQsPX7k3CXjIvd320fr4CzQDF0q/16
         lAM5x3CvUOAXP7onNb9mELkLm1/+TXC8FPnvVOIT86MWCx9Fsomaimk09A7cSJ5M+jLZ
         PAsjmh+R80t82L1rWTBwJ9ubBX86dXtkdLuZNFnkai/pQX38prO6b/HO2Qc+P7aBkBHC
         pBn8QQg5NjyRr0MJLJK+uJ/QWUnu3C5o95LG/Q6BMh/2JovKTpwOYW1dqaHDtT/klro5
         WNcw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:to:from;
        bh=MTISLY++cJpy++1Y25bwY/90Kxy/5fYxVtCkkdd/HMY=;
        b=WTTFCXEvVWKbUTfZVVzPWEyFfU0/iGlEwLLC6If54Cx5dTz+BeYMXExfLutQzmbjze
         cFSA7sujcrQ0DFOshtB1QD95+RG2ukFLr5FjXM/PbW1rVvebmCAMZDtSo1AiuFEGFj15
         tzKOioLjBHwQ8OmhY3c5WS/swr0Tk2Qxkc+rNaZL7BmKCBRkfyUmK2m7/k9w6JtcXFDs
         FmzQvrd73A/e23PU+tYS4YOxasDqEw5ACCnbPg86QG4wtFtDcUnBANSJ+0/cZ+OGQdiG
         hKxtGCE+JePeASzc7+UzvXcCNkifYh5HjE5YOD3jl9hVIzy6R4dAE9EhBmEf0+SujOLR
         55tg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s7si1147297qtk.82.2019.03.06.07.51.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 06 Mar 2019 07:51:31 -0800 (PST)
Received-SPF: pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of nitesh@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=nitesh@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 107853087BAE;
	Wed,  6 Mar 2019 15:51:31 +0000 (UTC)
Received: from virtlab420.virt.lab.eng.bos.redhat.com (virtlab420.virt.lab.eng.bos.redhat.com [10.19.152.148])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A01901001E60;
	Wed,  6 Mar 2019 15:51:26 +0000 (UTC)
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
Subject: [RFC][Patch v9 5/6] KVM: Enabling guest free page hinting via static key
Date: Wed,  6 Mar 2019 10:50:47 -0500
Message-Id: <20190306155048.12868-6-nitesh@redhat.com>
In-Reply-To: <20190306155048.12868-1-nitesh@redhat.com>
References: <20190306155048.12868-1-nitesh@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 06 Mar 2019 15:51:31 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch enables the guest free page hinting support
to enable or disable based on the STATIC key which
could be set via sysctl.

Signed-off-by: Nitesh Narayan Lal <nitesh@redhat.com>
---
 Documentation/sysctl/vm.txt     | 12 ++++++++++++
 drivers/virtio/virtio_balloon.c |  4 ++++
 include/linux/page_hinting.h    |  5 +++++
 kernel/sysctl.c                 | 12 ++++++++++++
 virt/kvm/page_hinting.c         | 26 ++++++++++++++++++++++++++
 5 files changed, 59 insertions(+)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 187ce4f599a2..eae9180ea0aa 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -31,6 +31,7 @@ Currently, these files are in /proc/sys/vm:
 - dirty_writeback_centisecs
 - drop_caches
 - extfrag_threshold
+- guest_free_page_hinting
 - hugetlb_shm_group
 - laptop_mode
 - legacy_va_layout
@@ -255,6 +256,17 @@ fragmentation index is <= extfrag_threshold. The default value is 500.
 
 ==============================================================
 
+guest_free_page_hinting
+
+This parameter enables the kernel to report KVM guest free pages to the host
+via virtio balloon driver. QEMU receives these free page hints and frees them
+by performing MADVISE_DONTNEED on it.
+
+It depends on VIRTIO_BALLOON for its functionality. In case VIRTIO_BALLOON
+driver is missing, this feature is disabled by default.
+
+==============================================================
+
 highmem_is_dirtyable
 
 Available only for systems with CONFIG_HIGHMEM enabled (32b systems).
diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index e82c72cd916b..171fd72ef2ae 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -164,12 +164,16 @@ static void hinting_ack(struct virtqueue *vq)
 
 static void enable_hinting(struct virtio_balloon *vb)
 {
+	guest_free_page_hinting_flag = 1;
+	static_branch_enable(&guest_free_page_hinting_key);
 	request_hypercall = (void *)&virtballoon_page_hinting;
 	balloon_ptr = vb;
 }
 
 static void disable_hinting(void)
 {
+	guest_free_page_hinting_flag = 0;
+	static_branch_enable(&guest_free_page_hinting_key);
 	balloon_ptr = NULL;
 }
 #endif
diff --git a/include/linux/page_hinting.h b/include/linux/page_hinting.h
index a32af8851081..60e0a21bfbe6 100644
--- a/include/linux/page_hinting.h
+++ b/include/linux/page_hinting.h
@@ -12,6 +12,8 @@
 #define FREE_PAGE_HINTING_MIN_ORDER	(MAX_ORDER - 1)
 
 extern void *balloon_ptr;
+extern int guest_free_page_hinting_flag;
+extern struct static_key_false guest_free_page_hinting_key;
 
 void guest_free_page_enqueue(struct page *page, int order);
 void guest_free_page_try_hinting(void);
@@ -22,3 +24,6 @@ extern void __free_one_page(struct page *page, unsigned long pfn,
 void release_buddy_pages(void *obj_to_free, int entries);
 extern int (*request_hypercall)(void *balloon_ptr,
 				void *hinting_req, int entries);
+int guest_free_page_hinting_sysctl(struct ctl_table *table, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index ba4d9e85feb8..7b2970e9e937 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -96,6 +96,9 @@
 #ifdef CONFIG_LOCKUP_DETECTOR
 #include <linux/nmi.h>
 #endif
+#ifdef CONFIG_KVM_FREE_PAGE_HINTING
+#include <linux/page_hinting.h>
+#endif
 
 #if defined(CONFIG_SYSCTL)
 
@@ -1690,6 +1693,15 @@ static struct ctl_table vm_table[] = {
 		.extra1		= (void *)&mmap_rnd_compat_bits_min,
 		.extra2		= (void *)&mmap_rnd_compat_bits_max,
 	},
+#endif
+#ifdef CONFIG_KVM_FREE_PAGE_HINTING
+	{
+		.procname       = "guest-free-page-hinting",
+		.data           = &guest_free_page_hinting_flag,
+		.maxlen         = sizeof(guest_free_page_hinting_flag),
+		.mode           = 0644,
+		.proc_handler   = guest_free_page_hinting_sysctl,
+	},
 #endif
 	{ }
 };
diff --git a/virt/kvm/page_hinting.c b/virt/kvm/page_hinting.c
index eb0c0ddfe990..5980682e0b86 100644
--- a/virt/kvm/page_hinting.c
+++ b/virt/kvm/page_hinting.c
@@ -36,6 +36,28 @@ EXPORT_SYMBOL(request_hypercall);
 void *balloon_ptr;
 EXPORT_SYMBOL(balloon_ptr);
 
+struct static_key_false guest_free_page_hinting_key  = STATIC_KEY_FALSE_INIT;
+EXPORT_SYMBOL(guest_free_page_hinting_key);
+static DEFINE_MUTEX(hinting_mutex);
+int guest_free_page_hinting_flag;
+EXPORT_SYMBOL(guest_free_page_hinting_flag);
+
+int guest_free_page_hinting_sysctl(struct ctl_table *table, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos)
+{
+	int ret;
+
+	mutex_lock(&hinting_mutex);
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (guest_free_page_hinting_flag)
+		static_key_enable(&guest_free_page_hinting_key.key);
+	else
+		static_key_disable(&guest_free_page_hinting_key.key);
+	mutex_unlock(&hinting_mutex);
+	return ret;
+}
+
 void release_buddy_pages(void *hinting_req, int entries)
 {
 	int i = 0;
@@ -223,6 +245,8 @@ void guest_free_page_enqueue(struct page *page, int order)
 	struct guest_free_pages *hinting_obj;
 	int l_idx;
 
+	if (!static_branch_unlikely(&guest_free_page_hinting_key))
+		return;
 	/*
 	 * use of global variables may trigger a race condition between irq and
 	 * process context causing unwanted overwrites. This will be replaced
@@ -258,6 +282,8 @@ void guest_free_page_try_hinting(void)
 {
 	struct guest_free_pages *hinting_obj;
 
+	if (!static_branch_unlikely(&guest_free_page_hinting_key))
+		return;
 	hinting_obj = this_cpu_ptr(&free_pages_obj);
 	if (hinting_obj->free_pages_idx >= HINTING_THRESHOLD)
 		guest_free_page_hinting();
-- 
2.17.2

