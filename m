Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 777E3C10F03
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 30EE6217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:10:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 30EE6217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D3EC16B0280; Tue, 19 Mar 2019 22:10:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC71A6B0282; Tue, 19 Mar 2019 22:10:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B67B56B0283; Tue, 19 Mar 2019 22:10:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8901C6B0280
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:10:17 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id 35so927360qtq.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:10:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=iDlUo7saY4oT1s3VUd9zMo3eNXlfqXNdDJT52MZbq3Y=;
        b=bTcno6+WdIhyRcnn7yYeQ4vTCcYeUMvMod3djpATp3MVKUEf14TM4FnzmQLtVmaHxH
         ZSku2OW0jSnImmGpRUo00822JSD9uLu9wYtnGJ6vOu3a2/60i2pGT20gMZUnlYbyZ2Ry
         RNWJd/+AvzqrUXkUI80NiN7vAsrX1No5QZIhknSVl9F04LIzpUXJNXVwZ+V9smVTUnLw
         3TawCqO7fEs54+it9lqCMKBQhVj6iGKnyLQTNfuX3JPzxYQWnLiNcakEI+KhvDzDCJLG
         Z987Sg1cR0kQ+yZ6yttz9+YT0Sed/aIvtDMejj/2fFCEggFDdki3ZRXBMFPxzw7wN6AP
         nXtA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXChB6o9PfrvMgQZvCMSDSos+9cA2M4z4INFNHvBzIWMHu6dbir
	BnU7lbivr+UNZARbJPbPIg/woNWDuvOPyIk2/5bY/TAcqeLI+KrXRKQD+cbfVu0Mzgh8XAoWpXk
	L0/uARjKuOxetwTAJAJRR1Y/6LmeqZl5PcqhZQMrLLOMU9cqJtSZKeiSvDe5Xl8e+fw==
X-Received: by 2002:a37:dd91:: with SMTP id u17mr4358952qku.264.1553047817331;
        Tue, 19 Mar 2019 19:10:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzixT3YmluB+P4QqyVvwwSDoRu9nXK20f6cYbNBdW9lzbN+ZDc4qrhAS6qFuBR5j1O1umlM
X-Received: by 2002:a37:dd91:: with SMTP id u17mr4358928qku.264.1553047816588;
        Tue, 19 Mar 2019 19:10:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047816; cv=none;
        d=google.com; s=arc-20160816;
        b=CB/YIiqslKXHtmJzCnDklwyJJn30Y3lTnCTwd0eLYkbopBtmUAdqi4a4tB41AASBTu
         pHZh3B21JCj7QIlsN+KTVXVEJbh/CjnJu2x4iDRxjTvpP8GZ+RjYDCHxmg/1EZoIF7aL
         Sbmjt0a+eg6KdLnG0avjBO07ktgtHZ7RYIW30qNVYpUnB06KgMi+A6UQcs65pAvtl4A0
         cugcUMS/WgqVKdDPv4o4s6Aknn98b3qA3iM+OYKe1LKXf+xBViv53CApwMIIAtTvEuWr
         BbhQHjSEtUDhEMHTOMrTX4Tsc1w5bEBIs+mmN7c3i7K4T6z2kc5Q+AP8nz8WOtmoVYnW
         HF3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=iDlUo7saY4oT1s3VUd9zMo3eNXlfqXNdDJT52MZbq3Y=;
        b=YWCnJN2C+zstJX/Y4GXU1t6yETZzDp3vGAL5QUyx9bMIgFWWGGTiw8EwyA2CSvCPGT
         Pp/xCEmLBtAi9AqoA23AW0Gi1vvwaGEfS8tTGrve3a08l5BOsf3gY0LXOkyXxnRmU7RM
         cGwowoVQQb0VtsYMeKjhBzkrCQKrqyCKcE5iisqmz27gqPtEc0eS0OHBw6baYNYxRMUV
         5xgD+ZxdTZLdMq5zhvX+mY74RHr55ymrz2BuOMjlornfCKCFxc04VQA7aIo1HzEpsYat
         1m0irxmpz3olo/DONRz1H++ChCKajCyZcBPz83vrccBg9+don/FXeU8vMj+WqQ1SjR3Q
         /Xaw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n53si451539qta.65.2019.03.19.19.10.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:10:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6A27983F40;
	Wed, 20 Mar 2019 02:10:15 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id AA2316014C;
	Wed, 20 Mar 2019 02:10:09 +0000 (UTC)
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
Subject: [PATCH v3 24/28] userfaultfd: wp: UFFDIO_REGISTER_MODE_WP documentation update
Date: Wed, 20 Mar 2019 10:06:38 +0800
Message-Id: <20190320020642.4000-25-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.27]); Wed, 20 Mar 2019 02:10:15 +0000 (UTC)
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

