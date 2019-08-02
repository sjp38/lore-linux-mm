Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2EBDCC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DD04D2080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IdQZjyJh"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DD04D2080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3FDBB6B0279; Thu,  1 Aug 2019 22:20:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3336C6B027A; Thu,  1 Aug 2019 22:20:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ADD76B027B; Thu,  1 Aug 2019 22:20:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id D37F26B0279
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:50 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so40743486plo.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:50 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=r+i3YmgE7v22AH15+PBbtnpqpvOIdFOfqgcedhwuGlENzqpyO+bnvBdB1zdKqan1Jd
         YbA0l/dBeACyZFBubC8kVQ7sz5DyZIcQhMxWWrNolyRE1z87fG0ROJaTrICwWRueS1ui
         hr+ev95EHG5HdLMA/S6ZaxJ+RnwnlSpWDCtp7kEz0yttXYiPAGBLAb+mU8qNBWkRVPOm
         YbrlYlIYtuu+n6D31jdwWLIVS5mDAXW7H2fR29iQD7UaUlSykhb5O5SpzuW9gWgNsaLY
         Vw8N620T2e11a4nbfrYmTzNyIuC9dQgcEmGRjlTDhgBqd2ZKFUqRS6NRNaM4B0hmZaMA
         AHhg==
X-Gm-Message-State: APjAAAULQP3bOmHnNPqUzAHPJcRMJAxU9CGdy77tmA2n611PRk3cSHlY
	wz4eNgdCd6lD0PWjrUVqgIJvIRo2gyb1GrR5fi7fogeff+K5ee7ZCjsskbIPebx1LlnPIloStPU
	zRGcITvtKL0WNLRhDI4S6Zf8+lMD+OoSSGQOhmXuvRQkrtw69QsmR1iNb26CDlObrZQ==
X-Received: by 2002:a65:654d:: with SMTP id a13mr105399011pgw.196.1564712450425;
        Thu, 01 Aug 2019 19:20:50 -0700 (PDT)
X-Received: by 2002:a65:654d:: with SMTP id a13mr105398978pgw.196.1564712449716;
        Thu, 01 Aug 2019 19:20:49 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712449; cv=none;
        d=google.com; s=arc-20160816;
        b=w7gXrLRJfNuVbWfgXPLMmkDj5tGkoWZ9pcZeqUbNiuAWlZ3TNm/oKltCPd/856/+Sl
         3KrlyE2UKb51vaZL6L4Llv5zZ7Kk1s1l2p+pmNX09H49gejOQisrgeLSOHPDuniJY/BM
         1zvPo4GMDpc9S2EFo2RTtkB5ShqXBG7FrBKRxacfPX4m+TDjaGR5+oCk3aVGAAAA6igN
         LwG35BNPxTXPJCZkqtX4Y686wUDd2SqDh0ebQzhJZfSDxMNc33LGWm8tb+B7FMiTXYKO
         1rXRSzwBZ2tVRjQJO1KVCUXbUHocxY5x+qKt4hWjDZ06wgLsntV2ItnVseaM6S4HOBRE
         I0ZA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=q5fjvC7ljazP9DW0j/NVW53XaBbTLIKzlB+DlWpZ4DWFeDXEXEndS4cC0QcpjNfd1s
         wo6ADhjtOTv8PcgZ41Sda4jdfy6P9s+92/P5xzH8rv6ZUcV7LszlQEkTtEn52IvfOIPe
         tdHXacTAMn+Xw0VDcrOqdtSO2XXHD62l8hw++OmImSAdQAamm6CpoNoBQ4e6HsfA2AE8
         09/+j6jfRwZmWRsyhxmuOYHD8bpPQt8op5X0LJ4drL/ayBQbSrr88FRmE8rRqUPOy/W3
         m0pc7HXk9aQgjxwod7QyZkDTxdOvmzGayLhRexDz/JKmrE+VJpP/ydUuS0/+/RvkXFzp
         A1zQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IdQZjyJh;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m23sor8427906pjv.21.2019.08.01.19.20.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=IdQZjyJh;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=IdQZjyJhMTiA3ru+rOrbTXLCRfg1Iz7YPF+8DSWpdWDcWtOO1jwAD+njJSqb4AFsL3
         BoorK7WVXpk5wvzf+3MNWsWlqvxT2AU71m913kuKWpgnoA+0ZYT8hPv0DG2k2t5CL0So
         4HfYIB1+xctKU8nZMy0TNVHkmmwgfvFDwPBOEjDSZMguKyYiKdAvH/kYmRGOOCm1PmW7
         4QVOBE2D85KD1ebTOdlBPaqm/TGzFf20gzANQLnGH2MHePv/KbpSRa5elxYK3OTWVg7W
         lX3umVSebAxAiH6LaR7v6UhLbExl0YmQ1qyvKE73k3aH42K6tSy55ZxlEvZWhHEAZhKs
         EwnQ==
X-Google-Smtp-Source: APXvYqyQ9NWbm7e7UjvOHtMhAwjS+tkI0uFYNRjX3KlyXdyqOSjy3adbw2n2ONz+amcM+RqqbPvknQ==
X-Received: by 2002:a17:90a:cb15:: with SMTP id z21mr1894788pjt.87.1564712449418;
        Thu, 01 Aug 2019 19:20:49 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.47
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:48 -0700 (PDT)
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
Subject: [PATCH 24/34] futex: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:55 -0700
Message-Id: <20190802022005.5117-25-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
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

