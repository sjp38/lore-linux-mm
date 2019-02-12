Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BAFDC169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4A0D2084D
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:59:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4A0D2084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8BCBA8E01A6; Mon, 11 Feb 2019 21:59:09 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 86D0E8E000E; Mon, 11 Feb 2019 21:59:09 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 75D628E01A6; Mon, 11 Feb 2019 21:59:09 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 525EB8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:59:09 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id a11so3238876qkk.10
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:59:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=MibS+TtRueKTrLwoGYVp90wSttr+ZpLaqBjvkYtAgns=;
        b=uWXpFdLn+u7NrzGvIHGNd47BQ2GxWE7A/JQw3tIYhxvJrccZtG4yjGe/xSCawEhWVb
         MNIpOvlkjQgep2lzYUXcKnFXBytxlZKcJ70EJt6hIu+hfHu3UM+IbCrzK2olpPFskW1f
         Cd2THYDNHoagk38ukAAOyzjtyhTQGJaqESNRfcSI6az0fW/nwBDlGzn3Hx9/hHTqhTZS
         LRXgkd8jPVGIxvnKITohy4UgymohtRPE3rE3QwOQQL9fUjN9jSune+U7XCld0p+J7QXb
         dRVN5Cay5fayZtqx3LpALbzBQG9idEHzGEPpkg4zYO6YkPFQI0NdmmeMilSdnUZYj9Vj
         9HRQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAub3T6NxnyoiAaaAxiahH93RMrdAcpeJe4ccjx5ywZH7MGk0U40H
	0nAfRf31toTwyuyvr1a0Jy9w2hb5wAVLuIWhQgtpQ5p42v3NqQf86U8Mr+bMSG5tIUNpX/HOAUS
	17VvkcEMl+5xnppIBdo/UoTGz3b6nYMNjuLBAjCr+bhB/c56WOBEM51Pqvph792lIVw==
X-Received: by 2002:ac8:f0f:: with SMTP id e15mr1099170qtk.373.1549940349127;
        Mon, 11 Feb 2019 18:59:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZquKxtigZB3OJUyayzHtr0F4AODNldfIQq2Cod8SIbYKQNJ0eoDH/lfWwSTv5JeSIyDC3L
X-Received: by 2002:ac8:f0f:: with SMTP id e15mr1099153qtk.373.1549940348648;
        Mon, 11 Feb 2019 18:59:08 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940348; cv=none;
        d=google.com; s=arc-20160816;
        b=XNZ2nLWchoKgajTKtNqskgVrF/ii0xWU09Qn5niN81Oq+6D/ElY4/WLrHZteEFTlGq
         n27Gl8SbxvWUdgX5SLwQZwdI+hIBBxTovfv+UUL7/NdjLm6E8u3HCUefCTifwsv0gNdU
         exsP8yop29T7/toriIWOuaZHmNzcY3chPLj6vjlAfLHhDb7N722W0zTgHFEEw2mUbRas
         SVhiVtW/jJrmmNJSEhu+8pfSJkQhtI1ZPoIK7+pI/tXiTsnEzq3npDDEjQ5zWBK6TX2l
         wYNRmk2rnSNaSXz7rgzqJcrgLdUK8BivkTcZzmuyDFj0c2dUVhg782C13+gaeeH2gKNc
         6fdA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=MibS+TtRueKTrLwoGYVp90wSttr+ZpLaqBjvkYtAgns=;
        b=V87LoP+jNtJxrwYRQTf1F+QJ/fg9oK+2uMCyAkAm70e1rRo692dJA3L86XjGP+jRDW
         Naswm/exy6HGu5Ju4QMClkMrWOXnMxEpgOhE85v1oPYYzh+Y25XeH0Cqahg67MXnDo3L
         da2TKqvIrZkrDUG8btLDwOX8Eaau3hXH08Gjq7jBbd80y8wvQ0WorlUfVcAa7Xqt5beG
         Bbrwd3NDWesKCLiCUiN1k7N5RF4tQtLiU+k9/q8iQ16E39j5SCXspr3YWVpcnr6vaRph
         Bun0ezvR1oDYKYcIKl/qxdLkBIq4crxC+WVsWAxrc9jtW1jsCIdC48JQ25daNfFdh+Ho
         UnaQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o60si751185qte.262.2019.02.11.18.59.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:59:08 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id BCCB719CF29;
	Tue, 12 Feb 2019 02:59:07 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id E0969600C6;
	Tue, 12 Feb 2019 02:59:01 +0000 (UTC)
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
Subject: [PATCH v2 13/26] mm: export wp_page_copy()
Date: Tue, 12 Feb 2019 10:56:19 +0800
Message-Id: <20190212025632.28946-14-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.29]); Tue, 12 Feb 2019 02:59:07 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Export this function for usages outside page fault handlers.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 2 +-
 2 files changed, 3 insertions(+), 1 deletion(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index f38fbe9c8bc9..2fd14a62324b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -405,6 +405,8 @@ struct vm_fault {
 					 */
 };
 
+vm_fault_t wp_page_copy(struct vm_fault *vmf);
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
diff --git a/mm/memory.c b/mm/memory.c
index f8d83ae16eff..32d32b6e6339 100644
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

