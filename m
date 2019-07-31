Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFBD8C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87A57217D4
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:08:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=shutemov-name.20150623.gappssmtp.com header.i=@shutemov-name.20150623.gappssmtp.com header.b="Adcw5GPs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87A57217D4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=shutemov.name
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A01F78E000B; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98B938E0009; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7669A8E000B; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 18F1D8E0009
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:08:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y15so42617757edu.19
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:08:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=uRHR4JyNhqg33njeUSvVGNylXkFyo7B3QnIKSQpCDwk=;
        b=kHt8tMSa9Z9e7bfCLLCvaU0YOL2be3RGq+zhLGKd1aApEDJNmfndyTEoZOUT714mb3
         XEhYneoWdXEKc61gMl/TWK+v5KxpsLBuYLX2xcK43JPC2xpyc/zfhNi0muBRoU8tiVep
         dYe8sBQJ8l7HzFEUSlPUoWHg2ceLfuTe9qTSpbalQvTC+cJ9QR7pvQwKtomCLWevzlkd
         kAaqXUF4UwXqLH7KcBozKrn6h1X5NKFobZVjdiBHTSITLw3JLGFreI6LfQpuyF58J1XU
         9Du+UPwHcJvFGB6Pkz0V71erPN6R80mPTJzTQuc421OTU86/cjDrKOnFBhBiZZBMDFrQ
         qKfA==
X-Gm-Message-State: APjAAAX3/6MoMQiw9FD2Ws+xsRJZ/8VgnhSIPDA19r5sBhcjwRkSTiu7
	VfcJkhhMNuKAIgVAU5YtvwkGutpeZPw7YTZzbPk0F52AlBOr8axpCk3UI0o3P8EGfCUwNvUeSle
	/kKHXmZyKyC9HvecXA53RXNkkfWbSumNkWTsi8/T6o9PRNW11QtX6t3ax1vP2pc8=
X-Received: by 2002:a17:906:9385:: with SMTP id l5mr93321308ejx.8.1564585700624;
        Wed, 31 Jul 2019 08:08:20 -0700 (PDT)
X-Received: by 2002:a17:906:9385:: with SMTP id l5mr93321166ejx.8.1564585699155;
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564585699; cv=none;
        d=google.com; s=arc-20160816;
        b=MhP8A4wst4wFsmc3GULyJ8TwJcRhErOnViSoSgSjMDNah7fZUITc333bdes5URJUAl
         p1o9cm6ckI49ys2MxkKIg2isZqMlXrlutuw5IkbV5pNvfGYSedlR0wGbJvUk3AnAFod+
         PC0a6QxegXpVZ7jEQg4EwFpqW3ny5yUpLys/uMGHL0DNdZi/KBq+34fJkQdSzx4yAyfM
         t5ESmZ78ruhQ/dgCofoGO5K2/SPrWRgyE0FsFAzmLT027Kpc45ylIHA1x8Vx5Sw9Aqdo
         n8CG54/JLdvUAqzV3OnqMeQfPISq41CThJMqjGPpQYV4b/jTToYe4bw4oZ6Y+WYHWQWj
         ZfkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=uRHR4JyNhqg33njeUSvVGNylXkFyo7B3QnIKSQpCDwk=;
        b=HBC8TfEUaEk9a78KMJTGb4O7Mg5avawQ40gW4D2txHhaVcpgqI/4IWFVHxHIw1mYa8
         CEv4L7FkvqmT2TPUlTKglimMmHEiMWWSeZbW+xFKngJ/EVmPfFjUlt8RZplFczczQMmF
         jIEAbJ02oUt3rGpRIVCVhFPic0aC/47rWg5zxSz+uBTKHYMaW7oO0WZqPH/ccfwb/bSo
         maM5B/yprcK8gkptv+hJd+JYRG5eE2mVdxkcknlljPes7klQiaGrBiZJ3cWAG001yAJH
         6AIjyjhM62o3Sex9MMuLbHgY00+OEelSjlTZlxEQq9ZOqhXck4IzW5d6gloiLGZJZld9
         CfBg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Adcw5GPs;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id no5sor18519064ejb.51.2019.07.31.08.08.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 31 Jul 2019 08:08:19 -0700 (PDT)
