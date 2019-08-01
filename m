Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BEF1CC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 763C220665
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 15:24:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="H9kRmo9D"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 763C220665
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C9BE88E0027; Thu,  1 Aug 2019 11:24:50 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C24C58E0001; Thu,  1 Aug 2019 11:24:50 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AC9038E0027; Thu,  1 Aug 2019 11:24:50 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA588E0001
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 11:24:50 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id p34so65006957qtp.1
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 08:24:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id
         :in-reply-to:references:mime-version:content-transfer-encoding;
        bh=I9xocEcKfjedMKhCpMGCXOBDXpoq1e/vB1JDr9sXjKk=;
        b=L/oZl20Btaco9szurQ7W1uMXzqv6QHT8L6Kh1SX/71EVUBVyYCG/2pVKoAB0r5zdLV
         tUVEhV9SiD2uKiBap9UpA7s73PlE8EpofePv+Hifoys2fMdxVGS89j4ECJOCAC9lkJ1W
         6VaN3nwtemrDzJ+7/S+Zd/STVxefPeRlbx5106JhrjaUfuphEbBPBPlym2EIh25y8Y4S
         w3xPiWdLmQ4WsoWYfQsekgsC3cw01AypSTH0eyI3JEIFKDVeGxPzsHp6QzB380IAPLOn
         FwSJWCPwKrkHJFFPxkJxLNkm+7dSP7c2Th91w4HXoPi6J3pkJKFGbC2CkKKUbp8jlBs2
         cxnw==
X-Gm-Message-State: APjAAAWzetmJPcFHqBNiyqPZDeiHCFPHdEtEIvV1QWCHQOY9KVS+m3kT
	X2qPz8AAV3iCK0BsNZUbdcNLCPN14Vb6wT6NsdwpgRrpfgqnAuyrGkwZ73Xki4XnfBmQq9RqJ4P
	+tWQoflQC6hKlC9UN5tOjoWTmNdU4CkOxoSitnYXbw5/1YUlmGX/KimkfXzjpj7Jjqw==
X-Received: by 2002:a05:620a:10bc:: with SMTP id h28mr85368861qkk.289.1564673090252;
        Thu, 01 Aug 2019 08:24:50 -0700 (PDT)
X-Received: by 2002:a05:620a:10bc:: with SMTP id h28mr85368768qkk.289.1564673089074;
        Thu, 01 Aug 2019 08:24:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564673089; cv=none;
        d=google.com; s=arc-20160816;
        b=ttwUTEgSJQu5IrX7zmVyx0FCJzubNDpVgkkbnubplL/q2/Tmt2pwyLa/MxHVEmKMsn
         sV625gwFuO5UXC3e9RDuceRZ/9fxmP/fpgouW1/z7pWlmgP/fwI6v8uWDFUhLeOMwPUN
         OAc9H5y3C9nVdfB/6L4rg4S9t6HphzZRCFuvOlyv3hXhQYskEF5r6HuMVp7iLBT7i8XU
         UDRGTVH0KA72Q6XPT/xBf23ApPaaznpjezwOgzRCunpv3bPuCRUGi+io7HNFMEdFNC17
         fMksE2TdlLq/Ho/8XOVJIOpzWIoUHvWgDETj6vKxRtwLGlyv0oJDt6sV4wn6F86lu6JK
         FEoQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:to:from:dkim-signature;
        bh=I9xocEcKfjedMKhCpMGCXOBDXpoq1e/vB1JDr9sXjKk=;
        b=dEw0Nt6wZULWMwA+z7w9xbVwtD0JJpmUvKEVyX9sdhVc4ERnpU4CuGS07N6/1lRYW2
         p2XQO2+nWodLGQznemtqliEUOflWRE9DrVdiraFQ93dGUIYH4HzTSF35Hessot2RMU3p
         06qfwZfToGGc/j+tqP5rJHKodMPk6+/gXA5RJxhLIuq5ApXXbE2FWR/KGq2VO8x9Wsjd
         +lE19wAhB88YxBoPabCjQHPuvI3uxilDVzGq0XZeIG/Uy8mrlB/kKE27oTsxBAdzk00C
         mt11CzhsGtQFQZbRaEnfHG5WssX6j+HMdiYffvia18xlnP+0t0tZEiG/yNrzs2iQlvru
         WmWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=H9kRmo9D;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y19sor60420447qve.64.2019.08.01.08.24.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 08:24:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b=H9kRmo9D;
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=I9xocEcKfjedMKhCpMGCXOBDXpoq1e/vB1JDr9sXjKk=;
        b=H9kRmo9DikDA0wnk6Qyetpuog8uAfvIr/1QRoCqruP1kppB96lBaO26ZiL52EwXeKs
         0bqZ398TbTpBlAZl3KwLimtGSWFq86L4fcdbuYX+7rG6OyKFNiNNXU+GC7VgzW4/OrlL
         Y6zWDcwqUj+jn9usrnRDOHh68Bson2VGCnjkY5kHuOiCldPiYSLd0jeW02uJT8AO8Wpz
         kfp+MQ6oxCTcI2nuFseZZRndqhOiyrt1WaI8QKQUaiJw1f4CL5zIcPN5aM41r6lgi07x
         4qr/Xqj4Ho657Hl1M4ZbvF0KVHExeLlcGiYwPKNHghKMNWvXOnfa72z1f4HHCBeZiby1
         mcKg==
