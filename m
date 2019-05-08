Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2C55C04AAD
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 75D9A216B7
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:47:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 75D9A216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0EDB6B02BA; Wed,  8 May 2019 10:46:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A72236B02BB; Wed,  8 May 2019 10:46:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9102C6B02BD; Wed,  8 May 2019 10:46:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5703F6B02BB
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:46:15 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id d22so121618pgg.2
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:46:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=x4/Z50S2DWAd5rYId6h1vAEZLevWJ2xcvSwXBFBahYU=;
        b=rTs3LW4Y442i22owHhS66Db38yser9EzYK8tS6a3UVqYr2fczLDPGtFHiG3/aCAmIT
         BWijJJt1XuBowyl5eCGp8rQeIMVaguybr+EyZKT8W9bbWrn0tIKNGRnPQXpJLQ3s9QAR
         +C/IalMAYhZm556kOHN7zhAG6GnccFDvxXJScJWRj38T1A+RJjC9dv0xjcvLtpaGh3jm
         slZKaYtYVlyIIAATAGB+W+b8YIZZgzGJHGzIfTRAKlfTB8Z+c4IA2iGS3KXhI/b3IJkW
         ThqRzUFjQzZJli4MniTuMWp5rm2gVlmFvnp2otXCezaiQ1NGri6THWup3DImQtP6eAz1
         S/Jw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAXwBOVzFHwKlISoYKpYN3Gw74KH+WqjvKkp/fStbvNZHC7UUs/W
	xnq2PB9ZcO/t2mGf1SEQCC7sqTKPcdcn/xHSM3BXkBmrKvN/+iuveXrWzneg9M0GrK5q15N0brB
	PHuUytjD5EqLUQOMqsrtiIssctmXpJjkod0xw3WOubtnSzUgMq9zoHsp99R5NkSQOmA==
X-Received: by 2002:a63:2d41:: with SMTP id t62mr47971406pgt.113.1557326774990;
        Wed, 08 May 2019 07:46:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpbLZ4ymIks4q1Pv9VVEfIHNR7cQb2iNIBtZq2wD79o2kr9liFayxoIJwyEaK90weDuivm
X-Received: by 2002:a63:2d41:: with SMTP id t62mr47960942pgt.113.1557326684949;
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326684; cv=none;
        d=google.com; s=arc-20160816;
        b=xiDKcpFZ2hp393FCkWOiIuccMQ0SHwL4wncsritNzXmSPCMzXOyy9W1YzrBdchDsmg
         UtyNtj77S+pcy1AQArn9J/tBsOM2FZmATHlWmqWg1iEYwDN4kOCBOprEy06U1eW9WXDI
         4IWUGbvIqImbVrKsZg4yTc3jOCaCfvlpQOZBQx8QAmnCYL5BdR0aj4p3M7rd9IV5nU/5
         G6ieiDILeHx31eYeOr6a9HyuvFGk9lTKzFfJfI/FG6ZphBaUrSyzEUUvWB5Rmhh1miMn
         aRIpppNnev+kOxh6J4ojePoN2IkSpAhHs/oooGP8eE89jXCVimiCp4+464FOHYFqMMfs
         B33w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=x4/Z50S2DWAd5rYId6h1vAEZLevWJ2xcvSwXBFBahYU=;
        b=0OgsiqgCstek+mNWuxRofwS1rzM8lQdWGdYXUctSii+cPxfTTLcfpKN6VEabeVjwfW
         tSEnMapQwzhKL0Pd7Q6dQr+gGX1ypCqvbkhvRaydNVxvby5hA3lh8yz/FN1UsSzQ684u
         rYJb5GCej5YvePwSx7SNRli+jip8TKJVBasMbMDjvdZn/Qk4YpqXngAdc6UbxuMaaDrp
         piJ/2O5q0l1WO7Z5exy8tFyeyia/akjDujk4LE9n4sWxuNeO61ITAeCnlUyx57wySKwY
         meG1S0L+CvGYBkBbOWS9KC2xk1WJ85ibiitW46z4k/9ypyd2DRwtCwsRVBSilFie8Zku
         YI7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 90si19482350plb.86.2019.05.08.07.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:44 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) client-ip=192.55.52.43;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 192.55.52.43 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga005.fm.intel.com ([10.253.24.32])
  by fmsmga105.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:44 -0700
X-ExtLoop1: 1
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga005.fm.intel.com with ESMTP; 08 May 2019 07:44:40 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id 11A32AF7; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 28/62] keys/mktme: Set up PCONFIG programming targets for MKTME keys
Date: Wed,  8 May 2019 17:43:48 +0300
Message-Id: <20190508144422.13171-29-kirill.shutemov@linux.intel.com>
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

MKTME Key service maintains the hardware key tables. These key tables
are package scoped per the MKTME hardware definition. This means that
each physical package on the system needs its key table programmed.

These physical packages are the targets of the new PCONFIG programming
command. So, introduce a PCONFIG targets bitmap as well as a CPU mask
that includes the lead CPUs capable of programming the targets.

The lead CPU mask will be used every time a new key is programmed into
the hardware.

Keep the PCONFIG targets bit map around for future use during hotplug
events.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 42 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 9fdf482ea3e6..b5b44decfd3e 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -2,6 +2,7 @@
 
 /* Documentation/x86/mktme_keys.rst */
 
+#include <linux/cpu.h>
 #include <linux/init.h>
 #include <linux/key.h>
 #include <linux/key-type.h>
@@ -17,6 +18,8 @@
 
 static DEFINE_SPINLOCK(mktme_lock);
 struct kmem_cache *mktme_prog_cache;	/* Hardware programming cache */
+unsigned long *mktme_target_map;	/* Pconfig programming targets */
+cpumask_var_t mktme_leadcpus;		/* One lead CPU per pconfig target */
 
 /* 1:1 Mapping between Userspace Keys (struct key) and Hardware KeyIDs */
 struct mktme_mapping {
@@ -303,6 +306,33 @@ struct key_type key_type_mktme = {
 	.destroy	= mktme_destroy_key,
 };
 
+static void mktme_update_pconfig_targets(void)
+{
+	int cpu, target_id;
+
+	cpumask_clear(mktme_leadcpus);
+	bitmap_clear(mktme_target_map, 0, sizeof(mktme_target_map));
+
+	for_each_online_cpu(cpu) {
+		target_id = topology_physical_package_id(cpu);
+		if (!__test_and_set_bit(target_id, mktme_target_map))
+			__cpumask_set_cpu(cpu, mktme_leadcpus);
+	}
+}
+
+static int mktme_alloc_pconfig_targets(void)
+{
+	if (!alloc_cpumask_var(&mktme_leadcpus, GFP_KERNEL))
+		return -ENOMEM;
+
+	mktme_target_map = bitmap_alloc(topology_max_packages(), GFP_KERNEL);
+	if (!mktme_target_map) {
+		free_cpumask_var(mktme_leadcpus);
+		return -ENOMEM;
+	}
+	return 0;
+}
+
 static int __init init_mktme(void)
 {
 	int ret;
@@ -320,9 +350,21 @@ static int __init init_mktme(void)
 	if (!mktme_prog_cache)
 		goto free_map;
 
+	/* Hardware programming targets */
+	if (mktme_alloc_pconfig_targets())
+		goto free_cache;
+
+	/* Initialize first programming targets */
+	mktme_update_pconfig_targets();
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
+
+	free_cpumask_var(mktme_leadcpus);
+	bitmap_free(mktme_target_map);
+free_cache:
+	kmem_cache_destroy(mktme_prog_cache);
 free_map:
 	kvfree(mktme_map);
 
-- 
2.20.1

