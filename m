Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10B20C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C5F78216F4
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 14:46:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C5F78216F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8C5986B029C; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 879606B02A5; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 47E7E6B029C; Wed,  8 May 2019 10:44:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 05D8A6B029F
	for <linux-mm@kvack.org>; Wed,  8 May 2019 10:44:52 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id d21so12791259pfr.3
        for <linux-mm@kvack.org>; Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=28xTjItZNk8xmIKVtdFAjCqOM3U8CMWMQgK9dL8uH64=;
        b=Gk59464pz+1NrTjylUCUC0bpYJ3iKNdOrLKMtMdpToa4OrXZV4SyvceLl9kjBpzEzS
         Z0oBXJWeXguwHvkXI4RpEMenjoFb8jJK5EXXbt22pcBlGJ+o+bTYiL19awCvMr3O6J1L
         lSvyg+9gFO1ErXOM66IapWwLrabw0bmCQToWtPT0GiCiZ7guZTwf0U2n8YQcFxyKgITh
         azwhOp6QAe7Js8QySwjGCGoAGZon1g7+r+qNgd4pasdH4HyR5WobFhjTyJPPPr6lxd/d
         Y9KJCfiKYqTNIrsiQ3VMDEb9X42nIpFKuyD0Q5zlvaHi60UOltgPUriICMvadQbPhrYY
         lhWQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVzPxO3o27mEOia0Rfgc2H6AP8RgX1rY3/L2Mgpa+EsvyXF6ITR
	twr8psQaj7EHnwswIswkjr0ZIQ0+MUIfOPenMrNkw3/2W/e7qbczYx0B4XTvObKp6FAIkd67Up3
	cRT519ycZahs3d4901BoUW1mRtajOCK75vfs3K6RHLwLhNy9sTWKkNRbHQldleDQu9A==
X-Received: by 2002:a17:902:868e:: with SMTP id g14mr48733829plo.183.1557326691564;
        Wed, 08 May 2019 07:44:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwmr/nrpBgZ8Ldu+Nr8LeTn3GJnVJCKH45Muwikhxnx8Ts931xidLIhbA83o7KULSZelc9b
X-Received: by 2002:a17:902:868e:: with SMTP id g14mr48733697plo.183.1557326690329;
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557326690; cv=none;
        d=google.com; s=arc-20160816;
        b=pxPj01szZ79wX8D2Ad2REEDIZK7i7PeWAkcINf+8+KfdZXnBtjXUR7zfCtA/hHOMQS
         YRukUSR/G1plKNPQI/oj81jfwgETYXWxsOadxUGY328WgHkumKwrWVvUmKMY0FHidRyv
         TIBfMbPr0XnA9f31ffSieuc90CMWl/OPoKfP4AEFh/SoLvhw9YfWl8V7i1xrhdSRdrpq
         pQtwjJwRfvx0RAYjYKy+OG/68sJJ4Qo7Xb58AQyPcHu2fyWmx2tIA0Zb6DLDap17Hcd0
         pbSqfcPQ8kCeyLF4efpGLR+doEKU9rkloTMj1CW4VMUITZ45Puspff73sufq4Ibjgzm9
         ipkg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=28xTjItZNk8xmIKVtdFAjCqOM3U8CMWMQgK9dL8uH64=;
        b=tnna+KoKXhMJ0AKqhl8vbHlO4yB6MVgH0c6y+SApR4n6clDkIizNqc2vf1aVjSnftA
         wDXPuzICT1RUZ/1hwGLO7d7OmRsmuerVVzFO/U/smGrvNAW1xGVnjr15wB1iTTdzPTd+
         SYwIHYSldzypqDlvtJ8Bn+J2DiD7BCLWasb9k2lt0KFXDIX0FsuD9mIiExe2VcrcOzal
         UylPyMyBVF8egrNWWlpIDfZoTH1NcHRoa/Xicb8YmbVgij7cqc/ueBBkAVIVTCkFsyFw
         AOIZ82RhZMWXUfYdHh9HZjcavhJDNmjA08Qvf02F7FM9nx1PKbi95ZphzIKjeAV9jR77
         eeWw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id q8si24066889pgf.3.2019.05.08.07.44.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 07:44:50 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) client-ip=134.134.136.20;
