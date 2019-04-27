Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED136C43219
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AB68C208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:43:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="yOKebXeV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AB68C208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 597376B0005; Fri, 26 Apr 2019 21:43:25 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5470C6B0008; Fri, 26 Apr 2019 21:43:25 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4120C6B000A; Fri, 26 Apr 2019 21:43:25 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0CB8E6B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:43:25 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u191so3195513pgc.0
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:43:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=F3AfJAF1rKS+8/rt67c0OI7E6CVVyON59WB+/sj4aqc=;
        b=k2QWXr+elN6XB+pmY1lTZ05sIKP9n2R75M4zF1yp1kajgF6P89/ditE+B1fGa2zqKp
         4Eiv3f64qKzbxwaciMdxS7+0HyiK67tpq9Os9FQxdB6Ykogiq7+fsCwqszDMvbWvjcWu
         qFoR3r62e7NW+DVhljzsPDmC4qS/5V1msQ+O6PxzJ5YZjlH0vwvpS1BYr8W9Q/e/j8eH
         DIYUsOBIxPOPdupa4Y/gJ1HWG5GQNOMyITzcVnff+8zJ3dkcAhkUuIJMOEFStQ4/4b5n
         qHhU/icjsWuEWBAkGbRswDKvN8ePIESnkbqHOZLZ6E77j559o9eyY63uJpjzSTjzuc6m
         8nPw==
X-Gm-Message-State: APjAAAXXzqs25yW5Elkny/+Ppdy4y7vLVyHRmlUi13/mfsKCrllLXxBR
	rpFYeR5v5RdgAQyZ/75St2rQidYOwWWTEKlb4TsUDrf9R14IzMrBhNdDSdEQh9AnYunE9FOUDB1
	GIIyO9YrSUy7xvoXRYr1WTaZ4aNO40cxIk0OUo7z8dHgL5QZZgYQ75P+l5mAMfyMlwA==
X-Received: by 2002:aa7:8453:: with SMTP id r19mr50390733pfn.44.1556329404712;
        Fri, 26 Apr 2019 18:43:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxWIs6rqszN4SgFN78pW4UHVT76G2xsBLkCGBqlxFHFRw6cNS5nRZXIbv9zS6uOmF/Mqdtq
X-Received: by 2002:aa7:8453:: with SMTP id r19mr50390693pfn.44.1556329404016;
        Fri, 26 Apr 2019 18:43:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329404; cv=none;
        d=google.com; s=arc-20160816;
        b=Dhps+ByDOF7BPyxpcR4X+jFlW/WtrGugpwNJ7wdepXTPUpJH8EA1TTf3qAwDkwAyuW
         DWHqeqyecKsWsDoqJZ+J60y4wg5yCQ6whkDqgY7eWscXvGBu93/XHjJpvgTilnDLtbJL
         L0X0nVncFR3v5DDzInH6AeCzt2qnGlMCec+pSBjcmJnbexzUNhSr7YJKPTL8/ccW2xvu
         62A5qnBVWoN6+RAsTVVaLU68bVjkABERfJpJuiRsN84fIVpiPhh/+HkQuz3ILnKXtYQE
         Iw4hgrwD32pRQ6hrw6tos9a3PuAvx4JXEcf8THohAWunVq6VDxFoZRMZzhwYq6VtPdpL
         sqUA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=F3AfJAF1rKS+8/rt67c0OI7E6CVVyON59WB+/sj4aqc=;
        b=H/EGHOsBWCZcixDyPEcXsaWpB660DDF1q2i7uRH9wH+oa8LLZHl/qFVE4ibs09PdiZ
         rI+50/eqv8hOSC7FqyMsVTVlPxaKycw8dP/jC6+K8Ecg6wLs5teH23zXFekxiEev/zvH
         0rdn4F554l52GoyhOVyIjV2Q6elGRqG4OSFf8l6/sU9w0eFpbRybUdi48ub8sgqHOHHN
         uSI2xS55cZ2IPXPsHxGyKTZ+RSVt4WPUsn56q1FD2XeocpTJgFjkpYpiyAvfkKFiHc8x
         NXJACGMmuWwcsqwS+EEIrf/RoaFIt2vuPbuqK08s1Dz/XMv/YRb2KW9eTTqluWX/PlXB
         wA6w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yOKebXeV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h11si25168041pgv.163.2019.04.26.18.43.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:43:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=yOKebXeV;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id DE86C215EA;
	Sat, 27 Apr 2019 01:43:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329403;
	bh=csu3/yVdw+AXRydbiwpoo18j8p8IZhtRNOJJ4Sc1mbk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=yOKebXeVtzG7CzQVJU5T0nIWJ3eBTM3hYl7wbLJZUivvsyUbIGe1ACzsBwWzTwpUE
	 STILYbSo/t/sO7VwtY0kJfyJOjHmXJKHXkZmOqHU3Oo7NdaUMBQ5gRUiQ5udKw2A9i
	 eRhGl4QvSc7JhcNQv7oKCozPtB/jGD5ep0djYMXs=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 32/32] mm: add 'try_get_page()' helper function
Date: Fri, 26 Apr 2019 21:42:23 -0400
Message-Id: <20190427014224.8274-32-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014224.8274-1-sashal@kernel.org>
References: <20190427014224.8274-1-sashal@kernel.org>
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
index 4023819837a6..ee0eae215210 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -839,6 +839,15 @@ static inline void get_page(struct page *page)
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

