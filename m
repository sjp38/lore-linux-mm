Return-Path: <SRS0=luIg=QH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7625C282D9
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:08:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 93610218AF
	for <linux-mm@archiver.kernel.org>; Thu, 31 Jan 2019 03:08:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="btJPnHFF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 93610218AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 28D348E0002; Wed, 30 Jan 2019 22:08:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 23C568E0001; Wed, 30 Jan 2019 22:08:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 154C68E0002; Wed, 30 Jan 2019 22:08:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id CACDF8E0001
	for <linux-mm@kvack.org>; Wed, 30 Jan 2019 22:08:10 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id v11so1312228ply.4
        for <linux-mm@kvack.org>; Wed, 30 Jan 2019 19:08:10 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=iec/iwyk+9yIyetIpSnDlz9q4nLWbzvs4Tb+BjkPjDE=;
        b=pO80iymBfVBu4Fj/Qv2yfwGe+1/wApqNqoaqVn9uTuqKx+J3AT+QDUyFu3hL1U/+lk
         VEuRbV8pclPihIWcf7qIgikAiFSXBugKGZ8+v1tgKcd3OJhsgXrBXg2F+TtXldu0bFkb
         stZ9PDkd0zMxQbQj4oqeIiL5+9r3o9IR/qkG6TAduqfUTEZxnDV3xzhf3Cv4830+uCYl
         HHQS8GqsAflVZQMi0RFEzMMWlz399x0grysIJactZ68ku3ea0cD3HFinW4mO9vhF8bQU
         C9W2XDco5HjKW/JKNyv5eNuzfHk4UhZDzgViLXrSc/Y0MUO/YD8QcxSY0ODMlG8ek/O+
         auhw==
X-Gm-Message-State: AJcUukdw17l/DLVrqU7EVo0egVIXFQBNczpBBLF21EL6pAHwSYK/nWde
	sXHEznXnj63wU2STDfdCp/DYyAk2uPJNJpETw94Rl2OG62iLniDSltQqgyAEFdCFIvDyYW/ODK2
	JEqUVNnyRMKzWlz/yReOStQ+oPTvECWYlumqHL6qjvpXC+zYNp9BUgpyRDndnK0LkBYmNt2PVos
	0Ctl+Rh5NnQvhMxzvLEeCRiMh4gAN1ie+fyh5rdqePLDmxOsdHnRKA28HJ2RVW57xuamhSAihLB
	9QgW/BWGBXIyDK9xo37jbJsDX7iQ7vUIeOGxh0sBWtztWesbrn46ifEeXwp8Hpp8//O5UHcBXqq
	coXjnRZFiNS+DLPmbhTpt7HP7Gc6tnynEjg9G8F/6Ir90dMR8aj9DrL3duMX4W/MUrAmCs78Jbw
	3
X-Received: by 2002:a63:8f45:: with SMTP id r5mr29571948pgn.222.1548904090485;
        Wed, 30 Jan 2019 19:08:10 -0800 (PST)
