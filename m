Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3E56CC48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 04D6B2084A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:21:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 04D6B2084A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A0CA56B0007; Wed, 19 Jun 2019 22:21:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9BE788E0002; Wed, 19 Jun 2019 22:21:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8ABFB8E0001; Wed, 19 Jun 2019 22:21:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67FDB6B0007
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:21:06 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id h47so1639023qtc.20
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:21:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YUbZDsKt/IT4N2Y9eylDmgPpHsIMfaDKW5AWYk9iEhQ=;
        b=fz7ncKLyEfe6MtOVtw1oHrTpbUqKuHmm6kvHdwcXRCX+tKiihBv5ZfD7R62QYeibyA
         g9BaVm4jTcbS8TYGRxqZP7gFi3ECyKm0KGgOBWBzwiOHAA5PIYewRKuJwt3+b5m3RBmH
         WVx3r2EHvrcZIwHaFZIE/s+Gjs/T5hun/Xzur7xZfqfvtBLVVDCDKRXQzrWgI0pHNNi7
         quokhKg5dq0uGbsQzxVDR3FE5qelk4+CRenDyhXYNV4TygTB7Acq+7+PcqfHeDL9rEbE
         b94YY57VhPEjW4TcxSBp/o1K4IGJeEIk2hTm0egEm61qecyIoxLMSFeDp7aslFNIsVmg
         qIXQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUV2LiNCIq4JEDvhJ94ZWEFyNiDpxrs/mQAMdP2P1v5kn2Ao5P2
	WdhHcYonX2FBKhnpPSOj9CPoNhLR+frfEWPhkDS3bkOCG5VHRm2p8Ibx2cH3+PeUMBeBgUoaTNI
	8EYpJmVC45mFVJwf+adfOkt/iMloH5DRebbMxMHDRqOE4o6tn8bXmsb0q0Tlyvut8Pg==
X-Received: by 2002:a37:9d04:: with SMTP id g4mr101417887qke.52.1560997266211;
        Wed, 19 Jun 2019 19:21:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7M4Wn0nOsbzBdFOGWdg95IRC54D+KVObgeGr5fZV1dELTi3f43wNMyxmtWMvYA9JDFahU
X-Received: by 2002:a37:9d04:: with SMTP id g4mr101417799qke.52.1560997264964;
        Wed, 19 Jun 2019 19:21:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997264; cv=none;
        d=google.com; s=arc-20160816;
        b=AvOO2gOUwBCaNEAn4uMvNxnIJpcjSYgdgvDM5dm1DbcrtybyhnkZ0wFK8FA+ibz+rl
         SZ/s8/Ed1WLSzrWrrKdZXdHuAqC/N7v3tNEce3VLidFydeKNoPLR6+HzrmyNRbBbNPcD
         lRotRqUoQN4St9bt2XYTqz8hHktHmCq8e6w4ZkZoyBWSf3w48Qeo4B4OlJhJfqK9szj5
         vDCRh2F0POeZmqhe2sAH6FtAW7tqp1QHKmhXvb91sVf1IcmDOPPTFHbikYay9EUeQ+RP
         nth/HxAB6IqUf+aA/GmvFF7jaZOcQ68NdSwowL4s5+JYsxHLeOXuKEJ4rUYJA7k8HtnC
         +iRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=YUbZDsKt/IT4N2Y9eylDmgPpHsIMfaDKW5AWYk9iEhQ=;
        b=javPb3ZacobatAgpyb6quOKUWzowNMXnqQQWpszJjkWp8xY8xfZYgQyWlUJIPkTg/D
         93rCl/aU+Y2c/kHGA5bps1MokNxragR8Y+oiiePHAzYWRaNnSiOoU3sI2Ze2ypEHAfD1
         EgIsB9gm4IjXi98VKkc+/mnnk4EN9LPIiLb4VgeGbd4TZOEe8sXYpJIEk1SFj05kaaS1
         fl8cIGsTSMqsTyCcqoK7I31w9w9bFXKghvst1QyswH9PSL1KAsY/l6fZIEsY3OjRKK0J
         9yaG8uzgGGiazfXGq7JhsRh3JFgpz8H3QJsHom+7rxmpMTZOw5XW/5ocYAGwFLhoOjFN
         IRZg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id l197si13630397qke.198.2019.06.19.19.21.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:21:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 02FDC356FE;
	Thu, 20 Jun 2019 02:21:04 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 24BC41001E69;
	Thu, 20 Jun 2019 02:20:55 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [PATCH v5 03/25] userfaultfd: don't retake mmap_sem to emulate NOPAGE
Date: Thu, 20 Jun 2019 10:19:46 +0800
Message-Id: <20190620022008.19172-4-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.30]); Thu, 20 Jun 2019 02:21:04 +0000 (UTC)
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
index 3b30301c90ec..5dbef45ecbf5 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -516,30 +516,6 @@ vm_fault_t handle_userfault(struct vm_fault *vmf, unsigned long reason)
 
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
2.21.0

