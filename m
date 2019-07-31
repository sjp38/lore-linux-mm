Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76D44C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2A2CD21850
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="F0MT0Anr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2A2CD21850
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D853F8E0021; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBE108E0024; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A72918E0021; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 53DD38E0022
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:52 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id l14so42632175edw.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1BQJGkT0s+shkdXKpDMkrADfSTioqQt/ZZz1bLqTUmQ=;
        b=SrUHwLCZzlgFzlAq1yyo24AlHOpjjCi7mE162kvP7d+J4OHpLxO+2gGeE43TQ4hkE+
         7g8cKQhWQPijGEijMX2e/0CmvKhgpCf+/tn/bwmtRPGqNEbQFtGKvk2QQ6j0SGJPX9t1
         DX9eEghWcfp+DESHjt5Qv9G0r1HOhmgF/SU8cGcbSOjJAkvWjRb2vV9NFQkSkwU2bVzc
         b/hLQ5N6bdgCCkQ/Zti7MxNWPiGRnX17EwdX/JZ19hlDHSUkSRXxlKWh8vJyVb/YJ0WA
         Sr5fHT2sq3SyJju/5nO2Cy8UWytj4zkWLftmWkzAj88+4EVXIoXQIxIYVSgpxCNFEbBK
         0D5w==
X-Gm-Message-State: APjAAAWbpGHo9c9lLO9Po842LS77pBRUu8+NiuGbfuhFGwmI99xsk2eO
	SfuvWhNbipOpWlqUhnso21D9/dWwMt/UibpIHMMsgDboWyAqYWFdAgaVMohbOFUsvXcqmeWAAdn
	tH5ftepY52f69g+O2mIkWS373vgAsHukzBLr9Js598HXFs5t9qfEJSF8vuDrQBqw=
X-Received: by 2002:a50:ac46:: with SMTP id w6mr111922326edc.238.1564586031914;
        Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
X-Received: by 2002:a50:ac46:: with SMTP id w6mr111922188edc.238.1564586030664;
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586030; cv=none;
        d=google.com; s=arc-20160816;
        b=b1/rK3DToRZjlAUxYCnAgboHoc7gRUTme4ZKJzyPqmHF8dpPrYA8nulfpumcTKG8ty
         TUE6GOuxrqYp2Xy/6zUx4rMaKQzKIb/eRKqDsfqEDRE+TEVk+qbgN/DEuuiRheGKSW6H
         WfY9vDo4Mxuaw9QO/jxXxBvfkXHuk+AwQo+qBcuCZsM3qAx7khTW0fKnUXZqqH4yMeCM
         wNmqzsyEuySrL2OjPEVaiEQ8ICuwrVQ3TxvFUf6cu+bzi67JwvvmKQ3rIAc+qI7PkiLo
         ydKuuVxtFmAX2xtXf2HmCqNufeCYHkLymuUgLa8HCmkVqpQ2R9UwrKOr/kM/uwjh/0D4
         Kkvg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=1BQJGkT0s+shkdXKpDMkrADfSTioqQt/ZZz1bLqTUmQ=;
        b=Yxy3XcB0qWkBiMhV3ezBwj6H5z+O55ASQFuodOYWyeQ97GSR/DnFL/3EnDa1SMUaJ7
         cOziDGuoNGMrJUkGNcJ7Yz4E0r5Q4wW2dnT//cAoDCLd7Y6i3G+qNh7Yr3n2wenY6wzN
         74qByDnFvATI8Z0X8WqfnYqjDV+PI3j73mMUbUpTY5g+zSQAKljeBXInpv4k7muDTZmv
         z/6j2RqT8Wv4JpeXIedwwl6/rmyYqH+z+0//S7tFAGNs4PLq6zk/kp4RyAr2J/oVwqB8
         VjwVqS1uOId3D7dyeYJACRZTevTirQP6aUqZuhiC/lpjAi9018GBsi2jF7/bANUF0w/s
         n59g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=F0MT0Anr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d23sor22165404ejb.63.2019.07.31.08.13.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=F0MT0Anr;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=1BQJGkT0s+shkdXKpDMkrADfSTioqQt/ZZz1bLqTUmQ=;
        b=F0MT0AnrCovBczYaK6YHDuFLb0wBcNajj6NHjl7jAd1Y6o1sz/pNiCycggcpbm6sR3
         dDEawPYmizqxf+941dOmoLsE0S6Q6h1HQDO131T53iZuuKNPHzVa3IPL9WD/cAQThRxW
         19GfKEGA+MvSm2zoe3KKZc/IX3XQ6h9saIaqsaf2Cv3IGGslYpWhz/Y2aQxDBt3NfhUb
         w/gBHQa/MfFXThu2xMpIdQZhfx6ijjecuKQ3SRFmAoT48fh5DVqlO0eNkdkALj71DjZx
         huhf1zc3aR8yYQEOtkcgzJ7LoEXxQCLmXSefv3Umpu1K5rbidj3HWE72bSF4c6y4iBlq
         mv+Q==
