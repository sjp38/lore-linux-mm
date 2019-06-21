Return-Path: <SRS0=pbvW=UU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1F310C43613
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDE52208CA
	for <linux-mm@archiver.kernel.org>; Fri, 21 Jun 2019 10:15:47 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ro5qRdsO"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDE52208CA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7CE816B0008; Fri, 21 Jun 2019 06:15:47 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 77F5B8E0002; Fri, 21 Jun 2019 06:15:47 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6709E8E0001; Fri, 21 Jun 2019 06:15:47 -0400 (EDT)
X-Delivered-To: Linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2FC296B0008
	for <Linux-mm@kvack.org>; Fri, 21 Jun 2019 06:15:47 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id k2so3814828pga.12
        for <Linux-mm@kvack.org>; Fri, 21 Jun 2019 03:15:47 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iaAWHMgj40YUiiiLdOSCUs5wONEm8RdZ1pbQZb103Mw=;
        b=kaWFjTLussL42YeN8iiMa/3ZMdJDp6UjPene8RV2XhOAespcyga+X7GDzXbnwSqC5f
         hhE+fnCf+CUIlxhycgFnsS96tkIFvKNPRjLQfsqhl09oZMxDBYqn4+ew3R8kUb9eEAzu
         LyOcH6sTL+jhMt89OuGgzlZSkm3KWyiEmHgHjz2sdo4Y5RHH8AdkDfsmZId4VfbJdkaa
         HLSLCha8FRKOy0tvqHc2QkKJIOARbpBDGqzItozzXmIL4fqhsE9w7blNG3e0k/UmeioC
         47F4Fqm4wjoaXd0xjyalgKdctjmAEg3eznf/B+w0ZKYvjax9zuAIwOzAYuordiPJ4jEf
         XaSA==
X-Gm-Message-State: APjAAAWqaWSDZO9R8zd0Isa++p0GVCNiBlwXkVTl0oxLPTp5P5Xclhqn
	JqfDCHSWLXQMPsl8Fz4VkZ/WRpredWLw8/PYlj30TGDbr4ZRoPPRWAcFLX8EwsrITttsLlRW6AG
	tT+6IzyX58sbR6i1POKb6T4oLJwCVMQe+2b4Npo0J3/I7QJS0NIn3/GzmucC/G1aURw==
X-Received: by 2002:a17:90a:26ef:: with SMTP id m102mr5556746pje.50.1561112146861;
        Fri, 21 Jun 2019 03:15:46 -0700 (PDT)
X-Received: by 2002:a17:90a:26ef:: with SMTP id m102mr5556681pje.50.1561112146178;
        Fri, 21 Jun 2019 03:15:46 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561112146; cv=none;
        d=google.com; s=arc-20160816;
        b=Wi5sIxq+PdDDik0xWAb2Cts+mQ20C2NI05tziCNjQJhniP1Sv1IGyS0cdWdueBW8sK
         JrFnIE7n6k3Kpl8tyIwKO9rw0zPVJ8S0OxyYNEzu4qGVRWP7gWH22i0odSxVDecszWOA
         K5dZ3nU4jy85yL5I5PeazYYNUYwm+f6md1D4E5+WU/JAhJLMX/N5RDVaxUrEmJD+QklA
         5E4pxbycJrp9046CyPCUFEqm1alijCF32oyzmHyr4U1H2NpGaTUxs9BFkTVMdEQr9QQL
         GwEjpFKW+WxXNJ+J9qiGKU/rYDrmJYKxiLnNYVlw1HUHGauKfh8Z34N0eOVCm60L0mCN
         kwoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iaAWHMgj40YUiiiLdOSCUs5wONEm8RdZ1pbQZb103Mw=;
        b=dPwXN04eEhLemJihfLOA4AER19EPjsUBvoU+OH3OmLa9KpTTtQwP5Z3NmKS5DPwXXy
         ftKUbOO9T0SWLJakdFMTyfZ3br6wZHaUZATF8/JGnFUx6+SVoxU3CF2IgGvQR3VueQur
         hhl2rOKhjTcdcSbKttKrbxJH0gY8D8d1SkcIR/4909u5LYfqdHabvFzJSkQXkK8QsoVO
         khlDMDGA6Wqo/hEdWrgWTjma8OS9yMT36BxsxQaERbUDeTjcZ81eZItdeKrd8Xlt08wI
         skBJwRdBkmFFjYtPdJjHuKxmSSLLtdZ21Ws9tnDod9hCBPwnNtypfxoSWfEDnVe4gguH
         MFnw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ro5qRdsO;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id go5sor2828198plb.37.2019.06.21.03.15.46
        for <Linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Jun 2019 03:15:46 -0700 (PDT)
