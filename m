Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A6671C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 21:47:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5F5BF20854
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 21:47:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="HH1g71BD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5F5BF20854
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EBB946B0006; Tue, 30 Apr 2019 17:47:30 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6BE86B0008; Tue, 30 Apr 2019 17:47:30 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D81CD6B000A; Tue, 30 Apr 2019 17:47:30 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f200.google.com (mail-vk1-f200.google.com [209.85.221.200])
	by kanga.kvack.org (Postfix) with ESMTP id B6C006B0006
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 17:47:30 -0400 (EDT)
Received: by mail-vk1-f200.google.com with SMTP id y19so6920807vky.4
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 14:47:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=f5tP4i9oo8ss2ldojh86/XKSddC2xJw6xj+Nunlyeqc=;
        b=GhSUzEnvXkxoagvLa5Xc1sL4ooX9fAte8Kw56p9LSkHqtZFagsSVPSAuI1/IplDMzC
         m51yN4h22O9OD2ObKWGaIGvKAGUc5biNDBvcWuafmIdRSazDdi/6UtintpdACWLW4Z57
         t8SgOydMnTpBLspssgCeiPcPMP5kO+wc0DJh5xdP5h1pbRLy6JVV3H9mwTmducXRGlHN
         qozbamX8zhTgEXmYb0eChZeMGEhxZgVJmD/yk2+rBPNPpWKxH5qsNbYzVEFOr0In/DkO
         95kpr17VhKr+T8MK5/xKBbauZjnc2CmJOnP2kuvRUfDmB026OyyIc4Hdg2Ve5Es4GvUx
         CUOg==
X-Gm-Message-State: APjAAAURY4k1FNYWKkp5+O+tQczHEULr6AjEFEJVP7FcmbROMeRKgWLs
	ucKbXToO4ExY+cEbmiyji8axCzns9gHJiz0xogMQ2+nL15dYe9VFiVSUIPeA7lMyIkoQkb1bDs7
	pgIkwnMQr7FjmY2NIuausT5aA3XYIVGRT/lGBdJh31XkiMNrXMi6TQYYIofjZ9VO6kg==
X-Received: by 2002:a67:fdd6:: with SMTP id l22mr11931173vsq.183.1556660850307;
        Tue, 30 Apr 2019 14:47:30 -0700 (PDT)
