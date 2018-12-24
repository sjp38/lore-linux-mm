Return-Path: <SRS0=oA8h=PB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.4 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_MUTT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 46745C43612
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:16:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 007DC21850
	for <linux-mm@archiver.kernel.org>; Mon, 24 Dec 2018 13:16:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qM6wO8wX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 007DC21850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 859768E0003; Mon, 24 Dec 2018 08:16:37 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7EE6F8E0001; Mon, 24 Dec 2018 08:16:37 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CFAA8E0003; Mon, 24 Dec 2018 08:16:37 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2B9E18E0001
	for <linux-mm@kvack.org>; Mon, 24 Dec 2018 08:16:37 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id 89so9892853ple.19
        for <linux-mm@kvack.org>; Mon, 24 Dec 2018 05:16:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:mime-version:content-disposition:user-agent;
        bh=LP5lsofdni2cSLjgAraOzOMBqzsN96J57RYIndiS9eY=;
        b=OI7AC1OB4mJtuvTM2odPIGkLM/Rzox1MQFTxVOwIQxzbsJ+8pzjzKOzw38kuqDGS9H
         Yc1Uazb61alQAOCvVzCJ3jy8aRT+uoRAl0lO/armTCJybgdbCrfeI5ARvtM08oEB8hU2
         vw9Z+P+z1uW3XyCciU8wNbHXG10ewfyz4DacInY3rHQ8awBLdTfFNGghdRRBrK6zJsk9
         B6qHMXRl4NxaSX+DicW0ALeZCcXJLhGuW608KBwAajiaKVM/R+r1vGIzoqhsyPilz1lB
         8oTY5lmdyGwSW7GUOZMbnnnbi+ubQflma/0GJzTv+VmDip/LQZqOSmWj6Jjz3fof2fL/
         Qpng==
X-Gm-Message-State: AA+aEWYW0p2a4oTxCKBs83uX7/pT/YY+Pbd6j+vR00PopdLTgy5jcN4C
	Df4+64Uq6B7NwfxiLTMsJTo0gUWh6uqODsjZkZhswc2TZsA0m/JR6cB8PzvczmVCnVNr1cde/6P
	M13lTQQEYaIdcaC96Bb/dz9iqrf8A3+ESuwt4d+6kHhOwfcejoOsarOrwM/8las0STSOnjgC6yH
	3yLt9lgudQ1IQuIFrU2zDj9TLcVuPF30HwMR+NL9OkkUGO1RZGesTZacPIehbmthnpiMsKYxzON
	5dkMcKpxu2W2rB5oPobLQO3NLSGje05opJdJCqVh5C0mNjx2LvKF++9O3u7TyHqpEWson9GmP8g
	mtwehLexUO1520Sk9QK2HqMnvsBDUYgJnpd610hYYJGM/5axdv+jqIpdFODMosbm9QGZAF6DyoI
	u
X-Received: by 2002:a62:7086:: with SMTP id l128mr13049120pfc.68.1545657396765;
        Mon, 24 Dec 2018 05:16:36 -0800 (PST)
X-Received: by 2002:a62:7086:: with SMTP id l128mr13049064pfc.68.1545657395892;
        Mon, 24 Dec 2018 05:16:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1545657395; cv=none;
        d=google.com; s=arc-20160816;
        b=z/XXZxpPuTEnbzp9ediOWO+KWenjRNGmUpGyzUgYF7kVBVhdUHNsuhCg5zka7xLRZu
         mvuV0SVzW1OL4JZnT5VLFYtNJmeldE4UwLSV1kLYGcfGghcobkDzxvmsYDBxNqxzuyNd
         g5TOfR68+EVEr0DIeXb+HXw5RiUPqyCL5UDAtZtOgf/nf3fqCxQ+G1yiee8mTkDpesSw
         8+1BklUL6em2cQk+M0Z/EZCi6731Nl1AQyEzjw3M+KgxrLEeB83Ca5vTl2UKwml8Wy7G
         HgFKYp0XrrzkNOzUpywZ68pvAQkfZXLOCU4yutqJFszCcMriwtYkIGriNAay03GYRwfL
         J9JQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:content-disposition:mime-version:message-id:subject:cc
         :to:from:date:dkim-signature;
        bh=LP5lsofdni2cSLjgAraOzOMBqzsN96J57RYIndiS9eY=;
        b=vTkOrxp3m0xQhaJqP8MFtSHFmh7QpsYrcWDCL5jQiIjRc31CGVFhLblwEOAZhdSGTl
         9QxjOCef05tTfagPnwZz1IqBdRR9K544BCmRy9wVZdHkhGZ+Ch873SiZD0v9LL7Rx5iT
         PTyFTM9SJKMfajofvHHS6R+9KoRKlZ2Tss7ESAbMaw49PPbAMcekz3KxyXCu+pVWbIbQ
         9OVEHpTmqYbmoueeVZeNDiSyQzNQafVHJcNNZtKPrJxbVj01kd5FCe7aqFOPQlSrQaSW
         n81J0EmgL3T0H0Uqx7hrDamktlnuzrWovxoYoZDMLBrQ0Tev9QJiTNYQHZa7b4zqucfR
         mFgQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qM6wO8wX;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i37sor47053576plb.45.2018.12.24.05.16.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Dec 2018 05:16:35 -0800 (PST)