X-Received: by 2002:a63:8f45:: with SMTP id r5mr29571923pgn.222.1548904089821;
        Wed, 30 Jan 2019 19:08:09 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548904089; cv=none;
        d=google.com; s=arc-20160816;
        b=uu8yXQGhjCruVwYF7UwK+9gvnsWdh6Is9PdL7RXsMbq7xtUPQraJ0kOQdCgVu6Uol7
         gOWl/3eCMnRXO/vARg8RFPnAxf3xMK3qxwc/+vpf30Ce/NIyB+7Y/58tkVLVJJYLmOuc
         /m79OjqCJ75yWrHw2uqyl0nZqpWcQGWYOe47ZTXBRWUccyFRsW+rv6g79zOcjrPEB+qi
         yFIcIpgRPuvfIzwRKTiuoUzMSLdx5ULFFPGP/i1S2soqthBTQKIrofL/QGtAKJG3ECzP
         X6KL05H3j8cJUAIiSZFnjunJux/765rPGE1HGhCWM9Uj02tbMHUOGFMAFMMjSAdkS/Lp
         M3TQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=iec/iwyk+9yIyetIpSnDlz9q4nLWbzvs4Tb+BjkPjDE=;
        b=qycb3EtvMv80od1BPgXuQZvwFji+4gelxYn971+Dt1CrAyYyqED1RvSeenj8KdTR1l
         GEy78FnaY6OH1Igiv8OaxGA8rWlS7pmh2lQwKq+Ksfm5oKtKGoHKQRdpQJRnARnlY3RC
         hEIV+cdK/qxo2Fg55rpMqPmMLuYOyMk6ki/F6xhCx1ZXgBZCOdtOXsjpmSRPIgtJnzTW
         Z3O515VsJDRThiUEMakD8fVh4fQPc8deVmylhj8CFEE92khyY52+Oe6GcimrTnsAjEFf
         7hHEAev05NdvNypvAYA5oNmvvRz5rq8TQngEDNcB3Exe1hTI6bSMm+SikngVmH5EjKOo
         VyCg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=btJPnHFF;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t190sor4925804pgd.31.2019.01.30.19.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 30 Jan 2019 19:08:09 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=btJPnHFF;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=iec/iwyk+9yIyetIpSnDlz9q4nLWbzvs4Tb+BjkPjDE=;
        b=btJPnHFFmNfaReq5/e7TkaGbwn15giRl9XlitU46PRtF/0teXo0bWC1peOMGRPqPA8
         hxAb0yGT180I0FDMfC86c/tvU+9G6qZ1Rx1ilqWyX4vHBBETh7UPpSVVyUGUHQV1uQQo
         Nd3mIgmXCAbNkh8lBEMTntnGXxdqSwKzraFTYyTORHy0zOogKhLvdaw47rbsjlLPPuRs
         aeqhr8e4CwkRDvSeOrC7vIPstO0GVYeSubKCmIlkrToB20gf51xWHeogaA5+SVliS+ZB
         SoSvM7OtvGHYInHjKr77zMMAlEywrAABgpKu1dA0bjh0cumvwJ/m0hgNXUPCXOF1J3H7
         mDkA==
X-Google-Smtp-Source: ALg8bN7nn3ngJBjBBd3F3bgclAbBF0cXBwm0q+GBXn5HYfScD2qZEcAMQ9j5PQSYrWPibjpeeIgmmw==
X-Received: by 2002:a63:1f4e:: with SMTP id q14mr28672360pgm.88.1548904089076;
        Wed, 30 Jan 2019 19:08:09 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.20.103])
        by smtp.gmail.com with ESMTPSA id z13sm3977258pgf.84.2019.01.30.19.08.07
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 30 Jan 2019 19:08:08 -0800 (PST)
Date: Thu, 31 Jan 2019 08:42:22 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	joro@8bytes.org, linux@armlinux.org.uk, robin.murphy@arm.com
Cc: iommu@lists.linux-foundation.org, linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCHv2 6/9] iommu/dma-iommu.c: Convert to use vm_insert_range
Message-ID: <20190131031222.GA2356@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Convert to use vm_insert_range() to map range of kernel
memory to user vma.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
---
 drivers/iommu/dma-iommu.c | 12 +-----------
 1 file changed, 1 insertion(+), 11 deletions(-)

diff --git a/drivers/iommu/dma-iommu.c b/drivers/iommu/dma-iommu.c
index d19f3d6..bdf14b87 100644
--- a/drivers/iommu/dma-iommu.c
+++ b/drivers/iommu/dma-iommu.c
@@ -620,17 +620,7 @@ struct page **iommu_dma_alloc(struct device *dev, size_t size, gfp_t gfp,
 
 int iommu_dma_mmap(struct page **pages, size_t size, struct vm_area_struct *vma)
 {
-	unsigned long uaddr = vma->vm_start;
-	unsigned int i, count = PAGE_ALIGN(size) >> PAGE_SHIFT;
-	int ret = -ENXIO;
-
-	for (i = vma->vm_pgoff; i < count && uaddr < vma->vm_end; i++) {
-		ret = vm_insert_page(vma, uaddr, pages[i]);
-		if (ret)
-			break;
-		uaddr += PAGE_SIZE;
-	}
-	return ret;
+	return vm_insert_range(vma, pages, PAGE_ALIGN(size) >> PAGE_SHIFT);
 }
 
 static dma_addr_t __iommu_dma_map(struct device *dev, phys_addr_t phys,
-- 
1.9.1

