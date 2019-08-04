Return-Path: <SRS0=DZuJ=WA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 815ADC4152F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 389942089F
	for <linux-mm@archiver.kernel.org>; Sun,  4 Aug 2019 22:50:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="M2L6YAdx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 389942089F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B07656B027E; Sun,  4 Aug 2019 18:50:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A8BFC6B027F; Sun,  4 Aug 2019 18:50:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8B6FA6B0280; Sun,  4 Aug 2019 18:50:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4EF806B027E
	for <linux-mm@kvack.org>; Sun,  4 Aug 2019 18:50:07 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e33so9378987pgm.20
        for <linux-mm@kvack.org>; Sun, 04 Aug 2019 15:50:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=hsfHTe2PztXemahXmkVjBEasld9rPellOy00GPVUAYGbuTKa0PeksWjR8tJC10o/Vr
         v5dG2iCEnD6fBSn1u80qe2Ff9/Rsf294ArNRyrTNauXcGGiglOxukIsIDw2zOP0vxTRy
         XaVLYVyGmWyE289IjF9V8lGgYO6pHg20YN7hmD/69ZhyY52LPZkcTHqit7V2Q+xcSUJW
         71SUj8kSfoQdekLz1FqphUDq7TxsmCgOlVNTs0FkIETSB7xiEN/jaH04lat5eDQtfzfo
         APUIc4AqU8+wpQxfxneW/8N3+ahbwQcrjjjYQPtxfMDVTcVcyUmfmp7PSKVTUuhyiwd0
         d3TQ==
X-Gm-Message-State: APjAAAVVvFdf73vJCLmCECn7RodHUXevJBJwRUlE98lVSxFuokjjIVzv
	YHiWnlGddhO/qBjRd/xpui9DWANiuO1pER1sjFwn/+cqwqg79sbvPpGgM4lrRA0dS/M/zyAVAhY
	mDBxqPP+u7/E/qgOfo+KOeS6c4GLKygbpQ6+MfacUNPXPsuWla9s3v7SSMIacAc2fsQ==
X-Received: by 2002:a63:e54:: with SMTP id 20mr130889210pgo.244.1564959006854;
        Sun, 04 Aug 2019 15:50:06 -0700 (PDT)
X-Received: by 2002:a63:e54:: with SMTP id 20mr130889176pgo.244.1564959005761;
        Sun, 04 Aug 2019 15:50:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564959005; cv=none;
        d=google.com; s=arc-20160816;
        b=ReXQpLPiZ/BzgefFvZv8MB0kAzBAbxfs5k4iMVOPI+cDlfbQ2ffRymfA1MH/J48vqP
         uLY7h8v3jo5LkjzeIJxjytJZRmHfoHA3ea0+Bf15Qzq9G1M2U2c+cf4wr9qf3Z7HDOrU
         PHMwvpx76VkrlcQMdO2oWhvt/8euZkCTUGmRAQGrizUSU333GpgCZzv8nL4iRQ/Huhd/
         yFTFcHRMxkjfFOTNp018UrqeJ81JOJ87tyOeZ4hYn1PLuIqacAEScIUgrS/cMSHqdQ+2
         NJDfWJE4a4Xc467TEiJSf2YaeC2Ai+b2ksQ7jag1+LrQk5ICvaNLWLW0zefrVSjj9Wh+
         GlQA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=ul7rBbKoAt5Y81R4KEWyf8FlkTautkzgCnqSA8GeB7yC6AiwQwCdp2vbVyQK1WG5p3
         unF5TFrf9Nm5PznXvFHXF3OBCvZ9gB3a6KKPv9CrVOcpN3oN8yqDS/iBxybXbELBsUfb
         KWl+oCgRqHWkS5IuIGiEkQzxubTbFsjMTTVKtlCX39ijAomXtLgVHu5sQ7Fh5mYLHT4H
         bbdF8C7xXvCrOpyilFmRnJL4nSC5pTfYTgpL1VjTwyJh5kLesQs9cvFzG3wEFuKcXKTx
         gB3R+Syas+OnhDl8m3ZQmMxuzbmdoaHOsp7ggfHA5eWh6oes4jMjKt0oQOwk1OC02s6e
         WDvg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M2L6YAdx;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j39sor98294622plb.22.2019.08.04.15.50.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Aug 2019 15:50:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=M2L6YAdx;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=M2L6YAdxRG9wjsRrCe6Hi1BWSuOg3nnT/7fZiBi9EPm8FKwRKPZG/qe2iVkh5HnVN4
         aOY3UbjkBBnyU76TUmUntE+kZe6hTFiJw358fIRHno09JT1X6eXkCbDzppqL0p2wk4as
         lvnBxcaafGoFzaHDQmz1tjx1PupzVr+3Bwm67hS0uZ1vXhGSeRklj059Ttpi/TbXqeOB
         q+Wl+DhD48e6x3JgIGWaWg109om0eB6fx6VWuDjwbuhJAY9G+Qx7/vpxnkVUdLKuN2o0
         4E0MKgE+4sHPl7NeWK7fjvH31HAT3/QXcQRRRT0MdjjRb3hC4ZkOnyD0xdYCwRJ/SF1P
         5dnQ==
