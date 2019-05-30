Return-Path: <SRS0=aa49=T6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2B0AAC28CC0
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:55:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D4C3F2620A
	for <linux-mm@archiver.kernel.org>; Thu, 30 May 2019 21:54:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QntIfn3Q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D4C3F2620A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 777F46B027D; Thu, 30 May 2019 17:54:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7280F6B027E; Thu, 30 May 2019 17:54:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C89A6B027F; Thu, 30 May 2019 17:54:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 307AC6B027D
	for <linux-mm@kvack.org>; Thu, 30 May 2019 17:54:59 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id b64so380504otc.3
        for <linux-mm@kvack.org>; Thu, 30 May 2019 14:54:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:subject:from:to:cc:date
         :message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=tFR5eWyyHKLzv/rG+/k1EP28VfnvmUHd1en3f8cuet4=;
        b=jpE5UKzeX5B4IRI3xybSLhugyRd+2eriN63XPhH+uyZvXANlFGllaZijJ1BQpTAmNe
         elpjgWZG+J8huUYRk77YbcZNG1iZBSE8HT+NbVHZy8aIzAYFMbtepDY9mGGXrCb2T4n6
         0akdwpIgZCPN6pcog3v9y2RAObn47DAZBPc7Bl2VLU4qrVShGa2CErOATxXNiQ2yZGyP
         3gnuMaCHWANnCsK5vvV0Ugt1k2CWPpZADfhckZRD11YKvKoPNKWqj4LTVYqjEb1k6k4L
         Zh+OVke1N7zEqjUr1fAcuTi3ZV9RDS5rllejZE6nnUR9b5QxMgUPuDYQ8YdUlb3VwnLg
         IjJw==
X-Gm-Message-State: APjAAAVKEDaoxblemQFkdtCme9gGk7cJJzporeIi1EWAARYFc3xQtBUX
	NzVF33thNxK9xGKUdSF52z3ckSaXlEJy4IL2NgAqbFLN+aJnjbs0lUpUSVdyd/nj8afQP3oQJ0R
	OCutgGna2hmsj4D8r8s3TF3d++fRgm1TJOoI8ox6E+MwCFu81OXpMf9YdGBACUCmQmg==
X-Received: by 2002:a9d:411e:: with SMTP id o30mr4289711ote.122.1559253298915;
        Thu, 30 May 2019 14:54:58 -0700 (PDT)
