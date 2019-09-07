Return-Path: <SRS0=dqyo=XC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7BD82C43331
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:25:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4125E218DE
	for <linux-mm@archiver.kernel.org>; Sat,  7 Sep 2019 17:25:50 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GP196Uxh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4125E218DE
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E3B766B0266; Sat,  7 Sep 2019 13:25:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DEB746B0269; Sat,  7 Sep 2019 13:25:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D28F66B026A; Sat,  7 Sep 2019 13:25:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0067.hostedemail.com [216.40.44.67])
	by kanga.kvack.org (Postfix) with ESMTP id B32E76B0266
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 13:25:49 -0400 (EDT)
Received: from smtpin21.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 6F8D2180AD7C3
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:25:49 +0000 (UTC)
X-FDA: 75908802018.21.crow09_15b1d1eca5e4e
X-HE-Tag: crow09_15b1d1eca5e4e
X-Filterd-Recvd-Size: 5649
Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	by imf04.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Sat,  7 Sep 2019 17:25:48 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id z6so2048168oix.9
        for <linux-mm@kvack.org>; Sat, 07 Sep 2019 10:25:48 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=subject:from:to:cc:date:message-id:in-reply-to:references
         :user-agent:mime-version:content-transfer-encoding;
        bh=kSopJtjN0Bct/j9/oVkg8pXbs8bfoPtfq3tp15cWbFA=;
        b=GP196UxhtesI4DpzLroLGitq6AT3yCg6JIv7eHeX5bE512Bt2rY5UX8Owl6UWaLuqS
         KBU4alhzy/RjfOR2TD2kzxNOol1Dd7elx6QeLBSjvXAWYZ6J72Ui7zxbgwBqcpRN3GUw
         HM+GqbVngxARkCzWLz6bcneox7MpCZMhaZa7BbElkS22E1/H9BVwFHjSHB7D8HdTnNB8
         s9D7U+SPL6HVQH4GdqLxg+X1sIFEo1PwYNdUecPhL42WU/f2CPZGoIfUWj2ABQ0FomHv
         p1CyrMS2490/kosLr9EtAAYUk6zgj+NGlrqlwd2lM4GhpruzQf8L1+BRJ/tGzqsdCmoi
         ndmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:subject:from:to:cc:date:message-id:in-reply-to
         :references:user-agent:mime-version:content-transfer-encoding;
        bh=kSopJtjN0Bct/j9/oVkg8pXbs8bfoPtfq3tp15cWbFA=;
        b=iJwNcUNyr0lJIP0hnYQ0l2KR/FqZPxV+c5BCiO77WS9HFrzvAJdY+HyYlyGRPWqZMw
         f6K6lo5DsRryJDFGDIQmPX2RHSTA4d9YpzoHSf1zS2p2PBtENa3DDpCPV7jglMNaS3NM
         k9o7b/02rxE2rM7ku/GUZJPbEmAbDIcxNptsYOEWs37Slpd84LZcr8sGkLkaLnoJzQmq
         Kgz8vbsrohrii1cBdbXFO1QmBhwHDGxSxKiU5M84h7ldyeuVEk64hsKh11nM1o9ySCNl
         4tcplO8uH8Oywk3areCWQGnjnegR+SFg5cxGn1nKAWrRGLkhqNeHOEWiqMWZDS6cyWVl
         /9qw==
X-Gm-Message-State: APjAAAWUm0nuzMpEOW0edF+eCuh8n28jRl5UZb9bDUieSk2a2YTQGUTR
	aNwiYVuIJQ/zWHNvBWBu/0s=
X-Google-Smtp-Source: APXvYqx2weNfO8K71L99snv6nx65rVmU19IskIQeolfUre8SXryHDBsQbX2DReh7lqCg7Zl0p2XdAA==
X-Received: by 2002:aca:2105:: with SMTP id 5mr9598351oiz.84.1567877148171;
        Sat, 07 Sep 2019 10:25:48 -0700 (PDT)
