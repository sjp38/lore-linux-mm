Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6D76C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 90FBE217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 90FBE217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A2BB6B000D; Tue, 19 Mar 2019 22:07:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 351AE6B000E; Tue, 19 Mar 2019 22:07:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2411C6B0010; Tue, 19 Mar 2019 22:07:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 059616B000D
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:45 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id f89so925458qtb.4
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=e0fxVMddmA9GXiTtSfkbRCEUFj7blRCWENdC7N/YeF0=;
        b=VRPrboQ5g1/Bg8DD/GTUy8MgkI4N8Z90W1gF2gLT6VruO6JBl6mW7HJDpqlE2cgJNZ
         fE3XpV62EzvZy/0q2mlrm3/HBY8zrrn8oTs7IPCc44xC8twnuIDFYc0h3V7a+rYIL2Pt
         ySEgzZRLWi4DXmMBGePQ5JUVE1R96AlHArZZ5ngImq1qDOa5H8S4CDdGRBsf/gG0HQei
         2VADCmyKGptIboSPhPxxCXlsdbr6PZYEEAwyX+WiKzFoUONBwnnp56UTi4XwIBPCUQe0
         /0qXukq08gJgxZgvetZja8iJNOINMtviJEe0zbILMzvb7Xb1dsdNFtZkIC/gsEVjJ4se
         aj3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVEm7JaNpqBcxuznI9HUcjXuvRC6us2tBX+Tk8z23MUWAIa1G3V
	IWwSapj8ZgJTaBSfSj8LOpIlXiQJNyAYU3MW9YaydWBWAnRAiyAL7uFSGS3lEfDi+wJW9G4mM8s
	YPbO5U08iP06QrasXI55rnmIHpiihjm4ordwCZrqcd5HNs+3XIgOfdcNuke7jcmawsA==
X-Received: by 2002:a37:a390:: with SMTP id m138mr4392184qke.72.1553047664812;
        Tue, 19 Mar 2019 19:07:44 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwbIYfh+P8hCcfjYcY3pSWrvMsTj7e0WzG1k27zz4YXZQB/UHYFu3SLugfYYv4wpRTYqB+0
X-Received: by 2002:a37:a390:: with SMTP id m138mr4392153qke.72.1553047664182;
        Tue, 19 Mar 2019 19:07:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047664; cv=none;
        d=google.com; s=arc-20160816;
        b=HesJaUVrsek7MNAmadahD36AxH79meFBk3NGL51VXdg6yu3lZxDHIjvsCXc2liAPTs
         C5BeNJ/eEEMBVJPd5zFWTc5kk/y0BxtWGnBKdgEIC+yj8tWH0JNuR66mXurN2/wwb9Rv
         FdFFYGbCIgZoQGPYPbPJSD8xoGk6QBskaAZFeVH2xyCd+hOXx1CQZ8kCnYwpMZzN4WCe
         7NhynWITNB1xH1vGOqoTbW66A50auxa+IdQ1yPcfRuWNaePXivr+HlYWhV3+Ok3QQzrv
         nL+2AjEC/cK03q8WnQ+vxSiyyerbjrbF4jDqkrO4dCx8F8Br9zwpgpdKDwu7WrrC7Wse
         XQeQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=e0fxVMddmA9GXiTtSfkbRCEUFj7blRCWENdC7N/YeF0=;
        b=Qs8YQMsqx6iGivonCvfjNoQRmE+CAB0xTeA9hl3Gf8H22FCjTRg6IUQm10sy2wQYH6
         H+GedH5zgZAgHJ7bJS8awDf5e0zRDfeyD2B50QoFvXBph4lJh6A0srpii8OOLSKm+vQE
         ol7lpc15md8bF0+XmoQJHrEfvsBkQ13LmjE+ZUaRcw+2H0GON37Kg2awGdH/yBIlV9Fl
         rnyaFXeDQLlUMu4ij8/1/BkRO070bXazKsyUip+aZdKnycuzc9ZfcDXMMBNnsOj3S64e
         F67UCjt7+v+UQAOjLCIqcTVkB+NIorZChWkh1FXfoCdWeGM5DTnVTH/mRTBHbQPgbdLv
         dp9w==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f50si448830qte.34.2019.03.19.19.07.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 43696859FE;
	Wed, 20 Mar 2019 02:07:43 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BD7476014E;
	Wed, 20 Mar 2019 02:07:32 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v3 06/28] userfaultfd: wp: add helper for writeprotect check
Date: Wed, 20 Mar 2019 10:06:20 +0800
Message-Id: <20190320020642.4000-7-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.26]); Wed, 20 Mar 2019 02:07:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shaohua Li <shli@fb.com>

add helper for writeprotect check. Will use it later.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/linux/userfaultfd_k.h | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 37c9eba75c98..38f748e7186e 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -50,6 +50,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return vma->vm_flags & VM_UFFD_MISSING;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return vma->vm_flags & VM_UFFD_WP;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return vma->vm_flags & (VM_UFFD_MISSING | VM_UFFD_WP);
@@ -94,6 +99,11 @@ static inline bool userfaultfd_missing(struct vm_area_struct *vma)
 	return false;
 }
 
+static inline bool userfaultfd_wp(struct vm_area_struct *vma)
+{
+	return false;
+}
+
 static inline bool userfaultfd_armed(struct vm_area_struct *vma)
 {
 	return false;
-- 
2.17.1

