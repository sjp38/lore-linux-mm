Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 599EDC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20B4D206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:54:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20B4D206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE946B0273; Fri, 26 Apr 2019 00:54:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9D3F6B0274; Fri, 26 Apr 2019 00:54:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9B5206B0275; Fri, 26 Apr 2019 00:54:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7B1146B0273
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:54:00 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id e31so1907356qtb.0
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:54:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=HQXeCDuaeEzp5u9iQHCKOJfnvV1Ev3VBPvZheWkVmck=;
        b=W8C1byNmqEHqkiyaEvnxQ2DgroUBIH2psOIlS/WxzREvTtW+aeyQzujwPfkS4/ptZd
         oY4iGWDGcgVwuwMPQwAQpB5rvzrpp9DEqQwlMPSntRK6+5v62KDFCWULPXx+tettrw2t
         GTYdPK8T3kJRHxGB3CVKK2I5gzmkWf+JPwIAsV+t62yghUHyPD88ca9xlCPQhBU6h4ZZ
         b3b29hjgHIffUXeA8eECR7SJAqrpQABuoJowyt5v2BsPFOiSuDI0gP0y98ZRNSKBpNDW
         56rZviURBtUlaVKT76XS5npuDTHNJOtG7R02zhtigUGPoI5ONJ4wolKwHXOjXSI81M69
         3lTg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU3B9xvpMEuBboXqDmLr44xKIOHg5dU8RKEnfJUrhLISIWx2vpH
	XwthjsRi7Z+Fp/L0ON1b17rjudXNSlGscQp6ReQbfMDbfU7DQELOqBwZoBdOnOz/7F1HDaQRIlT
	pDxxZ6NpHu+3il4gzy8cU8a+xjM9TL7DrlzZQgx+zi1uAFFMdsDgwMQcI53rfaQBe4A==
X-Received: by 2002:a37:6c81:: with SMTP id h123mr30706337qkc.201.1556254440302;
        Thu, 25 Apr 2019 21:54:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwPHq+TczNZJ2n/k9L16tlHidboIo2vXq62Z2bxKNcSJDi9xUXF0D35SRDtl7QIyC40pnPs
X-Received: by 2002:a37:6c81:: with SMTP id h123mr30706312qkc.201.1556254439744;
        Thu, 25 Apr 2019 21:53:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254439; cv=none;
        d=google.com; s=arc-20160816;
        b=ATaFUszANtEJ9Hx4SdWU4ohCUCLm2QkEpRhtWnAVpfJyY2fFUb26yTvshiuhYC2Awt
         o24O38yoayjmgxcWVnJWVEgYzy7vR2gJP2ow3Y+Ko6024R3xeIlLN445h3ud1XVteoXS
         aNMHKWKk0nHdm5qozBtVVhQCXw7BiGFBERtzJIrf/sCukCHoYQ9W0Bt+JbqSKJ7qjYHu
         mafxzCY7csFlUM+SwfN9xwOVvoj4jpozCv6bk+n/IoktsejQlbxD+JwxsTplxaxILNKT
         +11B0m3Tx9IaiEXqvucKG2Myk4N613kw2Ur5ORpLI/GmGjuypf7ZY4CnpdcHiSZzT/50
         OAjA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=HQXeCDuaeEzp5u9iQHCKOJfnvV1Ev3VBPvZheWkVmck=;
        b=okj3LjO1/UpQb1VOFa79fg39/Dp0NKbrlghlCrWo5PZQwB94KCvDM5+Bqdyr5xIpLz
         w0mu7eIhduvm6Uv2tNzsCKbqVSBvASq8GCWwk5lsiXIeKjDe7jbWYLfNjjdH9zVXPOer
         LDjX9q87MUM/jUffplS2L9AlQHSHLgcMIUDuopC2vdn3sPALGhMqRVaZp3fAxodmPg+k
         DZsZna9ZYt0fSHjcKpL7l+A4Km0gytDi+R3uEF+5vtHzemWOAUezUW5wQZTyEu4Xm6jT
         4rjluKpRlJdLI27PcGR0VGgkPOtVxWsw69YDrNk6e0Si8XTUcf9QeOOyLCf+qcWooMMj
         8uGA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si2422391qte.277.2019.04.25.21.53.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:53:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E5C3781E16;
	Fri, 26 Apr 2019 04:53:58 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 0B738194A0;
	Fri, 26 Apr 2019 04:53:47 +0000 (UTC)
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
Subject: [PATCH v4 13/27] mm: introduce do_wp_page_cont()
Date: Fri, 26 Apr 2019 12:51:37 +0800
Message-Id: <20190426045151.19556-14-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Fri, 26 Apr 2019 04:53:59 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The userfaultfd handling in do_wp_page() is very special comparing to
the rest of the function because it only postpones the real handling
of the page fault to the userspace program.  Isolate the handling part
of do_wp_page() into a new function called do_wp_page_cont() so that
we can use it somewhere else when resolving the userfault page fault.

Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/mm.h | 2 ++
 mm/memory.c        | 8 ++++++++
 2 files changed, 10 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index a5ac81188523..a2911de04cdd 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -445,6 +445,8 @@ struct vm_fault {
 					 */
 };
 
+vm_fault_t do_wp_page_cont(struct vm_fault *vmf);
+
 /* page entry size for vm->huge_fault() */
 enum page_entry_size {
 	PE_SIZE_PTE = 0,
diff --git a/mm/memory.c b/mm/memory.c
index 64bd8075f054..ab98a1eb4702 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2497,6 +2497,14 @@ static vm_fault_t do_wp_page(struct vm_fault *vmf)
 		return handle_userfault(vmf, VM_UFFD_WP);
 	}
 
+	return do_wp_page_cont(vmf);
+}
+
+vm_fault_t do_wp_page_cont(struct vm_fault *vmf)
+	__releases(vmf->ptl)
+{
+	struct vm_area_struct *vma = vmf->vma;
+
 	vmf->page = vm_normal_page(vma, vmf->address, vmf->orig_pte);
 	if (!vmf->page) {
 		/*
-- 
2.17.1

