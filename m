Return-Path: <SRS0=iTus=TK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EE74C04AB2
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E1194217D6
	for <linux-mm@archiver.kernel.org>; Fri, 10 May 2019 07:21:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E1194217D6
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 043BE6B000E; Fri, 10 May 2019 03:21:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F0E676B0010; Fri, 10 May 2019 03:21:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E24E46B0266; Fri, 10 May 2019 03:21:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id BFC586B000E
	for <linux-mm@kvack.org>; Fri, 10 May 2019 03:21:33 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id z34so5360368qtz.14
        for <linux-mm@kvack.org>; Fri, 10 May 2019 00:21:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vOejBc1QN8TJ6K5lhz+Yvn4+87eApSQ46e32YrdputU=;
        b=OTa8DO/9iURQRMDXomZs18mb2peGLR9ksUo49ijwFsmdHL1+okuwJ8of/2WKwVpVXK
         A/AybugSZj6u7CLS7Aj5GqX4pjYtCPDHcSwXA7xIiZcn0l1h6zdBJQUGO2MfRUdpnkAX
         3w0eziynKl18nAwLQtGMv/s8IWvEDAGBRJDSOHBQzDGkGaV6eLbk9HqTCqccwcZWXHIj
         woSu2LQrvZ2bgvBjcXcC78mwUrdyNn3l50lfFwGq0f2P8Q8nn/ler45fkBvn0MNemd8f
         ZacSosao4heC1JQpJFNyD0PrRjn78Enwt2DUMa7bMIqIkcwrXQ29y4Mmcofv0R0UJr03
         VGlA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWFm2mJH73xtcJW9D217dmwRPLmRJOtz0eZ+o5YopAcLrxhmIlB
	37s+Dr7T43FjX5lckj6xxZYANlG/N+rXwyQSDK8OMqfFRqBrOCfljsbQXcarOqocJoD562hMrXL
	f+wJbDCsobJ58m7d/QRkxwMGDRZ98u180iyHIwhKPzr7e28TAsefBwSq8+RKwCOm8RA==
X-Received: by 2002:ac8:1931:: with SMTP id t46mr8128884qtj.170.1557472893540;
        Fri, 10 May 2019 00:21:33 -0700 (PDT)
X-Received: by 2002:ac8:1931:: with SMTP id t46mr8128823qtj.170.1557472892307;
        Fri, 10 May 2019 00:21:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557472892; cv=none;
        d=google.com; s=arc-20160816;
        b=0H9Re5N6K5TUrh4o28TCvYNshYggXMpbjzzIpIUCV3q//D2Ah9HsRIXtfK7tgjZ/pA
         EJDLRfNiQDvHpm88KOV80qn4SK4DrfrRpSZ6QXJG2bIzjkriYDY0owrVCSB1pQkq0Zb8
         vhUPyzJcqUtqIGsDlD4Oaq0pO7QbEkSo0Sb8OeuuTeypJnvHUPgtLbUUsmsBbaTxuFyM
         VA1AXpfjsjD+JfrfpnNTfEwBuEXZ6AnTVy3gLYHeH5yK5DhLBD/8Kn2Hlj/fjEkQLBL0
         BJU3xrT+bEsNKpfqo3DUOaWcy+wrKtzHh7TS51CJzFU0f6RwC9yemjbTRFj0lTDnhBTN
         +zVQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=vOejBc1QN8TJ6K5lhz+Yvn4+87eApSQ46e32YrdputU=;
        b=VY5N38FJdzx2A+Z9um20yWskBeZ69K31r0MBk1iEo9MNu3xkHCYBFHnjjGSoCfvBaY
         jIjwy9lJIY3/Y4muSmp/Bas5F5reDgBzXLjVT4stblzQdAbAl3HqcHeCYqRl4CyLcgub
         bslPPmvXxXkiam+d6J45aSeV8iOPSp+PwPAjLHFLEevS8v8YMJUrGZTtRkR/s/yA9vVn
         WcUztaASjWoDTfM5DCvgjPttXBfPzGkWTwiS4hYKpzv1WHjPFrCHEiHfJ9XaXp0tvEKl
         0xUX6to7hI2RTpkaYSaDZ1yTyOCgbrv4fXJ2vJsmkojf9LgCirrffGWhl6itZTyovq+X
         6CIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m135sor2567975qke.42.2019.05.10.00.21.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 10 May 2019 00:21:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of oleksandr@redhat.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=oleksandr@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Google-Smtp-Source: APXvYqzPe26b8EbsZNX43wXIk/ZJMwyIsrlo41vyylWWI/zUIYOTf4fWR2vuKOPN9vH/HO0FjC5SPg==
X-Received: by 2002:a37:5444:: with SMTP id i65mr7490671qkb.263.1557472892023;
        Fri, 10 May 2019 00:21:32 -0700 (PDT)
Received: from localhost (nat-pool-brq-t.redhat.com. [213.175.37.10])
        by smtp.gmail.com with ESMTPSA id y18sm2145077qty.78.2019.05.10.00.21.31
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 10 May 2019 00:21:31 -0700 (PDT)
From: Oleksandr Natalenko <oleksandr@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: Kirill Tkhai <ktkhai@virtuozzo.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Michal Hocko <mhocko@suse.com>,
	Matthew Wilcox <willy@infradead.org>,
	Pavel Tatashin <pasha.tatashin@oracle.com>,
	Timofey Titovets <nefelim4ag@gmail.com>,
	Aaron Tomlin <atomlin@redhat.com>,
	linux-mm@kvack.org
