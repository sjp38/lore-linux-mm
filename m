Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF60AC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8228E21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8228E21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 206338E01A8; Mon, 11 Feb 2019 21:59:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1B6FE8E000E; Mon, 11 Feb 2019 21:59:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 058F68E01A8; Mon, 11 Feb 2019 21:59:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id C22B18E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:59:48 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id 42so1275934qtr.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:59:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=P04+GFKWxEz1IxW9TwcjuRARGsgBA+kAqrjkE60dE6k=;
        b=SLySybCZsRCBW1q0+lV+7S+ik2z0qZrRq35DLEGWR5A9wa4TTmCRqjiUdhZzPNYzdT
         ffeoT1XC9RXGDyKsUzK82C+lhBGJWqei/kGyt7zqdnUQyhOHaGCXnRAdAuQM8Zlj3VI6
         NlkyIuEZTfBpS3HEmLv9wgKsG7Giv1Y/f65hTo+V/cczBTiEofDe06SG7vAlgkQcfP8z
         is/2pV5JMPPrz+LveApJH3DiXCRLgFWp5GpebBum2NheQ6Ltj7G4Zts2I97U69Y2lfHl
         tUzQ2kWzhZLUefMUR/6YFoJ/DL1k79600Uqw06BMMSnYMppmwmmwMdxb7wikmEfyRW8G
         Whag==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAua3unixzgt96XS8ISEwMACJYtopT5De9HINlCj4ZKxsL61fd/rk
	OnIrLk8uTOAhXyN4CGyhJOKRWNFfvcZhHyw5FyufvyOFnaJqJzZhl7MRimYYdCCGhc24/wNLHsY
	EDHaR8d3jb1+Utd0mRZ1kD566DPNKglqzZNJMjsK4hdH7AkX22CGTbRSpU1H8xIRI/g==
X-Received: by 2002:ae9:f712:: with SMTP id s18mr984730qkg.83.1549940388589;
        Mon, 11 Feb 2019 18:59:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZfboEOqlFl1ZeL97xlfwf/gzZ0hJjNxbLyNPQwe0aUTmXa/opJbYHYhJGvx3EfzLGNlXDh
X-Received: by 2002:ae9:f712:: with SMTP id s18mr984718qkg.83.1549940388187;
        Mon, 11 Feb 2019 18:59:48 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940388; cv=none;
        d=google.com; s=arc-20160816;
        b=DKtTvCcww26ubO11zxdGQ9UbDwoVfO66X3fxiX/QQZ8TTSrL4RW72LTW8C8pQomSb4
         uEuvjmhmAgamwHAQkG6RRPFLweIdcmpjXR/jLB2Zeyq+hy+6qCVK0mmJ/zErQuKfmPi+
         +GpXx7Fcd+3PiscjndJieGL6j6a5iJpKLgmoGUyNcQqpkqlwgzCCcKfkm2lF1rJm38y9
         06oTQ37P57s8zhZuLTal3I1q4V+twcH5lDLUkkueYLaLy7ABGI1QoSEaNTyygBnJbXTj
         CveRKCMjXW/BX3bzzaRfw7JJxPoEnelm3esqdPOxtdjgwgSfunzqX53zg9Iq2hahqA+X
         O63A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=P04+GFKWxEz1IxW9TwcjuRARGsgBA+kAqrjkE60dE6k=;
        b=O9uGIDxRNooM4UrNAlePcUWuwi+eH8Ja/77MtuI5hYhhYalUNKyKab/plp0XybR3hH
         F113ltA7Vt+wxy3Y/fOi187GJYagoo/EauZuBj2i4N0EMriM5J7Kaqn7lbTrgwLb7gax
         p6vrbbTGaD1wSvCU4rhh75UCrldLd0sJ2sbt1PMM1hXG2l+PcibQ6cDpeV213RtT34A7
         vDyhi36sEJ8kp4pcKXNRZf0ipLsBrCI55+9Mbx+5C9uGu/xO6+KV+1JQa2JTn+0fIai/
         GNoqQHZyGV92rwWo94kqDZATwwL/kYjtSRT8v0M3fhIqwokn/P6MhgBp97IOcJA39P9p
         kJyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b21si3283517qtk.244.2019.02.11.18.59.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:59:48 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 413F3C06C9F8;
	Tue, 12 Feb 2019 02:59:47 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 10907600C6;
	Tue, 12 Feb 2019 02:59:35 +0000 (UTC)
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
	Marty McFadden <mcfadden8@llnl.gov>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v2 16/26] userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
Date: Tue, 12 Feb 2019 10:56:22 +0800
Message-Id: <20190212025632.28946-17-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Tue, 12 Feb 2019 02:59:47 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Adding these missing helpers for uffd-wp operations with pmd
swap/migration entries.

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