Received-SPF: pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qM6wO8wX;
       spf=pass (google.com: domain of jrdr.linux@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=jrdr.linux@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=date:from:to:cc:subject:message-id:mime-version:content-disposition
         :user-agent;
        bh=LP5lsofdni2cSLjgAraOzOMBqzsN96J57RYIndiS9eY=;
        b=qM6wO8wXOsTCCQjmN5W2bh1Yc6f8aW1WDDjGj9PbWNWc2o79ATdhag+oaoZPNPzt6K
         ma0RAy9eFNdLoLaz9htzWNODQWdvDKW7joEPPAdI4N9ZNw04c82tpSKjho+qWDoRBeIH
         N1p9vHkj4DPmaFcBQk35HegJ83jO83edL9GgOg2ErX3ZZ+XvYXqoDlEmwPT6wa3imIT0
         T1nCoqL5yFy5XNreHjeoMzrX+u5MwKvIQ8ttnzIFgFzU52htaKbK9ggMZ02hlyAc4nzQ
         IqLSm1jXGOTu+uTZeYmteZ8VUjbr6oMUx31ohJHf9UUTLFfcMN9bGnJn5P9wRpIyKK87
         nFGA==
X-Google-Smtp-Source: ALg8bN7wOSrZcfXhzYNZV0rUN+/7d8bG9BYL8F6X7CbsAJiBB+mCxvpTDoGJWLYuM5s39NiTv+v4ng==
X-Received: by 2002:a17:902:4025:: with SMTP id b34mr13074182pld.181.1545657395486;
        Mon, 24 Dec 2018 05:16:35 -0800 (PST)
Received: from jordon-HP-15-Notebook-PC ([106.51.18.181])
        by smtp.gmail.com with ESMTPSA id n22sm59491886pfh.166.2018.12.24.05.16.33
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Dec 2018 05:16:34 -0800 (PST)
Date: Mon, 24 Dec 2018 18:50:31 +0530
From: Souptick Joarder <jrdr.linux@gmail.com>
To: akpm@linux-foundation.org, willy@infradead.org, mhocko@suse.com,
	kirill.shutemov@linux.intel.com, vbabka@suse.cz, riel@surriel.com,
	sfr@canb.auug.org.au, rppt@linux.vnet.ibm.com, peterz@infradead.org,
	linux@armlinux.org.uk, robin.murphy@arm.com, iamjoonsoo.kim@lge.com,
	treding@nvidia.com, keescook@chromium.org, m.szyprowski@samsung.com,
	stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, heiko@sntech.de,
	airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org,
	pawel@osciak.com, kyungmin.park@samsung.com, mchehab@kernel.org,
	boris.ostrovsky@oracle.com, jgross@suse.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	linux-arm-kernel@lists.infradead.org,
	linux1394-devel@lists.sourceforge.net,
	dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org,
	xen-devel@lists.xen.org, iommu@lists.linux-foundation.org,
	linux-media@vger.kernel.org
Subject: [PATCH v5 1/9] mm: Introduce new vm_insert_range API
Message-ID: <20181224132031.GA22051@jordon-HP-15-Notebook-PC>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Disposition: inline
User-Agent: Mutt/1.5.21 (2010-09-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>
Message-ID: <20181224132031.eqpEu3I1gmPBznTADJeXt9DRAJ-b1Oi_P9KYKO8X0To@z>

Previouly drivers have their own way of mapping range of
kernel pages/memory into user vma and this was done by
invoking vm_insert_page() within a loop.

As this pattern is common across different drivers, it can
be generalized by creating a new function and use it across
the drivers.

vm_insert_range is the new API which will be used to map a
range of kernel memory/pages to user vma.

This API is tested by Heiko for Rockchip drm driver, on rk3188,
rk3288, rk3328 and rk3399 with graphics.

Signed-off-by: Souptick Joarder <jrdr.linux@gmail.com>
Reviewed-by: Matthew Wilcox <willy@infradead.org>
Reviewed-by: Mike Rapoport <rppt@linux.ibm.com>
Reviewed-by: Mauro Carvalho Chehab <mchehab+samsung@kernel.org>
Tested-by: Heiko Stuebner <heiko@sntech.de>
---
 include/linux/mm.h |  2 ++
 mm/memory.c        | 41 +++++++++++++++++++++++++++++++++++++++++
 mm/nommu.c         |  7 +++++++
 3 files changed, 50 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index fcf9cc9..2bc399f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2506,6 +2506,8 @@ unsigned long change_prot_numa(struct vm_area_struct *vma,
 int remap_pfn_range(struct vm_area_struct *, unsigned long addr,
 			unsigned long pfn, unsigned long size, pgprot_t);
 int vm_insert_page(struct vm_area_struct *, unsigned long addr, struct page *);
+int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
+			struct page **pages, unsigned long page_count);
 vm_fault_t vmf_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 			unsigned long pfn);
 vm_fault_t vmf_insert_pfn_prot(struct vm_area_struct *vma, unsigned long addr,
diff --git a/mm/memory.c b/mm/memory.c
index 15c417e..d44d4a8 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1478,6 +1478,47 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 
 /**
+ * vm_insert_range - insert range of kernel pages into user vma
+ * @vma: user vma to map to
+ * @addr: target user address of this page
+ * @pages: pointer to array of source kernel pages
+ * @page_count: number of pages need to insert into user vma
+ *
+ * This allows drivers to insert range of kernel pages they've allocated
+ * into a user vma. This is a generic function which drivers can use
+ * rather than using their own way of mapping range of kernel pages into
+ * user vma.
+ *
+ * If we fail to insert any page into the vma, the function will return
+ * immediately leaving any previously-inserted pages present.  Callers
+ * from the mmap handler may immediately return the error as their caller
+ * will destroy the vma, removing any successfully-inserted pages. Other
+ * callers should make their own arrangements for calling unmap_region().
+ *
+ * Context: Process context. Called by mmap handlers.
+ * Return: 0 on success and error code otherwise
+ */
+int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
+			struct page **pages, unsigned long page_count)
+{
+	unsigned long uaddr = addr;
+	int ret = 0, i;
+
+	if (page_count > vma_pages(vma))
+		return -ENXIO;
+
+	for (i = 0; i < page_count; i++) {
+		ret = vm_insert_page(vma, uaddr, pages[i]);
+		if (ret < 0)
+			return ret;
+		uaddr += PAGE_SIZE;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(vm_insert_range);
+
+/**
  * vm_insert_page - insert single page into user vma
  * @vma: user vma to map to
  * @addr: target user address of this page
diff --git a/mm/nommu.c b/mm/nommu.c
index 749276b..d6ef5c7 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -473,6 +473,13 @@ int vm_insert_page(struct vm_area_struct *vma, unsigned long addr,
 }
 EXPORT_SYMBOL(vm_insert_page);
 
+int vm_insert_range(struct vm_area_struct *vma, unsigned long addr,
+			struct page **pages, unsigned long page_count)
+{
+	return -EINVAL;
+}
+EXPORT_SYMBOL(vm_insert_range);
+
 /*
  *  sys_brk() for the most part doesn't need the global kernel
  *  lock, except when an application is doing something nasty
-- 
1.9.1

