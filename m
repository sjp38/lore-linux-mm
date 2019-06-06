Return-Path: <SRS0=utKX=UF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 732F8C28EB5
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 46150208E4
	for <linux-mm@archiver.kernel.org>; Thu,  6 Jun 2019 20:15:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 46150208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6EAC96B02A0; Thu,  6 Jun 2019 16:15:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 69E5E6B02A1; Thu,  6 Jun 2019 16:15:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CDD26B02A3; Thu,  6 Jun 2019 16:15:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id EDB4D6B02A0
	for <linux-mm@kvack.org>; Thu,  6 Jun 2019 16:15:25 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id g9so2285251pgd.17
        for <linux-mm@kvack.org>; Thu, 06 Jun 2019 13:15:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=+sTJWF6AyOPSr6M0VfrE46RFU8heKaSNwIJptODPH8I=;
        b=Obc1/GH+Yv5nSsrMkJ0QAqjdsNeeAYMP21ZiQaY2PaGZ/fbaKZB9S7XgeQcGJ76bu1
         RwFdRtD+JvnVL+6LJTWknak7IVBDIdEpyobRUK15SNdPmvBp3k5Mfld5RY/JQOHGl9fW
         uMxYnFG0KB5EU78c5lLG+TQaUZ+MZRnGZPeaIpfTH/89OL6BUzaogWDyb+kbtKjNl7vk
         P2V8DO49qrrwiPW+4mEPWrBCrxE/B6Cka6IHxPfOnMa3wzaWmMKrrYGQFhHNoeeq3ep0
         WGxQsgJgbhOsM+IEsPKUF2iZgPDJggNQp2FrHAXyNlx6zmM3K/727FD8JDL8C1EvEFoo
         SKiw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVQ2eN31qa9cg1NLLT9EBfGGFHe0yHQdlDZHyIdhIJJ2GI0AxQj
	H0MnbRSKgNNkBSJ92i7Ee2F64tXvsFgWbtzqTVumlUbK0B323MZjj8xdZJwbAPIU5Ax23uUODjn
	yttGXgHqGZIb9hSmhQUNbZRh3fbvQQDGWAvvpISuSLOKY59TqcnhkZdiTqFfeT8XGBg==
X-Received: by 2002:a17:90a:2e89:: with SMTP id r9mr1616856pjd.117.1559852125651;
        Thu, 06 Jun 2019 13:15:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxUHICzcUzGZOuuqv3C6gE/Cz/BhCfttS4fszVZS620aSpNTdDhCowTBWQP0sW8gn2UFTrv
X-Received: by 2002:a17:90a:2e89:: with SMTP id r9mr1616794pjd.117.1559852124700;
        Thu, 06 Jun 2019 13:15:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559852124; cv=none;
        d=google.com; s=arc-20160816;
        b=0x8KbWjL2b2D7JGqqYAzvOueZKwBZ2iTv3zgXxVsd4rWJNfso3qtX8C6q13Gmt2Pqo
         CmoL3PMW1seGPLC9O9/nW1o5YwiqGX/PSutDrmU4tf42NSXuPVLAUWDjEJHOMSwMShaT
         NYYVMjtXlnkjCX/lZTPa/aDpeK7e6N+lgy48gCLWH5vN77MHpFkxKqU2WZgaC1t5ztKt
         Aa/3aoWIYegFoIpvkUUAQX/lmSlX2+idRDuOBYPxEPz+ZlX0VSTCrt55slqY0i+uUrB0
         fnsThCjGAdmn+tN3goWdEiipqnXMTldQ5BhvrHC68zWfStjkzEBd5tXhNIt1PM5k/9Di
         DwPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=+sTJWF6AyOPSr6M0VfrE46RFU8heKaSNwIJptODPH8I=;
        b=ZQUPfAAkQ0X0ZKGeRI58JU/ky7mcYz2mY4xUgBnZC7g3vSdwNpNwbCchvl15gTIvUD
         nC8zWF1nlhopnaZvt2cx7yy7c+bLb8YPdtn3pGhAuQs4+7gJP7hEvydfq9hnB8y7Xqp6
         9GOGan+QmCAJH6vbaTTaaEcCxVqwvIBsGeqwqeztpTHNbgSZL0mfCLIs7fQIBjy5raH6
         g8iUmYO2JQF3NOXzH+VhrrXV2nTUTUMgcul7iKdEObiFzgjwDcpX5d9omu1ZK2BcGvBD
         lRJowc8Gb3ngopANmvUfNsM1TC9XHq6GaxT2+JDHb/tWXayDeHiVvFYj1XTvUHuVo0qv
         FQvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id r142si2785300pfc.219.2019.06.06.13.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jun 2019 13:15:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yu-cheng.yu@intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=yu-cheng.yu@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga002.jf.intel.com ([10.7.209.21])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 06 Jun 2019 13:15:24 -0700
X-ExtLoop1: 1
Received: from yyu32-desk1.sc.intel.com ([143.183.136.147])
  by orsmga002.jf.intel.com with ESMTP; 06 Jun 2019 13:15:22 -0700
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
Subject: [PATCH v7 12/27] drm/i915/gvt: Update _PAGE_DIRTY to _PAGE_DIRTY_BITS
Date: Thu,  6 Jun 2019 13:06:31 -0700
Message-Id: <20190606200646.3951-13-yu-cheng.yu@intel.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190606200646.3951-1-yu-cheng.yu@intel.com>
References: <20190606200646.3951-1-yu-cheng.yu@intel.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Update _PAGE_DIRTY to _PAGE_DIRTY_BITS in split_2MB_gtt_entry().

In order to support Control-flow Enforcement (CET), _PAGE_DIRTY is
now _PAGE_DIRTY_HW or _PAGE_DIRTY_SW.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 drivers/gpu/drm/i915/gvt/gtt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/gpu/drm/i915/gvt/gtt.c b/drivers/gpu/drm/i915/gvt/gtt.c
index 244ad1729764..44f35880d771 100644
--- a/drivers/gpu/drm/i915/gvt/gtt.c
+++ b/drivers/gpu/drm/i915/gvt/gtt.c
@@ -1185,7 +1185,7 @@ static int split_2MB_gtt_entry(struct intel_vgpu *vgpu,
 	}
 
 	/* Clear dirty field. */
-	se->val64 &= ~_PAGE_DIRTY;
+	se->val64 &= ~_PAGE_DIRTY_BITS;
 
 	ops->clear_pse(se);
 	ops->clear_ips(se);
-- 
2.17.1

