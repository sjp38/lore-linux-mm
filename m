Return-Path: <SRS0=t1E5=WD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4A8EDC32758
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:49 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05CFF217D9
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:49 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ZAOMcyqa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05CFF217D9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 523B46B0279; Tue,  6 Aug 2019 21:34:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4AE326B027A; Tue,  6 Aug 2019 21:34:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 292216B027B; Tue,  6 Aug 2019 21:34:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DED4B6B0279
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:27 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id g18so49407784plj.19
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=bC7tPnNnAj3OlR6APPkN82A3tHBEWK79iM1tHcKldSauV4woa7o9rQYnRmwOetp9rS
         SQBKzloOafGb10s66blzB3WIgEkl/7kJLTVwJmi0/IKXU++rRmruXt8Zzwbq96K44jX5
         gVL1Dlmf3X6xoRRwG0hBZDgDGrMdMhbZENnDKcYr9MliXN5l+e4GYJzw4gTIFIXgBqtN
         LpJ+lbTEqxLF3GKsb3kFcqrPJAjPRnTa+DqK8qza1CqsEl3j0ftSC0oAPWSnG5Y++bmQ
         VylDy7VQUSuTtQKq0U4qDxsQzLBwPmAhOl0xycXf/RYEynjKqp5JEcSbHAMPetHpwrAM
         PFlQ==
X-Gm-Message-State: APjAAAUReszfQIj/0RyXKr3PplqTLG93WrRmtRVZjaWzoe4ckg7nftRf
	VPyUbwW9CPFjUw5gMZALpr9vOPR/VmpoeSHZwmhbo3xJYeE6950IRsaKi9g73o0QCgNdy+SVOFb
	0kCxhkkBXFYj8NBnqZarGDc6rHHpmj2e/WONiLl9SIp/356gxMYOSn8DNONICDsTYZw==
X-Received: by 2002:a62:198d:: with SMTP id 135mr6656503pfz.169.1565141667602;
        Tue, 06 Aug 2019 18:34:27 -0700 (PDT)
X-Received: by 2002:a62:198d:: with SMTP id 135mr6656467pfz.169.1565141666983;
        Tue, 06 Aug 2019 18:34:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141666; cv=none;
        d=google.com; s=arc-20160816;
        b=01HxjH+gVMJre0BSQK+dlFwDgZ8xCe6outYudeQbAMJ7EOdrqTrez49GkWnc+ip6yK
         Qj3z0oYu9ZOELSdXy4uNp2wzNB79vT2dKz0HQZLQHI4ciwJ3jZvZC/ZEKCAK+VHqYfqC
         jZ4q9VPKjnWSdpECOKR1UTL4USxbJ5mEojmp+w4SAP+5HPWvnxYiBCyq0mNskaNd/fPb
         JoY3+wMZN8Sytmcuxc7MPyrz67kQvEu4rRscMscyoYps9k2OJ5AVv0DnG1cbbjjE6L/4
         uRlzbdyjF5mh3Gnyp6h/tE6vRXoMgtc3m++iTODu8dUTx2ga0MXMCsCoF41GCJxxEF1c
         9xsw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=Y1YwzpO7nY3tilNkIsj13ttu5M+wMKG+qopTCwJin3bu0km5KAtyzpE9n5/pVZ7kUZ
         luXSzsL85Ew3TSXtJBRznWdrYlL3dDNKrboqEHyYffk1fx2kvloW0GXWNuro4aM6cvbJ
         tkmKo8qTGoo5MxODfqkuaiHJkI6URZ0le5c/HtwireVhDlVDMIXdQgNzNsFKoRf9+ad2
         NOpxOZoql+kPHfA7FBE0y5Y2ORq9fJgDVxejOO9cBF1ciatxEKVWleA4l6GwRDMK2RUy
         M+ZdscXrHQewnI9qi3jluNu5lYFtUayhLZ1FYHjfuMklfsnfDwhrTqViBhVw6Px8NcWQ
         ab8w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZAOMcyqa;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f7sor62120236pgc.20.2019.08.06.18.34.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=ZAOMcyqa;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=ZAOMcyqaxqY643ITrRXBO6KWZEv0BPrbx5tJQbPH7rHQpilJpWZFaQqivaW1dFVk9n
         HEg+YPfjTMvoOIccb/08xfn9NKdsR6RZrkMFQVLviReHqdXnWL+vc4R4t0ltPC+hbt68
         VA4jLMoR95CN/y6sAkP8CqnObqsDT6qKWV75L660iR7mpVuhSyRR/4cQnMVcKpvgWZXu
         ppOap2XKxusMXjt7xI2vgsY0f8KkQAj/hv5RrF9v3DRsqTv3I7ksuzgSRnKVipJSmOcw
         MASa+XFQrV8LVi8afesATNPV3nj9fqATOCuf2yKuf9L1MVFlsmCg+cL6q2lyis0vQrGP
         pY7g==
