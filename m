Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 399B2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB6E521773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:01:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB6E521773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 958898E01AE; Mon, 11 Feb 2019 22:01:17 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8E0068E000E; Mon, 11 Feb 2019 22:01:17 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7A8BC8E01AE; Mon, 11 Feb 2019 22:01:17 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4B7868E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:01:17 -0500 (EST)
Received: by mail-qt1-f197.google.com with SMTP id 43so1266795qtz.8
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:01:17 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=4SS/tii+Fgf7IamftibaxkkOaBEJw8ULTu3fmYKLaOU=;
        b=bofE9rEz1S7I16gvoxoKCL9XSXHf1WTbCC0dreDQ0Li8pPxBesBy18iwOZ15ud7ccD
         DJfYzRLUosbEbr/hnRpqR/je5AV+Ag+nKcMFkakH+Db7B48St/sytVzSECRN0DFDhNHN
         TTAoEI5eWAtOe3DgA6M/0n94x//X6ZAxknxQPXEz7lZ5uu+XtEVVbwFEyxvnQ7IyLaL1
         awqNaMt8ktFzpQD64wREcxAiqkp8P7fJ15PX7i4FH+0FJR792FzXfgmW3dERiysXK7RL
         Dkchwumg+EBY6yzbAXL8O0i4PJvdK8RVmjTUC+0R6OOEqGh66cguaVrihI5NhoM4y32u
         1aAA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAubTOTTHlgPkvAJqZFf6CKjRufl0onxZY5gKhjYernveseCBh5an
	eThi4YQsK2kx3WrCo6sNFVj3n0C8ivLjhKhcvS4Hskbz7PR/AiRn+q44rONwQ0phgkjrtRLgwim
	T0jr+diyZCB5Fm068y8MPFiaymILa1HQKlNg3G4uJgoC5UPHUuZD/GBFxzoso8UYnVw==
X-Received: by 2002:a0c:c966:: with SMTP id v35mr1071620qvj.116.1549940477088;
        Mon, 11 Feb 2019 19:01:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYJveBrBLxN5VkGySu6NJEd1vIxtdHAI+TcM4FN1a4UumUQPQgdfDOmDg1fp2QjNVPTmUeS
X-Received: by 2002:a0c:c966:: with SMTP id v35mr1071598qvj.116.1549940476558;
        Mon, 11 Feb 2019 19:01:16 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940476; cv=none;
        d=google.com; s=arc-20160816;
        b=vpmncx3Xgd+Q3xJQNQdixalQwUwA1b35RuSHGOXqkUnxbXmpwe0lsNVstDHfYGp8DM
         PgNJkqc8USHZtuNGgHmXMO4MmNcvd1BV0rkcWQTbddGYw0SZ2EfMTTouq63Q3n/KgE/W
         YXGgsvMlz+RNAZV6fypNgw04xkX0YGTLSHdTcfXr2bTGfg9vYG3SyY6b0S1G95R/DgiX
         yaF5fAk8ft+QkIMJ2bx5VxOwEq2ETyWr2o80fgS6KsE9d5BZUScGLNis5JlerqVazlU+
         ZrYriDEr8yXDdciHG3NHzy78fTrVmDfIzlfdPS+as8FhvjAdXXQy+TiSG7oejrH2sVdn
         n6JA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=4SS/tii+Fgf7IamftibaxkkOaBEJw8ULTu3fmYKLaOU=;
        b=MvnzgRhhm5DbqFXnod7cLUIGL+9xaogUsN2CiPhx6QdhgaxUnslzOIegsl394cQlMX
         RO0uuwO8yn7BPmWDuFKO7ckDCjDOT4NKLYXQpi7osKYbh78NhYZILeuUE8s57V4nBfAl
         hknqr22tF9e1PnPki0ZEY5sHI4ktDHNHWFa45e1zTdUiSKTOeMAGlDEpVSf6T914xmp3
         Io2nW8pFYCOBl0ZvjmCSGiA0pnG9HbLsVfrwTrOCB438AD9/f54g3FKhWmG461p58Ulu
         5eBV7FWCZO+sB8a30R8cGxjxFRjSK2u1/K/y7UfZr9Smef1J/MbqSNPh6QSyk+AQ5x3P
         oUMg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b1si862802qtr.173.2019.02.11.19.01.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:01:16 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3B9B780F75;
	Tue, 12 Feb 2019 03:01:15 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id CBA2A600C6;
	Tue, 12 Feb 2019 03:01:02 +0000 (UTC)
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
Subject: [PATCH v2 24/26] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP documentation update
Date: Tue, 12 Feb 2019 10:56:30 +0800
Message-Id: <20190212025632.28946-25-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Tue, 12 Feb 2019 03:01:15 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Martin Cracauer <cracauer@cons.org>

Adds documentation about the write protection support.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
[peterx: rewrite in rst format; fixups here and there]
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

