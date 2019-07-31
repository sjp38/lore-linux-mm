Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 902E5C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 48DFB2064A
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:09:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="GZAidz/Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48DFB2064A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2D6C58E0013; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2873C8E0018; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 152B38E0013; Wed, 31 Jul 2019 11:08:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B144D8E0018
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:30 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w25so42560466edu.11
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=LSpLd4hZuC7djly8qH62+kJZqlzlyenE+/UQYliczqM=;
        b=mxgGz2AWDSZ0zgOyBa21D4e8/nTAUy1F33lWspmEkkWUEIJ3GtFBvgwtJTH3iwo2cs
         thEEdsrg0PcK90HJbltApDylQp5fMhNpTTdS4DPCpQMKiRkz87g1Gy5EpqQU64sJEOBh
         0kfEoTR10dFqCJwbuvWN9QJ5TOwc34s2H7M4rfThcpR5DJHihoQyJS1GoeTxFe3hyeV/
         H8h0H/sG27Ycyerlf+1MNrSDRf1IQzTpHJ+UntqqgSEh0x0hCnOoBHr7zlAM4chDrYBk
         yug+QDnFVroMhhEN8GazYA6PI0qv8oz62NPGFyx/XUEY5/HnscqDDD4PGd9D6Gz8Qf3u
         ybvQ==
X-Gm-Message-State: APjAAAUBwWhBRGy37PmReYPe3MyyJOiVh3ZYKcjcfFdjJ8YJhr43+5ii
	wQ8eO7s+kxEUzvxfjj9IzYK9VeIngXGWnUxlEftf76lBoo7vLIsa48SEvwCTks6KBAWFh2keB0k
	qMKbii3Yaz64keV9r3S97cHGKD3Nm+W73xrSt0mMJgmOFbHWz067hnJ4Y7ekWaJQ=
X-Received: by 2002:a17:906:2797:: with SMTP id j23mr79708720ejc.50.1564585710266;
        Wed, 31 Jul 2019 08:08:30 -0700 (PDT)
X-Received: by 2002:a17:906:2797:: with SMTP id j23mr79708623ejc.50.1564585709174;
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585709; cv=none;
        d=google.com; s=arc-20160816;
        b=W664FQwm5lRLynnWtUy6UuUo+LiGd3eyUsVcK4zavhYpBV0k55wNo2ly9ZQFOFf4Un
         df4pu7jFKbYpBbN10fLhd2UzZYbwBP7sQLkuRZ6nw7FTPe9F6EsfitTma8QqNqGJWRqq
         u8cOS4izGmbt11Koo7bXhIYO6xnTdojupxx/ThD0Q8x0ROZbzn0+0XOp56VhmtmmIJfR
         GvUyfTYerXsFRhk10nsA2hXT1LoClf3hhuWela4oKNWUOfrk+OHWDAT+wweEjcHZDG9I
         l4r+X06pIcBIorOkt925OHATDM3vU/7ioZjNDiIw0NNor+2C1Sdvk2Iajqra96cYqV/+
         RbNg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=LSpLd4hZuC7djly8qH62+kJZqlzlyenE+/UQYliczqM=;
        b=RYD6+96Mj7oNyOI1geWS977WhzvVNo7UHcSUqyooRUS54rZa4znTnKvAGfPZxiUlmv
         bKWED4jq4SDv7On5KWHAIvbK0Aa9UuOBADupH7Y08UdILPhMXsH4wQlM/PqDg9pmJc4c
         re3qFbj/tvJoYEz9wHZ/lTlUyEvax9Bif31/2PYd+BzKdbYXV+8G6GxV+8PtLH99ZZ63
         da/nH8ipewYKmb57siJUFtNfdCbypW2sB+2p4IlvW1WS9dfiDeRJFlFRSTTAW4TgdlMn
         5d5uT81WZ7aWGIdWeSR8J+g1NFpXjMqUJ5JGOBf091INKWn2ZOkm3/u2z1E5qiHKNBaM
         6RFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="GZAidz/Y";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d16sor52279223eda.20.2019.07.31.08.08.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:29 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b="GZAidz/Y";
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=LSpLd4hZuC7djly8qH62+kJZqlzlyenE+/UQYliczqM=;
        b=GZAidz/YZr5AJC6YjcivhC/xqBVAms+Bun6/vc7F/gyEggHe0hZuW419LPz4dWQdJT
         vjHvZ3FQT2pTLNYI8+diNtZJ4Mxf5qQsCaz8bhGx2tJou3Mvi7Xln9rS3xcAAjGFrppw
         gW+UH+S5g+sAHB/UB1hV0L34nZqdQDFvZLBbqH54Bn/Rwmq9aj94nYVe/7QXryCOhcoD
         vwwLv3UG02KHn4tO4cYfAr/TC4lta3wpVG9Dtv+I97XG9iONckyaqQzJX2KNv21wwD/S
         NQJW0wh9O3kxFRnoNJn38/KJX15ote/7R4K6CnTOCcK6umCWPj89ZozJSoXMwY2epZJk
         nulg==