Received: from localhost.localdomain ([2001:470:b:9c3:9e5c:8eff:fe4f:f2d0])
        by smtp.gmail.com with ESMTPSA id x6sm4135651ote.69.2019.09.07.10.25.45
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Sep 2019 10:25:47 -0700 (PDT)
Subject: [PATCH v9 5/8] arm64: Move hugetlb related definitions out of
 pgtable.h to page-defs.h
From: Alexander Duyck <alexander.duyck@gmail.com>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, mst@redhat.com,
 catalin.marinas@arm.com, david@redhat.com, dave.hansen@intel.com,
 linux-kernel@vger.kernel.org, willy@infradead.org, mhocko@kernel.org,
 linux-mm@kvack.org, akpm@linux-foundation.org, will@kernel.org,
 linux-arm-kernel@lists.infradead.org, osalvador@suse.de
Cc: yang.zhang.wz@gmail.com, pagupta@redhat.com, konrad.wilk@oracle.com,
 nitesh@redhat.com, riel@surriel.com, lcapitulino@redhat.com,
 wei.w.wang@intel.com, aarcange@redhat.com, ying.huang@intel.com,
 pbonzini@redhat.com, dan.j.williams@intel.com, fengguang.wu@intel.com,
 alexander.h.duyck@linux.intel.com, kirill.shutemov@linux.intel.com
Date: Sat, 07 Sep 2019 10:25:45 -0700
Message-ID: <20190907172545.10910.88045.stgit@localhost.localdomain>
In-Reply-To: <20190907172225.10910.34302.stgit@localhost.localdomain>
References: <20190907172225.10910.34302.stgit@localhost.localdomain>
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

Move the static definition for things such as HUGETLB_PAGE_ORDER out of
asm/pgtable.h and place it in page-defs.h. By doing this the includes
become much easier to deal with as currently arm64 is the only architecture
that didn't include this definition in the asm/page.h file or a file
included by it.

It also makes logical sense as PAGE_SHIFT was already defined in
page-defs.h so now we also have HPAGE_SHIFT defined there as well.

Signed-off-by: Alexander Duyck <alexander.h.duyck@linux.intel.com>
---
 arch/arm64/include/asm/page-def.h |    9 +++++++++
 arch/arm64/include/asm/pgtable.h  |    9 ---------
 2 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/arm64/include/asm/page-def.h b/arch/arm64/include/asm/page-def.h
index f99d48ecbeef..1c5b079e2482 100644
--- a/arch/arm64/include/asm/page-def.h
+++ b/arch/arm64/include/asm/page-def.h
@@ -20,4 +20,13 @@
 #define CONT_SIZE		(_AC(1, UL) << (CONT_SHIFT + PAGE_SHIFT))
 #define CONT_MASK		(~(CONT_SIZE-1))
 
+/*
+ * Hugetlb definitions.
+ */
+#define HUGE_MAX_HSTATE		4
+#define HPAGE_SHIFT		PMD_SHIFT
+#define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
+#define HPAGE_MASK		(~(HPAGE_SIZE - 1))
+#define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
+
 #endif /* __ASM_PAGE_DEF_H */
diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
index 7576df00eb50..06a376de9bd6 100644
--- a/arch/arm64/include/asm/pgtable.h
+++ b/arch/arm64/include/asm/pgtable.h
@@ -305,15 +305,6 @@ static inline int pte_same(pte_t pte_a, pte_t pte_b)
  */
 #define pte_mkhuge(pte)		(__pte(pte_val(pte) & ~PTE_TABLE_BIT))
 
-/*
- * Hugetlb definitions.
- */
-#define HUGE_MAX_HSTATE		4
-#define HPAGE_SHIFT		PMD_SHIFT
-#define HPAGE_SIZE		(_AC(1, UL) << HPAGE_SHIFT)
-#define HPAGE_MASK		(~(HPAGE_SIZE - 1))
-#define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
-
 static inline pte_t pgd_pte(pgd_t pgd)
 {
 	return __pte(pgd_val(pgd));


