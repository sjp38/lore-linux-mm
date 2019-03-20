Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7E480C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34648217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:07:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34648217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D671B6B0008; Tue, 19 Mar 2019 22:07:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D167D6B000A; Tue, 19 Mar 2019 22:07:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C06B86B000C; Tue, 19 Mar 2019 22:07:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id A341A6B0008
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:07:19 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id 23so19463475qkl.16
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:07:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vKNT6GfdSA2RaFRR5Rx6tafrEcvehh1DQki77hDcefA=;
        b=AZQ9tLWSwKkQwwfF9nEQvGRqmkwK/uhtCTYznYNsAX07Iu/J1OhTiCJOzCB3kb9kVV
         SUVPXVtPKqhvlyfiMtSPft1cLV/S8q+JNoNhyz/DSQ+rXy7ib94qvz9v0AWteL0v59gL
         Dqpu1ccd3K+tPfuuuBKp60hV0EB0KDvAGVKfx5bqLenKEhWmY1i4lGz2dSlpb5RW5eIw
         qG5gzy8Exh4/ubzEErf28Rl4T933ou8dz4N0P3jk4m47V8ULOqqEGSrx1daqTC5PU/tS
         IPulAQ5qzhSrBjlNS597bVtoAzOvTn9qHVYCHqD5t117JfB33zIai1no+LV+EUNWIfvV
         zrgA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUgMmQxZG/YBNj8YkNvPog3yKjXbrAxRKiOgpGv766CE/sDzmdh
	tmrVSvBNZq0d+nu9XL8bZFei/WRm1JxjjIhIBd/NncgogSaIRD48rLrFkIpibIDMIHkWu6nu1fh
	rf0oLssSn8711a/Rn6o6OLHnB4xWMFIhLn00tHAIv1XnTAr41ObOqwlbb4FKZxf1ezQ==
X-Received: by 2002:ae9:c314:: with SMTP id n20mr4589240qkg.191.1553047639392;
        Tue, 19 Mar 2019 19:07:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwd5GPx3FBznlbZ6k8DP080MQr8Y90gAdRvn3aqZhhEzH1EJSm+mqnnaUgHFz9/NbCxL7Ir
X-Received: by 2002:ae9:c314:: with SMTP id n20mr4589198qkg.191.1553047638649;
        Tue, 19 Mar 2019 19:07:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047638; cv=none;
        d=google.com; s=arc-20160816;
        b=QiVtEfIhBEh7OkMMlwTtTe9qXIkQSTpm7mh9Vxd6zE713z8XIl4cdz0ZTFOQr0VUwA
         TdluMV8U+owd1dR+ph7sxYM7wSNttbFiC4uh9XYUoq9+UsLJ3kCtKzCFacWFlCyRpEcY
         /EJTA3nmI5uNMW6JODbplzDPz8G1d9hh4j2JvP74DGeByBbaZ7blHJCtH/oNJShyrFEm
         l7oGQ/4oPeUVdmdCrsQ1snrMog1NYwLa9CA8TG9JazgrdX3x/CJIzDhScnfR0dPlVj/U
         1ZYmSFeooAto5r0whbTxOv5kCP8FwrYl/7YYVCnzT3AZ3A5s2wmgTsN3pwb4SVXwY/RF
         8kMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vKNT6GfdSA2RaFRR5Rx6tafrEcvehh1DQki77hDcefA=;
        b=QwecyyGnPjmno1RDPXrWBfSXoUC2oVqVwjSFG66CwwG/GwLEurjdAeBujjnJW7TZ4j
         V4kyILIxG337SkVq1L+U1TPVtyC/3CU4vbImZOe0Ddo7Gv4lYCSAEQquhNa7aHrEmHwx
         Sjrc804ZZHs6gINCXulx8EfY8zf1Im9HqItdcfobJ1JwRHfNcfgwpLXZp+G/4vFs4492
         Uly1dfeCTMGbZ9SM7BmV01tooo/kmJSwIOZ/NdLyVdgXXdScCBB0bLALTbqCb/XWtl0O
         tDZk1J+d3Mg/M5QId4IjO4ReLr/fKgnGGdET0+S3up36WLxgbnt8VKHZBXGMX6QSt3hd
         9HMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h39si414549qth.201.2019.03.19.19.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:07:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 80AD83087934;
	Wed, 20 Mar 2019 02:07:17 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id B9EB16014C;
	Wed, 20 Mar 2019 02:07:09 +0000 (UTC)
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
Subject: [PATCH v3 03/28] userfaultfd: don't retake mmap_sem to emulate NOPAGE
Date: Wed, 20 Mar 2019 10:06:17 +0800
Message-Id: <20190320020642.4000-4-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Wed, 20 Mar 2019 02:07:17 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The idea comes from the upstream discussion between Linus and Andrea:

https://lkml.org/lkml/2017/10/30/560

A summary to the issue: there was a special path in handle_userfault()
in the past that we'll return a VM_FAULT_NOPAGE when we detected
non-fatal signals when waiting for userfault handling.  We did that by
reacquiring the mmap_sem before returning.  However that brings a risk
in that the vmas might have changed when we retake the mmap_sem and
even we could be holding an invalid vma structure.

This patch removes the risk path in handle_userfault() then we will be
sure that the callers of handle_mm_fault() will know that the VMAs
might have changed.  Meanwhile with previous patch we don't lose
responsiveness as well since the core mm code now can handle the
nonfatal userspace signals quickly even if we return VM_FAULT_RETRY.

Suggested-by: Andrea Arcangeli <aarcange@redhat.com>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 fs/userfaultfd.c | 24 ------------------------
 1 file changed, 24 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index 89800fc7dc9d..b397bc3b954d 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -514,30 +514,6 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 
 	__set_current_state(TASK_RUNNING);
 
-	if (return_to_userland) {
-		if (signal_pending(current) &&
-		    !fatal_signal_pending(current)) {
-			/*
-			 * If we got a SIGSTOP or SIGCONT and this is
-			 * a normal userland page fault, just let
-			 * userland return so the signal will be
-			 * handled and gdb debugging works.  The page
-			 * fault code immediately after we return from
-			 * this function is going to release the
-			 * mmap_sem and it's not depending on it
-			 * (unlike gup would if we were not to return
-			 * VM_FAULT_RETRY).
-			 *
-			 * If a fatal signal is pending we still take
-			 * the streamlined VM_FAULT_RETRY failure path
-			 * and there's no need to retake the mmap_sem
-			 * in such case.
-			 */
-			down_read(&mm->mmap_sem);
-			ret = VM_FAULT_NOPAGE;
-		}
-	}
-
 	/*
 	 * Here we race with the list_del; list_add in
 	 * userfaultfd_ctx_read(), however because we don't ever run
-- 
2.17.1

