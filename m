Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6261C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8137F21773
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:14:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="GgMDYljg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8137F21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAE298E002E; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5B948E002A; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A03E78E0030; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3E8AE8E002E
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:58 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b3so42567451edd.22
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=c5WMXVoIZssEiK4OS2ZsI14EAD5bwwEyXB7tLs9S9Os=;
        b=gtlcKDtX9c3ytcy+6JbJiDfl0hVTWvPjb8QKzebXComV6F4mHIhjchYftqmWrtW4Tu
         udG3+QhsY6fmz/5o2vRieo2BprxdMNm6R47FANMtDu6i4MYWfUMxerQEeHLc4YwtrzOB
         0lhCHNcmV9t3uEEPlPGoVmbLCqswNgR/YPSgqbG0TIrS5xvAPatHMIteDAu1BqKcwk9f
         ELbX/QOB1lznNV4X+0a7uXwULXBGc4AfrZHUSqgLsKiE4I9/IwnAupGr0IO7JIeiAaf4
         IA1H6bT0oUkpeFcNwfqKSQWaISlHXbUBbQ774Q0OrT6JgPWzu1jVoWu/JBX22TCFM89R
         yDuQ==
X-Gm-Message-State: APjAAAW6/g0hP5xUl3ywp+H8o/TacmMUtq23Ip8zmJLhJxNr1nc9MrrO
	5Dezi1Oa2zFduthuSkxnYZT/jwhqRpSPl8WM4v5o5H5gy1tHPY8Q9S8jOID5TOWljG4e7iyMs6b
	u02HTKZyYnKpmYrjicm4TmeMpYJFZZt97ANS3mvRXXU6gW35KtDEnkKJl4CrgmRk=
X-Received: by 2002:a50:9167:: with SMTP id f36mr107716954eda.297.1564586037850;
        Wed, 31 Jul 2019 08:13:57 -0700 (PDT)
X-Received: by 2002:a50:9167:: with SMTP id f36mr107716844eda.297.1564586036776;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586036; cv=none;
        d=google.com; s=arc-20160816;
        b=EbXkD4bqNQvLKHwmQKmlZON1pFE/NlmNp3Zf7P01v4r6z1k64M/C+0ENT2cIhpPVE0
         HV2NcdgMbqFwku0euSEPr+487DXO/pA/RdOcz6HAiZz8xe8sJhdrz9SEF2HaEztbtEz2
         LgaJZhJgPBj6bCtDP8p8QBwjAv7+rGW1K2fOzLxcugaw08NjvGcU88RpIlxO57tCqPr7
         GwVUdxkMObCVfQgERQXrnLwmtAjEcG3i/kV62bKG73Bw6vU9n8DrpmqmKjUPwLSKBb5D
         UzZK7uvc0ZalglmNYA/sJ1hojZ+72zE+VXJXq6vivv5dpp8YrEaf/iM1w+uduseCtQOg
         4uIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=c5WMXVoIZssEiK4OS2ZsI14EAD5bwwEyXB7tLs9S9Os=;
        b=PFf3oAn6XP1dzFyF9pr/f3jC7WcT3EKJ00j904BslanuEOGiBZx5jd01BfEnK2nCjk
         kgFCt67uyoNcbwJoXmGXsYSsUFb4pAlqHJb4AO9wtGNzqyTSIFhHr8hD9Grn8Kug2q4L
         6/83X6PaK4uq8FLmdYxl30pdJwaA7sIQ8+mi3YnHIK+J/Y4YX7Ep5L8nQfVtQg2gdAVR
         Qc4zuRxm+pzvhqaJ2B5OXMMFwR5odvylLJMZaFUHwz/Hb4C5XAETrOQIT39+5tmAVFkR
         UAXj1xZ5khb7TIZacaHfHH3um89iE5Aqhv7DHXbJt4XWRCeGG0kj4Wcy6kw4p4zLuP0b
         8FXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GgMDYljg;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q27sor16474852eji.6.2019.07.31.08.13.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=GgMDYljg;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=c5WMXVoIZssEiK4OS2ZsI14EAD5bwwEyXB7tLs9S9Os=;
        b=GgMDYljgt69NuT2KJuOpsbtMf2bZflY04jkdcsb64J58gp3TxiHEEkOrT1ozLhakGl
         94A0Aqkr8JolguUGlRobFPi57btYrwT3g8MYH4q5fgBYWQAov6IpM5yec8GdWQhRD5tC
         0Ax6JsB0ooIwmT4n5nblwvmWo7thAMBxnFrHSP9RfZBW9LLERr65CaaolDQ48tv/CAKX
         l2OBdufhK2nJeUB9MMPZPdYfYOqpvH6oRpIZCUxqhsrsgYyEegj1/UXzCzFcS0ucxo4Z
         EdcRyeDiAndnOaS1LNOs83hgApICxD3lTMqnXM53LXOsfL7gbP+s6/BUFBXV4t3iCpQw
         uzGw==
X-Google-Smtp-Source: APXvYqwYMqulY0Xx64lB5aqfOhV4++kQN1Oobfks3JeYhOF1doEtw6JzyLb48pAr8c5dYOSv/qswsA==
X-Received: by 2002:a17:906:e204:: with SMTP id gf4mr92542915ejb.302.1564586036461;
        Wed, 31 Jul 2019 08:13:56 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id d7sm16507912edr.39.2019.07.31.08.13.52
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:53 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id AA55A1030C2; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
Subject: [PATCHv2 27/59] keys/mktme: Destroy MKTME keys
Date: Wed, 31 Jul 2019 18:07:41 +0300
Message-Id: <20190731150813.26289-28-kirill.shutemov@linux.intel.com>
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

Destroy is a method invoked by the kernel key service when a
userspace key is being removed. (invalidate, revoke, timeout).

During destroy, MKTME wil returned the hardware KeyID to the pool
of available keyids.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 29 +++++++++++++++++++++++++++++
 1 file changed, 29 insertions(+)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index beca852db01a..10fcdbf5a08f 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -50,6 +50,23 @@ int mktme_reserve_keyid(struct key *key)
 	return 0;
 }
 
+static void mktme_release_keyid(int keyid)
+{
+	 mktme_map[keyid].state = KEYID_AVAILABLE;
+	 mktme_available_keyids++;
+}
+
+int mktme_keyid_from_key(struct key *key)
+{
+	int i;
+
+	for (i = 1; i <= mktme_nr_keyids(); i++) {
+		if (mktme_map[i].key == key)
+			return i;
+	}
+	return 0;
+}
+
 enum mktme_opt_id {
 	OPT_ERROR,
 	OPT_TYPE,
@@ -62,6 +79,17 @@ static const match_table_t mktme_token = {
 	{OPT_ERROR, NULL}
 };
 
+/* Key Service Method called when a Userspace Key is garbage collected. */
+static void mktme_destroy_key(struct key *key)
+{
+	int keyid = mktme_keyid_from_key(key);
+	unsigned long flags;
+
+	spin_lock_irqsave(&mktme_lock, flags);
+	mktme_release_keyid(keyid);
+	spin_unlock_irqrestore(&mktme_lock, flags);
+}
+
 /* Key Service Method to create a new key. Payload is preparsed. */
 int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 {
@@ -198,6 +226,7 @@ struct key_type key_type_mktme = {
 	.free_preparse	= mktme_free_preparsed_payload,
 	.instantiate	= mktme_instantiate_key,
 	.describe	= user_describe,
+	.destroy	= mktme_destroy_key,
 };
 
 static int __init init_mktme(void)
-- 
2.21.0

