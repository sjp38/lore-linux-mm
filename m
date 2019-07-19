Return-Path: <SRS0=qzwp=VQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42863C76195
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F0BE6218BB
	for <linux-mm@archiver.kernel.org>; Fri, 19 Jul 2019 04:10:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="T+aMUavr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F0BE6218BB
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 99CD68E000C; Fri, 19 Jul 2019 00:10:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94D2B8E0001; Fri, 19 Jul 2019 00:10:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 815338E000C; Fri, 19 Jul 2019 00:10:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F2468E0001
	for <linux-mm@kvack.org>; Fri, 19 Jul 2019 00:10:34 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id q9so17918646pgv.17
        for <linux-mm@kvack.org>; Thu, 18 Jul 2019 21:10:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=HT3DjWZf2h1n4z0AhWETG/IWeIOyFysqsV67VG/d7PM=;
        b=DOkahDH6RDYuDfKkL2uwzNH1HG3v6dQUamoiGZxBa92tJ8kXm3+wAcmcDZKQkRqpIN
         1/i1LknqD3oQzGiRiNgjpvgIMiH1oN/iFhJEio2Tu6kALK4aPxCdiJOZO9H5kGHfYk04
         pOUvvcFQWjNojGfprs3p+b7fZ4vD5Cu1H7TkN5MkctmWQB1dZuSYJ22lZDd+sbL59QTP
         9i5Uu0hc6pMhpoBG/HJpsCaEsSuk3e2UpZ/tgMVR7Nom1t4uwMCt9aIhfkErHBRQNxHp
         UDJYXP4PUA8B14okYyWkL4nqMvZolkQW5eoy8wBXDSMNnetAVz+osC8F4GYglplRjn+F
         RODQ==
X-Gm-Message-State: APjAAAWiwk1pJS996e9vyJTn0TNiQyjZ3g7QnR3ZhinZeXyk6BZ2Mkxd
	MI0SZA8rp3nu1N8R94MaKcCbqyeWEgXDb+b40pUhk8oILsCPMr/ygpf1fiNADViLxsLZpoDvmmu
	VMIGXzQ5k0uvpmHF04Wtt28jNG32klpz1N4LFCa+CjStRTZ8bZUkmvQVB0tN+Jj8Uiw==
X-Received: by 2002:a63:5550:: with SMTP id f16mr33532444pgm.426.1563509433893;
        Thu, 18 Jul 2019 21:10:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwrE4deaqLY8K9qIXk+N0f3FqwhuXgAcVnEblpWqiePoLNKbA4LIrKvvO4N3e4n7XZVt1+N
X-Received: by 2002:a63:5550:: with SMTP id f16mr33532386pgm.426.1563509433218;
        Thu, 18 Jul 2019 21:10:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563509433; cv=none;
        d=google.com; s=arc-20160816;
        b=mDF9IHQwtSzCRE1pH1vPQeK+S6vlU/1Ci5PeMj56Y0QS809+a9CYzY7HywsfxOmGnn
         594OtDJE/llbTSmxXaWmIhJ+xhGoaO0Fvkl+Dm3KOs7yY/j+nBluVsmOnOB+mW3uEyCQ
         fn5cMDDj3yI+iuSrTS42y9REOhbH1WMKTYjMl3EiGym/ZwqvJ8i1szziVxWfQMFey58E
         ZBzsEFlh0vmQf+lW5DCV/Rj1nlU0notdxAvFSmqz38qdXfDtKbHhUchChno0vRDFFofu
         RO6xJjEDhtuigJz3im9ZR/1onXdVmFMq2z9VUuPnnRH5uDxDqgGfY6Kfpi/uz3vnVk3o
         N0OA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=HT3DjWZf2h1n4z0AhWETG/IWeIOyFysqsV67VG/d7PM=;
        b=Rz4aMZdXuUY90XXDTj9yOXWsmfWFgCogypqEzPtFO7Y4nI3qLe8yyOoYcxgRfEPjes
         19YBEER5NAjTlESIwkWjVKBora4cGOajUrfLebtwEMdBAYQoVgeJM67N6dHLiZUuXO2x
         panKsNDyVVWpqqRKsWkRQb6EmNxDl2wsjkyfOZnOqOtLY0EyUgHPz0/C9ihJzyH202VC
         vTjmE7zKq03YkspyE1Z0dqRODmbTETW47yxE6d1Z12/7iB5XVDokV3sPc2N6B4SF03kw
         WCvhzJwqdeXCC9YNbqLa3BeDD5XbwG+xBQWkxfHyeiKZGf5VR+1QsSLm6prylr7EWGqF
         s64A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=T+aMUavr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id x22si947897pln.150.2019.07.18.21.10.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Jul 2019 21:10:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=T+aMUavr;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id D5D55218B6;
	Fri, 19 Jul 2019 04:10:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1563509432;
	bh=rEOxhVje41GtsRNcgA834B2vdF8qdzCHLjggyEcMFM8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=T+aMUavrXnh81sXlmspXJ+9K/U9W4Q3/cvhL/RIF9FDCCVE39iy70dJFC/YSYy7R2
	 9W22NXzO95FNIveejdgjlJOm5PvKNZ5eI3H7xYIABMhVjw3JvEmCsK12tJ6CbR8qki
	 gJ4XtSAXKmC0onyvicApzIRCbL9QUffGax/HAPKw=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Guenter Roeck <linux@roeck-us.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Robin Murphy <robin.murphy@arm.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 090/101] mm/gup.c: mark undo_dev_pagemap as __maybe_unused
Date: Fri, 19 Jul 2019 00:07:21 -0400
Message-Id: <20190719040732.17285-90-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190719040732.17285-1-sashal@kernel.org>
References: <20190719040732.17285-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Guenter Roeck <linux@roeck-us.net>

[ Upstream commit 790c73690c2bbecb3f6f8becbdb11ddc9bcff8cc ]

Several mips builds generate the following build warning.

  mm/gup.c:1788:13: warning: 'undo_dev_pagemap' defined but not used

The function is declared unconditionally but only called from behind
various ifdefs. Mark it __maybe_unused.

Link: http://lkml.kernel.org/r/1562072523-22311-1-git-send-email-linux@roeck-us.net
Signed-off-by: Guenter Roeck <linux@roeck-us.net>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/gup.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/gup.c b/mm/gup.c
index caadd31714a5..43c71397c7ca 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1367,7 +1367,8 @@ static inline pte_t gup_get_pte(pte_t *ptep)
 }
 #endif
 
-static void undo_dev_pagemap(int *nr, int nr_start, struct page **pages)
+static void __maybe_unused undo_dev_pagemap(int *nr, int nr_start,
+					    struct page **pages)
 {
 	while ((*nr) - nr_start) {
 		struct page *page = pages[--(*nr)];
-- 
2.20.1

