Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DA8BC76191
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27181229FA
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 11:41:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fABmKKov"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27181229FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AB0AA6B0008; Wed, 24 Jul 2019 07:41:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A62DA6B000A; Wed, 24 Jul 2019 07:41:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 904448E0002; Wed, 24 Jul 2019 07:41:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5DDCD6B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 07:41:41 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id j22so28318942pfe.11
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 04:41:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ORy6NrKMahXgXjCFxtBMjvZtj+K0mFoX1H4GDy2eV+0=;
        b=hgUmrYM+HmLQUzmrngv6tpCsmavUYjh6/4s+IbaQ7nP0jGJ3PCVMmZaiTXN0koXcDD
         /sPPV0+Ge6TXnGSYY59baCdSgP4kMK9V7ei6q+mJGa2OImqbQfY/atoNelh88zYJItjQ
         j+2e4I6DrxnB+I1rUEwpXIV5RkelXv++zWJvrLhVWQF/8qmkPOp7Nb7uA4YD9dsdTTlX
         T2rlZRejhM7DoJFG0+NNpyD4dAPA/PrT3W4L5neOBmKbNvVKY4Gp/irzfSWZ6DSQJJM/
         KyBt24JJy7fDVRhAGTlXqL34x6MwY3AbvydRof7JHk5Gw7mQxFGvAdV5klrbE9IezYNt
         yl+A==
X-Gm-Message-State: APjAAAXl9PWGCtAICJifdqhu2c8cdBbiV4BZd1hcG2Jk9t6xdrTJjy6X
	OFzKDpq9HWCBVG8h5/FUiIjZTm2P9BmVy8I6NliI7TpigpnOYQaBWhSGA/l6VYT9XbJJPYSEh1X
	A3bb2Cm4bRlWkXDLLfWiFGCVK8tHoB7+Dc2LrMzCZkG2vqCJFd7gTlP+gr+PcieMxPA==
X-Received: by 2002:a17:902:aa09:: with SMTP id be9mr1549423plb.52.1563968501014;
        Wed, 24 Jul 2019 04:41:41 -0700 (PDT)
