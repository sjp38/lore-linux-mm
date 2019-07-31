Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1BEE1C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C814C20693
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:39 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="nvqdVZ7h"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C814C20693
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBDDA8E002A; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD32F8E0030; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FC268E002A; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4238E8E0030
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:59 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i44so42652135eda.3
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=bD/5ZInA5DBfNF/OoolUD2uLCIaOC1DGsUwSCxp+njs=;
        b=VIzL4VAPT63JmqODvU+FF2JFcKiMBCtmRAmZFGS2xI5pAdiaxUNLXAnxhv8tvgAWiC
         1i0nIiBDGIP9cmj9tqSwkz9cq8GEgpuI/Mhl4xXEiLk0PDFxVEZdQnxGQqRyRp0Ej+tA
         naml+my21KzhEIiIvmFO/st1YgA31LbV1Me8Pi2O6xK16JAnquOuQM97cpqnbz89RHel
         P3aduIjAjpHySwDw+IQInqslxOsI+zrTyjjApoCWBB82WcTToZmTpzrGL5pl3d62aSgF
         4cLLBvU7u2QlZyIrp6FdTeSODZpf3GgB8pvRONgz5UxoS/93bo4+zb5gnfT9XKJDZP0g
         ntcg==
X-Gm-Message-State: APjAAAUS04WwyCmBsCnZNYjDDy4TLJVGXeZ1fHIeYVJJJyZp5yMaIiRS
	GTooqkvt55MqBytJuVKYjGF8F+2LiLTBEGlObSc3Tg8Ah9Ej2ZbRbvRY2lUi+inkpZvqK6ANsGF
	D1QJeBu8iRVVRgE25VZ9F2OWQgTEYLitHoiq+NPb2hF/0F82Gg+XtAdwHgKrSWBs=
X-Received: by 2002:a50:e718:: with SMTP id a24mr106273300edn.91.1564586038834;
        Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
X-Received: by 2002:a50:e718:: with SMTP id a24mr106273185edn.91.1564586037618;
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586037; cv=none;
        d=google.com; s=arc-20160816;
        b=NmC8724Zj/0RlCcCjVwJz0WHV2EY4X2DUznZDkQzjC84ZMk37P2cEo6x0ICZwAl9YA
         cMos8UrEqm+/UydvU1yU0rvg+6ogIlJoL6QhJ4+EU6wqlR8TQT73/cAlh9bFarbQlPe9
         EX2ZvBsBOekQpxcHYbEJ4fjWAbmMkfbNJFJDjBS+SSXFsbpbFFWN1C+osQfTzpndrJ4U
         JvRV1xmmwF7CuZdxoMgexUfpB5flluKGdp0RaLSCnC5NLGGo5l6NIgJPFoe2rhuroTBG
         jrodVms/0T8YWSjZ1rYnvWoLeoo/1yhn/Q4AjzMiGfES0eexVUM2Hj73phWe9jSAPauY
         XaZw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=bD/5ZInA5DBfNF/OoolUD2uLCIaOC1DGsUwSCxp+njs=;
        b=Uzt0iMYvhfeAiXBipuOSIpzBUA8PBj/aI7+qUmLqnEHxs93X7YFULz8NgH+1mnzc5R
         8VPa3FtxeywTbgoUPLoKamQb6zf+dRjwgzF+uBaBCub0XQSpZgyHBIETSjYbC9pd8EYe
         T7WEHtJqmYuvgoKtU1eldOHSuvVUAX48kqk7/PX7QidYjeF667Hj9460wgzqf6ub0HoH
         57goKO2OR85rMU8AdLI49NLs3tlAb54Ye6TFW+ot4HZ5L9OKPa+g3ctPFPE89osJvSkS
         qn4DkNUrUFofaU3OQZbNTZquTvBwtNY51A9ZF4eXST4B60bHHJNvM20SRr6Tcd1CRGck
         T37w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=nvqdVZ7h;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c38sor51978791eda.0.2019.07.31.08.13.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=nvqdVZ7h;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=bD/5ZInA5DBfNF/OoolUD2uLCIaOC1DGsUwSCxp+njs=;
        b=nvqdVZ7hy8prTTJcbUZBwkmbx2dG13l4tJOjU/HGiWPNPCIzhkiP7BT5p8Q5xWDndr
         7DeAzS8uAbr6+O45Oq+aNxw5yIDCtTUXGB0id3g7Z8mpUiISvVh8+Qdpp6w9Mrz78JiC
         0VezF9Twz7YfGrVqrIO2CaQOxV5IahFa9jvmh6yBk00rx18AqNPPp2V83WMw5/RHJxZK
         V7Ij2TTHXT4PuakKHcAQZMB0LBshUp7ZbQOCUWMzIrguS1msbfDi5NilYa6XZJJc6A82
         xAVNYZPhVRKGVGB4dKsMF59lYW4aPwm4ovfr9mL7D2xAkl0s4z/mmm5UiL+UO1fObzyu
         5wPg==