X-Received: by 2002:a67:fdd6:: with SMTP id l22mr11931140vsq.183.1556660849552;
        Tue, 30 Apr 2019 14:47:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556660849; cv=none;
        d=google.com; s=arc-20160816;
        b=BCJxJ7ZksLoqe63YnNaiESUb4oimxSk34L/6MYUT9WMcDn0m6FO0LfEZ4btdZiz+iM
         jebGBzahD1fkx9CGiM0/7Rtd+11bD6j8HkXCiUbWsuI1G+qxHYMcHl0kERKhdE2csSYB
         1G9c4FMdIFO5tntrxGyl2A6d6Pel63MxcD5dZqCvzw517MMWutcp7Vd2EYoyfe/wRuTK
         A6zvHDk2PWPtuqx4gU+GL0HzC0njXZvDQ8yF5HofJx3UBkVMTD9jp1i6lqI1gE9Lj45d
         RHRzRlAdKoQ68gf/J1nMPUokSF1lC6aTvLzOsTH4RvTIjb4VCa8spvjlYgtVElMAywWW
         apSA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=f5tP4i9oo8ss2ldojh86/XKSddC2xJw6xj+Nunlyeqc=;
        b=l1WH67FBjoi+BtqxmFBXb4bVX0l7KT+9beprBu98vhXCxAaH8ffC3unTiBB7+llwKl
         MxVeQHLE0ZVWZZU3hK4HKWF7HKZcpgWIO0gxr/BemZAmzfj8km4cwJPNDNm5r0orpuMW
         BcifO3WnDumbudtxQkqGei0FqWKXlSrM1QHEFkgHwO0U0oMWiNK7u0mi1Rq7flJAzQxk
         qyVbRpQob76s+UnRmtAxKFxQKsIZgJdQ9yStUjSi7p9CQ9Hz3B8oHfTIjFoeV8MyHB3r
         JOilPRrN6DCKG3Cq5mstmhrBYKbwnPQIFR2s9mvqy5MWSlyn3azLC5xRuvdCMXPKb4TZ
         Viaw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HH1g71BD;
       spf=pass (google.com: domain of 3cmlixawkcauxfrnytq0fsjslttlqj.htrqnsz2-rrp0fhp.twl@flex--samitolvanen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3cMLIXAwKCAUxfrnytq0fsjslttlqj.htrqnsz2-rrp0fhp.twl@flex--samitolvanen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w25sor12445133vsq.5.2019.04.30.14.47.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 14:47:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3cmlixawkcauxfrnytq0fsjslttlqj.htrqnsz2-rrp0fhp.twl@flex--samitolvanen.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=HH1g71BD;
       spf=pass (google.com: domain of 3cmlixawkcauxfrnytq0fsjslttlqj.htrqnsz2-rrp0fhp.twl@flex--samitolvanen.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3cMLIXAwKCAUxfrnytq0fsjslttlqj.htrqnsz2-rrp0fhp.twl@flex--samitolvanen.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=f5tP4i9oo8ss2ldojh86/XKSddC2xJw6xj+Nunlyeqc=;
        b=HH1g71BDh0kd5On6O+cgQEFGbxHeePhHvZv+uUiQh904NfitGz2iyJidBX2oomrgYh
         Zn6BKmWc5/aX0jsauNQMpRzitKmF0UbktdM0c1zlLj1gJFYOn8X231TuoiC97SgYkQi/
         Dh0CLjxYzHFcFWgxS+e8MHyIZIzs/9JMJU0rWba4MUfPP8jRb3i0g9fe0NadEP2fzunT
         Zz9wKSEgora0dnDDqabTYlSbDAi2oIa9TGj6HB/8dIWGQBa1Gf9HXirfdPMOGuJLPHRk
         pnUHNOZI3PmUEEwcI0etxqMSXk0wBGsRTpiY7qGHejXP90JodfiH4513pKL8aICiWJuk
         uSHg==
X-Google-Smtp-Source: APXvYqxcE2wG3pImcrXpXqIXxtFPTmq690IFhm0p2DArgi2jwzSLTlMzp6g2awj0Ibx6ZE4IberuF7eONksJhkocJZ0=
X-Received: by 2002:a67:ad03:: with SMTP id t3mr6155852vsl.159.1556660848948;
 Tue, 30 Apr 2019 14:47:28 -0700 (PDT)
Date: Tue, 30 Apr 2019 14:47:24 -0700
Message-Id: <20190430214724.66699-1-samitolvanen@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH] mm: fix filler_t callback type mismatch with readpage
From: Sami Tolvanen <samitolvanen@google.com>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Kees Cook <keescook@chromium.org>, Nick Desaulniers <ndesaulniers@google.com>, 
	linux-kernel@vger.kernel.org, Sami Tolvanen <samitolvanen@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Casting mapping->a_ops->readpage to filler_t causes an indirect call
type mismatch with Control-Flow Integrity checking. This change fixes
the mismatch in read_cache_page_gfp and read_mapping_page by adding a
stub callback function with the correct type.

As the kernel only has a couple of instances of read_cache_page(s)
being called with a callback function that doesn't accept struct file*
as the first parameter, Android kernels have previously fixed this by
changing filler_t to int (*filler_t)(struct file *, struct page *):

  https://android-review.googlesource.com/c/kernel/common/+/671260

While this approach did fix most of the issues, the few remaining
cases where unrelated private data are passed to the callback become
rather awkward. Keeping filler_t unchanged and using a stub function
for readpage instead solves this problem.

Cc: Kees Cook <keescook@chromium.org>
Signed-off-by: Sami Tolvanen <samitolvanen@google.com>
---
 include/linux/pagemap.h | 22 +++++++++++++++++++---
 mm/filemap.c            |  7 +++++--
 2 files changed, 24 insertions(+), 5 deletions(-)

diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index bcf909d0de5f8..e5652a5ba1584 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -383,11 +383,27 @@ extern struct page * read_cache_page_gfp(struct address_space *mapping,
 extern int read_cache_pages(struct address_space *mapping,
 		struct list_head *pages, filler_t *filler, void *data);
 
+struct file_filler_data {
+	int (*filler)(struct file *, struct page *);
+	struct file *filp;
+};
+
+static inline int __file_filler(void *data, struct page *page)
+{
+	struct file_filler_data *ffd = (struct file_filler_data *)data;
+
+	return ffd->filler(ffd->filp, page);
+}
+
 static inline struct page *read_mapping_page(struct address_space *mapping,
-				pgoff_t index, void *data)
+				pgoff_t index, struct file *filp)
 {
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
-	return read_cache_page(mapping, index, filler, data);
+	struct file_filler_data data = {
+		.filler = mapping->a_ops->readpage,
+		.filp   = filp
+	};
+
+	return read_cache_page(mapping, index, __file_filler, &data);
 }
 
 /*
diff --git a/mm/filemap.c b/mm/filemap.c
index d78f577baef2a..6cc41c25ca3bf 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2977,9 +2977,12 @@ struct page *read_cache_page_gfp(struct address_space *mapping,
 				pgoff_t index,
 				gfp_t gfp)
 {
-	filler_t *filler = (filler_t *)mapping->a_ops->readpage;
+	struct file_filler_data data = {
+		.filler = mapping->a_ops->readpage,
+		.filp	= NULL
+	};
 
-	return do_read_cache_page(mapping, index, filler, NULL, gfp);
+	return do_read_cache_page(mapping, index, __file_filler, &data, gfp);
 }
 EXPORT_SYMBOL(read_cache_page_gfp);
 
-- 
2.21.0.593.g511ec345e18-goog