Authentication-Results: mx.google.com;
       spf=pass (google.com: best guess record for domain of kirill.shutemov@linux.intel.com designates 134.134.136.20 as permitted sender) smtp.mailfrom=kirill.shutemov@linux.intel.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga002.fm.intel.com ([10.253.24.26])
  by orsmga101.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 08 May 2019 07:44:50 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.60,446,1549958400"; 
   d="scan'208";a="169656569"
Received: from black.fi.intel.com ([10.237.72.28])
  by fmsmga002.fm.intel.com with ESMTP; 08 May 2019 07:44:44 -0700
Received: by black.fi.intel.com (Postfix, from userid 1000)
	id BF156D4A; Wed,  8 May 2019 17:44:30 +0300 (EEST)
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
Subject: [PATCH, RFC 41/62] keys/mktme: Support memory hotplug for MKTME keys
Date: Wed,  8 May 2019 17:44:01 +0300
Message-Id: <20190508144422.13171-42-kirill.shutemov@linux.intel.com>
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

Newly added memory may mean that there is a newly added physical
package.  Intel platforms supporting MKTME need to know about the
new physical packages that may appear during MEM_GOING_ONLINE
events.

Add a memory notifier for MEM_GOING_ONLINE events where MKTME
can evaluate this new memory before it goes online.

MKTME will quickly NOTIFY_OK in MEM_GOING_ONLINE events if no MKTME
keys are currently programmed. If the newly added memory presents
an unsafe MKTME topology, that will be found and reported during the
next key creation attempt. (User can repair and retry.)

When MKTME keys are currently programmed, MKTME will evaluate the
platform topology, detect if a new PCONFIG target has been added,
and program that new pconfig target if allowable.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 57 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 57 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 489dddb8c623..904748b540c6 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -8,6 +8,7 @@
 #include <linux/init.h>
 #include <linux/key.h>
 #include <linux/key-type.h>
+#include <linux/memory.h>
 #include <linux/mm.h>
 #include <linux/parser.h>
 #include <linux/percpu-refcount.h>
@@ -626,6 +627,56 @@ static int mktme_program_new_pconfig_target(int new_pkg)
 	return ret;
 }
 
+static int mktme_memory_callback(struct notifier_block *nb,
+				 unsigned long action, void *arg)
+{
+	unsigned long flags;
+	int ret, new_target;
+
+	/* MEM_GOING_ONLINE is the only mem event of interest to MKTME */
+	if (action != MEM_GOING_ONLINE)
+		return NOTIFY_OK;
+
+	/* Do not allow key programming during hotplug event */
+	spin_lock_irqsave(&mktme_lock, flags);
+
+	/*
+	 * If no keys are actually programmed let this event proceed.
+	 * The topology will be checked on the next key creation attempt.
+	 */
+	if (!mktme_map->mapped_keyids) {
+		mktme_allow_keys = false;
+		ret = NOTIFY_OK;
+		goto out;
+	}
+	/* Do not allow this event if it creates an unsafe MKTME topology */
+	if (!mktme_hmat_evaluate()) {
+		ret = NOTIFY_BAD;
+		goto out;
+	}
+	/* Topology is safe. Is there a new pconfig target? */
+	new_target = mktme_get_new_pconfig_target();
+
+	/* No new target to program */
+	if (new_target < 0) {
+		ret = NOTIFY_OK;
+		goto out;
+	}
+	if (mktme_program_new_pconfig_target(new_target))
+		ret = NOTIFY_BAD;
+	else
+		ret = NOTIFY_OK;
+
+out:
+	spin_unlock_irqrestore(&mktme_lock, flags);
+	return ret;
+}
+
+static struct notifier_block mktme_memory_nb = {
+	.notifier_call = mktme_memory_callback,
+	.priority = 99,				/* priority ? */
+};
+
 static int __init init_mktme(void)
 {
 	int ret, cpuhp;
@@ -679,10 +730,16 @@ static int __init init_mktme(void)
 	if (cpuhp < 0)
 		goto free_store;
 
+	/* Memory hotplug */
+	if (register_memory_notifier(&mktme_memory_nb))
+		goto remove_cpuhp;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	unregister_memory_notifier(&mktme_memory_nb);
+remove_cpuhp:
 	cpuhp_remove_state_nocalls(cpuhp);
 free_store:
 	kfree(mktme_key_store);
-- 
2.20.1