X-Google-Smtp-Source: APXvYqxfkW3YmNbFSguKjUSffCBIjlvJw7vj1+8RS/D77djY6uAKTxwgECDWxNVy5ZuTfly0BeWccg==
X-Received: by 2002:a50:c35b:: with SMTP id q27mr108087273edb.98.1564585708851;
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id k5sm12233535eja.41.2019.07.31.08.08.22
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id A370B1030C1; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 26/59] keys/mktme: Instantiate MKTME keys
Date: Wed, 31 Jul 2019 18:07:40 +0300
Message-Id: <20190731150813.26289-27-kirill.shutemov@linux.intel.com>
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

Instantiate is a Kernel Key Service method invoked when a key is
added (add_key, request_key) by the user.

During instantiation, MKTME allocates an available hardware KeyID
and maps it to the Userspace Key.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index fe119a155235..beca852db01a 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -14,6 +14,7 @@
 
 #include "internal.h"
 
+static DEFINE_SPINLOCK(mktme_lock);
 static unsigned int mktme_available_keyids;  /* Free Hardware KeyIDs */
 
 enum mktme_keyid_state {
@@ -31,6 +32,24 @@ struct mktme_mapping {
 
 static struct mktme_mapping *mktme_map;
 
+int mktme_reserve_keyid(struct key *key)
+{
+	int i;
+
+	if (!mktme_available_keyids)
+		return 0;
+
+	for (i = 1; i <= mktme_nr_keyids(); i++) {
+		if (mktme_map[i].state == KEYID_AVAILABLE) {
+			mktme_map[i].state = KEYID_ASSIGNED;
+			mktme_map[i].key = key;
+			mktme_available_keyids--;
+			return i;
+		}
+	}
+	return 0;
+}
+
 enum mktme_opt_id {
 	OPT_ERROR,
 	OPT_TYPE,
@@ -43,6 +62,20 @@ static const match_table_t mktme_token = {
 	{OPT_ERROR, NULL}
 };
 
+/* Key Service Method to create a new key. Payload is preparsed. */
+int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
+{
+	unsigned long flags;
+	int keyid;
+
+	spin_lock_irqsave(&mktme_lock, flags);
+	keyid = mktme_reserve_keyid(key);
+	spin_unlock_irqrestore(&mktme_lock, flags);
+	if (!keyid)
+		return -ENOKEY;
+	return 0;
+}
+
 /* Make sure arguments are correct for the TYPE of key requested */
 static int mktme_check_options(u32 *payload, unsigned long token_mask,
 			       enum mktme_type type, enum mktme_alg alg)
@@ -163,6 +196,7 @@ struct key_type key_type_mktme = {
 	.name		= "mktme",
 	.preparse	= mktme_preparse_payload,
 	.free_preparse	= mktme_free_preparsed_payload,
+	.instantiate	= mktme_instantiate_key,
 	.describe	= user_describe,
 };
 
-- 
2.21.0

