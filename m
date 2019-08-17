Return-Path: <SRS0=ZelW=WN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 465D2C3A59E
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECCBF21019
	for <linux-mm@archiver.kernel.org>; Sat, 17 Aug 2019 02:46:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="EVqaWfDS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECCBF21019
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7C0426B0275; Fri, 16 Aug 2019 22:46:48 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 774056B0276; Fri, 16 Aug 2019 22:46:48 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 52B616B0277; Fri, 16 Aug 2019 22:46:48 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0069.hostedemail.com [216.40.44.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2B74B6B0275
	for <linux-mm@kvack.org>; Fri, 16 Aug 2019 22:46:48 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id CD74C127BD
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:47 +0000 (UTC)
X-FDA: 75830382054.21.point59_1138a325c722
X-HE-Tag: point59_1138a325c722
X-Filterd-Recvd-Size: 8314
Received: from mail-qt1-f196.google.com (mail-qt1-f196.google.com [209.85.160.196])
	by imf46.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat, 17 Aug 2019 02:46:47 +0000 (UTC)
Received: by mail-qt1-f196.google.com with SMTP id x4so8219474qts.5
        for <linux-mm@kvack.org>; Fri, 16 Aug 2019 19:46:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ERR6ga21MfM+DJETWw5X/yqx0nN/RzBQu+O8HwS3oQQ=;
        b=EVqaWfDS7LSA3yW55QFi3RiB93knF+Y1sPRub0ZatptMJjbb+IuJBqRb/xTbEp0mGY
         X3VTKkGRCamjtgc8K1D5rJ3TPHaEZmLrUXu65kEb3rZS99k3jWpUrpRp9ao+KPifv1RU
         4AQpTuMmEFbZn/A+Op72Z00RWzCig3MvgSs9S2gxBLAUAAJUVir4pI9B4ZcWG3qpo6n0
         oF9W/tZJLrm5cSrJYBcTIWidlToJ6zrEkQmPEg0Pnw27emi1e6eFGHRUvQQrr5JfldPc
         t/ozFYFFTDcCOc0A8CSQf7QFWHqh2lkRPt/3Zl1dtLLTT25z2uygphFmcaY+vAZU0R/N
         05lw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=ERR6ga21MfM+DJETWw5X/yqx0nN/RzBQu+O8HwS3oQQ=;
        b=p8wN28s3wyKFzA/1o3E3BWSOZ+RE82FF1OXoGxSkVA7VedGppsT90m/zN5JG8MUqPs
         qaRBS+D3uMMuwfvIZdA0V8OT2jTK/akNoLt4L2ufmJVhqoBwAwjpF7AjyUiRvW2RJMFn
         4ENUZ/aV9MAgT/qdCjKvEBdOVuZR5hlMzo4LxFCIIZsBISsGXzDyJv+E7JlWfrBP2qcV
         OkSqL06PwasL3MaznSt5PePIxwSKWsnIlRHLRilbA26AhgikkK+PRuS5jMp7Rj2FWwie
         pkf9jxJO7kpS5w+BMeQ5PSzWuiW3fWJkhK/+huQ2zmh3ySl8hrdAc6j425hgfPY2n6Yf
         zZ0w==
X-Gm-Message-State: APjAAAULsSTwwi6Brawr5Y5L5OrgIJ/8rabsfWQNLs9BRbm9rQEBBham
	mhMoT1AWhyF4UsIMy8JEzEgHSg==
X-Google-Smtp-Source: APXvYqyFjy4eVrE3LEU7hmoOELaMDP4RDH3Zf0t+d6DSDNTFmwjKd+7q5EA5nSF9/6teMaAjG7TQFg==
X-Received: by 2002:ad4:50d1:: with SMTP id e17mr3952806qvq.9.1566010006762;
        Fri, 16 Aug 2019 19:46:46 -0700 (PDT)
Received: from localhost.localdomain (c-73-69-118-222.hsd1.nh.comcast.net. [73.69.118.222])
        by smtp.gmail.com with ESMTPSA id o9sm3454657qtr.71.2019.08.16.19.46.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Aug 2019 19:46:46 -0700 (PDT)
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
Subject: [PATCH v2 11/14] arm64, kexec: move relocation function setup and clean up
Date: Fri, 16 Aug 2019 22:46:26 -0400
Message-Id: <20190817024629.26611-12-pasha.tatashin@soleen.com>
X-Mailer: git-send-email 2.22.1
In-Reply-To: <20190817024629.26611-1-pasha.tatashin@soleen.com>
References: <20190817024629.26611-1-pasha.tatashin@soleen.com>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
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

diff --git a/arch/arm64/include/asm/kexec.h b/arch/arm64/include/asm/kexe=
c.h
index 12a561a54128..d15ca1ca1e83 100644
--- a/arch/arm64/include/asm/kexec.h
+++ b/arch/arm64/include/asm/kexec.h
@@ -90,14 +90,15 @@ static inline void crash_prepare_suspend(void) {}
 static inline void crash_post_resume(void) {}
 #endif
=20
-#ifdef CONFIG_KEXEC_FILE
 #define ARCH_HAS_KIMAGE_ARCH
=20
 struct kimage_arch {
 	void *dtb;
 	unsigned long dtb_mem;
+	unsigned long kern_reloc;
 };
=20
+#ifdef CONFIG_KEXEC_FILE
 extern const struct kexec_file_ops kexec_image_ops;
=20
 struct kimage;
diff --git a/arch/arm64/kernel/machine_kexec.c b/arch/arm64/kernel/machin=
e_kexec.c
index 0df8493624e0..9b41da50e6f7 100644
--- a/arch/arm64/kernel/machine_kexec.c
+++ b/arch/arm64/kernel/machine_kexec.c
@@ -42,6 +42,7 @@ static void _kexec_image_info(const char *func, int lin=
e,
 	pr_debug("    start:       %lx\n", kimage->start);
 	pr_debug("    head:        %lx\n", kimage->head);
 	pr_debug("    nr_segments: %lu\n", kimage->nr_segments);
+	pr_debug("    kern_reloc: %pa\n", &kimage->arch.kern_reloc);
=20
 	for (i =3D 0; i < kimage->nr_segments; i++) {
 		pr_debug("      segment[%lu]: %016lx - %016lx, 0x%lx bytes, %lu pages\=
n",
@@ -58,6 +59,19 @@ void machine_kexec_cleanup(struct kimage *kimage)
 	/* Empty routine needed to avoid build errors. */
 }
=20
+int machine_kexec_post_load(struct kimage *kimage)
+{
+	unsigned long kern_reloc;
+
+	kern_reloc =3D page_to_phys(kimage->control_code_page);
+	memcpy(__va(kern_reloc), arm64_relocate_new_kernel,
+	       arm64_relocate_new_kernel_size);
+	kimage->arch.kern_reloc =3D kern_reloc;
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
 	if (kimage->type !=3D KEXEC_TYPE_CRASH && cpus_are_stuck_in_kernel()) {
 		pr_err("Can't kexec: CPUs are stuck in the kernel.\n");
 		return -EBUSY;
@@ -143,8 +155,7 @@ static void kexec_segment_flush(const struct kimage *=
kimage)
  */
 void machine_kexec(struct kimage *kimage)
 {
-	phys_addr_t reboot_code_buffer_phys;
-	void *reboot_code_buffer;
+	void *reboot_code_buffer =3D phys_to_virt(kimage->arch.kern_reloc);
 	bool in_kexec_crash =3D (kimage =3D=3D kexec_crash_image);
 	bool stuck_cpus =3D cpus_are_stuck_in_kernel();
=20
@@ -155,30 +166,8 @@ void machine_kexec(struct kimage *kimage)
 	WARN(in_kexec_crash && (stuck_cpus || smp_crash_stop_failed()),
 		"Some CPUs may be stale, kdump will be unreliable.\n");
=20
-	reboot_code_buffer_phys =3D page_to_phys(kimage->control_code_page);
-	reboot_code_buffer =3D phys_to_virt(reboot_code_buffer_phys);
-
 	kexec_image_info(kimage);
=20
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
 	__flush_dcache_area(reboot_code_buffer, arm64_relocate_new_kernel_size)=
;
=20
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
=20
 	BUG(); /* Should never get here. */
 }
--=20
2.22.1


