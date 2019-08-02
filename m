Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9A51AC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 534792080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QRyVr5yg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 534792080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 35D046B027D; Thu,  1 Aug 2019 22:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2E7FC6B027E; Thu,  1 Aug 2019 22:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 187C26B027F; Thu,  1 Aug 2019 22:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id D75C46B027D
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:56 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i2so47122740pfe.1
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=Ba04IUtSj+yDwCs7XnfohxncE3mYEB6+RyTfscGUb0uSUatUG/VA3g4bS9/2HUeFd3
         fVLMfaO2xAm5lq0C1ycCv0WeZrlG2F6kX7uBNxp8GB3BfbXU0UYZ6AH6m6vvfmYEEPtS
         OtbbZqnp6cCsQYTPpBnKWaGNl2yNLpfq/5cNDBCRg1cJlaSut4/iLEjCpVSc6L36PGpq
         UnvoytILkSjl+qRVGzU6pmSsRFafzHV48/uMLE46nvuWPTC4TSbG2W2Xun5ckbxxalCX
         qrQtxpiFf36hdHFK2Q5qWDEPeQVOU9QIauQoO5CC9fe8b9bsN7f0JW1Skp+FhQ9qY+KH
         OUjg==
X-Gm-Message-State: APjAAAW89VhxKLwYOQP9r0/MDZy6boORTO806A9QpNoRmNo22766Hf2z
	2kh7XIHZzDD+GxTYsLCd8yvYRoEj3JOwWRE2FApvGkTZcSh7eiTm1OijDFnDvpuDkGpxZQph3j4
	waIKVFFbeK/ftvDcppjWwZ5qtdzaS9C2/BrHhH3TcCf2v/Cfp3CYwvGgvHJ/qET2jeA==
X-Received: by 2002:aa7:9117:: with SMTP id 23mr57235462pfh.206.1564712456584;
        Thu, 01 Aug 2019 19:20:56 -0700 (PDT)
X-Received: by 2002:aa7:9117:: with SMTP id 23mr57235411pfh.206.1564712456015;
        Thu, 01 Aug 2019 19:20:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712456; cv=none;
        d=google.com; s=arc-20160816;
        b=SbMnRBEehAGy1ol5cQuZze2QfZYhEqpe544QVZZC470OAtuGTeIteMGiYdInD/wspc
         mXCQpK1ZRVEFhHoQTYVi1af3m5J1qFe8pcEoC6DJzUR7SzXrNrhqUJjt1GI3fQAFCapx
         BZnsVTC5I+oVneHRzWqgd6sb6TutwGOz6BmyDYYK/dX5+mTpqyPwL6XfBdS5N7RclAHJ
         a0pLc2IGIeUk1qZjDla1nInfafhC2QuwHFItjN+Tq3w4VJRCmcE4InfF4dIx6Bp4vGeC
         y+u95g7Cq2KDBHiZ5bzfswHkw6VDP9xToLg8khWqfx64bKJNvbKZGuPzFz042gaR7Xku
         9ZLg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=p1ddIH4ui3/ff9SkOLcnBRghQQjj68OvQB3YBiyAYAYIN+y9/j9zu9MMx+N1kw82hf
         Tncxs6xi5GLnHgULBAI7OYc6U2IfjWV1J6wCj3WMAvqwk69CpeudhGmdS2AxUhtlqw2T
         JBKAYQJvqlpk7tbisvPG9RcyW9jdyZ8RqLoGQQlZl3QWf6P6njcN96A8lUNt4WG5a5Qn
         QR6WiuVbQLivuuNUL4Q0tyoqqFREsCRdomMULJDgQs06ozpDSxtqDK6iaS/173ZNUwtT
         q9ity9/WmPGmwFR6yOkh3ynlMy4FMtDmDTD8H1GVYL4rtiMlg2cpTsepd4fL3fhd5bme
         zOfg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QRyVr5yg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73sor87845938plf.60.2019.08.01.19.20.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QRyVr5yg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=Puv5caB6Xd1AJbwd7nGzyFKNouoVWAfL+vJwz/b+4QQ=;
        b=QRyVr5yg7UVnGFe/94tarV2cx/oce/jeAuEbGS+hXnWMVkUY07iSzJ+XdsjD5nlJBq
         rtaqXFFIyJDVZMz/IPqdxV28iUWO51kec9aYcvEuc1NKK19hn11UPjRAndaZuD321pFs
         RKnDddIFoWzyAYe9j0yIZ0ilD198KHwio3GcyDW9wHOLHbZQnh4EWC6hi4aeKuKjN/3A
         ASJiUynmLC6iZL/fZBtp3/NtpLCOGP1VvcXTdQwMcpbWEECy63Zknc8xjKmFGFNfVmU2
         0O+/0uGt4SKVMx7bM2tpg32Bk0v9UkWkkUlVmxU39ntVy853hr2Hw2jr21+6/jgrAg21
         vCDw==
X-Google-Smtp-Source: APXvYqyaZ4okZt4HMDulUfOascyI9kF+Bm8CH1styyIgJXB6Yp2GZVtQjz5NJsvyCn9V25oNb5Ohjg==
X-Received: by 2002:a17:902:100a:: with SMTP id b10mr87552918pla.338.1564712455774;
        Thu, 01 Aug 2019 19:20:55 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.54
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:55 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Daniel Black <daniel@linux.ibm.com>,
	Matthew Wilcox <willy@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 28/34] mm/madvise.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:59 -0700
Message-Id: <20190802022005.5117-29-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Daniel Black <daniel@linux.ibm.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/madvise.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 968df3aa069f..1c6881a761a5 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -672,7 +672,7 @@ static int madvise_inject_error(int behavior,
 		 * routine is responsible for pinning the page to prevent it
 		 * from being released back to the page allocator.
 		 */
-		put_page(page);
+		put_user_page(page);
 		ret = memory_failure(pfn, 0);
 		if (ret)
 			return ret;
-- 
2.22.0

