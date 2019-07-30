Return-Path: <SRS0=QSbQ=V3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8BAC5C433FF
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43300208E4
	for <linux-mm@archiver.kernel.org>; Tue, 30 Jul 2019 05:52:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uq+lPiYK"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43300208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 665F08E000D; Tue, 30 Jul 2019 01:52:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5EF168E0003; Tue, 30 Jul 2019 01:52:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 491CE8E000D; Tue, 30 Jul 2019 01:52:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1124A8E0003
	for <linux-mm@kvack.org>; Tue, 30 Jul 2019 01:52:42 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id n23so28002415pgf.18
        for <linux-mm@kvack.org>; Mon, 29 Jul 2019 22:52:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lQ9XWeQmmP2B/eiMeXgVV4uJBU5pKgmRyH+iL8uHSEM=;
        b=JBtS5MEky03lyJtt0jTXNyvxuvHmdYaTegboajbufZrgIcpEuUXOdQXJJXR8iFGCI6
         8mrzKItbp+JI/KMSgiGwNjdmkLqo0w/LFAE0gJ/yacl5cL3l9EbnDxR10XuyeBXyOOSr
         cgFvqMuGJWGDT2h9vSBexXyjYHX5L5inZAZzztyY8Wp0TGTkU1KXL4fN+VLke8LcuCjn
         FrwDqhzQCURKWsGpk28aBTdH7OhxtRtZNw4u1kJTHnAyya86PaRSBh1Q8dewCaj3+nqI
         XDWuPGEAgOD9xhsyehXESN27cjeFJNcOwVHdQe10c0aGPOIdbdjmaRWgUgDu7rXM2+OP
         lIBg==
X-Gm-Message-State: APjAAAXnIxdkhkLDgVmxdRVWT9C46EKMSVD5RYHJJs/4VeQ3s9CPdNuw
	QXfHvEdJOndDRKIQ5zN7aNGjOk52C13cix1/tejfyjsKbDVD/7bVaaYsg5rkOCMFkREJ/xrRxXm
	irp7uMmMGlzb48TTaAYbjwlWQqeJvCZPjU/eXvCktsS2OfoZxymLP762jqL0vJBc=
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr113235852plb.81.1564465961774;
        Mon, 29 Jul 2019 22:52:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxAIC6g+9UHW7/8RI1T7doFUNDQV4mFuinXE0RSNQ+u/Y/K5M19S4Iof7jjzKoRhhsfWi/e
