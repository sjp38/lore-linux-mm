Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AFF6DC43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:40:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F89320B7C
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:40:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="1GBxLr6s"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F89320B7C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 10C0F6B0006; Fri, 26 Apr 2019 21:40:46 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 067946B0008; Fri, 26 Apr 2019 21:40:46 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E9A4E6B000A; Fri, 26 Apr 2019 21:40:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADC596B0006
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:40:45 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b8so3008485pls.22
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:40:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=N0a82VX9zm1dVGCHZg46u13qTa0hEHFDKHHc9ek8o2g=;
        b=Q8FmMCX671qENhfg6rTLd/RDCvVuOCLcPyxZozOpmBxY4lMxdjM2qnJNRK6UoLhnNh
         /dm4vevTYNZjmaMlnPHVQn3ygng1sQ7EwcWkd2CSwt97a4WztSCfxAV73h26XeQRQ3tF
         ASaHC6JGyD2/Pu5oA8j+8nkIw6luSycqWkrpdMSYWiem9A2S6z+Hl1qZuGkXF5ujoK7t
         OTVKxT0fe20bEduiuCsBFHUYmwWeJ9CRV9PzsgYoUB0fqkcJTFhm8KddRyKaqVSs2qvy
         Iu+AUpIxWfWr+bLHXtJCVBZc31K6wXze8haqbZK6mBnOBNrp1F/I3ejk59vBSbRgqC7s
         +gjg==
X-Gm-Message-State: APjAAAXqDB3041iVfH1aIDwowtneVdbNiUNTfXCMSn9eef+7wKXJlhCr
	gQPdOqX/Uyjg4AKKghGvuSDkZejuZ8zwZBRhJnWyf3to+3N9jIyQPfCVYYKynKYX8BCverCkS8x
	mpepTnI2yMqGsjizfKiOINbxd9yVgt1KcX97Xzeqg89I2xQi2ijEZk1fKhX7ilYcsAQ==
X-Received: by 2002:a17:902:e109:: with SMTP id cc9mr5125515plb.148.1556329245336;
        Fri, 26 Apr 2019 18:40:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwxQYspzPjNH7n2/j6YWwLHuaa7W++6ElxLzyGSpgErKXIdSrMa93OzgoQCnKjLcmQ62ULt
X-Received: by 2002:a17:902:e109:: with SMTP id cc9mr5125484plb.148.1556329244696;
        Fri, 26 Apr 2019 18:40:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329244; cv=none;
        d=google.com; s=arc-20160816;
        b=Fxwo+XzCkc1ddxo4IT5oWAnJqONLJtrczbHRAKIxWjYPIkWa7zOttFo+OZ7C5xM3TL
         tVgpb/G2JKwqDcj0LoQEVPofhP6Hwuae6pn2v0kc4Z0UOmDC1kWi8PYfHHbBNdPRe6a1
         gkFx+0+0poNxSmeViMgYHKPSAnCJAhwF4bMw6YILFCM3wQSzK6ml3QqWt0IU6Wz3NxVh
         5shHUjvlaEM0DMeMSsgpCcplHRWqIqlMLw6m1UDsJf4GGjaKFYm9Qvf6v9PblJM9fVM+
         cUx9adgQjIOwTPVI3qdv492u/NupE5Jt6aIKrVSLNDI4jKA+I5wULr6ERqbVohBbo+y4
         UGxw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=N0a82VX9zm1dVGCHZg46u13qTa0hEHFDKHHc9ek8o2g=;
        b=wMAwsKdpbrEEJh+9dzjfkLhEnqG1E29wXFXGn8DXLlA831+NyVHrSKSlADloESRhZA
         IeDEZsli/h/ljauY6EuY6XMsZU4k+oLu67Xxk5q0j6J7qV3ZrzW/aY2yM6XYuRV2Snyu
         RG6W8YQnCoRy/EEDEbAyAf6RN2IsMXpU34vqPYjNEDknrOEwh2nelbKA7cNR8Havw6EM
         AZ3qUziFupX8tKb0J2ywNmxV0Bbm/+6GPWihDTrHWuhKpO1QSXu0pV/EuX0IjwdjGbdA
         n06InlDnBIRajiNRYQUaVY5xcs0T2Dh/wdZBvwxOvF0TKQ9CgrweMwmgIY5lSCFqxO27
         jdAA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1GBxLr6s;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 92si26693270pld.383.2019.04.26.18.40.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:40:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=1GBxLr6s;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 936F120873;
	Sat, 27 Apr 2019 01:40:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329244;
	bh=R2rpl+9GTkX7UfwhQa+rgLmWIhB1wYRoWJDewNXmuRM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=1GBxLr6sp6zvcdMMZNKcw8TUcb94l8vShN01ZWKA7w6rjnQsIaXTt/4JrrXkLkiQU
	 nbTT7CXjfxhuUwNM24EraNPovBG4tfH6zvQ6pEy+PgfIw13MoeDdlN7UGBDHAxNL0T
	 o7I4+ENdFjz7VZaveVijLimj8uCsDQBGRAjWdXYs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.0 77/79] mm: add 'try_get_page()' helper function
Date: Fri, 26 Apr 2019 21:38:36 -0400
Message-Id: <20190427013838.6596-77-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427013838.6596-1-sashal@kernel.org>
References: <20190427013838.6596-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Linus Torvalds <torvalds@linux-foundation.org>

[ Upstream commit 88b1a17dfc3ed7728316478fae0f5ad508f50397 ]

This is the same as the traditional 'get_page()' function, but instead
of unconditionally incrementing the reference count of the page, it only
does so if the count was "safe".  It returns whether the reference count
was incremented (and is marked __must_check, since the caller obviously
has to be aware of it).

Also like 'get_page()', you can't use this function unless you already
had a reference to the page.  The intent is that you can use this
exactly like get_page(), but in situations where you want to limit the
maximum reference count.

The code currently does an unconditional WARN_ON_ONCE() if we ever hit
the reference count issues (either zero or negative), as a notification
that the conditional non-increment actually happened.

NOTE! The count access for the "safety" check is inherently racy, but
that doesn't matter since the buffer we use is basically half the range
of the reference count (ie we look at the sign of the count).

Acked-by: Matthew Wilcox <willy@infradead.org>
Cc: Jann Horn <jannh@google.com>
Cc: stable@kernel.org
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 include/linux/mm.h | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 541d99b86aea..7000ddd807e0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -980,6 +980,15 @@ static inline void get_page(struct page *page)
 	page_ref_inc(page);
 }
 
+static inline __must_check bool try_get_page(struct page *page)
+{
+	page = compound_head(page);
+	if (WARN_ON_ONCE(page_ref_count(page) <= 0))
+		return false;
+	page_ref_inc(page);
+	return true;
+}
+
 static inline void put_page(struct page *page)
 {
 	page = compound_head(page);
-- 
2.19.1

