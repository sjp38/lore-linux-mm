Return-Path: <SRS0=h8p8=S5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5F1A7C4321A
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:42:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 17BB2208CB
	for <linux-mm@archiver.kernel.org>; Sat, 27 Apr 2019 01:42:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sq6ZcvXz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 17BB2208CB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BB20E6B0005; Fri, 26 Apr 2019 21:42:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B61D46B0006; Fri, 26 Apr 2019 21:42:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A541C6B0008; Fri, 26 Apr 2019 21:42:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6FD116B0005
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 21:42:21 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id 132so3157757pgc.18
        for <linux-mm@kvack.org>; Fri, 26 Apr 2019 18:42:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rN9UQNtok4q9N86h0Hlpd3eqFga9WqBMCwlhkv00oTo=;
        b=C08WJjq/iFE/naS+keZIY3lSZ2v7FkP32V2TGKws1GV+UZ4oXkUo7gu5tc+B3cpCvJ
         pm4sqBNDw+Hml9byDr3ZLTspTlIz31fTzYfOLFG2j4+XHqRC3V/vmJL0C6bLBVI1VF+I
         eM3bpuGPZY52ocEqxO780L0houC5DZrY04Z1E5qElriLgBBs2Z+E4+UPMyuB4M3xQQXk
         bIYKJloT06LbjbErHiPev/ImoEBZJzHNWP/sUsufyM10dxZMMRTbnn1FnRDpQ6zaWVxv
         y/KzqWDRByrvaO4BV1RuUmI9rCuzhHd5s68+V6aNS1t2cpAfbOWRlZSRt5TUlmHzzbjs
         +XWw==
X-Gm-Message-State: APjAAAUvP62vKlFdmmtitrMqO+lh8ga14ctZZrfYUgvouYfBaQXtu3FV
	QfA/rUD9H/ecem7sX/y+wcaVrDJtartETQIjFLewFLtBbgla1ZtXceXuKyVDkKI+xTi8AueRsbr
	et9jkFZN4qJTagxQfqquZnwqQxLpvhKyFxDvBwMk85yGdlQEgfPssrban+4jB56+aPw==
X-Received: by 2002:a17:902:2827:: with SMTP id e36mr48099411plb.45.1556329341122;
        Fri, 26 Apr 2019 18:42:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3RwnxmNhNtGh0bYZq76+UfuXt4ZE3Bx6rap6uAtfnDJnAlVlEvhsBD4FBpZRJ4JTvN+QN
X-Received: by 2002:a17:902:2827:: with SMTP id e36mr48099373plb.45.1556329340400;
        Fri, 26 Apr 2019 18:42:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556329340; cv=none;
        d=google.com; s=arc-20160816;
        b=GtYqkwBocCfXVc+8dm4dVG00egBxjqf+MU48z/DpdBk6k0nAMEa64CauVaaJ9r/TcY
         JZHJac+OFbdlWw1GPb0n8R0ueP6owq1EkoS3+4WAeEyJqpAc40CEbDNKOHYI4P+d0iHv
         yIfvJFjhp4N0CFYbMkVaUGi66TvliHTaeP9etugK/ffkmYs/zi6q1IcaMXWA6G3oGwwS
         c9NpQpo8S+a8t41/JMHtKT2dN9S/WB4WDu7fSbKf6pM+QI9mRb4Vvr5AEcvW2v93dkxc
         C9h4iLRGwWCYsJOHJAdn6rxe8ArVrv/urrXXLDpCSRY+8G1q2Ia3l7MAkXr40MawijK0
         MV3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rN9UQNtok4q9N86h0Hlpd3eqFga9WqBMCwlhkv00oTo=;
        b=0f3oNrRSh8HNEGjWFu42IxzmH/yEbXDQvSIyygWsgfBAETi2/Ojxl5O2GwtuL29O+r
         D7sscWb+nGjNz5MtBr76TQWa1kTVXmp8h38S2HkQD2m58JtcHsYMesSPai5fnBHu9tb8
         Q2zmXtsFuk8K+JTZfJhj9xCdLW+wNr6C1QGZfnxaNe9hybdAmDe/DA2zponRFga4JpzM
         aWAAH7V3ujz8gAaAF/lFMOieGAXa9hRkSt1oT9OUcEm8TEoPvPR1TLLKduCuQYgvtEzD
         gusOQWbW+TpK3WuIzvADuF7ciCkfoFNaS9ZqCl/VwObWpX1bMRRi/08XKydDIFJUBIzZ
         DXGw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sq6ZcvXz;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h72si27522502pfd.86.2019.04.26.18.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Apr 2019 18:42:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sq6ZcvXz;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 432242053B;
	Sat, 27 Apr 2019 01:42:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329340;
	bh=hcpSQVmgA156WVY6t1uIxqFOm0AgCXm52bT6+ftrSGI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Sq6ZcvXzUKReBvwgIiLIhblqIjzv5KKPjIzYXvJ+yl1mduttVv04FXLjoisXpoG1O
	 vPuY7nTCRM9ccEgUQjxxeXbhySdWKjZFZm/W5NNtzc/UEw+kR6RlDyZVd7sgYSyrEd
	 fDFI4ZUKnoaLr8sxtz45RzQfKsvvz5nGqHvureh8=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Jann Horn <jannh@google.com>,
	stable@kernel.org,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 52/53] mm: add 'try_get_page()' helper function
Date: Fri, 26 Apr 2019 21:40:49 -0400
Message-Id: <20190427014051.7522-52-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427014051.7522-1-sashal@kernel.org>
References: <20190427014051.7522-1-sashal@kernel.org>
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
index 9965704813dc..bdec425c8e14 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -930,6 +930,15 @@ static inline void get_page(struct page *page)
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

