Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C46FC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D395B206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D395B206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 71D346B0277; Fri, 26 Apr 2019 00:54:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CCD16B0278; Fri, 26 Apr 2019 00:54:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5E3A96B0279; Fri, 26 Apr 2019 00:54:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3EF566B0277
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:24 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id z34so1869863qtz.14
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JMh9KCVPuDaGt/2VnHtIaAX3wvvxE5xtc+RuS52ZdHc=;
        b=CQWkmsvZNEOtxAG8zaH7ATtEkfOtmknO3qNXKLq2HRYhH0FOeQVFaASHRNwxaaDRyt
         UxE5JZ7zNm7zhYJg/MuuXkHIDrZWY7jJfUSApD1QLGTbuNQ3W+5a05OhWSUvPat0FL0E
         wP84iViJo4tiMVNj1B8TVTzVP3sMpIeqbMDcZBNPdoi0vonffy3VnTlrGRA8ZrOuQaP9
         VgbUdOLh8pL2AZwYvK3ZsXzLkP0IH2hwIeLT0On6OOptkaoC+AEsu3wVIswdCWG3+84A
         HcxbFkDTQnkq+V5Vz7i3xzfUPbUGGxjHaCXf+34uNWc7W2PPdApyg1LJKkdxkPsdOLPu
         wNmg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXrMWK7Ut1Jr192BBFamexfaA/2DndpCjrdZrp93Rs5MiX1KLzB
	QUy8qWO/dWD32whQjMlUDTYguQNP9M5j6K7FuwJ5dNKSAPpFpoGDzCjXJaYgR+zn5QZqBYgEAEH
	2yRaLA588bNgGYUwJJx97ouUHsEL+ByKk8j712a0iGwuvTXF2MPbsDe+eyRui2zN78w==
X-Received: by 2002:ac8:1491:: with SMTP id l17mr5785731qtj.143.1556254464060;
        Thu, 25 Apr 2019 21:54:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzlqFfsc0RMiyTn7yRxDDTfhcBuAm1sH1oEoVu9VvykV2j3nrTjjOqzK1BDhLPUZahl2CbK
X-Received: by 2002:ac8:1491:: with SMTP id l17mr5785705qtj.143.1556254463236;
        Thu, 25 Apr 2019 21:54:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254463; cv=none;
        d=google.com; s=arc-20160816;
        b=s30RyO2vmrAcPDZDszMpZQK9JBErpCroMzdwUtmFADvYytNyYwLM8AhMAQIrYQDgFB
         oa3qRSUpnPWQlslxiouGCam0iSnPLIPnbhXFlImd3QAABrzTo44zCTWx5+Kblvdx/epM
         W4no2Ai/cyvBSwiMOMsIZEhjDcheAEdsQLikopngyx/My/gIgSQcOgwKIHRiDWFNkbY4
         PGU5o2+JnSky3aAOmMnIcUKD9sb0UFLDxhCl6aImANjwYaO4HYi0Hn1dCRONm8Rt6Ykx
         x40hMSmGQJPkQAv3pBYvpg7GzvWiSllTtBg5YqsfvEBvjey3aNsApUP1+XwTSZj960uP
         brpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JMh9KCVPuDaGt/2VnHtIaAX3wvvxE5xtc+RuS52ZdHc=;
        b=QbAzB6V6bTRhLNM2NF+YmX7NG10WpQoSxhy2YS1TLzDmlDSOGuyBGLKnB649jcBOsB
         VWdx2QMltpnE+c6ImZyUAz5Tdo+Cc2nibRlAoZWAj3nIh1hP8QVPLmQkAX3m7Oo970ef
         4kLxmrKt8QO9fVCRWQWW12gEv5+yAegO5Pa1Zw8a7R1JbXNkOE9cPgRQ6Czc/TcazODC
         U+ONiJ8kqtPUnWNX191AMDGjKjAAqiD+CcCG27o6bG7Ok8s+aSHQ5p5LmyQvadNbJFJf
         BKhMEgxT14ZRQjtZize7o4lSbrbhMSx7fkJqadADlyz70ZsTE38LI6Lq0J/ww1+Om+/M
         IIkw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j4si4361657qkd.234.2019.04.25.21.54.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:54:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 62CD33082B4D;
	Fri, 26 Apr 2019 04:54:22 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 96F8D17B21;
	Fri, 26 Apr 2019 04:54:11 +0000 (UTC)
From: Peter Xu <peterx@redhat.com>
To: linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Cc: David Hildenbrand <david@redhat.com>,
	Hugh Dickins <hughd@google.com>,
	Maya Gokhale <gokhale2@llnl.gov>,
	Jerome Glisse <jglisse@redhat.com>,
	Pavel Emelyanov <xemul@virtuozzo.com>,
	Johannes Weiner <hannes@cmpxchg.org>,
	peterx@redhat.com,
	Martin Cracauer <cracauer@cons.org>,
	Shaohua Li <shli@fb.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v4 16/27] userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
Date: Fri, 26 Apr 2019 12:51:40 +0800
Message-Id: <20190426045151.19556-17-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Apr 2019 04:54:22 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adding these missing helpers for uffd-wp operations with pmd
swap/migration entries.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 arch/x86/include/asm/pgtable.h     | 15 +++++++++++++++
 include/asm-generic/pgtable_uffd.h | 15 +++++++++++++++
 2 files changed, 30 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 6863236e8484..18a815d6f4ea 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1401,6 +1401,21 @@ static inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
 {
 	return pte_clear_flags(pte, _PAGE_SWP_UFFD_WP);
 }
+
+static inline pmd_t pmd_swp_mkuffd_wp(pmd_t pmd)
+{
+	return pmd_set_flags(pmd, _PAGE_SWP_UFFD_WP);
+}
+
+static inline int pmd_swp_uffd_wp(pmd_t pmd)
+{
+	return pmd_flags(pmd) & _PAGE_SWP_UFFD_WP;
+}
+
+static inline pmd_t pmd_swp_clear_uffd_wp(pmd_t pmd)
+{
+	return pmd_clear_flags(pmd, _PAGE_SWP_UFFD_WP);
+}
 #endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
 
 #define PKRU_AD_BIT 0x1
diff --git a/include/asm-generic/pgtable_uffd.h b/include/asm-generic/pgtable_uffd.h
index 643d1bf559c2..828966d4c281 100644
--- a/include/asm-generic/pgtable_uffd.h
+++ b/include/asm-generic/pgtable_uffd.h
@@ -46,6 +46,21 @@ static __always_inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
 {
 	return pte;
 }
+
+static inline pmd_t pmd_swp_mkuffd_wp(pmd_t pmd)
+{
+	return pmd;
+}
+
+static inline int pmd_swp_uffd_wp(pmd_t pmd)
+{
+	return 0;
+}
+
+static inline pmd_t pmd_swp_clear_uffd_wp(pmd_t pmd)
+{
+	return pmd;
+}
 #endif /* CONFIG_HAVE_ARCH_USERFAULTFD_WP */
 
 #endif /* _ASM_GENERIC_PGTABLE_UFFD_H */
-- 
2.17.1

