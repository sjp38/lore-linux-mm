Return-Path: <SRS0=C/CR=UZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 59D2BC48BD3
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:45:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1BAFC21738
	for <linux-mm@archiver.kernel.org>; Wed, 26 Jun 2019 03:45:02 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="Sl0ruOfL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1BAFC21738
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 871D06B0003; Tue, 25 Jun 2019 23:45:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FD048E0003; Tue, 25 Jun 2019 23:45:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C51E8E0002; Tue, 25 Jun 2019 23:45:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 321DC6B0003
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 23:45:02 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id 5so783115pff.11
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 20:45:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lOJeH+nRmo+pjt6ur6bvl4YmeN1GtFC7flSlwpbMS/Y=;
        b=bAMuG/Uj0oi0kjGVHD4TVU8gPj2LDflMuITDSLoAdtCAVHdlxs6ESPvy5Svgk6M7SX
         NQp0IDZHvY32x6409+n0S/WSATjnv1QYUc34QvNeuQ7tDMbAw7NkXQZ/Ie96OwINk5te
         JBxr2M+Q62+ACtTj5mEECv8Z7Ivkr5TP7EMAL0Pk0fNwZzGv7GdVQDXiFLbHuEUP3T/H
         iycFPuq6729ek8BuX/o7v72aBjjIgNRcxp6En/yppSo1zCOXaMWbnD2qtMjTNvDqqCJj
         /M9HJw2bAMLfwq+GIquNvbWFudpUTpA4s4QO8TrrwHaQTPf7ENJxg8WRR+Nk8VTImR4r
         yRmQ==
X-Gm-Message-State: APjAAAV5VssPFKdTbpxgoN2Hy7UtTKBn4egg6BDgTiFCXB/Mpn2uui1P
	8PSrVz30WUJgOJOshgXGWKAhXxAsM0O/hso25f1z8PGRrNd0u9tWRY+pQTZL/0ifzO8PpV1K6M6
	9uNwd69TnHQleDobvroMzoHcpZD4k6e2e8BJEj+LrjQvGcvOt7E2XSDACEaxtS/59gw==
X-Received: by 2002:a17:902:b603:: with SMTP id b3mr2604035pls.9.1561520701845;
        Tue, 25 Jun 2019 20:45:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzO2XGwDOcp9Warz0OURC9fBmLKmEBvBNtDCTy8qxUrG0Z3YI4Kh4QdJkuv2xCwnggtKvv8
X-Received: by 2002:a17:902:b603:: with SMTP id b3mr2603971pls.9.1561520701192;
        Tue, 25 Jun 2019 20:45:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561520701; cv=none;
        d=google.com; s=arc-20160816;
        b=vtjpQGv+nxyJmzJUGb5b8FnizlCM/SskNvOc6dxj1EzN3qv5HT6eDvc9iCX2h9nkTS
         Z/WBsX705AoFYzmGyGqWFOFXqOtYcJVQywe3BUdVuqYILGeMQljAKa+bY7rk+81w4cwc
         OLlxhUZ8BKAeeBBsnQgAdLLRN1T8R7QZz0ZCTSyd4q212DK+vXWs9IjiJm9OeO/SFgqG
         QFRbysTYYebTeLQ8hWVerKQfv/W+ZRY7iSJzPdB9R2rrdJ4m8irxcU9rlGt3aKjeu1xA
         s26fD++/JOIKEz3XC04S+3z8tbZPiwFJ7+/2/SPPrHEsLx2PZaF/5dHKzAcpSuj5Qryr
         DwxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lOJeH+nRmo+pjt6ur6bvl4YmeN1GtFC7flSlwpbMS/Y=;
        b=BnQjSoXzNIdYCfF+7HRGeh8aOQhCImxl6baBIlh9vwJu639zE7x0wLxagk3456WYmv
         3iAru9BD36vZQR3rXK+iloezUHwvH/cMvWpMrGOSFgiXqsoXhtWCRLzvkk8sZIrQvH3Z
         ZAuBOoieTs3L7nhxav9Pi2vGnI9jpwA7QdSN7/8DNt7SGX4+klssLcnULGrigcbuvKXv
         N7FvR4ndxMaCyMC+iDnlZZ1xKgE91vt7FI3kYUiqfjPOPBsff4ycEZX68POyJaHZQR5c
         OIt9Bq/Mrebie20Jrz3kgd5+T3EjAkEalUuoUF1W/8eABIyJgxcXBs5KK6HgCEvRpNJQ
         AGeA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sl0ruOfL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id b12si15046024pgm.368.2019.06.25.20.45.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jun 2019 20:45:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=Sl0ruOfL;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (mobile-107-77-172-98.mobile.att.net [107.77.172.98])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8C94320659;
	Wed, 26 Jun 2019 03:44:56 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1561520700;
	bh=S6uv1RYVLfn2mCdAlui76MSgMxclMbcjRbl0OXKwVtY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Sl0ruOfLohfpmBcI7wO0cPN5GyK8I95XvInQSVl4KUVd2ybPXW5LIwP6FdRBc7Q3m
	 S38BZh3L1oI4PhLkuTvXDLRbWWDKE2ZjWQIuD3PsEzuKdZslNbyO+dM87B97AOLoiq
	 7h6n760I/BZVufIjCpEFjC4GzQKuLNf9FgIwykgA=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: swkhack <swkhack@gmail.com>,
	Michal Hocko <mhocko@suse.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.19 31/34] mm/mlock.c: change count_mm_mlocked_page_nr return type
Date: Tue, 25 Jun 2019 23:43:32 -0400
Message-Id: <20190626034335.23767-31-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190626034335.23767-1-sashal@kernel.org>
References: <20190626034335.23767-1-sashal@kernel.org>
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
index 41cc47e28ad6..0ab8250af1f8 100644
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

