Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AA17FC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 64075205F4
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:48:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 64075205F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B1866B000E; Tue, 26 Mar 2019 12:48:10 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3650A6B028D; Tue, 26 Mar 2019 12:48:10 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2080D6B0290; Tue, 26 Mar 2019 12:48:10 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id EF67B6B000E
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:48:09 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id t22so13646330qtc.13
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:48:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=iK/wmVZ8p1b2GI2LEEXxGPJxVgFfciFqYn5pD/bZPGQ=;
        b=qQ3tXePLJZhDHgDyzGXViQMchDEf2gJD8diXt9fmpBnYjf0HzuMVMJB1x5qEbW1sRx
         gC2Iak9PTiK3nrMPNGfO+hU/rSog/IOCIVhFt0YQw0wN3L9xpdjo9GZgalkjbMsNKqZI
         2RrG5X3IHonxxUl5RgwVWs3naQaR/aDwK9PROZ3YXcWeYBgyXZaR0XZIdf4GfiD6BHGt
         NkHOCjRDCUJPbJSDpk5i7Ccl/T9JPx+QRrEyafLFYwYQnSl/vdAtQsvxjnwpBn0SjIS3
         4VEuZ4g8rkiaHHb8MosQqWCUqjHCJekOdwcvQ7FUW8uKA0nJqKhPGSaJ3XTBELggdlht
         qS3Q==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUsHNUaKYjTnDcB/31qvQ5Cf50GhvRJXa2CuW7M1icx/UvF2jqK
	e4YQ+enIid6J5Lkw3JMuGMky5xAtilJ2ZlMMiwVxDw0u/iLys0OWpF65DAJ9hufJDYATiNviCGS
	XMw4cFJNHXZczvTh7+2FPvAj5pkQIx8W1rnLnurwuQywT/rFeNxUx3AETIPh95unvgA==
X-Received: by 2002:a37:47cb:: with SMTP id u194mr21246754qka.358.1553618889772;
        Tue, 26 Mar 2019 09:48:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwXXwu6XoRAENNTbhTsKJ+pInu8HjSWBq8dOg0p3QJcmhpDtwenroUfazBizV1EGSWcSkoO
X-Received: by 2002:a37:47cb:: with SMTP id u194mr21246718qka.358.1553618889177;
        Tue, 26 Mar 2019 09:48:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553618889; cv=none;
        d=google.com; s=arc-20160816;
        b=VBavY0Ru8Nbhrp6429rO+035Dt0yWfGx8zHgV7K3GxtRBalONVDFr1R7zIskAybYVN
         tQMSqTIn3eaj4mhcO4ueFskQOJ2uIKjDBXhaju9Rd+lejUlWt7L+AcKbcQrKfJZcz429
         fdN2brTgmnDjFfMQTHLFRqWnWiFHumGfZ/nC7jBljoh1I5OSyBxD7tfH8w/Su0xRSqux
         U84PYJ0kCmGxaXdppziUhasOSuzVNlCDs05rWWPE/TOMXXRSNE5QI2vZCbI+ByI51rOO
         Ps/Sth95tXrAxxPNHVDxwGmS1rJ/Gd0cwPiiGv+VVwp0uo2gAq/y42B0ftMeFwW/OjHk
         daww==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=iK/wmVZ8p1b2GI2LEEXxGPJxVgFfciFqYn5pD/bZPGQ=;
        b=iRL1m4/VHyPnHpw5AKukNAI6F7QHkR1wpcGkWRNf1QT11NEezngS3E3LrxILMZxQ9N
         ygmiPf+bxHpNVBQpVWwDjJO9yg9B/uUHijSD9zNwiYOp8NHeziY1B7VzlQ1K12CRcNcN
         BG/9Zxji86g+4UrlST6MasJtcB2mTrs4X/9xBrr6UXZRFExQR7tN1u4JXOJuE8L92iDu
         rPINbNYpF3muxZvFvV9+Is62LaSO9DIq7ESnmvpQodm4RPkv4VN21YteonFlxPc1+24G
         qzl5nyCRPGSfP/frYa0b8DHZZRr771lIMNYysuUEsQOeWUXQrFsonKDKUjLkNNpHM6b9
         ECjA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z4si723381qvz.104.2019.03.26.09.48.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Mar 2019 09:48:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.phx2.redhat.com [10.5.11.15])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 3419485546;
	Tue, 26 Mar 2019 16:48:08 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 10B7C17595;
	Tue, 26 Mar 2019 16:48:05 +0000 (UTC)
