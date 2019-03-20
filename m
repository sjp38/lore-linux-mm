Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C835BC4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 87721217F4
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 02:09:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 87721217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A0376B027C; Tue, 19 Mar 2019 22:09:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 32B126B027E; Tue, 19 Mar 2019 22:09:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1CC506B027F; Tue, 19 Mar 2019 22:09:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id EB5946B027C
	for <linux-mm@kvack.org>; Tue, 19 Mar 2019 22:09:58 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id c67so8204273qkg.5
        for <linux-mm@kvack.org>; Tue, 19 Mar 2019 19:09:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=1u7MlrLHL2FyLr/gtuJYMX9mDwFnzu7WWCE+9OL6ne0=;
        b=YOQ/qrOElspwRGFuiMDGa/ivY7IPcUYlisawihXE6Alq0uu/eyQSKRKv+dC+S98w1v
         Z/pZjEJS+5LiTkU7lmYwmbEjY0QrsWtMtpdCLnD65ooreuDn+oiQpfYcLX7Xllernml0
         G8CptwzG6Rs4ZnJZD+c9QMGynYXSm7KtWncXal23gzGTINu+vwhynSzupQdb2TEssVTr
         EI5etJeWo37umO29gYO7o+nhNpdDsfOyegeo/QvI3omBZ/ulBHRWY7Rn0/HfNDpcNjZ5
         YjnlZXS9ginNt0Op/YCew+auzD6INbF/XbcV5DbKxhj8B9rivSZ2hUm3kYb4Xd2r8mwA
         2kmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWEGb126AsMx4TZonsim9Gf60YHAzwrVSFVgGGO7MfiO4xoQT3m
	2leqwr5vZu71aOeneS/60FYPO+9fBz00DRXd28ZZh0Bzbw1msGjWiWh4H6+Lgi3wV1n3Ewo7fxi
	cVMcLiSWIX9U2Jf9pBFhkg4NEQG3ietxNefcmrrRJpf3QpioUTYZwob2MtXyEaAUIog==
X-Received: by 2002:a0c:e5c7:: with SMTP id u7mr4558219qvm.44.1553047798771;
        Tue, 19 Mar 2019 19:09:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy7sMNCwxxJSXEdliAaBFCjx6fLOLE/ZxFdDnpn0BVtxT93FE9hOrGtrDQoNNvjvSyRWTv2
X-Received: by 2002:a0c:e5c7:: with SMTP id u7mr4558184qvm.44.1553047798008;
        Tue, 19 Mar 2019 19:09:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553047798; cv=none;
        d=google.com; s=arc-20160816;
        b=lCfzC3smDEnzSlBToBuXEzYlsm3CadwuklG9MmUyrDduz9Khs2Ieyv9QjHmHirtRTc
         Uj8K6138FOSyfSxFAzTTbWmSeqVmI9XNRRwzIQXv8swIVaH/X/2eFtII8bF1aKLrHuU6
         YtkhM6k4m4a1nVrou45+GMlV019rO0w3bw5FjISXyxGc0MhrS+pR90RkE/KdiNJJPMRx
         m9ELA9Y+9ejLIvTjHFqaFv0o7vHHxno9FtVb1PQKgivBsZK9dK2b1Y0B5AgTg4i6oR6e
         65btvS3BX8q4+DOs6H8zE51la3ANb2fe9eIHTPvKq2n3lx9YQ9NsIx7O8M2fOFo2ZDaj
         F77Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=1u7MlrLHL2FyLr/gtuJYMX9mDwFnzu7WWCE+9OL6ne0=;
        b=ET1Jm1C7xBaPMApO9nksVyotK/xpX5xWGY3Wd6UxXJFcnBYUScS/a/8f5cBpbn5bod
         up5aAT1Uc1BFGzXW7TYpiNxWvxubm28Zk9l7yxKXfTNYjERBEaehesHmSKaRpKcnb2/O
         kkWCFAEA6vUlvUjfskurnmB7OlnvgZpJ1C2LGIb4eyFxyEMBfW3uIm4IR9bSL2/+RTNZ
         XZrvC7kIiJLRCKTkxLivHqcauUvMg569WhhB/nxXOrQTWB7W4UWdcCVDsx7Ne52bMtsC
         v2r8Z6uTfj82hybYgg72WndCM2qvP4cqGH7Z7QyPI620MjfZOn/xoXdZcl0nmYoyOMxB
         NTjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p85si368370qki.21.2019.03.19.19.09.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Mar 2019 19:09:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 254B63086205;
	Wed, 20 Mar 2019 02:09:57 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id ED1476014E;
	Wed, 20 Mar 2019 02:09:46 +0000 (UTC)
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
Subject: [PATCH v3 22/28] userfaultfd: wp: enabled write protection in userfaultfd API
Date: Wed, 20 Mar 2019 10:06:36 +0800
Message-Id: <20190320020642.4000-23-peterx@redhat.com>
In-Reply-To: <20190320020642.4000-1-peterx@redhat.com>
References: <20190320020642.4000-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Wed, 20 Mar 2019 02:09:57 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Shaohua Li <shli@fb.com>

Now it's safe to enable write protection in userfaultfd API

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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 95c4a160e5f8..e7e98bde221f 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -19,7 +19,8 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
+#define UFFD_API_FEATURES (UFFD_FEATURE_PAGEFAULT_FLAG_WP |	\
+			   UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
@@ -34,7 +35,8 @@
 #define UFFD_API_RANGE_IOCTLS			\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY |		\
-	 (__u64)1 << _UFFDIO_ZEROPAGE)
+	 (__u64)1 << _UFFDIO_ZEROPAGE |		\
+	 (__u64)1 << _UFFDIO_WRITEPROTECT)
 #define UFFD_API_RANGE_IOCTLS_BASIC		\
 	((__u64)1 << _UFFDIO_WAKE |		\
 	 (__u64)1 << _UFFDIO_COPY)
-- 
2.17.1

