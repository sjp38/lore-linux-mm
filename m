Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75252C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3403B217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:08:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3403B217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3E166B026A; Tue, 19 Mar 2019 22:08:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CED7C6B026B; Tue, 19 Mar 2019 22:08:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BDE386B026C; Tue, 19 Mar 2019 22:08:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 956F26B026A
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:08:44 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id k5so935761qte.0
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:08:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=hoTZlblJA2VeYKo/mEcOKhsmwUWo5+51FludXN2P/8E=;
        b=ZtAE3qY2WUIDjdVCRgvlLSzBeXVZB2gaIOuErq66QFaxhHQ3MP409MYYTNF/0nGeRV
         OhykdWqRGSOw1dh4qsVrR/ZBt1rJlvqjY7gRs1p4iOTr2PmVPWtkWayAPxx4U47xzKtl
         k9QHdxPYNJvDOuXq/OKhWf61JkLxDBxhB1/fn1JRDGFB6nF+zJlz5bVrP6XJrZKo/K1Q
         fjsR1+KEC9DkvopCvfs3sr/RyJDxeESAvQ/3IRsr77vyUKPAG58+HYwylIJrTNcyraDW
         ToW3XsrFFRXMx0AbYfR/LOcPRJQdKq+LhYW/MUxgZD4YULNcx0MGBnBC4wMCz2onDUqY
         86yA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+u0bOvUFlxYebMJZIhKp50jED9gTRJ+AB/ACtJZO3YeVhHOSr
	G9tX/aqKlHGiMy0zNISKHHn5rfaBxvoAW+Y4siOwlviEAT05XbCaSqIsNo9Z9n9GKMrG0CxaZfj
	AVq5o/iqecSfOG0fLZ2TPaYFSJSY+lYdviyV0om5gYRpvpp3nGYuvEy3YjmlXswp5UQ==
X-Received: by 2002:a0c:d1a6:: with SMTP id e35mr4554436qvh.174.1553047724400;
        Tue, 19 Mar 2019 19:08:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwDBXq1Uf/WxdcjAFnN8SivtSd74bfDeDtOQCkFcnzhhmSmtaaklFSgn2f2AasG1Te/P/Zn
X-Received: by 2002:a0c:d1a6:: with SMTP id e35mr4554398qvh.174.1553047723462;
        Tue, 19 Mar 2019 19:08:43 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047723; cv=none;
        d=google.com; s=arc-20160816;
        b=t1+7X0GR/dMyy6YlwQUxrrw40cUeeJWhGCAxPSwDtLzpW71+K7x/Kg+stTy0T8qA3L
         Q+XPnfR03kGj6BsddO3N6X6TPkIP6YDdDW2SjOGZK0qHnxrGMYPJM6y6Hy1JU700nnt9
         DaMCcLt0RI5UXmGNi0BIS2oQaLDSas0nHAPZAjoP9FW/UytPVv1ZimwmYPNFdx0KHjRJ
         YCVkIyTbyC3ypxJSNM606sxva/Y+/3zqWnuxRhCJ3XpXCRLxnDL4OyScKogDq5DPEuSa
         5enUxXlIqXK0TdmjM5Gc/gB6Jah8OQolyRMOuoiZSzSJPc3+Rp9pgMVq0gsBcaWovTXu
         HNIA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=hoTZlblJA2VeYKo/mEcOKhsmwUWo5+51FludXN2P/8E=;
        b=lt9yrxIf1AXgPgU4RgiB/WOmJNlbiU8h33B7iTsAzagdW+0CzUpJbpoGcdKRRidnv4
         ok8A2A4WrHjdBnshP1j7NRa6/WvoPhk484/NsJxY9Adib2Xl9mAbwUD8RjRN+iSB5bAB
         qsy8rptZGeq/e71fLqQMRVfUhRAobb2U3/vbnbt2bi9ypZyML6cllYGMGyqPw5Oi0WuB
         7KCGs4svw92RaIj2e8ewYQJCoLz1IyMEL2aL2vbwnqGHtgxvMoRkhLqsHOy2O5hLJiLp
         VIXaY2TLslXORdSaCGQxm/Dt/oylk0D96eUrXWG/5/LAjETXwyRYL28LPUy6suzs9Kfi
         mmbg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z34si253989qve.168.2019.03.19.19.08.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:08:43 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 9ABD13086205;
	Wed, 20 Mar 2019 02:08:42 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2B6F06058F;
	Wed, 20 Mar 2019 02:08:32 +0000 (UTC)
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
Subject: [PATCH v3 13/28] mm: export wp_page_copy()
Date: Wed, 20 Mar 2019 10:06:27 +0800
Message-Id: <20190320020642.4000-14-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 20 Mar 2019 02:08:42 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Export this function for usages outside page fault handlers.

Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index b39efe5ca7f6..00b040e0358d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -441,6 +441,8 @@ struct vm_fault {
 					 */
 };
 
+vm_fault_t wp_page_copy(struct vm_fault *vmf);
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
diff --git a/mm/memory.c b/mm/memory.c
index 50c2990648ab..e7a4b9650225 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2239,7 +2239,7 @@ static inline void wp_page_reuse(struct vm_fault *vmf)
  *   held to the old page, as well as updating the rmap.
  * - In any case, unlock the PTL and drop the reference we took to the old page.
  */
-static vm_fault_t wp_page_copy(struct vm_fault *vmf)
+vm_fault_t wp_page_copy(struct vm_fault *vmf)
 {
 	struct vm_area_struct *vma = vmf->vma;
 	struct mm_struct *mm = vma->vm_mm;
-- 
2.17.1

