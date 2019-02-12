Return-Path: <SRS0=CIMh=QT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7D2B2C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4352F21773
	for <linux-mm@archiver.kernel.org>; Tue, 12 Feb 2019 03:00:55 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4352F21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9FAE8E01AC; Mon, 11 Feb 2019 22:00:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C948E000E; Mon, 11 Feb 2019 22:00:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BED738E01AC; Mon, 11 Feb 2019 22:00:54 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FC3D8E000E
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 22:00:54 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id 42so1278896qtr.7
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 19:00:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=et7H5onmOlBCAp/YbZF3o8+/lw37bMOD7FBBfwvBrIY=;
        b=oKa7hk/A6dl88nGopkHrO6D7j30Th3Fz09X7Lqv0AS9hFcgbxF+hB2Qqzx/f6YokJY
         hiuIiW4If2Noz7p/C6w4mtsNuWs6JDXQbX1kGIxMAYDh3ucW0xFSu8azZMxiFUM5yKLB
         FcwenLtKtrEKiB2TO0+T+aGKnkj7kG81DK3VZleTPWCRjmh/QUMUEvTibQN55HA2PNsX
         Ue6brPSEM3zgpySCezrLFuFO7uz/DsAlDeKbZTd9Hc5RtH7GaGzdwBcvxHb8dYPK554n
         PWgd47UYIfHrmu0apE7oMGu80uUC/ntol24EeZR5PTdAI9yzrP76rB0bIiRGDEkLYpsq
         vutA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AHQUAuZiWzlqC8bs7nA+TV4f/Uq4kIzV8mwO8/jIlfmlEtB+3QIojUDK
	o4PZX4hEqb1A/Oqh/Mb43XhKC8thCgs6oYIyc7NYz3fX+/tPQ90mMD4S6Lk8hT7dBL9JFFmyKJl
	07gn4i6UgX3XmkLnCYXFKRcd50f0Y86Xo845I4QXocfYiGaOVGERdcH5kFC5pCnJAhw==
X-Received: by 2002:a0c:8b67:: with SMTP id d39mr1055670qvc.9.1549940454387;
        Mon, 11 Feb 2019 19:00:54 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYTbBMZYPO5A2R8CkbVDX5oGp01KeBoofQaXWsylCKUnaivPc7LW7qN7YC3iOBE+2Zfliku
X-Received: by 2002:a0c:8b67:: with SMTP id d39mr1055652qvc.9.1549940453993;
        Mon, 11 Feb 2019 19:00:53 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549940453; cv=none;
        d=google.com; s=arc-20160816;
        b=bIq8kMK1sGJZk3Pov9F3OuiORxKT7ctKruk6VxBVEKnj4djlzJaYO2u06DEq1KTL28
         rH9yoQVr9/JYMJGGjtcxkZ98zJsYFdXjdZPIT5mYnGpCqbwbE/16K7xz82WO0jChjaRB
         V8XNwm7elc2FkH92l/1Fn/pHfoIRaS8ybKQA2CM0h8ZV95B4hODlIGPuJ5U+4o7mUjLK
         TcVc0Js6Xu7AHMr3NbMhEv7Xf6GDFsH2wmVJ4eMnjdW81SF4LaQF5YfxrO0I6ihrgfmh
         qAy4Mym6M8tNvAjqvYCbLPZzDXjMTY6LZgcAS44Mm8TFaPr1LoveXOJkFgbBmwH1Cb2h
         ndJg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=et7H5onmOlBCAp/YbZF3o8+/lw37bMOD7FBBfwvBrIY=;
        b=Ke1JKOcUqkEz1eIgTm381srEJGOGpxYPMzn14QP2qBzrhyFL4gY63Y0TcJc4bnrQ7a
         Nw0gX+9T2/I7nu4jsuZwZvL7aBLGX2B7y26sZog6dzH8qvazS4QeYdDf1KPA99ahNIl8
         6mv4xu1DXSvVelgXhruF1DD8kgBYNtNCxmsN+JlV6Cdj8VwLUboDoCgQV0ym+v7QQ+70
         sJ7BDIT91WWeMF2vStERJArrwHf8xGm4asbGOk4lSOz5eRue2aLPzHP6Ro8ZVHCtrZQY
         Frul3ro96N8trs+9pPJhNmJF95uzytyNjeQFNfcUT0xq1w0jozAt3KBJHzdbN2MO2d8e
         5NEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q20si2613337qtq.364.2019.02.11.19.00.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 19:00:53 -0800 (PST)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 19DED5947A;
	Tue, 12 Feb 2019 03:00:53 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-14-116.nay.redhat.com [10.66.14.116])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 6EDDE600C6;
	Tue, 12 Feb 2019 03:00:41 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v2 22/26] userfaultfd: wp: enabled write protection in userfaultfd API
Date: Tue, 12 Feb 2019 10:56:28 +0800
Message-Id: <20190212025632.28946-23-peterx@redhat.com>
In-Reply-To: <20190212025632.28946-1-peterx@redhat.com>
References: <20190212025632.28946-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.39]); Tue, 12 Feb 2019 03:00:53 +0000 (UTC)
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
Signed-off-by: Peter Xu <peterx@redhat.com>
---
 include/uapi/linux/userfaultfd.h | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index 1b977a7a4435..a50f1ed24d23 100644
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

