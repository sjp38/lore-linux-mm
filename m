Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 684B4C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 280552176F
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 18:15:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IQrmXhYJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 280552176F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE23A8E0051; Mon,  4 Feb 2019 13:15:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B91BF8E001C; Mon,  4 Feb 2019 13:15:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA8B78E0051; Mon,  4 Feb 2019 13:15:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 65B428E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 13:15:55 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id a23so510252pfo.2
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 10:15:55 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=YZe004olxwKUVDNhwEwrZ8AUV4iVt97unB7E5kh6nQ4=;
        b=gIrXvE+myVSPKimzttDGcwbTP+1AWYsE4s83/x5VgqA+S+s0doSW6w0lcnLQ33E0Lz
         PDOd07TQhn8m2ikOj70IirtiJlneD+bJtLA9DKJ82KV8RH0CB+Dv2rsqW+OOjo8aHkoM
         EOeY5QKvc40dpn+keL6XAJJlMTs0vBjUMKA7FWJeAKn0nkYFy5k4H7w0LqD42KvoXXbF
         87GiJYUOIVh/kn9tzK0tF23WWrnjsCl5GHlfW40R/HrpLWO8dNS/BdirHm1O2sezxDbe
         Ut/f+Kg+DPgBV/rNGo/w8t0TZFJY0gduWUHBZLggLmQlfmt+pKejO/0HyoYLBssc3mXm
         3NsQ==
X-Gm-Message-State: AHQUAuaUSEzqwevSrcbR1G4Opt1DEVvOEdwJz8I8y8LnoskKmcKKALaS
	uzy4eUsLVxpWASfdE5ZtPe2OgPrj/xMiKUdOUqBT35THzPr6DVmGZjrSnVjaoYZayolCAJuttwV
	5CR5rwh0w4A3DXCWLF1TSG49qkYiLcGZwBYO8+PbABerwRpxmOz08PFUg8FliftKcsylBk0xg/b
	z6znCXww85fW/cKiP1WZU35zPWcQiou3K7eFxHoM8en21yq8iTtp7tz8j6iXbWvX4BcDifefavo
	go//ZZadav8ZpQSA3am62s3I1datAlf6qwZTvEOwKb5VC1/0sRmI7cIDYkcYhifs2cosWf/spOg
	0ShEB1QhPij08mHEKXcZ8nhbFf95iTItBsnfwSUvIBgBuzYWN4hebEJI56Q/S1CYIteXTA5+uGC
	w
X-Received: by 2002:a17:902:15a8:: with SMTP id m37mr679178pla.129.1549304155047;
        Mon, 04 Feb 2019 10:15:55 -0800 (PST)
X-Received: by 2002:a17:902:15a8:: with SMTP id m37mr679122pla.129.1549304154269;
        Mon, 04 Feb 2019 10:15:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549304154; cv=none;
        d=google.com; s=arc-20160816;
        b=JhNaB0ak9BDwcP/dYrPd3McLJmobc94NDLvaoweqOvM70CoduO5avvNLoNILJ18NuJ
         TVRSKw0Fjh2pidg9rK2M/PdqeqZuRIVCPtH2GErUZlD/CXcahIbP7+PhfAZkyzOCez9j
         7b2ZI1WUghA07Gq+E+6okdPwxRs5TC5c9BEB/1B1GMuVH565xAiV8PTfdGQQ5Oj9N/lH
         Brn2tS2XYmp3moC1d0p292tbomtTrapRDZkcxODlwYdvIDjBbBm0MZGloGxBx6fivSQr
         Z5efyCdNT5WRzy5qSkwbTqHq4SgsC+j992Cux2k+Uy4F8+OJWRIiooVUtz51U67ksqwE
         nxjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=YZe004olxwKUVDNhwEwrZ8AUV4iVt97unB7E5kh6nQ4=;
        b=rGxWDVp7P+PzAx02QxZMD1IiVRcDj8+BYtvyHdL5dceIxLNrNrYZ7K/kcLk+hRLuO3
         AkNZLZKzNrrI9qEkGoBk6df+U4DCq83ytClJi33b+QUkOO5SC3OLYTBW/w/vY4jtD92c
         idU+KYWfLyhdakS5iMSlChRJmwj6ACgNZy/cXfkimIsIYL45hyw1IOSvqb/tHJb2nGok
         0VJInQCG5lyjbwXHIy/p5rIeO7sX7lWD7ySdEWmk3FYsRmusW2tr4XlL7lg3ExUI4pTI
         uAAfVCqFnWKCS0b5ICLMcNGoJ2z2t/BtB/f32G0nB8CS2zxifp4QfNHbvG1GPS3VTqMA
         u6ZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IQrmXhYJ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x5sor1317104pgp.80.2019.02.04.10.15.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Feb 2019 10:15:54 -0800 (PST)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IQrmXhYJ;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=YZe004olxwKUVDNhwEwrZ8AUV4iVt97unB7E5kh6nQ4=;
        b=IQrmXhYJn+hqxmnp2CKgxQtlZ/Plcxr3XKvJAlVd5LVl4ehyQEQyTW3i6g9aDkFdWB
         BlSQvYrHO04cqFRXHDFceoyzCyJjkEUYcdv8SMX3X8kEcAFyGnZZnQy3YTjYAAoKzZzL
         37CyqRl4Xz3IG9WZGdn/ub1I0CoSEBtCocL0KPfAtM/Pq8+/TphetVo8ZCIOKRkSMe/e
         6zdTFFr4eBZmo16fnkCw3kEFRC29XwHCOtqP8uxcfKFLPIb9OtClIu6+Ed1cZ6kCaIqz
         YrpTH1YSNpQoSXSdmT38pszxTEWgFqbZ+qx5I7iUCxMXnWy77QKrrIdOErtX/PYZ/ZRv
         s1xg==
