Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08E96C4646B
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:46:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C2DB621726
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:45:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="uefC+ohN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C2DB621726
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 565586B0006; Tue, 25 Jun 2019 23:45:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5160C8E0003; Tue, 25 Jun 2019 23:45:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3DE418E0002; Tue, 25 Jun 2019 23:45:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 095656B0006
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:45:59 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c17so759740pfb.21
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:45:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VDGMbolI1275l0pMen/125ykBLo7257qo8kN0UiCZDo=;
        b=ReYg07BYzSVBGJJXJzEcUDrgxORjTcngn1VC8fVEUvD7slpT3GgMeX4xxb7rtQ69tc
         NOWckESBpIgsk0F47Dx6VMfAuY40mItxao4u6D5hXCturlBZbCCh+SQt2788QVaZKh0R
         iwqFWc6DAtjJQNFDJWAf9oRbzX88KE7HnzB2ofTgq8W7Ed325mYHiiOJq2XllvTBX1JR
         fE1u8LmQ15EirxgmlF5U23LVoCfAGETJ2cpAnq5Sh/9Y391BoVjt5kTWbL8psKjeEAJu
         xTy9mQQwURmHLKEA5ZxkF8RF1PG3PEKn2KtWS5c0Ed2fQ0YXVlAW6czmxpWGLYxFuSxk
         HM3w==
X-Gm-Message-State: APjAAAVuf2NePx1z17xlZgGdLmvcXGQ5oaIU8MwTTRDB4h7VmqjFpuTp
	bvs3qGMydkLlYxMd9K0gHhCavDxUcTfXhVM8KjerI1SukPHwqyhTtuJX63sKVtDHTGONaAYHD7P
	8oWhN4RkVpxvvGNYtoUOciQwb61YdMLiYzu/3nzEVL3hoFtccVvlGCGfVYFjydLFGYQ==
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr1853756pjb.42.1561520758695;
        Tue, 25 Jun 2019 20:45:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxfOv2sw02wKaz8YiQIkWagI3+SWcHOk9bcOtzCqJyPBEIz8uAShfXQZ1jQGsi97RxpH6jG
X-Received: by 2002:a17:90a:30cf:: with SMTP id h73mr1853703pjb.42.1561520758059;
        Tue, 25 Jun 2019 20:45:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561520758; cv=none;
        d=google.com; s=arc-20160816;
        b=V2PIgu+QbGm8Z2Og+XaHQ7rxTDA9n3/49OrSsR/HVVyEOd7SgATrnrtFPhmefKgjSY
         d4dw9FFlPVu932JQXkCZ0nilSaZ8+PXi2fvsFxWcHtUW/+cOXy8CVFFbztLhBlu6wBBK
         o7Ak8GWLr5diEkfWoLTF5WGDLRgwzhpCpDEoRjy88xvBMTUBbDFywHU01CtsRcyoS53k
         8h3H1sCZVVtPg/+hUS4NLerw3/ATPmhCXNvu6ugIGmlY+I3Gk3ld6nOg9i3fGWUsvcZC
         qACJah/8Twxv/4lANCy0RSc1ZnhVtGm9mX2AfjOEmVvCsqHbdr//YK29CYeM+Rl4dC23
         CLYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=VDGMbolI1275l0pMen/125ykBLo7257qo8kN0UiCZDo=;
        b=UwmmFeoc+uAfTD7aYkoNyqtM479bIbmPQuAnEbmmn1dj+BRGmc/NMQ/i2/EciWbDCX
         1JgA0IiEI7zHP76f4IUjp+Zq6gG0lgdXeHSsI+wtP3y1Z9CFSkIGaB9GePKR1Nu/gZPW
         31LhMBe3HE1h1/u7a8ZNBz27xk9/dApgPUOZUQF+vN5ADyRxXLoJaw446UgtPC8qgY5b
         JnZw/umBbbFqMv2pbsfpgPUF194fUNmhdFi9CM6q0saltG3wMg+y2wPgpjO/zUTa7CCY
         ohsGHzWltrhG7AesT0ebKK5sfJw96p1SHTTthlidIF9qw9meLVim4PcoYeVxKg4bw6Z0
         bHaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uefC+ohN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id z61si2025886plb.19.2019.06.25.20.45.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 20:45:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=uefC+ohN;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (mobile-107-77-172-74.mobile.att.net [107.77.172.74])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 87CE4216E3;
	Wed, 26 Jun 2019 03:45:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561520757;
	bh=97D4d2N2L19ZQmdIolUI5G0lZnrxoRiDWOVu/dcpEeA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=uefC+ohNPq/OQlnGgT4iXU2DkYYJ7JpuGl50krJpEBguLy90JIGgqaHk68SrSwQCV
	 vPIpITlzSxgkw94H5X3ivI/nkZc+k30FTnMNcWLcub2X2QkfKDkL1mBZjcTDtdPnAM
	 1Pt/gF+NCdCXe9Y0JVjCVf7lMjo0Fkq4hXNE5cZA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: swkhack <swkhack@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 19/21] mm/mlock.c: change count_mm_mlocked_page_nr return type
Date: Tue, 25 Jun 2019 23:45:04 -0400
Message-Id: <20190626034506.24125-19-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626034506.24125-1-sashal@kernel.org>
References: <20190626034506.24125-1-sashal@kernel.org>
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
index 46af369c13e5..1f9ee86672e8 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -629,11 +629,11 @@ static int apply_vma_lock_flags(unsigned long start, size_t len,
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

