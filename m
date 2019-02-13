Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0BABC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 641DA222B2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 13:58:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="pbigDwG3"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 641DA222B2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 380CF8E0001; Wed, 13 Feb 2019 08:58:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 275AE8E0006; Wed, 13 Feb 2019 08:58:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E317C8E0001; Wed, 13 Feb 2019 08:58:40 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 960AC8E0004
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 08:58:40 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id h70so1926792pfd.11
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 05:58:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=KoLA+3LlO7WJ84IYtjfADIs6cz3FANegvVG5T66Se1yyA0tjM6saotpKKc5urCU5LW
         /G7KC9uyXEVCJMJgxSI8ID0DROLBAJ+7O5Akyt2zFTdYqiv5QMDdtxyJ+fmQUqUJbIz3
         c2KEQrt+9Rt/I9GpGmXoavu+KmOscONJbogMeU+y3rMoHT2nsSDchF0Xw2RAmu0kzoos
         cRMqleguIp9bJaSA8KkyvKsYwVdgh2+Hraa1EMIjgXb7kH419wSmmhH6uMmGcmHLyiCv
         sIcdW7GEc4PJVFczAO9V6sYpApDFRHQlgGB8UDVxLzX9dkuoGAbklG7qUSKMUSTE6cUl
         wuOw==
X-Gm-Message-State: AHQUAuZ5DD7MT3InCFgM6j3XThaRobqhvJNt+XqcMYIRxO6xW8ZYbc3A
	+gEwviwZbg2ROq8Iutc8kbze4y9ENB2JaJfTqRaJxj4TkWDttBxiehNDKIxh1uUUMLoTGRdxzPg
	KmzS6SiblWw0rMNi8MVAkw07vvFpErM1s7MIf84fiASItroxtzePS0kBKdkrtFpQvmHE+qVHxCr
	yESvGFdUcfD3JDukVORonWN531zvmLLmfqV1YrkY6l0sAMwToA/+yKG2eE7q4rrp3hDPeJYQkLp
	M/PEXrl/T+oYCUKydvDbsnRiqQZiWrYNVWsWMS4tegwPTdEVVHFdshnKgBR+vGD9VItybN1Mh1O
	Yn46atOVET7BkS/I8ccNX29hMzFPJIUgXALb7QRUecCv1dqCUC792KhkG8zuGZRHrNt/UdwiMQ4
	n
X-Received: by 2002:a17:902:9b87:: with SMTP id y7mr680203plp.336.1550066320256;
        Wed, 13 Feb 2019 05:58:40 -0800 (PST)
X-Received: by 2002:a17:902:9b87:: with SMTP id y7mr680125plp.336.1550066318859;
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550066318; cv=none;
        d=google.com; s=arc-20160816;
        b=tmjK6vyMz8W7KsopngHDbEtSzipOd4gCIpSJT5IAot3DcgbdYDrVi4fzZ/btMvw8j1
         KcK7lWZRzxg0FFkEF1Q+2/5WBWzV55OlOPYVhkZO7bqmK85OT4+dhdErvxKnq4gEkAiB
         ZnaFAB6JgYvinzP3e/xIcRie06Z2gbWqflRYVn0qJ/NtssgqgOGf5Rogvx5g3kpyqZKc
         UCl8SebqxoMOUMn5lfWU8QJ3dTx8AC2tDMLlfkLXevmEECjalbJlE5YGqLlUahHOjduO
         aeP9WAIWsiK40HdJrxfY6a7ZjDoNmPkzaWdHiItixOIYgj6/J3mOXtWFkDmoyaDGKquJ
         riqg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=ASH6rQdzAxFehsd0Zyva8V5MyM/2p06tFySZGPwcSEpGBxZSeBQyq4ry/tRm+WSpsR
         t3zEKXWCC5pqgoXCXOgBzzPHi+HgzuLptyK5FuupKhQtGgRa9VDmSOgMr1b44KcauE92
         kvzAazeLUFJnZ7d6lvm47MUJecauyBthzdYmNZqEbqBwHHxZ1bdYrM6ReyhpECOk9BG7
         9TzgpbqY+o7Bzl3BnLJwu54l8rsuFU4QcdBgWB5xoCGVOMIGgd8fmURzjZpLChB1nZtx
         UAiqjN78fmdyRHkUTwRCN8lvc/1JDByYE8hT1VIsHZCXprv+5HM79u8ugJNRynEnaDuZ
         m0jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pbigDwG3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y2sor6550781pll.68.2019.02.13.05.58.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=pbigDwG3;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=cNyFM0J2DfW9voxw9FzV7E7Y/LrzsWkGDKLqwe0d5pk=;
        b=pbigDwG3xTm4YxvGqJgLG5mkUt5O5OB6iH/4JOZPoXunwWHE5QfP4W9AElQvSudJa3
         oftivCtQcvYNS8YSZXakLgY/n/6uMXhgwbuZgbrYOMW2A6d9qxKamu6y4VDWZG9hKIXJ
         Ozs0l8wXg2IVBGQ5Lx1acSQcHqvuaQpFa+H5Y1d0IpRM9leug/xYa7/aLNdDjG8Ibi0w
         4YGogL/vRIFJoYsg51t1pmC4flEIvAwvnxiLzYGzdVd4eEsIiXYF+OFdhEXjta13phln
         wgXDc3SFMpLh8t92NQ4l/buWitqvWvWgjk6iHFgB8KwSjqoqS1sBA9XRvXu1Nzpx0Uuh
         rkog==