X-Received: by 2002:a17:902:f089:: with SMTP id go9mr113235816plb.81.1564465961123;
        Mon, 29 Jul 2019 22:52:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564465961; cv=none;
        d=google.com; s=arc-20160816;
        b=cek3KpU56JqqskNwEcIvRqtiau5LmxbBpCB/Q38hP3snek8JzUuCw/qVAx1PeNue0d
         pycTVKjN0xDQ/y4+l3MH8rFf+Cy7xWevNahLLsvkoAekglJC6U4HmFCi08CU9SJR/VbV
         mryrViTa3ige7l5bVtT/q3ooVWplvPoKARot1HCB539uqISLI4kX0FH21FiNMgm/4m9O
         nFQCkeo27Ypi7/8VC/4MrL7tO/C7hZx4awIihkTCEd2NZS0VKjtvhtLYYIAoAtoo+u7e
         qcTUe+ZObMqaRXk032e1Qdz7oxhlpCy3PAuqLAoNEDOOtDoSpmTNQn2mm+/bVm+4wRsf
         hgdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=lQ9XWeQmmP2B/eiMeXgVV4uJBU5pKgmRyH+iL8uHSEM=;
        b=ya8wQYPFyey7DI84gYvd2yAfj7aRhbb+DBwsWHqyYIYtC5wBZ24keChi91Gy8SB66Z
         MPlUkwC7EFZArdueJiaB0q4R4yy1a4GbgtUwIkkEbWr8U+by9mTME5IOTKz4h/vvV5th
         Ffl1QCT1ZinYB9tOcKB94MNuRNgUwxVuiw+F1g5/Y8vDtivIYXWDNQ2VLfgEfFGMAVKJ
         gJNNYZRc7986e5AsESSAl5DQvfGX6KssvOI2nS1PKasKI3BTvdXHUY0O03l1lfRmNz0v
         KUujJuTuwNrvDZxIevn4lgBhpc+/RUWJiepoklYwPOcQRxwqm5Tl9O5BIj6eUO75v2WV
         Yxhw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uq+lPiYK;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a17si31168264pff.195.2019.07.29.22.52.41
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 29 Jul 2019 22:52:41 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uq+lPiYK;
       spf=pass (google.com: best guess record for domain of batv+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c7577188abbe010e1e13+5819+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=lQ9XWeQmmP2B/eiMeXgVV4uJBU5pKgmRyH+iL8uHSEM=; b=uq+lPiYKi3jyFWYRyJc2ZqGofZ
	AfLm7DwXmu4JT8EzoT14gmQsntskqRtuY8G1cnrd/LGbf8XPIjVfgOc8bb9ap9X0V7joXGNksytRi
	zALM22SNoQasN3BLoeBFR/vvCHaXwDoi9ZRyvE3+UeWsboS9MGuTqQ9l97jIiVzC7JdWxUgbDi94Y
	SNudo9geEIfISGK8/w858hjF3tJ5AFspbRUlnzqRM0O4lBbRAx36X7p2UDsP9spKDQweK0rlIxERO
	kDjVa7wlLGqVNCj2hmZofEs7SfZ+60OPJU4FjcxlQ7UvktaV6516z56wix5W6aeIElxYkE9PQKl+5
	u8tqsQjg==;
Received: from [195.167.85.94] (helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hsL3u-0001K2-4x; Tue, 30 Jul 2019 05:52:38 +0000
From: Christoph Hellwig <hch@lst.de>
To: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ben Skeggs <bskeggs@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>,
	linux-mm@kvack.org,
	nouveau@lists.freedesktop.org,
	dri-devel@lists.freedesktop.org,
	amd-gfx@lists.freedesktop.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/13] mm: remove the mask variable in hmm_vma_walk_hugetlb_entry
Date: Tue, 30 Jul 2019 08:51:58 +0300
Message-Id: <20190730055203.28467-9-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190730055203.28467-1-hch@lst.de>
References: <20190730055203.28467-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The pagewalk code already passes the value as the hmask parameter.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 mm/hmm.c | 7 ++-----
 1 file changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/hmm.c b/mm/hmm.c
index f26d6abc4ed2..88b77a4a6a1e 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -771,19 +771,16 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 				      struct mm_walk *walk)
 {
 #ifdef CONFIG_HUGETLB_PAGE
-	unsigned long addr = start, i, pfn, mask;
+	unsigned long addr = start, i, pfn;
 	struct hmm_vma_walk *hmm_vma_walk = walk->private;
 	struct hmm_range *range = hmm_vma_walk->range;
 	struct vm_area_struct *vma = walk->vma;
-	struct hstate *h = hstate_vma(vma);
 	uint64_t orig_pfn, cpu_flags;
 	bool fault, write_fault;
 	spinlock_t *ptl;
 	pte_t entry;
 	int ret = 0;
 
-	mask = huge_page_size(h) - 1;
-
 	ptl = huge_pte_lock(hstate_vma(vma), walk->mm, pte);
 	entry = huge_ptep_get(pte);
 
@@ -799,7 +796,7 @@ static int hmm_vma_walk_hugetlb_entry(pte_t *pte, unsigned long hmask,
 		goto unlock;
 	}
 
-	pfn = pte_pfn(entry) + ((start & mask) >> PAGE_SHIFT);
+	pfn = pte_pfn(entry) + ((start & hmask) >> PAGE_SHIFT);
 	for (; addr < end; addr += PAGE_SIZE, i++, pfn++)
 		range->pfns[i] = hmm_device_entry_from_pfn(range, pfn) |
 				 cpu_flags;
-- 
2.20.1

