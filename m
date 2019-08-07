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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0E678C41514
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B561421871
	for <linux-mm@archiver.kernel.org>; Wed,  7 Aug 2019 01:34:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="oYwU8ETg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B561421871
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CEAE76B0280; Tue,  6 Aug 2019 21:34:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C50056B0281; Tue,  6 Aug 2019 21:34:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AA2866B0283; Tue,  6 Aug 2019 21:34:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6614D6B0280
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 21:34:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id 145so57160290pfw.16
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 18:34:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=GWOFLHbaoJZ22AtxK1h/P9xhWpIm5tckt50uTXPKpp5MPNiYWSS99a3RLu7MuAZBIS
         Z0Gn7fpVmRPyUVojEA3eT0cGqNIT3mxrv+yaSxtAlUWblBJd5g1ZoHmBPiex8xTk69wH
         KEovVYilKFWs+hSNJdyOFTD5ba9RbLzKYEWRrUIV2kh138sTzS2yvn9hsJFT/RVHPMes
         OMwsp++cATIoVaOSo2G6gieRuVTCz6a2/wj3hRHPJRe9OFg7f17UJ9YX90n0Vo1T5XIo
         FXEfXQnowOpglweyUoc2AgT81SW9llMQhtBrYGUR5YQlM9jXtxXsd6IqcrIuaWWK4BhL
         Nuiw==
X-Gm-Message-State: APjAAAW4qSRvRrmCIFFn8LsRHqzitImldtJnWasWX+kMQ9EH8OAVrrDX
	BqjeKjeT9S3NQsTBmT54s/ztOe7ImP32MUV47rhodB7asLAjuJlmtyyS10oWmiHi+yh8vxwAfq8
	Z4leYotqwe6EqMV07wFSCB0/ZWDXp3CGGoWFYxORI50d1h+JO4vmUv0MY93JJQ1gzQw==
X-Received: by 2002:a17:90a:24e4:: with SMTP id i91mr6233647pje.9.1565141676089;
        Tue, 06 Aug 2019 18:34:36 -0700 (PDT)
X-Received: by 2002:a17:90a:24e4:: with SMTP id i91mr6233582pje.9.1565141674888;
        Tue, 06 Aug 2019 18:34:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565141674; cv=none;
        d=google.com; s=arc-20160816;
        b=hyBn1H51eVwN5ew+sr+PJaqP5FuxJujeqy2OSsM0xSh6Q5amdKhQI+UW/t8DmVBiu6
         C/Q80W4X0nCS1y6PSpXqeQUoSwR3rA6NgmCuJ75ZOA00p9MVFqiN7uF497oWL5FG2kZ/
         NpClfqSeKjMpf0qfo2ETzg+fU/t6K0qULQRzSJoXgtimZogUZNM6yiNwgBZfT8FTBys5
         QwVWsm4jgMbo1SWqrD1RnJJZukMzyOtgusEUf+BgY0W7NdHNOfYzhvPib4sicTBXc7ng
         CNkUGl97HlAlxnogBDU4mk72Z672E7PyVo1krmIuZ9tM+/dvSSwEZKXGGeQFYNWRkcmp
         uxIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=I7nqe82UbP5fXFLIFH7wmisERWVmEU6EdT/EAfS9nUjsrNhUpWzm7cvZdS90hfyiqM
         Oz35CUHCqlZ2iwxYdAYdzq184W706A/Qc5EuEObT9l0WsltzIOtmdmeBGyyQSc56QJXD
         QhcUJAcHRHC3p0PeQpnYr6NLhJ1VCqFx1Row1B5wPafOx0u1s+dKkK52kdeef/J5nNB4
         eGh0QVcNqPAe6hq/5WzvFag6ZSgtYjTfy2hQdWJFymK9/AwBIbQ5+cbBm4oiHbxBsbOr
         OMApqicSf1y40X2pVCUvAmp9Lly/Bs4AjZ+vjDbZLbhXoB1AxYMK81YbJZ8HQzfRzxAQ
         bqCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oYwU8ETg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f2sor105961727plj.43.2019.08.06.18.34.34
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Aug 2019 18:34:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=oYwU8ETg;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=P44t64b1Yt2CczJo6SOAPYnnEfAXhRMhGjbg0YSdFKY=;
        b=oYwU8ETglc6KiHkcA0RyRS5vGqCW2i7AIOfUQ1rGo+vD39eROBW26/892d5mL8jCka
         9NN3Xib7WtATsBiYJqkB3ezAv9jDjLgX0Nt2lJwKPO87RMwjfI/ercmqj2pogsz06Wb7
         pt7t+tRi22lEyEbjwYG4pvxEn5EP2upJ7sBYXvkRkx1OZr8K8A0zsi1zsXDmxeKjKGdS
         rd7sOAmNlVKLyRrCXgSP759pVqt58t0Qr3CX/SHM65KMfp9F8GOgkLwibGL9VUlsrg7f
         RCrbiDazxsGGGqq8tug1r4v+hpbk+DodA1qAwxGhZjgi6TOY5xhcloApNp8UIjMczhiZ
         1TFQ==
X-Google-Smtp-Source: APXvYqw8+L1VoxRPbf6Y+c4qD8GNaA9eNx8R+zkKMbLiZR/mjctguTvKD53OkN4n/knnADLxacIAYA==
X-Received: by 2002:a17:902:7782:: with SMTP id o2mr5960829pll.12.1565141674655;
        Tue, 06 Aug 2019 18:34:34 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u69sm111740800pgu.77.2019.08.06.18.34.32
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 06 Aug 2019 18:34:34 -0700 (PDT)
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
Subject: [PATCH v3 31/41] mm/process_vm_access.c: convert put_page() to put_user_page*()
Date: Tue,  6 Aug 2019 18:33:30 -0700
Message-Id: <20190807013340.9706-32-jhubbard@nvidia.com>
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