X-Google-Smtp-Source: AHgI3IabBr7i0UINT5tZChzG9mkUSIkz97ziRf+i4G4ZGRQ2Pfd1KkCHgUpEt1D+OFFkb4bWmp/4Cw==
X-Received: by 2002:a17:902:20e2:: with SMTP id v31mr640198plg.307.1550066318585;
        Wed, 13 Feb 2019 05:58:38 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([49.207.48.54])
        by smtp.gmail.com with ESMTPSA id f67sm30721286pfc.141.2019.02.13.05.58.37
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 13 Feb 2019 05:58:37 -0800 (PST)
Date: Wed, 13 Feb 2019 19:32:56 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH v3 2/9] arm: mm: dma-mapping: Convert to use vm_map_pages()
Message-ID: <20190213140256.GA21977@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_map_pages() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 arch/arm/mm/dma-mapping.c | 22 ++++++----------------
 1 file changed, 6 insertions(+), 16 deletions(-)

diff --git a/arch/arm/mm/dma-mapping.c b/arch/arm/mm/dma-mapping.c
index f1e2922..de7c76e 100644
--- a/arch/arm/mm/dma-mapping.c
+++ b/arch/arm/mm/dma-mapping.c
@@ -1575,31 +1575,21 @@ static int __arm_iommu_mmap_attrs(struct device *dev, struct vm_area_struct *vma
 		    void *cpu_addr, dma_addr_t dma_addr, size_t size,
 		    unsigned long attrs)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned long usize = vma->vm_end - vma->vm_start;
 	struct page **pages = __iommu_get_pages(cpu_addr, attrs);
 	unsigned long nr_pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	unsigned long off = vma->vm_pgoff;
+	int err;
 
 	if (!pages)
 		return -ENXIO;
 
-	if (off >= nr_pages || (usize >> PAGE_SHIFT) > nr_pages - off)
+	if (vma->vm_pgoff >= nr_pages)
 		return -ENXIO;
 
-	pages += off;
-
-	do {
-		int ret = vm_insert_page(vma, uaddr, *pages++);
-		if (ret) {
-			pr_err("Remapping memory failed: %d\n", ret);
-			return ret;
-		}
-		uaddr += PAGE_SIZE;
-		usize -= PAGE_SIZE;
-	} while (usize > 0);
+	err = vm_map_pages(vma, pages, nr_pages);
+	if (err)
+		pr_err("Remapping memory failed: %d\n", err);
 
-	return 0;
+	return err;
 }
 static int arm_iommu_mmap_attrs(struct device *dev,
 		struct vm_area_struct *vma, void *cpu_addr,
-- 
1.9.1

