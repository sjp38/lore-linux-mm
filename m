Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9669C04AB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8C18F208C3
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:17:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8C18F208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4699C6B02CB; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3B67D6B02D1; Thu,  6 Jun 2019 16:17:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DA2C76B02C7; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 982476B02C9
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:17:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f8so2314304pgp.9
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=4kJRqRgXrial8LUJDTZmTD0cX51XairXteK5iqWUgFw=;
        b=NzUTX88SYz0SYsGffgzze0+uiaISqnEnNFWJ/aXFwQKBoBDQDcr9KGqXEoi3VdgmhU
         vMhZSUyhBAQPebUpNqPIx66hCSbWLcOCRM6UtHo4MaxUPWze5SJmdDvke9TUdOKR0DdX
         G7PupuaVfIHSKLjlqnqC4HIwx5z2BzDUtma9Ps5iQ8IrMA5WXaBM7X+pegLY9Eybou7S
         CyXDnUBtlHtIQmwyLcIJ97GVHhLsOZEekj6R5tCdRuyt88uWR4gtKurFzOqIRps5LHSw
         Uzvb9gh0/eX0rfMTgil0una6HdJN9wIxGs0SANAdqA/YAzqHMphaIEiHVx1NfBk0eAjv
         mm9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAX+ru/f4QierASwQ32n/0hqPgHeAnVs178QDZgP3OlLuVTlq0ON
	T3miYrG1ET0YS1FwDCjMNpKXNG34V9qjrRfuQtGlFrTKqiWgsm/xC4i8HhZ5wObR6sZtDwsUPJi
	AV6bOLb0YrHtmXxJnoW/7raVeSgbKkuec6rCUEUfuZi1V8UzFRpesswyB4cUSAjnwcA==
X-Received: by 2002:a17:90a:62c6:: with SMTP id k6mr1624968pjs.7.1559852253303;
        Thu, 06 Jun 2019 13:17:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTnr083k7lH49BavJ2/Ee7QuOWUyN9y13Azj6o8BJoE1qSMfcUAF9Vlo0w2fCB3UQ4lN00
X-Received: by 2002:a17:90a:62c6:: with SMTP id k6mr1624914pjs.7.1559852252342;
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852252; cv=none;
        d=google.com; s=arc-20160816;
        b=vPT1tpTj3Wl2xg9j57APKfjjcLgm1RFNxfQBtpf93Z1O2ym2+8LaGvKBWd9qtQg/JW
         4B6gagrR8JqgVWjLbsUmw1vpYHuq7PdGga3iN3e6z3AUnSO+AdSHrIjzgHMvecbGuR50
         Xy0VqeX1GRAUAqoHwbO5mQpFygJg+Ac6Bv9dZHxicVxJ/bAQbeOuS62bTuF4AeAIZX8Q
         1Ir4F1rVuMzdsMqYxZJUvSDN/6twqCnByX0DCA6xhAVypswOJ6nXdWJrgFPz3BNHXp/E
         htCuih6efXgWTcChHWe68M1JCi9hD81QYIv7pLdB+kFivtuV1GfHXyiO1r/8mPdWj8h6
         BAog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=4kJRqRgXrial8LUJDTZmTD0cX51XairXteK5iqWUgFw=;
        b=GMDE+2tiuYcNkyaxKZMKeR8X0dIdwTTC+/asVxdn0K5wOslw+mqxKJHa1TEuMH0Fcc
         nRgMFfBmLMnLMc+d6buViT4o8M7p2MUj/qIH+MfjCbFjnHTJTrD4eIXOVMM6FHU785lo
         +LGfqdaJfYGZq1EVZV9/4JrknfosVAvhgebP+1qrl5SZBUIGdvNk/A5tg96e1b8rSg/S
         fHtovC3Y/WWiffwolcOhxs5eNmGbmW3hj6LcAPo+nCwCoyq75SNe8EK0/FIXyioJyPKJ
         hjM5euk3RKMT+GMMZJ1VVjQRNVVXkhmdwn/0Rc4/un+xvUK3eUsmILeCTrdX+zJCJgxN
         nMsA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id t11si66755plr.23.2019.06.06.13.17.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:17:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga001.fm.intel.com ([10.253.24.23])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:17:31 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by fmsmga001.fm.intel.com with ESMTP; 06 Jun 2019 13:17:31 -0700
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
To: x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	linux-kernel@vger.kernel.org,
	linux-doc@vger.kernel.org,
	linux-mm@kvack.org,
	linux-arch@vger.kernel.org,
	linux-api@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andy Lutomirski <luto@amacapital.net>,
	Balbir Singh <bsingharora@gmail.com>,
	Borislav Petkov <bp@alien8.de>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Eugene Syromiatnikov <esyr@redhat.com>,
	Florian Weimer <fweimer@redhat.com>,
	"H.J. Lu" <hjl.tools@gmail.com>,
	Jann Horn <jannh@google.com>,
	Jonathan Corbet <corbet@lwn.net>,
	Kees Cook <keescook@chromium.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Nadav Amit <nadav.amit@gmail.com>,
	Oleg Nesterov <oleg@redhat.com>,
	Pavel Machek <pavel@ucw.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	"Ravi V. Shankar" <ravi.v.shankar@intel.com>,
	Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>,
	Dave Martin <Dave.Martin@arm.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [PATCH v7 06/14] x86/cet/ibt: ELF header parsing for IBT
Date: Thu,  6 Jun 2019 13:09:18 -0700
Message-Id: <20190606200926.4029-7-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200926.4029-1-yu-cheng.yu@intel.com>
References: <20190606200926.4029-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Look in .note.gnu.property of an ELF file and check if Indirect
Branch Tracking needs to be enabled for the task.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/kernel/process_64.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/x86/kernel/process_64.c b/arch/x86/kernel/process_64.c
index 5fa0d9ab18f1..16dae646f633 100644
--- a/arch/x86/kernel/process_64.c
+++ b/arch/x86/kernel/process_64.c
@@ -856,6 +856,12 @@ int arch_setup_property(void *ehdr, void *phdr, struct file *f, bool inter)
 		if (r < 0)
 			return r;
 	}
+
+	if (cpu_feature_enabled(X86_FEATURE_IBT)) {
+		if (property & GNU_PROPERTY_X86_FEATURE_1_IBT)
+			r = cet_setup_ibt();
+	}
+
 	return r;
 }
 #endif
-- 
2.17.1

