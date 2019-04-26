Return-Path: <SRS0=i6a/=S4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9256C4321A
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B124F206C1
	for <linux-mm@archiver.kernel.org>; Fri, 26 Apr 2019 04:55:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B124F206C1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D3066B0284; Fri, 26 Apr 2019 00:55:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4820B6B0286; Fri, 26 Apr 2019 00:55:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 399346B0287; Fri, 26 Apr 2019 00:55:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1BAA26B0284
	for <linux-mm@kvack.org>; Fri, 26 Apr 2019 00:55:26 -0400 (EDT)
Received: by mail-qk1-f200.google.com with SMTP id m8so1844038qka.10
        for <linux-mm@kvack.org>; Thu, 25 Apr 2019 21:55:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=sOi2/XhOKc0PT+DtA8+paHYFsJMLE1++TUoCDDvkFl0=;
        b=EmueyDIAhzBIYb3vUKWTO3+eXZc93L8KjOoYQhu6CGE+8zXiWth1vDDa61Ty+EFp7Y
         ZETQa2sAN6lW9Kz4k7Qx56HDUmBuytzWPmADQYu1RP/7DuWNIW7GKmvWJ/IADZ1x1MPN
         YDEpaG8vozT60AHwqq80Kj0NwE1htkNeZF/XE5O2yZdtaF+TxOPQY8HGT7+dDCHBFzew
         kRTJpvVUKqS8ozHmqEnqYJTOyBosykdAMv8VqLzxAGeGX+SOg7l/GMZHEoUsid5iPurw
         Xxc5ySese61drzhi4QkCaiXRz8v3Xoy6IOUy5jMGrvdKqb/YM3h7pKGvcsuMBheA1vk8
         /9UA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAVtIC/TdQo5S/td56qVULjI30jl6I90tLUFnLAvHySFhHk3BPHn
	ZfxwygjS4yZ4rQcNYNqgxTCdXnArk71WpNFrX21d2SX/xH9kNZVQnUced2tIsgbvv4mQyvbi8h2
	wB1O6fnpNni18RphNd53x+KllXN05QunsXLtVUvoU6lsHuv+zKF1yIBR0rWT920Q3Jg==
X-Received: by 2002:a37:434d:: with SMTP id q74mr31100084qka.177.1556254525914;
        Thu, 25 Apr 2019 21:55:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwBsjV5IzVKFHN+VcLjHACVneb8xzqM1zvALEilKTglcc+8KGgBslqZacyVuj3mOrYVjj3t
X-Received: by 2002:a37:434d:: with SMTP id q74mr31100060qka.177.1556254525301;
        Thu, 25 Apr 2019 21:55:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556254525; cv=none;
        d=google.com; s=arc-20160816;
        b=wf7j4wnEbPkQdIqz7yr4LGzNVuzM1PaxFSZAiiuGPxIfuaDmMlRQdk9Bm1PnbAfm3O
         DTgKs/BHymc6HnVTAsAMmoyLSjfKbY8Zub4iFA+14IMY/CnDZGzicVbRyJQZ74e/CORn
         wX8ExyYGbxCTP28NaXEx/NeLunYcOQi2ctT6fnTP9poTEPua46MlFr/0xqzWPyK1x0gg
         jKlAivF9CUsqAtnBlhFfFDuco3I7DFWX8SDUqGAillMbbSNXAjJm+mzJNQLvcORkIqvE
         A5GSxuudENLtOxgXWVsfFxtnXX6fbScBE1AN7ajU0k51myPe8ovYHC7e/0kM66YIj+aw
         c2mQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=sOi2/XhOKc0PT+DtA8+paHYFsJMLE1++TUoCDDvkFl0=;
        b=YyGVfUTG5hzYyrofIYv2xEomUIIyCW+PjW6C447vXmIG5kydnPk0NsKb5EzY8GmukR
         ARmNE8enBl9ifq5DCF26obFWkou2R4+PadLFFDgJEcmr8WOFAPXGlFu6SJoUoPN1ImHp
         qWjsBQ009rjO2Xi0ub4wQNLZ6n3mIRb3Jl8Bm+lj3swzBovz6s6aTCqOS1OAdAekhDR2
         xrW1FoP5+Ru4R4bPPg8rfePxdwQcs4laUZ9hp5KmJ7ek4m24M+9SWlgzzAqkcL8vU6F3
         VeQCXfPXmLyNcSH5+i3ZdT63rL4A0a3Iaixp2hP0FkpdaEgKMqr2yzD0ZnJbaJBtNBQI
         aEDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k58si10155391qvc.193.2019.04.25.21.55.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Apr 2019 21:55:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of peterx@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=peterx@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 7C5DB3082B4F;
	Fri, 26 Apr 2019 04:55:24 +0000 (UTC)
Received: from xz-x1.nay.redhat.com (dhcp-15-205.nay.redhat.com [10.66.15.205])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 525EC17B21;
	Fri, 26 Apr 2019 04:55:15 +0000 (UTC)
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
	"Dr . David Alan Gilbert" <dgilbert@redhat.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Rik van Riel <riel@redhat.com>
Subject: [PATCH v4 22/27] userfaultfd: wp: enabled write protection in userfaultfd API
Date: Fri, 26 Apr 2019 12:51:46 +0800
Message-Id: <20190426045151.19556-23-peterx@redhat.com>
In-Reply-To: <20190426045151.19556-1-peterx@redhat.com>
References: <20190426045151.19556-1-peterx@redhat.com>
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.45]); Fri, 26 Apr 2019 04:55:24 +0000 (UTC)
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
Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
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

