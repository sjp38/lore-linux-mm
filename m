Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21C61C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DCC4C2183E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DCC4C2183E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 834D76B0273; Tue, 19 Mar 2019 22:09:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7BDC06B0274; Tue, 19 Mar 2019 22:09:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 65FA66B0275; Tue, 19 Mar 2019 22:09:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 336FA6B0273
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:09:07 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id 35so924567qtq.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:09:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=JMh9KCVPuDaGt/2VnHtIaAX3wvvxE5xtc+RuS52ZdHc=;
        b=CNV9WutjbFi9J7gXDJr1mwBFsLnPbdHHKkZbIHkUbzvfsYSdwvSR8jDQRBKJyr70H3
         NiP079ObNxDYdRpplA6VO7wmSRb81JOqhV8FF1OZyGsHnapXWW8o+Q+QjQxztph85fIO
         f9CPpTjDRZCN+4owgPjGVIQJTkHS8d7FXdWDAHLSMMgRNm5Hp8hM4u1/7GdHSO3DsXbM
         vl52byRfGOLKrWiJGP1snEjv4VuBq9OWdDHiP9igwfz/qf8l8UEGkV8kptFRueLlK6Se
         td79GC1tPUv2E3mFG4E1ijR7Hxu/l35AyIU7o3ZmYZiVlpn+wOh8anS2cmv98JL2wRtr
         eCxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVcm2VdfECUNVc7eZKS1vkhTwwzA5xeprAYcWm+8iktBud2r9SC
	4eYr5slpNkbjLsyWb5nbwUj3RH3h5PhnSIafgEvTr3CBEV03zZtsibY8ceTlCpIFixDlxMLBLdj
	5E28ZPWCGckWfLKMKUh53OzF/s3Er4xiOvOUeoYSdcm6lXnB2taZCAYllNA0ztdDQoA==
X-Received: by 2002:a0c:d155:: with SMTP id c21mr4526067qvh.64.1553047747007;
        Tue, 19 Mar 2019 19:09:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6gM70ie+PEdS9RL4rVgsWxECSJRlMCFaCiBlKn4nje1U+Y23Nqab57n4wCHypok2wM8/X
X-Received: by 2002:a0c:d155:: with SMTP id c21mr4526029qvh.64.1553047746057;
        Tue, 19 Mar 2019 19:09:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047746; cv=none;
        d=google.com; s=arc-20160816;
        b=dnSiAkV5gEaG/JTpMSRMrQG10NUyNoN+Tjy+FivPHCYBjgiB9oq/vx5pvGx2GA7zfd
         yDvVnpbAucJxhwL9dxvaOE/RuUOe5gENikjaPa4CMX65dgmyrZgwZzf2vrLelwQNZcMc
         t792Y9eO9Zh3uymvIp7FjvuNqOQT0n9LG3PT5JCtuEH/4OgWwGg1dGXNnerqC3PYwmE8
         92gMQeHM+joeoTAQZtHzM/DrDK25htwgDi5GYCGjDWcqBH3unT8zUwj8f/jV0ggcNgIF
         3R+KDNXwuflXSj6/LulO7xyYpYdHMOrCrr3Kd1joUYnitu54kVY3/+33z9GFeNuVRcnf
         DcBA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=JMh9KCVPuDaGt/2VnHtIaAX3wvvxE5xtc+RuS52ZdHc=;
        b=jqvnizd1qYoz6eqaTETFv/PBcQEkIMrRknW7a8szeYoxNXxrhEppoBwuO9lafVOOPI
         PKOqGnYvrhA+p/wNR6sO9jsXF5BOT+JNA8ZBY+ooS3MWvb338P8ZYIgIpq7qk6f1VwFQ
         HW8iOfrlqN2P0fTmND2leUNWLhsorSoNFdiG5u1andLxXvJ81HHI8DydqAwAXBu5/XAo
         x3rNnKShZkntr7pH53D6sgV8uJkA23a9dBpIYpnMe//b6hZzoXyxooLC4TQNRM4m4pSA
         ls1YQIlrX3TpifqCRCIbmtH5+u5vYWE6R2bRy+fdyFJND7q5JPV87xP37OQqBsZnzX4g
         KLSg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a62si358769qke.96.2019.03.19.19.09.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:09:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1E0D981F18;
	Wed, 20 Mar 2019 02:09:05 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 8E806605CA;
	Wed, 20 Mar 2019 02:08:55 +0000 (UTC)
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
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v3 16/28] userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
Date: Wed, 20 Mar 2019 10:06:30 +0800
Message-Id: <20190320020642.4000-17-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 02:09:05 +0000 (UTC)
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