X-Google-Smtp-Source: APXvYqxJIvkHF7kejGb362uxw7wEOxIDocRJ4jXYfh9K6XIBqdmcEBR8hDmMszbdv7iLHfJZFlKGzw==
X-Received: by 2002:a05:6402:6d0:: with SMTP id n16mr25572624edy.168.1564586037300;
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id t2sm17397627eda.95.2019.07.31.08.13.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:54 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id C65041044A6; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 31/59] keys/mktme: Set up a percpu_ref_count for MKTME keys
Date: Wed, 31 Jul 2019 18:07:45 +0300
Message-Id: <20190731150813.26289-32-kirill.shutemov@linux.intel.com>
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

The MKTME key service needs to keep usage counts on the encryption
keys in order to know when it is safe to free a key for reuse.

percpu_ref_count applies well here because the key service will
take the initial reference and typically hold that reference while
the intermediary references are get/put. The intermediaries in this
case will be encrypted VMA's,

Align the percpu_ref_init and percpu_ref_kill with the key service
instantiate and destroy methods respectively.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 39 +++++++++++++++++++++++++++++++++++++-
 1 file changed, 38 insertions(+), 1 deletion(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 3c641f3ee794..18cb57be5193 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -8,6 +8,7 @@
 #include <linux/key-type.h>
 #include <linux/mm.h>
 #include <linux/parser.h>
+#include <linux/percpu-refcount.h>
 #include <linux/string.h>
 #include <asm/intel_pconfig.h>
 #include <keys/mktme-type.h>
@@ -71,6 +72,26 @@ int mktme_keyid_from_key(struct key *key)
 	return 0;
 }
 
+struct percpu_ref *encrypt_count;
+void mktme_percpu_ref_release(struct percpu_ref *ref)
+{
+	unsigned long flags;
+	int keyid;
+
+	for (keyid = 1; keyid <= mktme_nr_keyids(); keyid++) {
+		if (&encrypt_count[keyid] == ref)
+			break;
+	}
+	if (&encrypt_count[keyid] != ref) {
+		pr_debug("%s: invalid ref counter\n", __func__);
+		return;
+	}
+	percpu_ref_exit(ref);
+	spin_lock_irqsave(&mktme_lock, flags);
+	mktme_release_keyid(keyid);
+	spin_unlock_irqrestore(&mktme_lock, flags);
+}
+
 enum mktme_opt_id {
 	OPT_ERROR,
 	OPT_TYPE,
@@ -199,8 +220,10 @@ static void mktme_destroy_key(struct key *key)
 	unsigned long flags;
 
 	spin_lock_irqsave(&mktme_lock, flags);
-	mktme_release_keyid(keyid);
+	mktme_map[keyid].key = NULL;
+	mktme_map[keyid].state = KEYID_REF_KILLED;
 	spin_unlock_irqrestore(&mktme_lock, flags);
+	percpu_ref_kill(&encrypt_count[keyid]);
 }
 
 /* Key Service Method to create a new key. Payload is preparsed. */
@@ -216,9 +239,15 @@ int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 	if (!keyid)
 		return -ENOKEY;
 
+	if (percpu_ref_init(&encrypt_count[keyid], mktme_percpu_ref_release,
+			    0, GFP_KERNEL))
+		goto err_out;
+
 	if (!mktme_program_keyid(keyid, *payload))
 		return MKTME_PROG_SUCCESS;
 
+	percpu_ref_exit(&encrypt_count[keyid]);
+err_out:
 	spin_lock_irqsave(&mktme_lock, flags);
 	mktme_release_keyid(keyid);
 	spin_unlock_irqrestore(&mktme_lock, flags);
@@ -405,10 +434,18 @@ static int __init init_mktme(void)
 	/* Initialize first programming targets */
 	mktme_update_pconfig_targets();
 
+	/* Reference counters to protect in use KeyIDs */
+	encrypt_count = kvcalloc(mktme_nr_keyids() + 1, sizeof(encrypt_count[0]),
+				 GFP_KERNEL);
+	if (!encrypt_count)
+		goto free_targets;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
 
+	kvfree(encrypt_count);
+free_targets:
 	free_cpumask_var(mktme_leadcpus);
 	bitmap_free(mktme_target_map);
 free_cache:
-- 
2.21.0

