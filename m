Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3CA90C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 051E0206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 051E0206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 940506B0288; Fri, 26 Apr 2019 00:55:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8EEAC6B028A; Fri, 26 Apr 2019 00:55:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DDBF6B028B; Fri, 26 Apr 2019 00:55:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5F06D6B0288
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:55:43 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id q28so1897085qtj.6
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:55:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=VaFnBBsHk80eRAT5JESA2qIabMvWOGHlSe7euPruE0Y=;
        b=tU0wVOicu9IwiOHOmeIYhMo3dF8BWfeHJ9Fq8PkWfI7Aa3KfGSXMXCTQgA04Ehfh+e
         jmwr2Pe+O4GwqetplLpE531Mnl003vH7Ake/JKNGHXxGxmHl6MUYsNwBZ4j2eYoiTWMo
         CBE26FuviUmn+hzrYx3nZ/7m6/OK+soij8IfyK01pZpDyAuKZFj2/N5KOhTJcmwP69Ja
         rYgOlvTPPvh5L8s8f6CpHeDePFfrEhODxGjI6yshkCS5XMi5ID71xwwiilvRHEuP8c7+
         0frgg2sAB0dFNJqIUVV2aGaF2YfBySf+UswzOIf/uGIpfPfBZDt4h+tJZhDMaXRfgJz1
         b4nQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWjkbTOrun9l5Rsu/dbW1/vVDky+Tfwrsn7F7nH3+0Cfi49t0XC
	+0lAGfuCoIVZKMKZYXpHmQ50fOlKJQpbTdUid5dj1op3p3uZVf66k9v/4/knPux8vA9IrHVPXxy
	envorgAkyKHJHiQoi6/+ynO8aZHO3JzOXTqjXXHEx+/rd/QVc8tRO6f68uGhAXtw48Q==
X-Received: by 2002:a0c:d1b4:: with SMTP id e49mr29183114qvh.87.1556254543177;
        Thu, 25 Apr 2019 21:55:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyh4foJy3nhOuTXpBxmxu9Dt20oLfWYuPH5AEEiUSz25ld0fUbWJEG3S4Mxz1YjgcRKXQYt
X-Received: by 2002:a0c:d1b4:: with SMTP id e49mr29183083qvh.87.1556254542525;
        Thu, 25 Apr 2019 21:55:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254542; cv=none;
        d=google.com; s=arc-20160816;
        b=Oi9STVYXPPrRK2sNU3q3zCh5FSeyYJnDEh9jjkINrIAjQBI60yOUpklR6KTVsg6MfJ
         hVgqTQjd91IfhPwkP339X7f4pvr+hyXVmJPd36koJE8TeBLgibZaVY3KV5cm0i9BKk6B
         TQZqICYX+Y+VnzzoIahrb0LPUjqTRAzem/5Xcfn2KzLP56Akz2YDavHuBuqN5Fd5kgsP
         dY6/4j7RBt07NH2yUINcBIRyY2TvhFCOTGRrnhY75OQrQFy7zx5gXSi2nYIYgij7T358
         N8pqnDpirlylDPbUWn9smF1en73tG81136TX0WZIzFm2/KCbkZSSyu1QgkNHMZc5K8XU
         NppA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=VaFnBBsHk80eRAT5JESA2qIabMvWOGHlSe7euPruE0Y=;
        b=AiJFjZHO+4QI+6Ou6f5mgYoswN1Vh+nxe+iawBEf6xJbu9J4ErtlnHOcDgmYFj1hDi
         JqgahtSSvds5TzQ+HH/VVRctNi6welDD9PMnOkL9ywVKGmcbR2z06u/rtVHDZfc2UVSq
         DHRa/cg+sr4yqaxXWC8vcXscZWuVgKQ05rtsA1se7DOSmi1MuGpq6JXiddEx1/kFiZ2x
         lYn115+4V5tf7BkImh24w5o16um9hFQ4cM4k2iZy9Z7s4dzReDxyAZo8Ci/uMtg4zZEs
         lojMMUg1LMkvgx/waaEsX4FwnWK6+gmQ5PeGBbi4q4/R/rvy0DUe4IwlEP1GjoYBJNhD
         ioMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 30si10756440qte.385.2019.04.25.21.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:55:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A9A953082B4D;
	Fri, 26 Apr 2019 04:55:41 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1B28F45AE;
	Fri, 26 Apr 2019 04:55:35 +0000 (UTC)
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
Subject: [PATCH v4 24/27] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP documentation update
Date: Fri, 26 Apr 2019 12:51:48 +0800
Message-Id: <20190426045151.19556-25-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Apr 2019 04:55:41 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Martin Cracauer <cracauer@cons.org>

