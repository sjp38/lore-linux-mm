Return-Path: <SRS0=CbiD=SY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 247AAC10F11
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CEDA5218B0
	for <linux-mm@archiver.kernel.org>; Mon, 22 Apr 2019 18:59:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CEDA5218B0
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3AEA66B0269; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 358C66B026B; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 223536B026A; Mon, 22 Apr 2019 14:58:46 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id CCA2C6B0269
	for <linux-mm@kvack.org>; Mon, 22 Apr 2019 14:58:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2so8448357pge.16
        for <linux-mm@kvack.org>; Mon, 22 Apr 2019 11:58:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=p6XVxxmeId6Fyrw7m3B0ifgQzW6nhwdk5H1SAhfRKS0=;
        b=BNI3LEBLVaMVJXoFqtKWg2Fw5YCft0+Q6hp/sA3soM1NE2BKstay8DxGolYaWm7eJr
         vh2LubBuIAlJDJm4XFS5/Aq++5r0KvVdiC1wAseoRmfr/QvgU1AS1rYtsCXtTC5qZqaU
         HYNj4CaXFWSp1yVLWlObRIBLLEiXclhFN81RGMRcJYRxBfZyzqFvGl5dg0M0DuyKM8l2
         G611CwuT3Iy9bzr+iOOL4SpUkOlDHujdXHVqtM5JpBL7Zv53v65g7o5cvQTSbVEbliJf
         8Eh4AHrrJw9SvsMGEoYHD9AvbA1kRXUftIPPAgV23iIgwRS1JyTILNzvKfKYVOGbC6JL
         nWBg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAUxY5Y5fEYUrK2qgFVq5nHgnnAgrOnyBilYAidYIqJliifSt/zM
	AxxEn8xQO7jQoduZzy4Gh6rvsrY6HWsTBt0EHsp/sX9l23BVbzUXX+v4YnO/ULzbgz1B7P3Gxml
	7pcbUFwv+AuVYeCOl7uAtcStC+L4KgkrfcRzFMH7Y9Wv//riyun0XRKPzwJxCvf62Pg==
X-Received: by 2002:a63:5c43:: with SMTP id n3mr20174334pgm.163.1555959525406;
        Mon, 22 Apr 2019 11:58:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9e1eaEuPY13QE4437Qli9bBZ9CzkZoXTrXqwsRrMDm/xZoa8rx5UuJCpJHy4EulnkfbLL
X-Received: by 2002:a63:5c43:: with SMTP id n3mr20174297pgm.163.1555959524616;
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555959524; cv=none;
        d=google.com; s=arc-20160816;
        b=o/FlyCMekM/QBtxJogXiNshf4fORTf5jV5u/1GzfmemjiUJMChIZcwV1HgfXdomsBv
         QHmJhb07klkRXPu5U23vU+dcwF8jpYXY8x+rwa4SpAW76KGgwI20ht8rSuMdsiMfy72i
         9nbnc/phGCTQyyeLbDtP5hWSbP+ieWYBCTL0gcIq3qFr/vV50POrlCKEZ1BThjyyag38
         S4o9q4KFczfRY3eqnQyZ+rHFLSX4SwfgQTfr+IeGzzV4xbojeNQbaYsp8aynVJCn0NBL
         92dCndsHX8XkYabVWzdQ/zVs5iMH68tGmklMs/Mg61Ha+3sEsR5mNiqiKTcn7GByi7of
         De+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=p6XVxxmeId6Fyrw7m3B0ifgQzW6nhwdk5H1SAhfRKS0=;
        b=PpudQdPyWtKVa+9uYVoo2qxGYOuICKJSX/+lMG3/bL+JODnO1c+J1W+mf+RFemXZYd
         1FQ2Yd/Vx09BdURKf0LArMeNGNz0WcLBZypfxNnvnwo4emrW363vmDZ0rwaH3TBfld/l
         d0HHyGqN6bGFKNI8hPX1UURQBQr4f2P0Mq/eBvdRqhDIz2XzphsuJtuQngEaQO59iFf7
         da3NvU2Yo9BqDB3qUg2SNp8wIG/cXLUp0bechrG9b7inL/RriMb7WLB1u9RKeHu5MrGe
         d01E6nhGeSuBmz+BrCEfVZyXhMrkPpoG7R1pBo+68/VZ5rB4nOY7nUmndZjvocz/YWVv
         kEmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id a2si12975117pgn.530.2019.04.22.11.58.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 Apr 2019 11:58:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of rick.p.edgecombe@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=rick.p.edgecombe@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga008.jf.intel.com ([10.7.209.65])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 22 Apr 2019 11:58:42 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,382,1549958400"; 
   d="scan'208";a="136417182"
