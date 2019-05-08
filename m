Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43CF2C04AAB
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0101E216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:05 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0101E216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9F7906B0299; Wed,  8 May 2019 10:44:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 831106B029C; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1EA466B0294; Wed,  8 May 2019 10:44:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CC5886B0294
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:50 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i8so10360108pfo.21
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=63N4Scvmymr/HxGljrqFhwEljj66qpjYxN4DGuSs010=;
        b=nc8FEzIBK8FOtYvN4mfSVrZAz57PHOUvETi4qMhEq2lDmyOn/Wqhgr1Iu/3EUbI/GT
         jkqlO0QosBRFPpoFEKoXOR/8sAc5+VxSMBQWJEUPj9KvoTifKvVbvcDqElHreoiFvvi3
         q3hd3q5dYfUXKiuWy/tkANhQWn1YYKfAQOjuLLKCkOhwLbqV202eYYhE5P/XgIhuF/kU
         teISMZ7GsUsZyqyeQoVWhgMNGvrwatqZiPMsCVdcB/fcYah35joFkG6Hbq3GqNhrQc63
         MaaFT4zt/sPwHDwUdblWr62ZqVzvXUKuOhYTTtXr0nNHW4rUG+3xrrl1JzOcNuDlo5cO
         LChQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVdSE6lzXvyb3Llmch9YtQzeHaiYjlGsWjLBNpH/2DKXEHngPyO
	eWJIFiE0o5xgRVCoPTn6A0IUja6aGQmPldADNBeLwMVx/0LnsGKBk8qhKWuLfTtErptpNRIWvz/
	kbG3k40BwuiCI5Q/rVdGrV3h/WtsoXe23z1JwuKJzyWowgfWonm5OBrilnGLBhNn4xg==
X-Received: by 2002:a62:2a55:: with SMTP id q82mr46765316pfq.90.1557326690485;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz/isOGu4GN31NysvdwC67asqbOrY7gZ0WFYaJBIFMHpftDnFYiTpAIHeqjv/gtb5Gfnjph
X-Received: by 2002:a62:2a55:: with SMTP id q82mr46765228pfq.90.1557326689713;
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326689; cv=none;
        d=google.com; s=arc-20160816;
        b=dj3MP9sMMREOurQ4QbeeeplosUAqH3IvX0izx9vIwBSewNw1kDNe3xxf3Bvx4wRAnH
         zTqgLeeEK+w0Nht98NuAkx9oMMwWHP4uWZKJkPt1YTw5yQykPtJRhWI4RNf2GDwEfRzy
         rfFS0luSQpGX5ldCkLqLmJV8jRmaoInRoXk+idTLTOVNjNb6h7oQfyGOGS6Y5zBT91L1
         FeSz/TF8NKpbGeY7/tTS3HTxHab5TUnUqO81EGP74hvsS/Jyod4p9GUgZwBMU8q5x340
         E/SnyurKWbGaOcjqOfSS/XzZMsI7bN1B9iZHQZOT9Ml9fGvDbAW3v3PkQi57Mv2ADNf6
         He2Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=63N4Scvmymr/HxGljrqFhwEljj66qpjYxN4DGuSs010=;
        b=qUlcAJVaWCMh/BmJfFh34R21V+4rk/0H9ata3Sp4eN3siGc/7IBauQF856lmJ8FPD7
         koPRfpjBWjf8FnrjN6UuzoWegXAawVH9uEPa7Ivk6bJLC+JV4ICU/j1nOwrl3VKiI3Kd
         eD/wvcq8LHZDqdJYavvu+8pGpsGhzPEiUrVZB2OJG8ONSa4j0ZUq854fBHRIHsxz1SSJ
         NY7nZbxd1KCzJiPS6K3SZdLw3P+0R0JKL6JMdtIjb3MmPXrjzz7CJ6ibpt7sp7Lv6dcz
         +ccNxMiMQ/i5n/4J0Zddxv9UOOtI6zKhRWwFgZP+7oU6DzmyLQhE+uoXNNDtubdIQQEm
         yABA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id s184si23372828pfs.275.2019.05.08.07.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:49 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) client-ip=192.55.52.136;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.136 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga006.jf.intel.com ([10.7.209.51])
  by fmsmga106.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:49 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by orsmga006.jf.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id CCCC7D8A; Wed,  8 May 2019 17:44:30 +0300 (EEST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
To: Andrew Morton <akpm@linux-foundation.org>,
	x86@kernel.org,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Borislav Petkov <bp@alien8.de>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@amacapital.net>,
	David Howells <dhowells@redhat.com>
Cc: Kees Cook <keescook@chromium.org>,
	Dave Hansen <dave.hansen@intel.com>,
	Kai Huang <kai.huang@linux.intel.com>,
	Jacob Pan <jacob.jun.pan@linux.intel.com>,
	Alison Schofield <alison.schofield@intel.com>,
	linux-mm@kvack.org,
	kvm@vger.kernel.org,
	keyrings@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH, RFC 42/62] mm: Generalize the mprotect implementation to support extensions
Date: Wed,  8 May 2019 17:44:02 +0300
Message-Id: <20190508144422.13171-43-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
References: <20190508144422.13171-1-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alison Schofield <alison.schofield@intel.com>

Today mprotect is implemented to support legacy mprotect behavior
plus an extension for memory protection keys. Make it more generic
so that it can support additional extensions in the future.

This is done is preparation for adding a new system call for memory
encyption keys. The intent is that the new encrypted mprotect will be
another extension to legacy mprotect.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/mprotect.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/mprotect.c b/mm/mprotect.c
index e768cd656a48..23e680f4b1d5 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -35,6 +35,8 @@
 
 #include "internal.h"
 
+#define NO_KEY	-1
+
 static unsigned long change_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 		unsigned long addr, unsigned long end, pgprot_t newprot,
 		int dirty_accountable, int prot_numa)
@@ -452,9 +454,9 @@ mprotect_fixup(struct vm_area_struct *vma, struct vm_area_struct **pprev,
 }
 
 /*
- * pkey==-1 when doing a legacy mprotect()
+ * When pkey==NO_KEY we get legacy mprotect behavior here.
  */
-static int do_mprotect_pkey(unsigned long start, size_t len,
+static int do_mprotect_ext(unsigned long start, size_t len,
 		unsigned long prot, int pkey)
 {
 	unsigned long nstart, end, tmp, reqprot;
@@ -578,7 +580,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot)
 {
-	return do_mprotect_pkey(start, len, prot, -1);
+	return do_mprotect_ext(start, len, prot, NO_KEY);
 }
 
 #ifdef CONFIG_ARCH_HAS_PKEYS
@@ -586,7 +588,7 @@ SYSCALL_DEFINE3(mprotect, unsigned long, start, size_t, len,
 SYSCALL_DEFINE4(pkey_mprotect, unsigned long, start, size_t, len,
 		unsigned long, prot, int, pkey)
 {
-	return do_mprotect_pkey(start, len, prot, pkey);
+	return do_mprotect_ext(start, len, prot, pkey);
 }
 
 SYSCALL_DEFINE2(pkey_alloc, unsigned long, flags, unsigned long, init_val)
-- 
2.20.1

