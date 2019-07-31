Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 62637C433FF
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1A18E217F4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:13:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="AOy2CWLX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1A18E217F4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9D61A8E0005; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9865F8E0021; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 827498E0005; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 36E828E0021
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:13:51 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id l14so42632154edw.20
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:13:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ukIFHDJenwkznoJ0S+ycGyH8eEeHrvR6n2ACiYDuDdk=;
        b=o5R3hHqw1fTuZ/lhYR3VGcnPnW56TtUbjJrw1Ww7u5aCUH76iXKSugvsJhrzECwW0d
         bFMbgTCIm53FFvb19Au1A3jzo6r3eH3tmA5runmHO2elXFJ1LWm76zOKOpc9kAh/S97x
         J8mCqzBrAnAOW81WPs5ValERmpLEEBo8Q0uSbMCES/94Zt1PM+BUNVoUEKyoOFbxI+dq
         9B98FSiWlJ2DUPqfPS+VzqPL3CnNIm6v3VWyBCHQwc4ZGyPY8R+YkNOLK22rBnyuW6mV
         cufJ/xvuKNypEY6pagd/vrReGv4srqq2Yd6MEbLs5Yb9TxbVPOlveghLlhZ+1SLIFxoh
         PqZg==
X-Gm-Message-State: APjAAAU+hpXrgAfa9blN10Vsc3K5FwBb23b56KpMY/e/9TnMns1tdcmV
	HFSOW6AmDOzeoSQxOHoeDwADS2tyo45Xo/y8iVeFx2mB/6Tkm9Q3R0ZwDG4rPTSPW+/ZV5RAIJy
	kruEnMuk8TgHVg/C+sP53C5VQKcDt+GsjD3Z7uKqn2KwQfm3vRRiS31YdyVxmn+Q=
X-Received: by 2002:a17:906:fae0:: with SMTP id lu32mr8621420ejb.283.1564586030760;
        Wed, 31 Jul 2019 08:13:50 -0700 (PDT)
X-Received: by 2002:a17:906:fae0:: with SMTP id lu32mr8621306ejb.283.1564586029372;
        Wed, 31 Jul 2019 08:13:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564586029; cv=none;
        d=google.com; s=arc-20160816;
        b=iqCQw/0mHgV6YB/Ibi6eq9/vpLHFfmeSYs2RGGio8WHtm/QqwWUtPladWnW92raXfZ
         n9+P1Ub3OWTjBU0hoN4pQsyY+iybwwKRj0VoF0wz1y6PaCSKX+j+0Sv+Ggjw/WDihk8E
         yjXJZ03J1s/rPkWaxFAm65tcjkq/z7++oZQcGuEM6+YR0p2KkSzghWYkJtnwmEYuAB1P
         l7WyVhSO9/C8KqIHcZHiTPvcuW3UayfXFsy1EqM4/CjYRhgbzg2DqwO+YHuHxKZypaYd
         AM6NYP6QemEoa5dtYFM6lJ0SA+9yZnxVJKmcVk7uNDY27LeY+oSjxWeYbRzwNDFzWz3r
         gZzw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ukIFHDJenwkznoJ0S+ycGyH8eEeHrvR6n2ACiYDuDdk=;
        b=a9XcscBYMygxxLcnDfwk7Ke6omVXTmJkJBt5UoPO+7C+meRANJabitl66ydHLsC2QZ
         163TQ/BICMvr6eXyYBuWowcKBVPtkvAOuFjaIkXwAHweZo6fPgYWHlMZq/ysyIsgQRXq
         vjEQld/VuPSayeT5gL8Sfyon38en6KMmIX0ZwFsxTndhPhg9pYHxi41phJ+c8P/rwyF3
         ixq3umod6z7jmW4WCH2/PkbHLNrbawQybAA23fcMd5+YyLMbF9Gxqrpg9rKrS/cCkFu6
         DiWdpVhYsI4G+JJJTSqKGNoC2cw6Xkc6mIOn+DKDvtaU9ljTq2CB+J8lkrmcjkaJbSiV
         HhhQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=AOy2CWLX;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q27sor16474736eji.6.2019.07.31.08.13.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:13:49 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=AOy2CWLX;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ukIFHDJenwkznoJ0S+ycGyH8eEeHrvR6n2ACiYDuDdk=;
        b=AOy2CWLXXb5HmAhiEuMvNlpAfvbzvVTmBhdFbnfbTg/elp4wHPlGZlanZYYDI/FrxG
         XR1qjn43zM5orBwV4t3lyE99FyrF9PkSX5oImrC331w0Zqkq8aM4qZ7W1MIsKYtR1Iq+
         R9RJkh8iSQEpA340quOn7TlujXd6hrIkjm5Jm0Xb21fUTBV8fnmRZXlmIojL8rcIgjCU
         PUTp3qDE06KwYQHnhsuC+tatmmIbYIQBPxFpZQsboYojGA8UMc7qiPLpOzuIoc1jePqI
         mj+jOHlIVv7dZaf23nr1b3w0Wc5cWJIlxSvk362WiEcqLVDtgLk3XpruSZHTCkoabCWN
         v2Aw==
