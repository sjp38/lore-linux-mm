Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2377C48BE0
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:25:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C3EE72084B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 02:25:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3EE72084B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 612FE8E000D; Wed, 19 Jun 2019 22:25:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5C35A8E0001; Wed, 19 Jun 2019 22:25:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4D9A48E000D; Wed, 19 Jun 2019 22:25:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F2C98E0001
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 22:25:01 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id x10so1687378qti.11
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 19:25:01 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=6M5vIGHcsYBb3WCxHxaonQjlAK8kKdGHX+f4QKpk54A=;
        b=UJgvi3pVnpXgXDCGkVmT8cYrLOqXFpLKG9VwUckt3k122CnR4Ynd44cZhXE58rQXTV
         7OX8JdI1m+B/Hv1VI1/oazlcFT47+auCN1oXuCoCr7WxoorYrwr52t7Ydw7RIxvZI8yg
         iRCkZ86ENTzFgk9uDxs9vFmYVWTDRh8G+dGsHtY1SnVlzeYoHyEbPwsxoNLjcnEZR61B
         ooAAHJFn1IvYsVSfGJ3IhIG91UfuyZ1fFU2pNymNjKjubOtCVxQtLkNDfIyijkGF8u4u
         RlVgVs6r5tJEM5Ybx4n6f1R/fFUxNOXX0cPshz9RaYmDeEh8UjmDT3XykSeR3BlLWcPE
         FtpA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVH51vUg97LjhYzaRNGVSKzA0ejBPdP6KKWSWz9q/UlSyO8DUk/
	brRln75cuOn1agDq/fQPSr9+/xTAf2spOnEoIf5t1SYXjhgJfCKLxDKMImjXCbikmG0A6n+Di3g
	q51fv9xK5Ogpt7eejbPI/WF2/mE3bKsBbOpQbRJ/AK9sTLxkXDQfGQQXw2sGeY22V2g==
X-Received: by 2002:aed:3f1a:: with SMTP id p26mr108477513qtf.113.1560997500973;
        Wed, 19 Jun 2019 19:25:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzybsm4ikg3cAo40AsKI7jtqBoVnsDhZNQfXlL7pQW8YuMbRfFUKyjEnjpeogwio2PKaB64
X-Received: by 2002:aed:3f1a:: with SMTP id p26mr108477482qtf.113.1560997500357;
        Wed, 19 Jun 2019 19:25:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560997500; cv=none;
        d=google.com; s=arc-20160816;
        b=t3nC9ELiMtn2zEgtws1QudVXPjEdv5fMOx7AlBP358QWYJLWgyeuJzSxHDaqb92enR
         kSB3XXhejagA83PNpzTI+f0WCyWOZ7QCi1KYZvRUe6Vo+TF8MkX8Wti6jb8VF+IMz0NK
         3qDRJ2yyvvocTzAH1hViaw4TuuoS6YvLUiKwiOCfllyovG1ovC+GrMTwg/D3rqCPbNKu
         Cacn3h/PqOFz5IHRe+lFvmgAvcY+t6ehkxWbq+TqkFTTs91jKuote8BcJvKUtHcfduOv
         KFMn/OQdm6OoM7c5gvRuHNNTNPWzXRzYmnEQXohxPWqV62uWozdJtP08s2B77x0old2s
         PFlA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=6M5vIGHcsYBb3WCxHxaonQjlAK8kKdGHX+f4QKpk54A=;
        b=App0vrrg1wK+aQGcW4wdhKsuFrRwLJZnC5XxDoalxDbaLE4hKgeLpqmg2kypMpHBhX
         0VISxaA/yeSdq7UbQooWh7lfGlRY7+5ABjZW0Y+ASGBqacVvMhwtCSLRTEVzFPpyesny
         8aZtQRzH771gR+XGzC7HMgerrj435KItldgtGCoNArNCmfoTKw0COX9WfM7NQVJ9t7vE
         m44zutvcQNUgCy8KCXd1Evcj5ASyarzScMRzLoitNmsySr2994Nj2NvtFT5+krjLOIr2
         eStUT3t8ggD02PpiEQQLZe9SptideBwp5RvK3DDaVGQh5A5ce+IJlL4bEKsdUCi9sbna
         dV5Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b20si3994439qte.321.2019.06.19.19.25.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 19:25:00 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7B2A685538;
	Thu, 20 Jun 2019 02:24:59 +0000 (UTC)
Received: from xz-x1.redhat.com (ovpn-12-78.pek2.redhat.com [10.72.12.78])
	by smtp.corp.redhat.com (Postfix) with ESMTP id C410C1001DC3;
	Thu, 20 Jun 2019 02:24:46 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>
Subject: [PATCH v5 22/25] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP documentation update
Date: Thu, 20 Jun 2019 10:20:05 +0800
Message-Id: <20190620022008.19172-23-peterx@redhat.com>
In-Reply-To: <20190620022008.19172-1-peterx@redhat.com>
References: <20190620022008.19172-1-peterx@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Thu, 20 Jun 2019 02:24:59 +0000 (UTC)
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
2.21.0