X-Google-Smtp-Source: AHgI3IYghO9Gyc5CdVnnZDhQJpFkPxKmWnw3rcVOoUNENx3bnkpWEbZ8P5nJPUmckNTyGdk2ogPr6Q==
X-Received: by 2002:a63:1f64:: with SMTP id q36mr580276pgm.230.1549304153874;
        Mon, 04 Feb 2019 10:15:53 -0800 (PST)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id q5sm2033090pfi.165.2019.02.04.10.15.53
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Feb 2019 10:15:53 -0800 (PST)
Subject: [RFC PATCH 3/4] kvm: Add guest side support for free memory hints
From: Alexander Duyck <alexander.duyck@gmail.com>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kvm@vger.kernel.org
Cc: rkrcmar@redhat.com, alexander.h.duyck@linux.intel.com, x86@kernel.org,
 mingo@redhat.com, bp@alien8.de, hpa@zytor.com, pbonzini@redhat.com,
 tglx@linutronix.de, akpm@linux-foundation.org
Date: Mon, 04 Feb 2019 10:15:52 -0800
Message-ID: <20190204181552.12095.46287.stgit@localhost.localdomain>
In-Reply-To: <20190204181118.12095.38300.stgit@localhost.localdomain>
References: <20190204181118.12095.38300.stgit@localhost.localdomain>
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

Add guest support for providing free memory hints to the KVM hypervisor for
freed pages huge TLB size or larger. I am restricting the size to
huge TLB order and larger because the hypercalls are too expensive to be
performing one per 4K page. Using the huge TLB order became the obvious
choice for the order to use as it allows us to avoid fragmentation of higher
order memory on the host.

I have limited the functionality so that it doesn't work when page
poisoning is enabled. I did this because a write to the page after doing an
MADV_DONTNEED would effectively negate the hint, so it would be wasting
cycles to do so.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 arch/x86/include/asm/page.h |   13 +++++++++++++
 arch/x86/kernel/kvm.c       |   23 +++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 7555b48803a8..4487ad7a3385 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -18,6 +18,19 @@
 
 struct page;
 
+#ifdef CONFIG_KVM_GUEST
+#include <linux/jump_label.h>
+extern struct static_key_false pv_free_page_hint_enabled;
+
+#define HAVE_ARCH_FREE_PAGE
+void __arch_free_page(struct page *page, unsigned int order);
+static inline void arch_free_page(struct page *page, unsigned int order)
+{
+	if (static_branch_unlikely(&pv_free_page_hint_enabled))
+		__arch_free_page(page, order);
+}
+#endif
+
 #include <linux/range.h>
 extern struct range pfn_mapped[];
 extern int nr_pfn_mapped;
diff --git a/arch/x86/kernel/kvm.c b/arch/x86/kernel/kvm.c
index 5c93a65ee1e5..09c91641c36c 100644
--- a/arch/x86/kernel/kvm.c
+++ b/arch/x86/kernel/kvm.c
@@ -48,6 +48,7 @@
 #include <asm/tlb.h>
 
 static int kvmapf = 1;
+DEFINE_STATIC_KEY_FALSE(pv_free_page_hint_enabled);
 
 static int __init parse_no_kvmapf(char *arg)
 {
@@ -648,6 +649,15 @@ static void __init kvm_guest_init(void)
 	if (kvm_para_has_feature(KVM_FEATURE_PV_EOI))
 		apic_set_eoi_write(kvm_guest_apic_eoi_write);
 
+	/*
+	 * The free page hinting doesn't add much value if page poisoning
+	 * is enabled. So we only enable the feature if page poisoning is
+	 * no present.
+	 */
+	if (!page_poisoning_enabled() &&
+	    kvm_para_has_feature(KVM_FEATURE_PV_UNUSED_PAGE_HINT))
+		static_branch_enable(&pv_free_page_hint_enabled);
+
 #ifdef CONFIG_SMP
 	smp_ops.smp_prepare_cpus = kvm_smp_prepare_cpus;
 	smp_ops.smp_prepare_boot_cpu = kvm_smp_prepare_boot_cpu;
@@ -762,6 +772,19 @@ static __init int kvm_setup_pv_tlb_flush(void)
 }
 arch_initcall(kvm_setup_pv_tlb_flush);
 
+void __arch_free_page(struct page *page, unsigned int order)
+{
+	/*
+	 * Limit hints to blocks no smaller than pageblock in
+	 * size to limit the cost for the hypercalls.
+	 */
+	if (order < KVM_PV_UNUSED_PAGE_HINT_MIN_ORDER)
+		return;
+
+	kvm_hypercall2(KVM_HC_UNUSED_PAGE_HINT, page_to_phys(page),
+		       PAGE_SIZE << order);
+}
+
 #ifdef CONFIG_PARAVIRT_SPINLOCKS
 
 /* Kick a cpu by its apicid. Used to wake up a halted vcpu */