X-Google-Smtp-Source: APXvYqz+78FWPbJakrK1ZelWQJSg29Gh/RFKsj1GJIoNKea8JqaCLYMVGyBI1IWh4QFTdizL46lHtA==
X-Received: by 2002:a65:610a:: with SMTP id z10mr5605978pgu.178.1565141666704;
        Tue, 06 Aug 2019 18:34:26 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.25
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:26 -0700 (PDT)
From: john.hubbard@gmail.com
X-Google-Original-From: jhubbard@nvidia.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>,
	Dan Williams <dan.j.williams@intel.com>,
	Dave Chinner <david@fromorbit.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Jan Kara <jack@suse.cz>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>,
	amd-gfx@lists.freedesktop.org,
	ceph-devel@vger.kernel.org,
	devel@driverdev.osuosl.org,
	devel@lists.orangefs.org,
	dri-devel@lists.freedesktop.org,
	intel-gfx@lists.freedesktop.org,
	kvm@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-block@vger.kernel.org,
	linux-crypto@vger.kernel.org,
	linux-fbdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-media@vger.kernel.org,
	linux-mm@kvack.org,
	linux-nfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-rpi-kernel@lists.infradead.org,
	linux-xfs@vger.kernel.org,
	netdev@vger.kernel.org,
	rds-devel@oss.oracle.com,
	sparclinux@vger.kernel.org,
	x86@kernel.org,
	xen-devel@lists.xenproject.org,
	John Hubbard <jhubbard@nvidia.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Darren Hart <dvhart@infradead.org>
Subject: [PATCH v3 26/41] futex: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:25 -0700
Message-Id: <20190807013340.9706-27-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190807013340.9706-1-jhubbard@nvidia.com>
References: <20190807013340.9706-1-jhubbard@nvidia.com>
MIME-Version: 1.0
X-NVConfidentiality: public
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: John Hubbard <jhubbard@nvidia.com>

For pages that were retained via get_user_pages*(), release those pages
via the new put_user_page*() routines, instead of via put_page() or
release_pages().

This is part a tree-wide conversion, as described in commit fc1d8e7cca2d
("mm: introduce put_user_page*(), placeholder versions").

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Darren Hart <dvhart@infradead.org>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 kernel/futex.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/kernel/futex.c b/kernel/futex.c
index 6d50728ef2e7..4b4cae58ec57 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -623,7 +623,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
 		lock_page(page);
 		shmem_swizzled = PageSwapCache(page) || page->mapping;
 		unlock_page(page);
-		put_page(page);
+		put_user_page(page);
 
 		if (shmem_swizzled)
 			goto again;
@@ -675,7 +675,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
 
 		if (READ_ONCE(page->mapping) != mapping) {
 			rcu_read_unlock();
-			put_page(page);
+			put_user_page(page);
 
 			goto again;
 		}
@@ -683,7 +683,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
 		inode = READ_ONCE(mapping->host);
 		if (!inode) {
 			rcu_read_unlock();
-			put_page(page);
+			put_user_page(page);
 
 			goto again;
 		}
@@ -702,7 +702,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
 		 */
 		if (!atomic_inc_not_zero(&inode->i_count)) {
 			rcu_read_unlock();
-			put_page(page);
+			put_user_page(page);
 
 			goto again;
 		}
@@ -723,7 +723,7 @@ get_futex_key(u32 __user *uaddr, int fshared, union futex_key *key, enum futex_a
 	}
 
 out:
-	put_page(page);
+	put_user_page(page);
 	return err;
 }
 
-- 
2.22.0