X-Received: by 2002:a9d:411e:: with SMTP id o30mr4289683ote.122.1559253298381;
        Thu, 30 May 2019 14:54:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559253298; cv=none;
        d=google.com; s=arc-20160816;
        b=mwj9Gw+eYREJWl/qMQ19bX5TGLroUky+akMZC9ewVkS9Y1HDAmtU4eEZKWAGjfOrKz
         8vejTQgpYvsCEl91cMKULL4OkPslfzLOO8TzWrnTcPcBpS5P6ywVZshr4xrMLk3z1Blk
         U2pdtLHf78AGlNqmOQbIUa4toq8kL1WrX5lh2B4R4X5vKDtdlZNO0rxR0WYC4/E562fQ
         kZINjArrp9r8eh3+amY3gSM/PR1d9bVTR80jdeVOzslIt8YLLAcIhrVgsTFTge9Mf+qU
         WBnGuI0fh5Ramo7KUBZCc0osMoHHeejbuz3hhHIflS9W/qJgJJRGypzbY6jMl6cRudL5
         /uHg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:cc:to:from:subject:dkim-signature;
        bh=tFR5eWyyHKLzv/rG+/k1EP28VfnvmUHd1en3f8cuet4=;
        b=BCHTL1etF53GcHaGiza9ZtY2TJ+GAEu8CvQSg+wDcQhtKbK1BIGTH4MkOVo7PdVQ1I
         rJKaQZxD4wtzhJ59FibzQ/GWgdBDTHot2ku1Dy7pNlWZzC3J5NExBgShD1/NNB+y/pEL
         JARe/R1gBRyW9Ntc423SgKyPFi3SbYmoH16iRezxThHBfBobj8iZyvZjFEAFSPiUboji
         xKrP2l/eo134KR6SQ4VshL6yoCfuB6H/dqdu0NBJC3y7Uf5wn60CdLGeTf7bONC/1hQR
         nxqmwg2tpPu65nNBbGLmI3ROwqky/uMQqno9ysswkgZvpLKxfZLj3xHmCL98HJFjYWOF
         0X8Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QntIfn3Q;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o188sor1233818oih.142.2019.05.30.14.54.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 May 2019 14:54:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QntIfn3Q;
       spf=pass (google.com: domain of alexander.duyck@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=alexander.duyck@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=tFR5eWyyHKLzv/rG+/k1EP28VfnvmUHd1en3f8cuet4=;
        b=QntIfn3QP7w8OAf3KeLsA35GzvqasynhBr/LPKQ9UMSeS7sqkj18UbNYx/lJnWUJpx
         f9XhduhHSqYQrgukNTzCY6WtbcIgGHsNYgnGj2IhxiM0AVHY2+kyTEyxdSCPnZMVDLIx
         9F25FqTBOpb+X9YuJjyHH3ZeN/n7u048oiFLngFfpUu8oI0RouCxcc88D1IA4PwTWbV6
         YeeIFLwG3GLDmk1UTKsyorsyB8oh3Cc+b4Ql1DRnh02Uyw3Mddx82RmNGlqoHGX8YCHx
         neY4bedgWaliCWNuwj2x5E4P1f3BsPX6mffX4wlZD7UVun/2Shv7YNn8yRoAMtSRlhmk
         Enrw==
X-Google-Smtp-Source: APXvYqxfGBCA97YkaWM4wjgbjBJNwlQrAjyiLnkd5V2gUCN0ncNK3/MIrN/Ma+crH/dforiEy7/ROg==
X-Received: by 2002:aca:4e42:: with SMTP id c63mr4187588oib.170.1559253298022;
        Thu, 30 May 2019 14:54:58 -0700 (PDT)
Received: from localhost.localdomain (50-126-100-225.drr01.csby.or.frontiernet.net. [50.126.100.225])
        by smtp.gmail.com with ESMTPSA id 33sm1412918otb.56.2019.05.30.14.54.56
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 May 2019 14:54:57 -0700 (PDT)
Subject: [RFC PATCH 11/11] mm: Add free page notification hook
From: Alexander Duyck <alexander.duyck@gmail.com>
To: nitesh@redhat.com, kvm@vger.kernel.org, david@redhat.com, mst@redhat.com,
 dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, riel@surriel.com,
 konrad.wilk@oracle.com, lcapitulino@redhat.com, wei.w.wang@intel.com,
 aarcange@redhat.com, pbonzini@redhat.com, dan.j.williams@intel.com,
 alexander.h.duyck@linux.intel.com
Date: Thu, 30 May 2019 14:54:55 -0700
Message-ID: <20190530215455.13974.87717.stgit@localhost.localdomain>
In-Reply-To: <20190530215223.13974.22445.stgit@localhost.localdomain>
References: <20190530215223.13974.22445.stgit@localhost.localdomain>
User-Agent: StGit/0.17.1-dirty
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Alexander Duyck <alexander.h.duyck@linux.intel.com>

Add a hook so that we are notified when a new page is available. We will
use this hook to notify the virtio aeration system when we have achieved
enough free higher-order pages to justify the process of pulling some pages
and hinting on them.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 arch/x86/include/asm/page.h |   11 +++++++++++
 include/linux/gfp.h         |    4 ++++
 mm/page_alloc.c             |    2 ++
 3 files changed, 17 insertions(+)

diff --git a/arch/x86/include/asm/page.h b/arch/x86/include/asm/page.h
index 7555b48803a8..dfd546230120 100644
--- a/arch/x86/include/asm/page.h
+++ b/arch/x86/include/asm/page.h
@@ -18,6 +18,17 @@
 
 struct page;
 
+#ifdef CONFIG_AERATION
+#include <linux/memory_aeration.h>
+
+#define HAVE_ARCH_FREE_PAGE_NOTIFY
+static inline void
+arch_free_page_notify(struct page *page, struct zone *zone, int order)
+{
+	aerator_notify_free(page, zone, order);
+}
+
+#endif
 #include <linux/range.h>
 extern struct range pfn_mapped[];
 extern int nr_pfn_mapped;
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 407a089d861f..d975e7eabbf8 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -459,6 +459,10 @@ static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 #ifndef HAVE_ARCH_FREE_PAGE
 static inline void arch_free_page(struct page *page, int order) { }
 #endif
+#ifndef HAVE_ARCH_FREE_PAGE_NOTIFY
+static inline void
+arch_free_page_notify(struct page *page, struct zone *zone, int order) { }
+#endif
 #ifndef HAVE_ARCH_ALLOC_PAGE
 static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index e3800221414b..104763034ce3 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -999,6 +999,8 @@ static inline void __free_one_page(struct page *page,
 		add_to_free_area_tail(page, area, migratetype);
 	else
 		add_to_free_area(page, area, migratetype);
+
+	arch_free_page_notify(page, zone, order);
 }
 
 /*