Received-SPF: pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ro5qRdsO;
       spf=pass (google.com: domain of kernelfans@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=kernelfans@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=iaAWHMgj40YUiiiLdOSCUs5wONEm8RdZ1pbQZb103Mw=;
        b=ro5qRdsOCcr007KyKnX0TdinBmxigmD6oO7ryvNgpYVDDhu6jym2pDqNFvcAvWTkxy
         xeSaO+LtF7D8jsbSKMsI0gVezGfsUxlZfDtyS+HJ+B9VlRP1VfRlkYKbV5W5inXuxzkc
         Pi0ESkw8ePLr2jvzD+roWvLRtYG4RTvC04QODSVen/AiH7MNkFuzaLkqG4vvfUVSOadD
         7oj9FGlTVMvneDDWAzmbQaKbxaxLUd50KhdQnoAmsmaQ4G0WRHN02tAeWivB6D9gX+/0
         ZITP6k8kRN2P/qtbI5tc2jIMJVnv7lXOj/tbG54yNtfD5+XL5CWygfbxjqD1OiGYGo+o
         ERZQ==
X-Google-Smtp-Source: APXvYqw64NArSYS+J2I2yZXnXVHQVwWJYFrAOUvBebEJQsxNVmcK50h/mJX7bfSLMNNQ+7aDRCY5hg==
X-Received: by 2002:a17:902:e211:: with SMTP id ce17mr48686801plb.193.1561112145655;
        Fri, 21 Jun 2019 03:15:45 -0700 (PDT)
Received: from mylaptop.redhat.com ([2408:8207:7826:5c10:8935:c645:2c30:74ef])
        by smtp.gmail.com with ESMTPSA id x14sm3040681pfq.158.2019.06.21.03.15.37
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 03:15:44 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
To: Linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ira Weiny <ira.weiny@intel.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	"Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	John Hubbard <jhubbard@nvidia.com>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Christoph Hellwig <hch@lst.de>,
	Keith Busch <keith.busch@intel.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Linux-kernel@vger.kernel.org
Subject: [PATCH] mm/gup: speed up check_and_migrate_cma_pages() on huge page
Date: Fri, 21 Jun 2019 18:15:16 +0800
Message-Id: <1561112116-23072-1-git-send-email-kernelfans@gmail.com>
X-Mailer: git-send-email 2.7.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Both hugetlb and thp locate on the same migration type of pageblock, since
they are allocated from a free_list[]. Based on this fact, it is enough to
check on a single subpage to decide the migration type of the whole huge
page. By this way, it saves (2M/4K - 1) times loop for pmd_huge on x86,
similar on other archs.

Furthermore, when executing isolate_huge_page(), it avoid taking global
hugetlb_lock many times, and meanless remove/add to the local link list
cma_page_list.

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Keith Busch <keith.busch@intel.com>
Cc: Mike Kravetz <mike.kravetz@oracle.com>
Cc: Linux-kernel@vger.kernel.org
---
 mm/gup.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index ddde097..2eecb16 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1342,16 +1342,19 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 	LIST_HEAD(cma_page_list);
 
 check_again:
-	for (i = 0; i < nr_pages; i++) {
+	for (i = 0; i < nr_pages;) {
+
+		struct page *head = compound_head(pages[i]);
+		long step = 1;
+
+		if (PageCompound(head))
+			step = compound_order(head) - (pages[i] - head);
 		/*
 		 * If we get a page from the CMA zone, since we are going to
 		 * be pinning these entries, we might as well move them out
 		 * of the CMA zone if possible.
 		 */
 		if (is_migrate_cma_page(pages[i])) {
-
-			struct page *head = compound_head(pages[i]);
-
 			if (PageHuge(head)) {
 				isolate_huge_page(head, &cma_page_list);
 			} else {
@@ -1369,6 +1372,8 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 				}
 			}
 		}
+
+		i += step;
 	}
 
 	if (!list_empty(&cma_page_list)) {
-- 
2.7.5