Adds documentation about the write protection support.

Signed-off-by: Martin Cracauer <cracauer@cons.org>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx: rewrite in rst format; fixups here and there]
Reviewed-by: Jerome Glisse <jglisse@redhat.com>
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 Documentation/admin-guide/mm/userfaultfd.rst | 51 ++++++++++++++++++++
 1 file changed, 51 insertions(+)

diff --git a/Documentation/admin-guide/mm/userfaultfd.rst b/Documentation/admin-guide/mm/userfaultfd.rst
index 5048cf661a8a..c30176e67900 100644
--- a/Documentation/admin-guide/mm/userfaultfd.rst
+++ b/Documentation/admin-guide/mm/userfaultfd.rst
@@ -108,6 +108,57 @@ UFFDIO_COPY. They're atomic as in guaranteeing that nothing can see an
 half copied page since it'll keep userfaulting until the copy has
 finished.
 
+Notes:
+
+- If you requested UFFDIO_REGISTER_MODE_MISSING when registering then
+  you must provide some kind of page in your thread after reading from
+  the uffd.  You must provide either UFFDIO_COPY or UFFDIO_ZEROPAGE.
+  The normal behavior of the OS automatically providing a zero page on
+  an annonymous mmaping is not in place.
+
+- None of the page-delivering ioctls default to the range that you
+  registered with.  You must fill in all fields for the appropriate
+  ioctl struct including the range.
+
+- You get the address of the access that triggered the missing page
+  event out of a struct uffd_msg that you read in the thread from the
+  uffd.  You can supply as many pages as you want with UFFDIO_COPY or
+  UFFDIO_ZEROPAGE.  Keep in mind that unless you used DONTWAKE then
+  the first of any of those IOCTLs wakes up the faulting thread.
+
+- Be sure to test for all errors including (pollfd[0].revents &
+  POLLERR).  This can happen, e.g. when ranges supplied were
+  incorrect.
+
+Write Protect Notifications
+---------------------------
+
+This is equivalent to (but faster than) using mprotect and a SIGSEGV
+signal handler.
+
+Firstly you need to register a range with UFFDIO_REGISTER_MODE_WP.
+Instead of using mprotect(2) you use ioctl(uffd, UFFDIO_WRITEPROTECT,
+struct *uffdio_writeprotect) while mode = UFFDIO_WRITEPROTECT_MODE_WP
+in the struct passed in.  The range does not default to and does not
+have to be identical to the range you registered with.  You can write
+protect as many ranges as you like (inside the registered range).
+Then, in the thread reading from uffd the struct will have
+msg.arg.pagefault.flags & UFFD_PAGEFAULT_FLAG_WP set. Now you send
+ioctl(uffd, UFFDIO_WRITEPROTECT, struct *uffdio_writeprotect) again
+while pagefault.mode does not have UFFDIO_WRITEPROTECT_MODE_WP set.
+This wakes up the thread which will continue to run with writes. This
+allows you to do the bookkeeping about the write in the uffd reading
+thread before the ioctl.
+
+If you registered with both UFFDIO_REGISTER_MODE_MISSING and
+UFFDIO_REGISTER_MODE_WP then you need to think about the sequence in
+which you supply a page and undo write protect.  Note that there is a
+difference between writes into a WP area and into a !WP area.  The
+former will have UFFD_PAGEFAULT_FLAG_WP set, the latter
+UFFD_PAGEFAULT_FLAG_WRITE.  The latter did not fail on protection but
+you still need to supply a page when UFFDIO_REGISTER_MODE_MISSING was
+used.
+
 QEMU/KVM
 ========
 
-- 
2.17.1