X-Received: by 2002:a17:902:aa09:: with SMTP id be9mr1549370plb.52.1563968500004;
        Wed, 24 Jul 2019 04:41:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563968500; cv=none;
        d=google.com; s=arc-20160816;
        b=01aQjGUO+2R/kLV4pfhC4gQ17DHki1p1T6N+99ckCVyYUdiSY7Km0LKc7/o9nwany1
         oxWcGZsDHy2gdFvB6mJiOdX3oKZ0g4WtrrurXMi+IvSDUw9uDsWOd0XKEL7LkVP+9jsw
         1Ew6jKkQne0833MVnzjZ0rOXR6J965Yd0xuQmRHr08YIl3SKUTv+RXr89+42xu6tLJKs
         3YLpUHNE2vwMboAvPpDkqkE9nCLrDIpAzKA+I+Ksem2EwNj77NfMS10WjlEzafebvIgm
         m0HZ7TdikHd9pzZw2UPU6uMxYwmcNi8ol4A9Wrp2Mk61j6YBXOr3zskuOwJ+VBmzjjGG
         ozIg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ORy6NrKMahXgXjCFxtBMjvZtj+K0mFoX1H4GDy2eV+0=;
        b=FFiPpcD3GDA3KTCKDO6nU/9fjTEvsdAIHJIBC7DH8ezRcMDDPM5ni3FGImq8BUOajb
         vv4x1ES4OXemaPCf3xoAqNo88qEYnI0G3ttqAn81CLrY70vz0854E6QC9Eemk7ScatOC
         Swv/R1J28qGV5jGvhHKwZfaRw07wQ5527LSHs467wv5M0yh1+VP87+78qXAClQ0tjDDG
         4cyIZur7u9GQwezIp3b0bw6AFZBVbt5N2DAWQTMpZbXAbD8GFU5zu8bJ9EI/7TMCF3zy
         irLg5aa5wXH/eH3okrAxo35GHylqcXFFgrbf98pn7Fb1Yjp/zOIkEyY29DHCRVbVmRAX
         fdiA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fABmKKov;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 133sor26978085pfx.14.2019.07.24.04.41.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jul 2019 04:41:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fABmKKov;
       spf=pass (google.com: domain of linux.bhar@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=linux.bhar@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ORy6NrKMahXgXjCFxtBMjvZtj+K0mFoX1H4GDy2eV+0=;
        b=fABmKKovZIa7BVn8ihmTaxmHzv2Wkkhsm0ffh+FTnE7+zcgHg0cU75n5KQOmW+Dl0r
         24F/bxwikeAXCzY7FWcBinMMg93Lqk6FZ0pLi5Ri+YUAzEiXrLL4RXPQhBkqKaAOPnLS
         BS6Yma/G8h23jbwDh9OCQFKe+mj8zFp3HpG59+0SPoxfl+3k7K9NQknftfi38SC2Prmu
         KJbF22DRE3X8ak6G2CbJWSD3ASdxhTeqiUzm/ag1eQ3zncxUnM1g0iH5yi7B1/5FKoBl
         fQhNDAgQx2VmuoDhYL1t+J2Q/pQvWsWmLDwsgecFXVTBgMNn68IiqDAtBau4jch7JOXI
         hLHg==
X-Google-Smtp-Source: APXvYqzp2fHJi0yy0Ks5Ez2LolTZSaJhGmodS4FvD3yCpT3yql7W9SKJXRj+FwZauVCERIQa/kPf+A==
X-Received: by 2002:a62:1d11:: with SMTP id d17mr10998103pfd.249.1563968499724;
        Wed, 24 Jul 2019 04:41:39 -0700 (PDT)
Received: from bharath12345-Inspiron-5559 ([103.110.42.34])
        by smtp.gmail.com with ESMTPSA id b30sm69751860pfr.117.2019.07.24.04.41.38
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 24 Jul 2019 04:41:39 -0700 (PDT)
From: Bharath Vedartham <linux.bhar@gmail.com>
To: sivanich@sgi.com,
	arnd@arndb.de,
	jhubbard@nvidia.com
Cc: ira.weiny@intel.com,
	jglisse@redhat.com,
	gregkh@linuxfoundation.org,
	william.kucharski@oracle.com,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org,
	Bharath Vedartham <linux.bhar@gmail.com>
Subject: [PATCH v2 2/3] sgi-gru: Remove CONFIG_HUGETLB_PAGE ifdef
Date: Wed, 24 Jul 2019 17:11:15 +0530
Message-Id: <1563968476-12785-3-git-send-email-linux.bhar@gmail.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
References: <1563968476-12785-1-git-send-email-linux.bhar@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

is_vm_hugetlb_page has checks for whether CONFIG_HUGETLB_PAGE is defined
or not. If CONFIG_HUGETLB_PAGE is not defined is_vm_hugetlb_page will
always return false. There is no need to have an uneccessary
CONFIG_HUGETLB_PAGE check in the code.

Cc: Ira Weiny <ira.weiny@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Dimitri Sivanich <sivanich@sgi.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: William Kucharski <william.kucharski@oracle.com>
Cc: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org
Reviewed-by: John Hubbard <jhubbard@nvidia.com>
Reviewed-by: William Kucharski <william.kucharski@oracle.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
Changes since v2
	- Added an 'unlikely' if statement as suggested by William
	  Kucharski. This is because of the fact that most systems
	  using this driver won't have CONFIG_HUGE_PAGE enabled and we
	  optimize the branch with an unlikely.

Signed-off-by: Bharath Vedartham <linux.bhar@gmail.com>
---
 drivers/misc/sgi-gru/grufault.c | 21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 61b3447..bce47af 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -180,11 +180,11 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 {
 	struct page *page;
 
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		*pageshift = HPAGE_SHIFT;
+	else
+		*pageshift = PAGE_SHIFT;
+
 	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
@@ -238,11 +238,12 @@ static int atomic_pte_lookup(struct vm_area_struct *vma, unsigned long vaddr,
 		return 1;
 
 	*paddr = pte_pfn(pte) << PAGE_SHIFT;
-#ifdef CONFIG_HUGETLB_PAGE
-	*pageshift = is_vm_hugetlb_page(vma) ? HPAGE_SHIFT : PAGE_SHIFT;
-#else
-	*pageshift = PAGE_SHIFT;
-#endif
+
+	if (unlikely(is_vm_hugetlb_page(vma)))
+		*pageshift = HPAGE_SHIFT;
+	else
+		*pageshift = PAGE_SHIFT;
+
 	return 0;
 
 err:
-- 
2.7.4