X-Google-Smtp-Source: APXvYqzvcTL7H0OIQGjS3ayyoz8R1VKYVpj6pg5T/bssf/mq4Dj4anh7C7dceOvoI1gpuWhC1CGXAw==
X-Received: by 2002:a0c:b2da:: with SMTP id d26mr92635309qvf.48.1564673088659;
        Thu, 01 Aug 2019 08:24:48 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o5sm30899952qkf.10.2019.08.01.08.24.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 08:24:48 -0700 (PDT)
From: Pavel Tatashin <pasha.tatashin@soleen.com>
To: pasha.tatashin@soleen.com,
	jmorris@namei.org,
	sashal@kernel.org,
	ebiederm@xmission.com,
	kexec@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	corbet@lwn.net,
	catalin.marinas@arm.com,
	will@kernel.org,
	linux-arm-kernel@lists.infradead.org,
	marc.zyngier@arm.com,
	james.morse@arm.com,
	vladimir.murzin@arm.com,
	matthias.bgg@gmail.com,
	bhsharma@redhat.com,
	linux-mm@kvack.org
Subject: [PATCH v1 5/8] arm64, kexec: move relocation function setup and clean up
Date: Thu,  1 Aug 2019 11:24:36 -0400
Message-Id: <20190801152439.11363-6-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190801152439.11363-1-pasha.tatashin@soleen.com>
References: <20190801152439.11363-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, kernel relocation function is configured in machine_kexec()
at the time of kexec reboot by using control_code_page.

This operation, however, is more logical to be done during kexec_load,
and thus remove from reboot time. Move, setup of this function to
newly added machine_kexec_post_load().

In addition, do some cleanup: add infor about reloction function to
kexec_image_info(), and remove extra messages from machine_kexec().

Make dtb_mem, always available, if CONFIG_KEXEC_FILE is not configured
dtb_mem is set to zero anyway.

Signed-off-by: Pavel Tatashin <pasha.tatashin@soleen.com>
---
 arch/arm64/include/asm/kexec.h    |  3 +-
 arch/arm64/kernel/machine_kexec.c | 49 +++++++++++--------------------
 2 files changed, 19 insertions(+), 33 deletions(-)

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexec.h
index 12a561a54128..d15ca1ca1e83 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -90,14 +90,15 @@ static inline void crash_prepare_suspend(void) {}
 static inline void crash_post_resume(void) {}
 #endif
 
-#ifdef CONFIG_KEXEC_FILE
 #define ARCH_HAS_KIMAGE_ARCH
 
 struct kimage_arch {
 	void *dtb;
 	unsigned long dtb_mem;
+	unsigned long kern_reloc;
 };
 
