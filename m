Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C9805C48BD6
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:43:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 92985216E3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:43:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="PUcE084K"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 92985216E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2A97F6B0003; Tue, 25 Jun 2019 23:43:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 20AC88E0003; Tue, 25 Jun 2019 23:43:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 036018E0002; Tue, 25 Jun 2019 23:43:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id B7AEB6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:43:30 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so787649pff.8
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:43:30 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NFfZ9NrVPY4DNRbADS4q9T3gLqVCLiY8Sf362/w8mB0=;
        b=pFfS923i/0OgGeYV5NbgFns3aOTGKN6LI5wXFJJDxHO3ZUPmKaEVr2SMM96jJQ2Lkz
         IetLHXM5MLDXDcGidA+2J4yf+ZAEKslONVRrv3/2sg/14xedyU6ZgtizEai6rZ8jAa9J
         TyyfGdfExBMDRFEAi0UWl+sQzxRlTMHCv5HQmw4y+hMe5HreQycjpAzLJNWJ2q2Ikcog
         7v2eVNA9qOo0u8k2lGPy0tL9m7HAyH5yozH6v6s72Su8IaDmaAv3ejw0k16QUBCvjHBD
         WD+jDr1Y1zfGwNxFIMqaF7z9kQt0vABZFT+76V+s5oicBnC52zpBaqsz4tUtLUtIYDL8
         UN2A==
X-Gm-Message-State: APjAAAV7RBoYoozkFt0OInlkDYSed41rlJDP3N6075GDQ9aYH8EbJuF6
	yjj/PPJet/z4+PHijPKBcNqeXsa7mXy8EdrVbOEX+EGiagqksIu98/zfNIU8Ejq4se5baXjVE27
	HjU78ljgth+kdq5EUhGNH0uhamSlw0v115Amo+HOUPX7u8piN8OVMZUEBp458X4sCGA==
X-Received: by 2002:a17:90a:be0a:: with SMTP id a10mr1713695pjs.112.1561520610196;
        Tue, 25 Jun 2019 20:43:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY6SlU/4G2xNls1f4C7ut0IGDpil+dGS9ngYgkWza2ZABbl8JwtLmiXhGtQ0grDNspTkBh
X-Received: by 2002:a17:90a:be0a:: with SMTP id a10mr1713622pjs.112.1561520609497;
        Tue, 25 Jun 2019 20:43:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561520609; cv=none;
        d=google.com; s=arc-20160816;
        b=ruwEFaVwDT9M3hqFIdXw9tal7vxqAgN7Huewn8XZrEJOeTI+pa0HQyOJs0BErSYIGh
         OiltOawUbDCg8ndjOLO1hR3cZdG6ufeHrnRtMCOMGwKiHWKim61isQ06ahig+LloE8gb
         ip7dxk89H9WPDjPSRZId/s67c8PFffKt+8ujWjckcxo4mofGuEcV15XRxNMmzmyL3bgr
         FREbi4IMaXvD8ydF50ulIvH29lAAI8EJFQajROqxR+85OPGeCp4Iq+pEIJeBU/s4qjFK
         8QiukPUCO0VuSbhNYRN+HDnftVezk+vP6fwlR/VBxvbiVJMLU5kgoNjMWbZrQABlUjNe
         KEcA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=NFfZ9NrVPY4DNRbADS4q9T3gLqVCLiY8Sf362/w8mB0=;
        b=eFkYpyA2OBkRK1NU8px7p7KynsqW1x8AYT6+DuklM+tuLI7Dkr+uWx3jCac1xwj5RR
         FP9sZm0ypil3cwBNL7GFlQwlFl1moU1jo0A1sjZM1Hb49/BfCTfn3nCMz6/9bS/KNV8U
         /rXZ4HupGeex7QHbYtn1I8M7rs0JKgWfl+w1SrAjU+Q3V440CweiyGX3BYMS/sRrw9CS
         qUc5oPojmYjTCpA3TvNjUWyNvyx563pKD8M/RSSB/lemGDI8rL7EZhTJG/2uIRrHOC5e
         dAQHKKW0/85Ctw+eME71urllsf2RH5Y8e9gSH12+UqzF6OIdYQv+J9i1nQlmdjujDF3f
         92wA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PUcE084K;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d18si9775515pgv.19.2019.06.25.20.43.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 20:43:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=PUcE084K;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (mobile-107-77-172-74.mobile.att.net [107.77.172.74])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9B065205ED;
	Wed, 26 Jun 2019 03:43:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561520609;
	bh=WQG4d7wo+oT5gncaeN0iEZzrks+hX0cXQBbrKttkDlE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=PUcE084K2KRcE/FFl+hqg91ZWD1kWylsIRx8keUUQWpXH9KGe6Kq0PMWacbzfyM2F
	 kyJEOEY0GR/Wt9U7PbA2GpDLQmmZyl0sDcYSPGg+zVKnB7eEIV0PK6rzkg2gq7LP9q
	 zAdb8G36+jQlFtd0FlqdaMyE116871+vSxTqHaAE=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: swkhack <swkhack@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 48/51] mm/mlock.c: change count_mm_mlocked_page_nr return type
Date: Tue, 25 Jun 2019 23:41:04 -0400
Message-Id: <20190626034117.23247-48-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626034117.23247-1-sashal@kernel.org>
References: <20190626034117.23247-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: swkhack <swkhack@gmail.com>

[ Upstream commit 0874bb49bb21bf24deda853e8bf61b8325e24bcb ]

On a 64-bit machine the value of "vma->vm_end - vma->vm_start" may be
negative when using 32 bit ints and the "count >> PAGE_SHIFT"'s result
will be wrong.  So change the local variable and return value to
unsigned long to fix the problem.

Link: http://lkml.kernel.org/r/20190513023701.83056-1-swkhack@gmail.com
Fixes: 0cf2f6f6dc60 ("mm: mlock: check against vma for actual mlock() size")
Signed-off-by: swkhack <swkhack@gmail.com>
Acked-by: Michal Hocko <mhocko@suse.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 mm/mlock.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 080f3b36415b..d614163f569b 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -636,11 +636,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
  * is also counted.
  * Return value: previously mlocked page counts
  */
-static int count_mm_mlocked_page_nr(struct mm_struct *mm,
+static unsigned long count_mm_mlocked_page_nr(struct mm_struct *mm,
 		unsigned long start, size_t len)
 {
 	struct vm_area_struct *vma;
-	int count = 0;
+	unsigned long count = 0;
 
 	if (mm == NULL)
 		mm = current->mm;
-- 
2.20.1