X-Google-Smtp-Source: APXvYqwAR1ooAm+K3YiNJXFD4tuydWLDFWaO0CLJ4VvvN+1W/RZGreelHnJEnGprjIniv/pPljEZRw==
X-Received: by 2002:a17:902:7202:: with SMTP id ba2mr144069047plb.266.1564959005550;
        Sun, 04 Aug 2019 15:50:05 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id r6sm35946836pjb.22.2019.08.04.15.50.03
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 04 Aug 2019 15:50:05 -0700 (PDT)
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
	Al Viro <viro@zeniv.linux.org.uk>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Christopher Yeoh <cyeoh@au1.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Ingo Molnar <mingo@kernel.org>,
	Jann Horn <jann@thejh.net>,
	Lorenzo Stoakes <lstoakes@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
	Mike Rapoport <rppt@linux.vnet.ibm.com>,
	Rashika Kheria <rashika.kheria@gmail.com>
Subject: [PATCH v2 29/34] mm/process_vm_access.c: convert put_page() to put_user_page*()
Date: Sun,  4 Aug 2019 15:49:10 -0700
Message-Id: <20190804224915.28669-30-jhubbard@nvidia.com>
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

Cc: Al Viro <viro@zeniv.linux.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Christopher Yeoh <cyeoh@au1.ibm.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Jann Horn <jann@thejh.net>
Cc: Lorenzo Stoakes <lstoakes@gmail.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Rashika Kheria <rashika.kheria@gmail.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/process_vm_access.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index 357aa7bef6c0..4d29d54ec93f 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -96,7 +96,7 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		flags |= FOLL_WRITE;
 
 	while (!rc && nr_pages && iov_iter_count(iter)) {
-		int pages = min(nr_pages, max_pages_per_loop);
+		int pinned_pages = min(nr_pages, max_pages_per_loop);
 		int locked = 1;
 		size_t bytes;
 
@@ -106,14 +106,15 @@ static int process_vm_rw_single_vec(unsigned long addr,
 		 * current/current->mm
 		 */
 		down_read(&mm->mmap_sem);
-		pages = get_user_pages_remote(task, mm, pa, pages, flags,
-					      process_pages, NULL, &locked);
+		pinned_pages = get_user_pages_remote(task, mm, pa, pinned_pages,
+						     flags, process_pages, NULL,
+						     &locked);
 		if (locked)
 			up_read(&mm->mmap_sem);
-		if (pages <= 0)
+		if (pinned_pages <= 0)
 			return -EFAULT;
 
-		bytes = pages * PAGE_SIZE - start_offset;
+		bytes = pinned_pages * PAGE_SIZE - start_offset;
 		if (bytes > len)
 			bytes = len;
 
@@ -122,10 +123,9 @@ static int process_vm_rw_single_vec(unsigned long addr,
 					 vm_write);
 		len -= bytes;
 		start_offset = 0;
-		nr_pages -= pages;
-		pa += pages * PAGE_SIZE;
-		while (pages)
-			put_page(process_pages[--pages]);
+		nr_pages -= pinned_pages;
+		pa += pinned_pages * PAGE_SIZE;
+		put_user_pages(process_pages, pinned_pages);
 	}
 
 	return rc;
-- 
2.22.0