X-Google-Smtp-Source: APXvYqySwhWDf4JA3GLQlNS2pqACUoF55kJ2wCVDTSRm+FoPw2vi1mKPJsOuuhC2eFbEA1+1nD2ApQ==
X-Received: by 2002:a17:906:1e85:: with SMTP id e5mr94007378ejj.200.1564586029031;
        Wed, 31 Jul 2019 08:13:49 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id v6sm12580413ejx.28.2019.07.31.08.13.47
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:13:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 025681045FC; Wed, 31 Jul 2019 18:08:17 +0300 (+03)
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
Subject: [PATCHv2 38/59] keys/mktme: Do not allow key creation in unsafe topologies
Date: Wed, 31 Jul 2019 18:07:52 +0300
Message-Id: <20190731150813.26289-39-kirill.shutemov@linux.intel.com>
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

MKTME depends upon at least one online CPU capable of programming
each memory controller in the platform.

An unsafe topology for MKTME is a memory only package or a package
with no online CPUs. Key creation with unsafe topologies will fail
with EINVAL and a warning will be logged one time.
For example:
	[ ] MKTME: no online CPU in proximity domain
	[ ] MKTME: topology does not support key creation

These are recoverable errors. CPUs may be brought online that are
capable of programming a previously unprogrammable memory controller.

Signed-off-by: Alison Schofield <alison.schofield@intel.com>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 security/keys/mktme_keys.c | 36 ++++++++++++++++++++++++++++++------
 1 file changed, 30 insertions(+), 6 deletions(-)

diff --git a/security/keys/mktme_keys.c b/security/keys/mktme_keys.c
index 6265b62801e9..70662e882674 100644
--- a/security/keys/mktme_keys.c
+++ b/security/keys/mktme_keys.c
@@ -23,6 +23,7 @@ static unsigned int mktme_available_keyids;  /* Free Hardware KeyIDs */
 static struct kmem_cache *mktme_prog_cache;  /* Hardware programming cache */
 static unsigned long *mktme_target_map;	     /* PCONFIG programming target */
 static cpumask_var_t mktme_leadcpus;	     /* One CPU per PCONFIG target */
+static bool mktme_allow_keys;		     /* HW topology supports keys */
 
 enum mktme_keyid_state {
 	KEYID_AVAILABLE,	/* Available to be assigned */
@@ -253,32 +254,55 @@ static void mktme_destroy_key(struct key *key)
 	percpu_ref_kill(&encrypt_count[keyid]);
 }
 
+static void mktme_update_pconfig_targets(void);
 /* Key Service Method to create a new key. Payload is preparsed. */
 int mktme_instantiate_key(struct key *key, struct key_preparsed_payload *prep)
 {
 	u32 *payload = prep->payload.data[0];
 	unsigned long flags;
+	int ret = -ENOKEY;
 	int keyid;
 
 	spin_lock_irqsave(&mktme_lock, flags);
+
+	/* Topology supports key creation */
+	if (mktme_allow_keys)
+		goto get_key;
+
+	/* Topology unknown, check it. */
+	if (!mktme_hmat_evaluate()) {
+		ret = -EINVAL;
+		goto out_unlock;
+	}
+
+	/* Keys are now allowed. Update the programming targets. */
+	mktme_update_pconfig_targets();
+	mktme_allow_keys = true;
+
+get_key:
 	keyid = mktme_reserve_keyid(key);
 	spin_unlock_irqrestore(&mktme_lock, flags);
 	if (!keyid)
-		return -ENOKEY;
+		goto out;
 
 	if (percpu_ref_init(&encrypt_count[keyid], mktme_percpu_ref_release,
 			    0, GFP_KERNEL))
-		goto err_out;
+		goto out_free_key;
 
-	if (!mktme_program_keyid(keyid, *payload))
-		return MKTME_PROG_SUCCESS;
+	ret = mktme_program_keyid(keyid, *payload);
+	if (ret == MKTME_PROG_SUCCESS)
+		goto out;
 
+	/* Key programming failed */
 	percpu_ref_exit(&encrypt_count[keyid]);
-err_out:
+
+out_free_key:
 	spin_lock_irqsave(&mktme_lock, flags);
 	mktme_release_keyid(keyid);
+out_unlock:
 	spin_unlock_irqrestore(&mktme_lock, flags);
-	return -ENOKEY;
+out:
+	return ret;
 }
 
 /* Make sure arguments are correct for the TYPE of key requested */
-- 
2.21.0

