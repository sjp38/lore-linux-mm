Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90859C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 526772084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:23:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 526772084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 048468E0003; Wed, 19 Jun 2019 22:23:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 01F408E0001; Wed, 19 Jun 2019 22:23:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E782D8E0003; Wed, 19 Jun 2019 22:23:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id C76B38E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:23:05 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id u129so1717741qkd.12
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:23:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0B6K/1qpxz5QZNrjR0a/hvrU0mQd0LSbp6v1C3+Zb7A=;
        b=bm7anhsVWjkrqE1qdZ3jnvLrgEhWGqaFoNQSqSG3OniLYzUuxqDFk3IqtS/cdGtOjP
         ZwqixyHXjHn6MtTneZUZYkcb6JTgaldonL6cZ6O136WlDBkc4SvPB5JEhRYjv5/3b7WM
         9dMt7ETjcgmvNMNsf0bWdUKKpCWpwWVa3eMPXZEAmAo5CrVwm1YOgr9R9j/7P8K8p3YU
         41GNRr5rrhveSHY2+8u6TV6FDbEsz/C/H9AhUhTj7iaEPdHl1HEuxXj0cMcYMJJRZwxr
         L8yoGIcApIJjZUaNing7Hk3CxwjNWEA1uHvomSKBZ6Ok1dpg4g49GWzWNBCZlar5L05e
         m88w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU4yEJLCCeQ9zbveP2/cM0UglshqhR0Xve3dDG8N+3iKa1zq/gz
	7He2QWhpqsnmKFehO4ZV+Mpicq5BY3pe7X3wCHGlTe5gT6MAe/MC3P6dAWBphrEJ49ug7tzSjuS
	xTSzjdzS6F6iOGeHWwtJS3kSRnGWTOXmExcbt2iLFRlgtA33oIKKqRj6DV6ynnv+3pg==
X-Received: by 2002:ac8:3267:: with SMTP id y36mr107265861qta.293.1560997385607;
        Wed, 19 Jun 2019 19:23:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwl0jtrmR+P781GqAXOBDHVMHIhdG8ZqN9XFulKSRIpUYnh17QtW/PKkcbg0cOnRFtR1yvK
X-Received: by 2002:ac8:3267:: with SMTP id y36mr107265825qta.293.1560997384797;
        Wed, 19 Jun 2019 19:23:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997384; cv=none;
        d=google.com; s=arc-20160816;
        b=jp3NsT27tJtevN4+tz5NjAB1x2yhU8a5l+jVG6i8/bYO+XZN9a9tYKn+S+7EbYzl9N
         reohy8qtEq9ajH7TN3Lz2B1h2RM0Fac8Hsq4fcEsV6GdMC8QsE+IMchfHdpbywOlqy2g
         QqC8FJ9oyGQm5ssjwX7pw1lJK/ZlTABJnbzHLoOWuc5q/16e81IMWFt1qENbn2dh03uN
         C9XKGTVxcAH809qgQ5jPDU/pIfKw8PJl7OB2DfMMPNU0rRdCZcWCaUEPT7v9ushkBst6
         /W+WP5mQNZ2GMMfLLqqcb6jPoU2lt2cqFOcAe7I/8P1rEENsPKcMdzTaRZbvbRTkXjxp
         suBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0B6K/1qpxz5QZNrjR0a/hvrU0mQd0LSbp6v1C3+Zb7A=;
        b=FNKjLc/5SvLX0KhDXfZ6h1Q0QpOkEFaN2lx1gRCQ2CKMiG0Sy8A8AqE/ahk/OTNZwh
         QT4+NXKcGEcGX285CTJCIaorfIC9ezpgQkaAEF/sUpjJFNz70aprAacsKKOaj0AdTuO7
         YEg7/PNuQw9cVt8Ufr20oROY5A4we+x78/Hk1iKcBqNdyea5yNv2/fCjY6khCJTHCKYB
         nNMo+wswvJ+J50VqfIr2JvjVI57968TvAWBhpPWLxnV5h658IUC2dIpLHB9ne1DETTBx
         cafWUk+33BMa/0+hSeJJqDMiNPIe16vPnhWC1NaznnjPzuLH6ZWof3JWNT3SNBMA97Sp
         QIOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e6si11350676qvt.108.2019.06.19.19.23.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:23:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id F0A5E308FBAC;
	Thu, 20 Jun 2019 02:23:03 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5886D1001E79;
	Thu, 20 Jun 2019 02:22:56 +0000 (UTC)
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
Subject: [PATCH v5 13/25] userfaultfd: wp: drop _PAGE_UFFD_WP properly when fork
Date: Thu, 20 Jun 2019 10:19:56 +0800
Message-Id: <20190620022008.19172-14-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.43]); Thu, 20 Jun 2019 02:23:04 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

UFFD_EVENT_FORK support for uffd-wp should be already there, except
that we should clean the uffd-wp bit if uffd fork event is not
enabled.  Detect that to avoid _PAGE_UFFD_WP being set even if the VMA
is not being tracked by VM_UFFD_WP.  Do this for both small PTEs and
huge PMDs.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 mm/huge_memory.c | 8 ++++++++
 mm/memory.c      | 8 ++++++++
 2 files changed, 16 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 3fda79f6746b..757975920df8 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -980,6 +980,14 @@ int copy_huge_pmd(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	ret = -EAGAIN;
 	pmd = *src_pmd;
 
+	/*
+	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
+	 * does not have the VM_UFFD_WP, which means that the uffd
+	 * fork event is not enabled.
+	 */
+	if (!(vma->vm_flags & VM_UFFD_WP))
+		pmd = pmd_clear_uffd_wp(pmd);
+
 #ifdef CONFIG_ARCH_ENABLE_THP_MIGRATION
 	if (unlikely(is_swap_pmd(pmd))) {
 		swp_entry_t entry = pmd_to_swp_entry(pmd);
diff --git a/mm/memory.c b/mm/memory.c
index d79e6d1f8c62..8c69257d6ef1 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -790,6 +790,14 @@ copy_one_pte(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 		pte = pte_mkclean(pte);
 	pte = pte_mkold(pte);
 
+	/*
+	 * Make sure the _PAGE_UFFD_WP bit is cleared if the new VMA
+	 * does not have the VM_UFFD_WP, which means that the uffd
+	 * fork event is not enabled.
+	 */
+	if (!(vm_flags & VM_UFFD_WP))
+		pte = pte_clear_uffd_wp(pte);
+
 	page = vm_normal_page(vma, addr, pte);
 	if (page) {
 		get_page(page);
-- 
2.21.0

