Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7180CC43219
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:52:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3AB4520656
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:52:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3AB4520656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D873E6B000C; Fri, 26 Apr 2019 00:52:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D37506B000D; Fri, 26 Apr 2019 00:52:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C26B66B000E; Fri, 26 Apr 2019 00:52:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id A3EE26B000C
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:52:33 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u66so1847799qkh.9
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:52:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=vKNT6GfdSA2RaFRR5Rx6tafrEcvehh1DQki77hDcefA=;
        b=K7qrCrNOFAAlg5J8Z8/SgEww+z3jp2+ybQFL4gr/PgkL2ak4QY0lMpODUNllxKGGxu
         oQ8Ry6rvjyxVdxpt9Oy3XdPKnTBU5dzrTTALD2DBG0ICQoTvXiPPaMnAQJKZfG/HaKWl
         7SEXgSEukUJnXgZUrG/8cdUmQABiqSRL419QWBMBCN0XGAfn+WWWpXB3VWpaIdmA9IQ2
         E+GGt9tlNkUBDjN1aazRhzZcuJtnrsRKHzUrTVDPS988C7+vl4349p05DoVOWnaHCxyf
         p5nnTxFtbmBeZNSE+A6ATn4xcd2d5KHz9zJImrkLrAjFJfN5S7qQhUcbnqZkMXNr23cE
         2uLg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWC/AJv/5vARCfii4taqUvasqWQhnKL+C78bMqBYRqtugN39KX9
	JXXlFRr6CZidcWSQI/om8tFZyOGkONVaGrwSiCYPQPBur7FRcAkNMTaq9ov1zg/08qa6ZXtkvb4
	k/l6tVqmS1FZJaPh5LSSeFESh3BdDuvp++yX615vpl1OrptEgmzP47up5iAKH3FlPMg==
X-Received: by 2002:a37:e119:: with SMTP id c25mr10607017qkm.75.1556254353440;
        Thu, 25 Apr 2019 21:52:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzldQgP8IQzyw1tWgp4He77GLfMOjGVlMA5aNOQnRT9md+DDPb+aCsWeEPLErOpUaoOyqL/
X-Received: by 2002:a37:e119:: with SMTP id c25mr10606982qkm.75.1556254352737;
        Thu, 25 Apr 2019 21:52:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254352; cv=none;
        d=google.com; s=arc-20160816;
        b=FUvsmF4F2T4XPSmZeweGg0xbGxJZXTxQF1h3LXtQgoHD/RgWj/4QLPs+D+FKox1bF1
         HzkiqWN0IQK+t46ko7S0T3/BcJVVee2Qb7AIm4guGCUm9cOqkHOU1J/UkZKOKSp14ocv
         3KzMpe1StXlWNlvayWkzJx+mzgaP8UdZeR526YnVdF5C6WPFRGW945R41FcjIG5uJHAU
         /Zyp80u0p/meU5kJFAPHYlfOze6PWwyA+HpThpmeml1DA6syUU8iRyGotHpd02lSlhtF
         aEWBMAPLESUVNFGWWjb/y32ElKhJTaN3oHtihClUqGocuY1D7qScSb6vlXtZOXxIwTBv
         og7w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=vKNT6GfdSA2RaFRR5Rx6tafrEcvehh1DQki77hDcefA=;
        b=Ze9XzA7UbXEP07DSSDekhtwiEWlGp0cf3W5suBMQWh/lyViBGOSTDKQmzztrvitlmB
         +/h3mJAnCJTJa0EhHzWMfhZdZ/KDcv5Ak77Rjbw//Qk59bCdcxzSIyOp5Y5k1+NmcdiP
         iEYlUuVCqox4vMFgHRHiYo0mrPze9Tpu43ctBknyKkkQwo5wAffHNC9Xv6uKJ6/kJ9g2
         RVbM1xfuMgVDcBFScMecOASNePUudHEj2hP0R+J8TcM5hhppGeJZjGNZ/VCNaWF24E9Q
         IH1brXTnH2Qsumz/RAmoEasfaZCQIFaXGTNoOT0bWqzQtc+vsnxFux4Vpxg5Xrx2vG1a
         fAsQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id o45si5188qta.395.2019.04.25.21.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:52:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id E1F71308A9E1;
	Fri, 26 Apr 2019 04:52:31 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 5407A18500;
	Fri, 26 Apr 2019 04:52:26 +0000 (UTC)
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
Subject: [PATCH v4 03/27] userfaultfd: don't retake mmap_sem to emulate NOPAGE
Date: Fri, 26 Apr 2019 12:51:27 +0800
Message-Id: <20190426045151.19556-4-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.41]); Fri, 26 Apr 2019 04:52:32 +0000 (UTC)
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