X-Google-Smtp-Source: APXvYqy+sAZ1XO5Dthl6XVadxh27450cRd8oWJweimgbdsPH0ca3T6NWosb4Y5aumCe01jgo510kdA==
X-Received: by 2002:a17:906:2555:: with SMTP id j21mr96482359ejb.231.1564586030314;
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id s2sm5404851ejf.11.2019.07.31.08.13.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id B152E1030C3; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 28/59] keys/mktme: Move the MKTME payload into a cache aligned structure
Date: Wed, 31 Jul 2019 18:07:42 +0300
Message-Id: <20190731150813.26289-29-kirill.shutemov@linux.intel.com>
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

In preparation for programming the key into the hardware, move
the key payload into a cache aligned structure. This alignment
is a requirement of the MKTME hardware.

Use the slab allocator to have this structure readily available.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 37 +++++++++++++++++++++++++++++++++++--
 1 file changed, 35 insertions(+), 2 deletions(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 10fcdbf5a08f..8ac75b1e6188 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -16,6 +16,7 @@
 
 static DEFINE_SPINLOCK(mktme_lock);
 static unsigned int mktme_available_keyids;  /* Free Hardware KeyIDs */
+static struct kmem_cache *mktme_prog_cache;  /* Hardware programming cache */
 
 enum mktme_keyid_state {
 	KEYID_AVAILABLE,	/* Available to be assigned */
@@ -79,6 +80,25 @@ static const match_table_t mktme_token = {
 	{OPT_ERROR, NULL}
 };
 
+/* Copy the payload to the HW programming structure and program this KeyID */
+static int mktme_program_keyid(int keyid, u32 payload)
+{
+	struct mktme_key_program *kprog = NULL;
+	int ret;
+
+	kprog = kmem_cache_zalloc(mktme_prog_cache, GFP_KERNEL);
+	if (!kprog)
+		return -ENOMEM;
+
+	/* Hardware programming requires cached aligned struct */
+	kprog->keyid = keyid;
+	kprog->keyid_ctrl = payload;
+
+	ret = MKTME_PROG_SUCCESS;	/* Future programming call */
+	kmem_cache_free(mktme_prog_cache, kprog);
+	return ret;
+}
+
 /* Key Service Method called when a Userspace Key is garbage collected. */
 static void mktme_destroy_key(struct key *key)
 {
@@ -93,6 +113,7 @@ static void mktme_destroy_key(struct key *key)
 /* Key Service Method to create a new key. Payload is preparsed. */
 int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 {
+	u32 *payload = prep->payload.data[0];
 	unsigned long flags;
 	int keyid;
 
@@ -101,7 +122,14 @@ int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 	spin_unlock_irqrestore(&mktme_lock, flags);
 	if (!keyid)
 		return -ENOKEY;
-	return 0;
+
+	if (!mktme_program_keyid(keyid, *payload))
+		return MKTME_PROG_SUCCESS;
+
+	spin_lock_irqsave(&mktme_lock, flags);
+	mktme_release_keyid(keyid);
+	spin_unlock_irqrestore(&mktme_lock, flags);
+	return -ENOKEY;
 }
 
 /* Make sure arguments are correct for the TYPE of key requested */
@@ -245,10 +273,15 @@ static int __init init_mktme(void)
 	if (!mktme_map)
 		return -ENOMEM;
 
+	/* Used to program the hardware key tables */
+	mktme_prog_cache = KMEM_CACHE(mktme_key_program, SLAB_PANIC);
+	if (!mktme_prog_cache)
+		goto free_map;
+
 	ret = register_key_type(&key_type_mktme);
 	if (!ret)
 		return ret;			/* SUCCESS */
-
+free_map:
 	kvfree(mktme_map);
 
 	return -ENOMEM;
-- 
2.21.0