From: jglisse@redhat.com
To: linux-kernel@vger.kernel.org
Cc: =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org,
	=?UTF-8?q?Christian=20K=C3=B6nig?= <christian.koenig@amd.com>,
	Joonas Lahtinen <joonas.lahtinen@linux.intel.com>,
	Jani Nikula <jani.nikula@linux.intel.com>,
	Rodrigo Vivi <rodrigo.vivi@intel.com>,
	Jan Kara <jack@suse.cz>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Peter Xu <peterx@redhat.com>,
	Felix Kuehling <Felix.Kuehling@amd.com>,
	Jason Gunthorpe <jgg@mellanox.com>,
	Ross Zwisler <zwisler@kernel.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?= <rkrcmar@redhat.com>,
	Michal Hocko <mhocko@kernel.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>,
	kvm@vger.kernel.org,
	dri-devel@lists.freedesktop.org,
	linux-rdma@vger.kernel.org,
	Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v6 3/8] mm/mmu_notifier: convert mmu_notifier_range->blockable to a flags
Date: Tue, 26 Mar 2019 12:47:42 -0400
Message-Id: <20190326164747.24405-4-jglisse@redhat.com>
In-Reply-To: <20190326164747.24405-1-jglisse@redhat.com>
References: <20190326164747.24405-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.15
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.28]); Tue, 26 Mar 2019 16:48:08 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Use an unsigned field for flags other than blockable and convert
the blockable field to be one of those flags.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: Christian König <christian.koenig@amd.com>
Cc: Joonas Lahtinen <joonas.lahtinen@linux.intel.com>
Cc: Jani Nikula <jani.nikula@linux.intel.com>
Cc: Rodrigo Vivi <rodrigo.vivi@intel.com>
Cc: Jan Kara <jack@suse.cz>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Xu <peterx@redhat.com>
Cc: Felix Kuehling <Felix.Kuehling@amd.com>
Cc: Jason Gunthorpe <jgg@mellanox.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ross Zwisler <zwisler@kernel.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krčmář <rkrcmar@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Christian Koenig <christian.koenig@amd.com>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: kvm@vger.kernel.org
Cc: dri-devel@lists.freedesktop.org
Cc: linux-rdma@vger.kernel.org
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/linux/mmu_notifier.h | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/include/linux/mmu_notifier.h b/include/linux/mmu_notifier.h
index e630def131ce..c8672c366f67 100644
--- a/include/linux/mmu_notifier.h
+++ b/include/linux/mmu_notifier.h
@@ -25,11 +25,13 @@ struct mmu_notifier_mm {
 	spinlock_t lock;
 };
 
+#define MMU_NOTIFIER_RANGE_BLOCKABLE (1 << 0)
+
 struct mmu_notifier_range {
 	struct mm_struct *mm;
 	unsigned long start;
 	unsigned long end;
-	bool blockable;
+	unsigned flags;
 };
 
 struct mmu_notifier_ops {
@@ -229,7 +231,7 @@ extern void __mmu_notifier_invalidate_range(struct mm_struct *mm,
 static inline bool
 mmu_notifier_range_blockable(const struct mmu_notifier_range *range)
 {
-	return range->blockable;
+	return (range->flags & MMU_NOTIFIER_RANGE_BLOCKABLE);
 }
 
 static inline void mmu_notifier_release(struct mm_struct *mm)
@@ -275,7 +277,7 @@ static inline void
 mmu_notifier_invalidate_range_start(struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(range->mm)) {
-		range->blockable = true;
+		range->flags |= MMU_NOTIFIER_RANGE_BLOCKABLE;
 		__mmu_notifier_invalidate_range_start(range);
 	}
 }
@@ -284,7 +286,7 @@ static inline int
 mmu_notifier_invalidate_range_start_nonblock(struct mmu_notifier_range *range)
 {
 	if (mm_has_notifiers(range->mm)) {
-		range->blockable = false;
+		range->flags &= ~MMU_NOTIFIER_RANGE_BLOCKABLE;
 		return __mmu_notifier_invalidate_range_start(range);
 	}
 	return 0;
@@ -331,6 +333,7 @@ static inline void mmu_notifier_range_init(struct mmu_notifier_range *range,
 	range->mm = mm;
 	range->start = start;
 	range->end = end;
+	range->flags = 0;
 }
 
 #define ptep_clear_flush_young_notify(__vma, __address, __ptep)		\
-- 
2.20.1

