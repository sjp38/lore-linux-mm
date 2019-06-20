Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33A2FC4646B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EFFB12084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EFFB12084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A31FB8E0005; Wed, 19 Jun 2019 22:23:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9E3F58E0001; Wed, 19 Jun 2019 22:23:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8D2178E0005; Wed, 19 Jun 2019 22:23:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 68C808E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:23:18 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id o16so1691982qtj.6
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:23:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OA/gE3dA9KiTq0wwEszkXEbgJHTkBwyZNwfY7oPqmEc=;
        b=Ypx11wMuJbKi6RcE74iF9aKEtJwgfhA4IxogGKiz46hxrqSDf3aK5D2m0YFyptiXnv
         hcR5b2pxR7ERjc5SWUI/wRA1PPCgyLDz71VY0B3lBVKcqN4Vsh7bxFikg8fjwx5qJ77F
         JlT0oJxS8TGCwXN6iovlmcHD6bekhoqmPeNamV4+6knwBviKrrAo37iCDQjeN3HRS25d
         aKpIo2sBFwsSbVDdhfUjtkEN7DLkfpk+a1Y9l5+deEjmoYQSmBIaqb6ruqZBgOdy5OYt
         DUtMfZh5Ub8ehr5jmJOMMfbyICeVRt/EJYvHUMUm13I0FL4L6Pxxiz2/2+Q8DzE/+vDr
         tLDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWbrwTXjRzNlEOk2NbjVOmsxVlRH5Qux8ANKF5+Zm/5RXEoKOI2
	q06EgNqWiYLAh+ZG9qYOgtbaN/QvK033DAKyLcRHfrV6OdChriCJ2m3E1EgL9yEU4eZM1IYcrE4
	v0zKn4nCFyNZpgDo6Xi9m+JISeM3l0mEYIfvz8DvvfmExg/+bNyBcHpptleP6zqV9hw==
X-Received: by 2002:a0c:9932:: with SMTP id h47mr37089184qvd.147.1560997398217;
        Wed, 19 Jun 2019 19:23:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwLER80aQsSSadjr+L6McUDn5p93/OUCVHazyM5W0F/XHeAI7ppN8tV6MGkEG1mvyXtyaAb
X-Received: by 2002:a0c:9932:: with SMTP id h47mr37089155qvd.147.1560997397736;
        Wed, 19 Jun 2019 19:23:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997397; cv=none;
        d=google.com; s=arc-20160816;
        b=Quel2pvIOv6/AEVH67uRVrhDLSuSj85ud2SVM0wKs3PIJnFP6rbjxc0blYDp4s6jfr
         vdaNyXbk3Wxjv5DvNLRoe0CLPvZ+9UMs1ZOdDyWFXy6pxCw4nVuLcEh9AghL9xpg2R8/
         YwTCWwxgAYLTEFCsPi/cNYU+j/zumVotzU4Me/Yn+mS4iDXu8cgr8tOGgvv93SshrHS/
         fl6ARNSyuL6URF0yf3fpScHYCEEFp1/CnY68son7pSO93NarKo1ORawM9tKBxTjlNKH2
         LJ78CPhz6yloa05EKEFjPQCojAf93dGOG51eYORo6Uo9auMiMMO/EIcfAVl6hbCIFzPk
         Ytrw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=OA/gE3dA9KiTq0wwEszkXEbgJHTkBwyZNwfY7oPqmEc=;
        b=nrCuHuvQ9Y65/zfKgfr9ew7iVEUmIOJi0YJafriqnx/xcARl5q1dHHAviZIS5Vx6Yw
         Wg76Pl33XL+9KeSiwdVA1GPlMH2McZtp93TItnzUzh/66iuyrZHP/Fn3NtvKN6rrB5Kn
         TKCYVLVJfO5f7UMd76+O11imrwL31jqzqrxS/qL4zn2CnownJL9cVxhfJSxHF/ERqXHV
         zMB7ddqABZVxOaMOHM3DnGVv0N0bhyJGlkRZ0aO0S5RAMqFqz8HaTDfz9pO6xI3zX/Wp
         Un+AsuxSs4PIQN/tzerAeGsZNWeM6vo/fZJp4snatTTbF1DFactWKQcciSRr3tPlF8SY
         /HmQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d22si3409892qtm.389.2019.06.19.19.23.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:23:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id AAF6B30018D7;
	Thu, 20 Jun 2019 02:23:16 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 74DB11001DC3;
	Thu, 20 Jun 2019 02:23:04 +0000 (UTC)
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
	Denis Plotnikov <dplotnikov@virtuozzo.com>,
	Shaohua Li <shli@fb.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	Marty McFadden <mcfadden8@llnl.gov>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Mel Gorman <mgorman@suse.de>,
	"Kirill A . Shutemov" <kirill@shutemov.name>,
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 14/25] userfaultfd: wp: add pmd_swp_*uffd_wp() helpers
Date: Thu, 20 Jun 2019 10:19:57 +0800
Message-Id: <20190620022008.19172-15-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.46]); Thu, 20 Jun 2019 02:23:17 +0000 (UTC)
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
index 5b254b851082..0120fa671914 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1421,6 +1421,21 @@ static inline pte_t pte_swp_clear_uffd_wp(pte_t pte)
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
2.21.0