Received-SPF: neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@shutemov-name.20150623.gappssmtp.com header.s=20150623 header.b=Adcw5GPs;
       spf=neutral (google.com: 209.85.220.65 is neither permitted nor denied by best guess record for domain of kirill@shutemov.name) smtp.mailfrom=kirill@shutemov.name
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=shutemov-name.20150623.gappssmtp.com; s=20150623;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=uRHR4JyNhqg33njeUSvVGNylXkFyo7B3QnIKSQpCDwk=;
        b=Adcw5GPsJkn83YXVJKj7Wqwm6NwWDC1hAYaUolv28wXp+8oH0VtnaENGQuZ/0K5+Nb
         4ttVuTcBuWW62tdKiOabj/bghgVhdlTVmNRPbQ83nxcV2pN29l6uGQo0wyZ/lAlhkLv5
         uu88EBPXw3XRRpwEaUjPB0g7WmxNmdd7QzlE0G/0MbaOwDTTzRhC9WWYSRAeSeO7X5bx
         QFUzmQ84OBFGl0JYzwuDQQLD8dx+iNms4LZ5CMlKmpkkFg5rsp7bDTsd+CepoXc38t5t
         U6hOGTcOi/3klKmjqufRITIY89IhP2ybvsPkGFX/lxa/yb3zD0rrCBZO9eKTlKALJ6M+
         k80A==
X-Google-Smtp-Source: APXvYqwgh75LQw16lfxHmAAueOtxiQIAT7Hemys++oZtGs9IrW8hC3dJ4CKW+gKV4lDeffYtzg8cig==
X-Received: by 2002:a17:906:6a87:: with SMTP id p7mr23487746ejr.277.1564585698812;
        Wed, 31 Jul 2019 08:08:18 -0700 (PDT)
Received: from box.localdomain ([86.57.175.117])
        by smtp.gmail.com with ESMTPSA id o22sm17282769edc.37.2019.07.31.08.08.15
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 08:08:15 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill@shutemov.name>
X-Google-Original-From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Received: by box.localdomain (Postfix, from userid 1000)
	id 03F8F10131A; Wed, 31 Jul 2019 18:08:16 +0300 (+03)
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
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 03/59] mm/ksm: Do not merge pages with different KeyIDs
Date: Wed, 31 Jul 2019 18:07:17 +0300
Message-Id: <20190731150813.26289-4-kirill.shutemov@linux.intel.com>
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

KSM compares plain text.  It might try to merge two pages that have the
same plain text but different ciphertext and possibly different
encryption keys.  When the kernel encrypted the page, it promised that
it would keep it encrypted with _that_ key.  That makes it impossible to
merge two pages encrypted with different keys.

Never merge encrypted pages with different KeyIDs.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mm.h |  7 +++++++
 mm/ksm.c           | 17 +++++++++++++++++
 2 files changed, 24 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5bfd3dd121c1..af1a56ff6764 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1644,6 +1644,13 @@ static inline int vma_keyid(struct vm_area_struct *vma)
 }
 #endif
 
+#ifndef page_keyid
+static inline int page_keyid(struct page *page)
+{
+	return 0;
+}
+#endif
+
 extern unsigned long move_page_tables(struct vm_area_struct *vma,
 		unsigned long old_addr, struct vm_area_struct *new_vma,
 		unsigned long new_addr, unsigned long len,
diff --git a/mm/ksm.c b/mm/ksm.c
index 3dc4346411e4..7d4ef634f38e 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1228,6 +1228,23 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
 	if (!PageAnon(page))
 		goto out;
 
+	/*
+	 * KeyID indicates what key to use to encrypt and decrypt page's
+	 * content.
+	 *
+	 * KSM compares plain text instead (transparently to KSM code).
+	 *
+	 * But we still need to make sure that pages with identical plain
+	 * text will not be merged together if they are encrypted with
+	 * different keys.
+	 *
+	 * To make it work kernel only allows merging pages with the same KeyID.
+	 * The approach guarantees that the merged page can be read by all
+	 * users.
+	 */
+	if (kpage && page_keyid(page) != page_keyid(kpage))
+		goto out;
+
 	/*
 	 * We need the page lock to read a stable PageSwapCache in
 	 * write_protect_page().  We use trylock_page() instead of
-- 
2.21.0

