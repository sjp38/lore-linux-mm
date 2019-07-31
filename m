Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 41952C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC2FC21874
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="IXEicb9B"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC2FC21874
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A17F8E0024; Wed, 31 Jul 2019 11:13:53 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 653E08E0022; Wed, 31 Jul 2019 11:13:53 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4CCC98E0024; Wed, 31 Jul 2019 11:13:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id F11598E0022
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w25so42570433edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Sg6bxLoMlRes885QhQrq9mVE221k6YoeytqqLikFglU=;
        b=V3RQLDJnwdxlHfDXIaQiCT3pcbn9CCLt8ThSLeWza9/6tgiQ37eID6lS3SyitCbU0y
         jSs1PYIaIx3rSZm3kFnQGHbpNMsOpcyZKGGJ1Cvt1sJJcYEHJOflWr1oYsjs9MiqUJGh
         z4u9nh1AVh/zLwpF1JKEsGigN692BTuYaMp/EElCX6Exnj3vyJ+/2dkMUuskjRUMBhbX
         0VAPhlVJ9UsNGCoKfETCe8CYvG6V6Zr3i2a77RcPaXRS9bMlcZcrdGIv93ziIr2uHCwl
         U4wpfDctzlckY9Pnx+ZLlEJr43CFCGO88cVM+jC3PxzozaGP7DqjMdz4oN8SjtFl5IQ8
         zLgA==
X-Gm-Message-State: APjAAAVN6OmxEN3zE7MuTUlzh51ZXXzByhUGQZByeKuR9pJsxR8qQClk
	hIMg4pjvSw6YNHHYk3APp6VzNdbVgnvRsGSIg/fVpMnUq02yUdlrJMZ7VTBtLVSCZ+WH8NjYxmV
	pzGz/a2yLHz8bnmxomW6E6i7R4zaSticsovcmV47bClXIVy0QD/I8oW7yMPYrY/Y=
X-Received: by 2002:aa7:d985:: with SMTP id u5mr106095318eds.222.1564586032559;
        Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
X-Received: by 2002:aa7:d985:: with SMTP id u5mr106095159eds.222.1564586031029;
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586031; cv=none;
        d=google.com; s=arc-20160816;
        b=XNNsaBLvacQ+P+UJml7LwSTZlx6x5KC2rbpOFJsEtpzTAFxqElmTWdMrrsWjuQ8wsK
         bYZreQKfTTGy/cV6S35AEDFeQYe1d19unxC3hLMuA/qE7TEX7iE3buiCTdQ2hj3I4USL
         cbp2KTayeiA3Qh5VvfKo8JnJ2wJPDP3F8hmsl7k1LdlZ4JLlmPei9ZmlRQhNxpKQaPpK
         G/YUtlBhTGo4Hj1mjqoNOXL9PJgglhBfZ06gdCpFO/QGwP3WTc5pG+M+50mufW3jJ8tY
         SMxoSleaJ6mdkeWWn96a820zlyEKOlxgo5hlKIsE8XcDyVIud1EprQu+JgLO2oUrPCZQ
         61yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Sg6bxLoMlRes885QhQrq9mVE221k6YoeytqqLikFglU=;
        b=R2X1Jgm4FGo92BQGrQN4gJgXbQmbBegw8+jopq+UG5YRCjbStT8gAB+INr7GFHYrGb
         AA/pH2IYy6En2rtFpP7ECVDt5lAkir3oYlUEqKj7pHOZlUVovAReTCvZoFpT81Bmz9Lq
         Vw09fW7mkW6jXBcIRLldUAqyomYz323zloz5nziNwPLx64mScWk791UaP2qIIbXLdUAu
         NahARX1iOhSuKQkWqJJPP6kZJpg6r1Z4XVUIwn6/C0vKTnnj38/pPSTd7T5ahkpRQPdR
         GwOA7duY5c+mmttDC3hw5RC0wldWU4AFBFQHdcdoJLGTpgaz/mUI2M+mCWTnt+jf/4vh
         Bq+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=IXEicb9B;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1sor18065153ejg.7.2019.07.31.08.13.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=IXEicb9B;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Sg6bxLoMlRes885QhQrq9mVE221k6YoeytqqLikFglU=;
        b=IXEicb9BiLYExfvQdFk4yaWrUYrtPs2P+FQ3xbHGAjJqFjc/Tjuex7il/QhhrAU3gJ
         1B0zMUjyCzuoPb2CGvJQ7dAtThjRe7D5+pWm017eXRhJ5OYV8RCaNICnYmJ009+sfvzW
         5NUoC3YokyUZoQB7sHYWULxV/2/f9TOcZ1/gPkf55duPH15/Vc4B/k9Omnv9/9Yv3CZU
         SeCOWTrZNYeWEwYFisHEi4GPFxy3g1PXFpyNHAYa2qaeY0jn6aM8/D2yPWi1YGyBcl0J
         4Kakk20YFCj7A+Ev81808+OjXvvP+eFNT1KH0KoZhORiukznX+DHLEGwFZnttRXtl3Xg
         KF/A==
X-Google-Smtp-Source: APXvYqzUHszTMCf0FqL0C12el1+4vYG6LYW8ml5drC1eMYBiTn4AhQh509XXdc2m4fyznpBj9tVZ/g==
X-Received: by 2002:a17:906:d052:: with SMTP id bo18mr88285067ejb.311.1564586030665;
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id u9sm17451892edm.71.2019.07.31.08.13.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id B852D103C08; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 29/59] keys/mktme: Set up PCONFIG programming targets for MKTME keys
Date: Wed, 31 Jul 2019 18:07:43 +0300
Message-Id: <20190731150813.26289-30-kirill.shutemov@linux.intel.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
References: <20190731150813.26289-1-kirill.shutemov@linux.intel.com>
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

Keep the PCONFIG targets bit map around for future use during CPU
hotplug events.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 42 ++++++++++++++++++++++++++++++++++++++
 1 file changed, 42 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 8ac75b1e6188..272bff8591b7 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -2,6 +2,7 @@
 
 /* Documentation/x86/mktme/ */
 
+#include <linux/cpu.h>
 #include <linux/init.h>
 #include <linux/key.h>
 #include <linux/key-type.h>
@@ -17,6 +18,8 @@
 static DEFINE_SPINLOCK(mktme_lock);
 static unsigned int mktme_available_keyids;  /* Free Hardware KeyIDs */
 static struct kmem_cache *mktme_prog_cache;  /* Hardware programming cache */
+static unsigned long *mktme_target_map;	     /* PCONFIG programming target */
+static cpumask_var_t mktme_leadcpus;	     /* One CPU per PCONFIG target */
 
 enum mktme_keyid_state {
 	KEYID_AVAILABLE,	/* Available to be assigned */
@@ -257,6 +260,33 @@ struct key_type key_type_mktme = {
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
@@ -278,9 +308,21 @@ static int __init init_mktme(void)
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
2.21.0