Subject: [PATCH RFC 2/4] mm/ksm: introduce VM_UNMERGEABLE
Date: Fri, 10 May 2019 09:21:23 +0200
Message-Id: <20190510072125.18059-3-oleksandr@redhat.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190510072125.18059-1-oleksandr@redhat.com>
References: <20190510072125.18059-1-oleksandr@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add separate vmaflag to allow applications to opt out of automatic VMAs
merging due to (possible) security concerns.

Since vmaflags are tight on free bits, this flag is available on 64-bit
architectures only. Thus, subsequently, KSM "always" mode will be
available for 64-bit architectures only as well.

Signed-off-by: Oleksandr Natalenko <oleksandr@redhat.com>
---
 fs/proc/task_mmu.c             |  3 +++
 include/linux/mm.h             |  6 ++++++
 include/trace/events/mmflags.h |  7 +++++++
 mm/ksm.c                       | 13 +++++++++++++
 4 files changed, 29 insertions(+)

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 95ca1fe7283c..19cc246000e8 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -648,6 +648,9 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_MIXEDMAP)]	= "mm",
 		[ilog2(VM_HUGEPAGE)]	= "hg",
 		[ilog2(VM_NOHUGEPAGE)]	= "nh",
+#ifdef VM_UNMERGEABLE
+		[ilog2(VM_UNMERGEABLE)]	= "ug",
+#endif
 		[ilog2(VM_MERGEABLE)]	= "mg",
 		[ilog2(VM_UFFD_MISSING)]= "um",
 		[ilog2(VM_UFFD_WP)]	= "uw",
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..114cdb882cdd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -252,11 +252,13 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_HIGH_ARCH_BIT_2	34	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_3	35	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_BIT_4	36	/* bit only usable on 64-bit architectures */
+#define VM_HIGH_ARCH_BIT_5	37	/* bit only usable on 64-bit architectures */
 #define VM_HIGH_ARCH_0	BIT(VM_HIGH_ARCH_BIT_0)
 #define VM_HIGH_ARCH_1	BIT(VM_HIGH_ARCH_BIT_1)
 #define VM_HIGH_ARCH_2	BIT(VM_HIGH_ARCH_BIT_2)
 #define VM_HIGH_ARCH_3	BIT(VM_HIGH_ARCH_BIT_3)
 #define VM_HIGH_ARCH_4	BIT(VM_HIGH_ARCH_BIT_4)
+#define VM_HIGH_ARCH_5	BIT(VM_HIGH_ARCH_BIT_5)
 #endif /* CONFIG_ARCH_USES_HIGH_VMA_FLAGS */
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -272,6 +274,10 @@ extern unsigned int kobjsize(const void *objp);
 #endif
 #endif /* CONFIG_ARCH_HAS_PKEYS */
 
+#ifdef VM_HIGH_ARCH_5
+#define VM_UNMERGEABLE	VM_HIGH_ARCH_5	/* Opt-out for KSM "always" mode */
+#endif /* VM_HIGH_ARCH_5 */
+
 #if defined(CONFIG_X86)
 # define VM_PAT		VM_ARCH_1	/* PAT reserves whole VMA at once (x86) */
 #elif defined(CONFIG_PPC)
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d43777e..717e0fd9d2ef 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -130,6 +130,12 @@ IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
 #define IF_HAVE_VM_SOFTDIRTY(flag,name)
 #endif
 
+#ifdef VM_UNMERGEABLE
+#define IF_HAVE_VM_UNMERGEABLE(flag,name) {flag, name },
+#else
+#define IF_HAVE_VM_UNMERGEABLE(flag,name)
+#endif
+
 #define __def_vmaflag_names						\
 	{VM_READ,			"read"		},		\
 	{VM_WRITE,			"write"		},		\
@@ -161,6 +167,7 @@ IF_HAVE_VM_SOFTDIRTY(VM_SOFTDIRTY,	"softdirty"	)		\
 	{VM_MIXEDMAP,			"mixedmap"	},		\
 	{VM_HUGEPAGE,			"hugepage"	},		\
 	{VM_NOHUGEPAGE,			"nohugepage"	},		\
+IF_HAVE_VM_UNMERGEABLE(VM_UNMERGEABLE,	"unmergeable"	)		\
 	{VM_MERGEABLE,			"mergeable"	}		\
 
 #define show_vma_flags(flags)						\
diff --git a/mm/ksm.c b/mm/ksm.c
index a6b0788a3a22..0fb5f850087a 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -2450,12 +2450,18 @@ int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
 
 	switch (advice) {
 	case MADV_MERGEABLE:
+#ifdef VM_UNMERGEABLE
+		*vm_flags &= ~VM_UNMERGEABLE;
+#endif
 		err = ksm_enter(mm, vma, vm_flags);
 		if (err)
 			return err;
 		break;
 
 	case MADV_UNMERGEABLE:
+#ifdef VM_UNMERGEABLE
+		*vm_flags |= VM_UNMERGEABLE;
+#endif
 		if (!(*vm_flags & VM_MERGEABLE))
 			return 0;		/* just ignore the advice */
 
@@ -2496,6 +2502,10 @@ int ksm_enter(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (*vm_flags & VM_SPARC_ADI)
 		return 0;
 #endif
+#ifdef VM_UNMERGEABLE
+	if (*vm_flags & VM_UNMERGEABLE)
+		return 0;
+#endif
 
 	if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
 		err = __ksm_enter(mm);
@@ -3173,6 +3183,9 @@ static ssize_t full_scans_show(struct kobject *kobj,
 KSM_ATTR_RO(full_scans);
 
 static struct attribute *ksm_attrs[] = {
+#ifdef VM_UNMERGEABLE
+	&mode_attr.attr,
+#endif
 	&sleep_millisecs_attr.attr,
 	&pages_to_scan_attr.attr,
 	&run_attr.attr,
-- 
2.21.0