Received: from linksys13920.jf.intel.com (HELO rpedgeco-DESK5.jf.intel.com) ([10.54.75.11])
  by orsmga008.jf.intel.com with ESMTP; 22 Apr 2019 11:58:42 -0700
From: Rick Edgecombe <rick.p.edgecombe@intel.com>
To: Borislav Petkov <bp@alien8.de>,
	Andy Lutomirski <luto@kernel.org>,
	Ingo Molnar <mingo@redhat.com>
Cc: linux-kernel@vger.kernel.org,
	x86@kernel.org,
	hpa@zytor.com,
	Thomas Gleixner <tglx@linutronix.de>,
	Nadav Amit <nadav.amit@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>,
	linux_dti@icloud.com,
	linux-integrity@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	akpm@linux-foundation.org,
	kernel-hardening@lists.openwall.com,
	linux-mm@kvack.org,
	will.deacon@arm.com,
	ard.biesheuvel@linaro.org,
	kristen@linux.intel.com,
	deneen.t.dock@intel.com,
	Nadav Amit <namit@vmware.com>,
	Rick Edgecombe <rick.p.edgecombe@intel.com>
Subject: [PATCH v4 22/23] tlb: provide default nmi_uaccess_okay()
Date: Mon, 22 Apr 2019 11:58:04 -0700
Message-Id: <20190422185805.1169-23-rick.p.edgecombe@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
References: <20190422185805.1169-1-rick.p.edgecombe@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Nadav Amit <namit@vmware.com>

x86 has an nmi_uaccess_okay(), but other architectures do not.
Arch-independent code might need to know whether access to user
addresses is ok in an NMI context or in other code whose execution
context is unknown.  Specifically, this function is needed for
bpf_probe_write_user().

Add a default implementation of nmi_uaccess_okay() for architectures
that do not have such a function.

Signed-off-by: Nadav Amit <namit@vmware.com>
Signed-off-by: Rick Edgecombe <rick.p.edgecombe@intel.com>
---
 arch/x86/include/asm/tlbflush.h | 2 ++
 include/asm-generic/tlb.h       | 9 +++++++++
 2 files changed, 11 insertions(+)

diff --git a/arch/x86/include/asm/tlbflush.h b/arch/x86/include/asm/tlbflush.h
index 90926e8dd1f8..dee375831962 100644
--- a/arch/x86/include/asm/tlbflush.h
+++ b/arch/x86/include/asm/tlbflush.h
@@ -274,6 +274,8 @@ static inline bool nmi_uaccess_okay(void)
 	return true;
 }
 
+#define nmi_uaccess_okay nmi_uaccess_okay
+
 /* Initialize cr4 shadow for this CPU. */
 static inline void cr4_init_shadow(void)
 {
diff --git a/include/asm-generic/tlb.h b/include/asm-generic/tlb.h
index b9edc7608d90..480e5b2a5748 100644
--- a/include/asm-generic/tlb.h
+++ b/include/asm-generic/tlb.h
@@ -21,6 +21,15 @@
 #include <asm/tlbflush.h>
 #include <asm/cacheflush.h>
 
+/*
+ * Blindly accessing user memory from NMI context can be dangerous
+ * if we're in the middle of switching the current user task or switching
+ * the loaded mm.
+ */
+#ifndef nmi_uaccess_okay
+# define nmi_uaccess_okay() true
+#endif
+
 #ifdef CONFIG_MMU
 
 /*
-- 
2.17.1