+#ifdef CONFIG_KEXEC_FILE
 extern const struct kexec_file_ops kexec_image_ops;
 
 struct kimage;
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machine_kexec.c
index 0df8493624e0..9b41da50e6f7 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -42,6 +42,7 @@ static void _kexec_image_info(const char *func, int line,
 	pr_debug("    start:       %lx\n", kimage->start);
 	pr_debug("    head:        %lx\n", kimage->head);
 	pr_debug("    nr_segments: %lu\n", kimage->nr_segments);
+	pr_debug("    kern_reloc: %pa\n", &kimage->arch.kern_reloc);
 
 	for (i = 0; i < kimage->nr_segments; i++) {
 		pr_debug("      segment[%lu]: %016lx - %016lx, 0x%lx bytes, %lu pages\n",
@@ -58,6 +59,19 @@ void machine_kexec_cleanup(struct kimage *kimage)
 	/* Empty routine needed to avoid build errors. */
 }
 
+int machine_kexec_post_load(struct kimage *kimage)
+{
+	unsigned long kern_reloc;
+
+	kern_reloc = page_to_phys(kimage->control_code_page);
+	memcpy(__va(kern_reloc), arm64_relocate_new_kernel,
+	       arm64_relocate_new_kernel_size);
+	kimage->arch.kern_reloc = kern_reloc;
+
+	kexec_image_info(kimage);
+	return 0;
+}
+
 /**
  * machine_kexec_prepare - Prepare for a kexec reboot.
  *
@@ -67,8 +81,6 @@ void machine_kexec_cleanup(struct kimage *kimage)
  */
 int machine_kexec_prepare(struct kimage *kimage)
 {
-	kexec_image_info(kimage);
-
 	if (kimage->type != KEXEC_TYPE_CRASH && cpus_are_stuck_in_kernel()) {
 		pr_err("Can't kexec: CPUs are stuck in the kernel.\n");
 		return -EBUSY;
@@ -143,8 +155,7 @@ static void kexec_segment_flush(const struct kimage *kimage)
  */
 void machine_kexec(struct kimage *kimage)
 {
-	phys_addr_t reboot_code_buffer_phys;
-	void *reboot_code_buffer;
+	void *reboot_code_buffer = phys_to_virt(kimage->arch.kern_reloc);
 	bool in_kexec_crash = (kimage == kexec_crash_image);
 	bool stuck_cpus = cpus_are_stuck_in_kernel();
 
@@ -155,30 +166,8 @@ void machine_kexec(struct kimage *kimage)
 	WARN(in_kexec_crash && (stuck_cpus || smp_crash_stop_failed()),
 		"Some CPUs may be stale, kdump will be unreliable.\n");
 
-	reboot_code_buffer_phys = page_to_phys(kimage->control_code_page);
-	reboot_code_buffer = phys_to_virt(reboot_code_buffer_phys);
-
 	kexec_image_info(kimage);
 
-	pr_debug("%s:%d: control_code_page:        %p\n", __func__, __LINE__,
-		kimage->control_code_page);
-	pr_debug("%s:%d: reboot_code_buffer_phys:  %pa\n", __func__, __LINE__,
-		&reboot_code_buffer_phys);
-	pr_debug("%s:%d: reboot_code_buffer:       %p\n", __func__, __LINE__,
-		reboot_code_buffer);
-	pr_debug("%s:%d: relocate_new_kernel:      %p\n", __func__, __LINE__,
-		arm64_relocate_new_kernel);
-	pr_debug("%s:%d: relocate_new_kernel_size: 0x%lx(%lu) bytes\n",
-		__func__, __LINE__, arm64_relocate_new_kernel_size,
-		arm64_relocate_new_kernel_size);
-
-	/*
-	 * Copy arm64_relocate_new_kernel to the reboot_code_buffer for use
-	 * after the kernel is shut down.
-	 */
-	memcpy(reboot_code_buffer, arm64_relocate_new_kernel,
-		arm64_relocate_new_kernel_size);
-
 	/* Flush the reboot_code_buffer in preparation for its execution. */
 	__flush_dcache_area(reboot_code_buffer, arm64_relocate_new_kernel_size);
 
@@ -214,12 +203,8 @@ void machine_kexec(struct kimage *kimage)
 	 * userspace (kexec-tools).
 	 * In kexec_file case, the kernel starts directly without purgatory.
 	 */
-	cpu_soft_restart(reboot_code_buffer_phys, kimage->head, kimage->start,
-#ifdef CONFIG_KEXEC_FILE
-						kimage->arch.dtb_mem);
-#else
-						0);
-#endif
+	cpu_soft_restart(kimage->arch.kern_reloc, kimage->head, kimage->start,
+			 kimage->arch.dtb_mem);
 
 	BUG(); /* Should never get here. */
 }
-- 
2.22.0

