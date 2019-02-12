Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C5944C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8D4F321773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 02:57:22 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8D4F321773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 22E558E017F; Mon, 11 Feb 2019 21:57:22 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DF058E000E; Mon, 11 Feb 2019 21:57:22 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0CD818E017F; Mon, 11 Feb 2019 21:57:22 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id D754F8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 21:57:21 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id b187so14443017qkf.3
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 18:57:21 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=ZLIE1+oU+vsDu0BxwTOfDTXs0UuTA0Eh09kMZGyxmIM=;
        b=B2vt9Yq0XoDEfMeemUI+um9AeAqycN+ikJRcK4eX/PtnmqYagKGlifLJWuV2D+GtWF
         poIS4XMUAUEamMhxqnpJDBeNbrF6/UXjCfpMluLlQwxneICntcDwKOqKSrKdPoxYhFBn
         OQc0w8U+CrLkUQMGT+LdTFtSF+i5I4hBhoglCv/RWdaYEDo0ySw8GdmYVwFl1dd8/Prt
         rCoopQy8ugj2morGkxwD0xiJVF/zhLNoIvprqbpsmf7B5sHwn9U1aHaJaEs2euMCqWQJ
         gdsBeL5+cb5nivMvXhaz4Y9ltStbL5SbrNG6VvuSm1cK7/gpSM/bhAgx/Xh/lsmmlEMI
         En9g==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZ/R/IZo3jho/PzYEnjZdqFGJhp3IEtMFeYP7VBzMVlwAf62VV3
	MPkmS7sCDMZpcT1vrIOfs9+Z7k1Qyf3tju6BuOCiwbDQ8by9iDwgAxlY1vr9+zWmODbrwMmQaB7
	g0vGdfs5a0c7eoihPigujuJL3zEGstd/dlBWLlDTFUBfdCMLiU91a7+1FfoagkY+jAg==
X-Received: by 2002:ae9:ec0a:: with SMTP id h10mr1037260qkg.22.1549940241651;
        Mon, 11 Feb 2019 18:57:21 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZ0zHF0UIeW8Dk16HqVkk8XkybYv2OpkjdNw9Ux4NR4Rwj5Sb94yEHvtne2q91ots/vDanN
X-Received: by 2002:ae9:ec0a:: with SMTP id h10mr1037239qkg.22.1549940241058;
        Mon, 11 Feb 2019 18:57:21 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940241; cv=none;
        d=google.com; s=arc-20160816;
        b=Y8bugUCz9KIwwpAOF2YCkZNKqg/MjS/MnZuoh2NXu978vbORul+3ZG0AD5xpk0ia0G
         p9C4ljqM+4FLEkhrbQyFC/+TLsRsgqVDwUs7ljem4KXFDxyYsZpR/43S6n0O6wmuwrtT
         uPvcdK/UkH2V/tyP5JB5tpkkT+pVIjNTaX6Z9+sesYHO/rvo1tLwzniCptxzTHe/P1Ab
         /NuwGMSmKUuSPJeI4K0IF5go+Oke6WH3cPqj5DCKISpWSnQpr5G0ciMKxdwSDqDy9zrE
         kr7jznMd32rwgcGeKp5ChS/ktV7K2olxRfpgte7ykOYDhFFtbVtFgtgz3VXxZ+SlfDSp
         VX0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=ZLIE1+oU+vsDu0BxwTOfDTXs0UuTA0Eh09kMZGyxmIM=;
        b=VHr4ZKtyJTBSujgEH+cxB/0V5LFAO1k+I3ZLeSBtfnXs8kq0t3MZ/2BfXCdkiKeyrW
         HuDzcRDqju8sNj1VG7wceFHZBN9C+xQGrzgK14x9QJYQZOmGpOWhRFzr4zA4uYGGhVsa
         lrcU8+actKNPD9ZitHPilAa+T+/ZAZzQjsXCh2/Sq+pAFIGch3vXmjcNxiVBo8XvSC8d
         wwSYNhT8Th1kKwwJ+NRFi1BxEBRczCZHwruh21n+MbOMQQuamteY+rjYKgCGhVxBaji1
         I+Eh3iw3ih6BIJjpGJfXtQrR5o6nyJM+oKr4QVvZAHOoemk3jp0me6ajMn7+qdrNMoDZ
         8ZUw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k3si1066083qkc.157.2019.02.11.18.57.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 18:57:21 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1CD7381DEB;
	Tue, 12 Feb 2019 02:57:20 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id A0579600CC;
	Tue, 12 Feb 2019 02:57:07 +0000 (UTC)
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
Subject: [PATCH v2 03/26] userfaultfd: don't retake mmap_sem to emulate NOPAGE
Date: Tue, 12 Feb 2019 10:56:09 +0800
Message-Id: <20190212025632.28946-4-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Tue, 12 Feb 2019 02:57:20 +0000 (UTC)
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

