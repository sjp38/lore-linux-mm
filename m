Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,
	SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 29B54C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DBED927266
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 13:17:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="AObX8iZg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DBED927266
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 790CE6B0271; Sat,  1 Jun 2019 09:17:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71B326B0272; Sat,  1 Jun 2019 09:17:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3AB6B0273; Sat,  1 Jun 2019 09:17:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2166F6B0271
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 09:17:57 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id i3so8234652plb.8
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 06:17:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=RURZ6tupkI5g85M30WuQr9T2QyvzaQr3vgRjWu66nu8=;
        b=Dtpp80erspC22tqq2REVPVwjxPVjRa6Gj84iGRrVTkDPU9pHoGL342V+ourx4gh+5C
         C6ZE4yfHfNhVyphT2phHW9GqExeruCuTn1lHIHVSQ4Jlmf9gN4LlQqQ4M+hnnfJbfG6v
         v/nqEYhnhiEdAw2Ugo6uaOXk6Thkdb/UgtmPev4l25ypvHtgQ5MdXl4estotAHzqa/bV
         SaQtdXzwyCvrcr30Dfpj+oCwRCZPJLyRiuuyWuzUSNUmfxpgdaYnk7o51XPiZT+L1hn3
         hxnIkicSNJkZFfAN7juuaCvEy7RN6OJCJc28CFAKiohUJK281WYY128olYxBHR+qAunf
         HgrA==
X-Gm-Message-State: APjAAAXeA1nO1Pnj3YV1Wg2PlaijVvo1SZL9LtG8oDzdluKmUDh34wUh
	bRkIKjZN4Pw5q+8Ho2eSNmWhvoqy+9ic8wWLrQg2s+9p2fIF/OG5IXHuhU+OMJ7PI/NQAKOVfRz
	4TilxNT/eqN8/UHLJzdZ2bYgvmiM/tiSqDoqJsVARZtw4E6TQmxmt+FERWE/aa/AeOQ==
X-Received: by 2002:a63:5c1b:: with SMTP id q27mr15448178pgb.127.1559395076763;
        Sat, 01 Jun 2019 06:17:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXuJVmSANRvkmIE10BS8voLTgfuR02nSUd5o7JbfQeaoHttBRPwh/tlSbBVfVBVze6+Ar+
X-Received: by 2002:a63:5c1b:: with SMTP id q27mr15448112pgb.127.1559395076081;
        Sat, 01 Jun 2019 06:17:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559395076; cv=none;
        d=google.com; s=arc-20160816;
        b=fnPVWVcclc9PCR1BYAKcXrmuCoK/F/1iIq3L19kQJlJj+vDwx7txQsqe6oRdOYrWpP
         UsapbDxV3IcUmJlHof66oRzZUB7wNUntKvwrW3J9Zh0SzVAYY5GMVIzZY/3mSr72YhMm
         /JHEgufhh9bJzXZq9FQVKI5wCtvxgEjv01uDOHGSOYEx8Tojb69KUziZF6jNOcCcFtmP
         YD9bLOSX1ehnLGXkCRwL+bgf1qnPgrkkpiZxwWZTg7NZnc7CvnQ59EBNw/60BZBvKPU0
         ZgqTlFF6BLjwghBedymZzWydwrhv1IE+ov4cliJLSN6yWAVXIeU/6Aq8CYn4ImjoPF9K
         MTPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=RURZ6tupkI5g85M30WuQr9T2QyvzaQr3vgRjWu66nu8=;
        b=dNiHeCtirknkTXmHQ0V/xehrlPLR6nSHKJds9GYsPR4kHSn3KNDVvvHjRQfcCq8Jn+
         pBasv2zXYu3SUMIUeq3jd6Avna2d3Zh7a41Do1Z360BoWz0omV6Irz/Vehk6AAKjvZ/N
         KySaOqQSjEnERpmhi7T4Wwr/05LUGl50LO7NNt2HFu/uNUfmkDKi4/VLkChlWhXzuxir
         2Jj9eG+0LrnCDpcKHDAccdd4XWL6Rn4DPTC1PLgsZAgfKxXxGh/dpjlEo4+oQDGpw5JX
         PEMBQ4DeXQlP1NTGU/bwk3FMqDETqjIFzGKHhuU7KXAEhjbs6u1cKp6jqjCwqcUV3HdU
         lFjA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AObX8iZg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t9si8688280pjw.35.2019.06.01.06.17.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Jun 2019 06:17:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=AObX8iZg;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 9B57525BFE;
	Sat,  1 Jun 2019 13:17:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1559395075;
	bh=lJU+MwtdUqpxJ6U2Kw9WErA+m+fp8zQU34Yp9GSvqrI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=AObX8iZg/Su+suBdAXD9IXNXEXvcSBUc0lMwl9UFMuXh7oPXdhx4Byy8LqUKDHzai
	 A5pHlUeftn6koXFmfNpct2fQr3lOy9/f5/rT9DJ9pZSgQlsuHjObwVzDhOPoDIH8it
	 qT6G84MoNQjWr3o3qAejJdZOsfZzl0r1SIouN1lo=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 5.1 020/186] mm: page_mkclean vs MADV_DONTNEED race
