Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CAFE9C32759
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 790D7217F4
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="AV7uFQE9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 790D7217F4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D4CEF6B0278; Sun,  4 Aug 2019 18:49:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC1AC6B0279; Sun,  4 Aug 2019 18:49:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F1676B027A; Sun,  4 Aug 2019 18:49:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 66BE06B0278
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:49:58 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id i2so52210765pfe.1
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:49:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=aTKHjnInhmjvfXYX7gxVxE0WOEOL0f0MX6UMhUatB+lo5O4yNUpdLMZWleHIr/beAY
         P/vTGysqQbFC+AjZfX0V2+w8ieY988FdgCG3A4QULUG23g+gTlcyrkqF9FRaJEGCu5lj
         cEwe7yRtUo7c8x4ACBg3C7W4sVhu7t3WQJ5svQhOoQk75hl6ylVV+wi3wfYbbIpYhiJM
         7P8DBgTuHOPDFwIFOGrrg0iwpuwCxBXOyPj9dV5893h3HF4yl1i7Du1Wfefplj0PIsVQ
         Uz1zZGAwm/RQkEi/sf7R9fROzJNfHxc0J/aypiUlDrcqDCgdbdDLGam2UZnyoV4Rlfmj
         +0NA==
X-Gm-Message-State: APjAAAXBopDrU2Oo2dZnk2i0syLfrKwTZA6JmZUpEL3ySZBH5P2OU9qz
	vQ4NFBmuT62UwiUOivIWcsTG1GvqQGf5YbxHnax2W1IATNqYJnW8aIReW022MSiArNw/NT31d2I
	xB4oYFKcz+XUUpuncYzhR2TWqfjn9I9bCVvLri2cLbKL+IYBAEDMwVwxf7g6ITWxctA==
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr137221496plr.74.1564958998120;
        Sun, 04 Aug 2019 15:49:58 -0700 (PDT)
X-Received: by 2002:a17:902:aa83:: with SMTP id d3mr137221480plr.74.1564958997548;
        Sun, 04 Aug 2019 15:49:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564958997; cv=none;
        d=google.com; s=arc-20160816;
        b=y1KjbcLcJRLV+dQa/T3Z2lBNpRdHJLbdWUwueg/Ed7nZzGiDxvzK/4sadmeZa3KAx1
         8oARfS1ZkDTEFKE0FPAt7yBz+ZB8NkRpGaoPgCVFEU6WCw0IKkiXlVf6lj+ShcaOKB2Y
         VEvdfxAvbgpDoB9k2bs+LRmck6wXoW0PNVJbRhXDiThaPLciwJG/R5MptY+BnrKtQBZZ
         J+SFQVONPbb+a1LrABVoNyYTD17GzmOzBcSwNTMXnTcWX3zmsnSEmGW4h8fUhK0nmXgC
         nAc2TtIiXH7xWA+O3WV+p535N8UUnCfi0llmMiaVVt4vSxnXp2Vrf4WJ7+o+2WdMo6q0
         SRCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=AGVEqZ8+FbYkBmPfn4PkJACiGtJ6sGJCwKJfnaLxvVuJOwNo8wq/7S6K3lKpSDqMmd
         KbqqK4l1qDFjRDhhU5ebsu/3BzrzNIWmahfFWagFU0TKkwJReoaZZg9jPaoe2sPSDH6C
         0wjS6SmHn0PtI5EVZm1kVKwXqq2cxgfmstyQuEPMGDGMb3qAOVyx1Eu7cFWuYhUU3dao
         IZJgEpGEvovl8s8BG1bGa3x/alf5KsSZ21bDjZQuTGjJ8dDwsBaPnb9aKuzZ+hTOZu2P
         dpd+EbwZDFlxidaYf6D8sreNAH8igfFXuFw+MXP2jOGKVw1YnodBNlcIlxoNnbA9pSns
         prhA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AV7uFQE9;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g15sor57442134pgg.19.2019.08.04.15.49.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:49:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=AV7uFQE9;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rRiJNzkH0bRoPJKYXoQcsROADD9YH4USeXVLEsmAa1E=;
        b=AV7uFQE9YUuDd+D7n/raE3+Vd4+M3WfHMpSGBy7Po/eVbcIBoj8uNAj9DUgT5bKiPy
         NOFpz/m3dZOdwDIxZQeVlxsCTnZ92dZxKMNJ/rR2X1bMUek0j8TGq+u0eAdIPX6nv7Xg
         3xla0EEXNbB0lWncn+d/ABroqlg3T2U7E2b5B9Xg8cDDZKP8nXSMimiXqXtFe+tBDXhV
         ARezJERjiP3GeR4zOW6+cUq9Pz5Hkpr43jELcaC0lfmmiiWVj3OueADfK4ODHerMWl3x
         WKZ0WyFn5raZ50oDfnPOKa2jV6SJBQSgxKSa9LR9P0FGYWA2KC5auYEx1XvMz/0dUJhq
         D/Mg==
X-Google-Smtp-Source: APXvYqxM1jqqH644LscYZh1fOmR6SQroZ5U0oF421RZK6m1nNZ1H1tDwWIOHK+9da6OAru/hIya3FA==
X-Received: by 2002:a63:61cf:: with SMTP id v198mr17505607pgb.217.1564958997274;
        Sun, 04 Aug 2019 15:49:57 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.49.55
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:49:56 -0700 (PDT)
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
Subject: [PATCH v2 24/34] futex: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:05 -0700
Message-Id: <20190804224915.28669-25-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190804224915.28669-1-jhubbard@nvidia.com>
References: <20190804224915.28669-1-jhubbard@nvidia.com>
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