Date: Sat,  1 Jun 2019 09:13:56 -0400
Message-Id: <20190601131653.24205-20-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601131653.24205-1-sashal@kernel.org>
References: <20190601131653.24205-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>

[ Upstream commit 024eee0e83f0df52317be607ca521e0fc572aa07 ]

MADV_DONTNEED is handled with mmap_sem taken in read mode.  We call
page_mkclean without holding mmap_sem.

MADV_DONTNEED implies that pages in the region are unmapped and subsequent
access to the pages in that range is handled as a new page fault.  This
implies that if we don't have parallel access to the region when
MADV_DONTNEED is run we expect those range to be unallocated.

w.r.t page_mkclean() we need to make sure that we don't break the
MADV_DONTNEED semantics.  MADV_DONTNEED check for pmd_none without holding
pmd_lock.  This implies we skip the pmd if we temporarily mark pmd none.
Avoid doing that while marking the page clean.

Keep the sequence same for dax too even though we don't support
MADV_DONTNEED for dax mapping

The bug was noticed by code review and I didn't observe any failures w.r.t
test run.  This is similar to

commit 58ceeb6bec86d9140f9d91d71a710e963523d063
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Apr 13 14:56:26 2017 -0700

    thp: fix MADV_DONTNEED vs. MADV_FREE race

commit ced108037c2aa542b3ed8b7afd1576064ad1362a
Author: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Date:   Thu Apr 13 14:56:20 2017 -0700

    thp: fix MADV_DONTNEED vs. numa balancing race

Link: http://lkml.kernel.org/r/20190321040610.14226-1-aneesh.kumar@linux.ibm.com
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Reviewed-by: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc:"Kirill A . Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/dax.c  | 2 +-
 mm/rmap.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/dax.c b/fs/dax.c
index 83009875308c5..f74386293632d 100644
--- a/fs/dax.c
+++ b/fs/dax.c
@@ -814,7 +814,7 @@ static void dax_entry_mkclean(struct address_space *mapping, pgoff_t index,
 				goto unlock_pmd;
 
 			flush_cache_page(vma, address, pfn);
-			pmd = pmdp_huge_clear_flush(vma, address, pmdp);
+			pmd = pmdp_invalidate(vma, address, pmdp);
 			pmd = pmd_wrprotect(pmd);
 			pmd = pmd_mkclean(pmd);
 			set_pmd_at(vma->vm_mm, address, pmdp, pmd);
diff --git a/mm/rmap.c b/mm/rmap.c
index b30c7c71d1d92..76c8dfd3ae1cd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -928,7 +928,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 				continue;
 
 			flush_cache_page(vma, address, page_to_pfn(page));
-			entry = pmdp_huge_clear_flush(vma, address, pmd);
+			entry = pmdp_invalidate(vma, address, pmd);
 			entry = pmd_wrprotect(entry);
 			entry = pmd_mkclean(entry);
 			set_pmd_at(vma->vm_mm, address, pmd, entry);
-- 
2.20.1

