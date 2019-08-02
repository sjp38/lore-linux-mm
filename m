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
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6826FC32753
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:23 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1ED202080C
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 02:21:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="bmiw3CX7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1ED202080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 160B56B027C; Thu,  1 Aug 2019 22:20:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0E5FA6B027D; Thu,  1 Aug 2019 22:20:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EAA5D6B027E; Thu,  1 Aug 2019 22:20:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id AD6886B027C
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 22:20:55 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id w5so46432737pgs.5
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 19:20:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=PcHbEInYP+oas7bxzYf9pXprVZ4asBF/W2/zFLDMa7ceXNBWg0kYoOJvvGszlnft3t
         BSVsmkS3FrUxMdRJ8HDnKqemBoCJLPlly2mGxpF/Dc1nnf4W7ZaFDgLB10/5J/uPDbXI
         oSo82qyHlbrLWcdcsTAwql6Y5n6nZMpXfpJ+VFwBnW29kmFnSLlV8ONWdI6tKoI5hsZc
         UNUfKlgXKBo7Z6SwvdJVk84gwKfpd4z0ZUuFkfEu/o/m6p/2/FQWCy+7nRzxKiP+R3II
         4tALSfzWKWCG+iXE3wujd44tRh5x5QLQ0DN/iXMf3xd8ihsCKi7OuFp9PRNTG0bZS1ob
         E+PQ==
X-Gm-Message-State: APjAAAWc+Kjvi/nc/77Vx4i3sLP+diiWob7NilLL1vVEAuQSNQXuwAPJ
	oE5h9BMDk2BmW0z2VNTUzeLVjkla1W8olEWqJ8JD7ONLe5KfsgYxl5qGDRPBpX8GkZbOaQkyBvm
	1Ul65iAfH1ilt3ZcTcKM7TKvqgMI6ercAD+9bqhxz9BeGmFNmm/Ar02kjPY3nmt98pw==
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr124368747plb.203.1564712455382;
        Thu, 01 Aug 2019 19:20:55 -0700 (PDT)
X-Received: by 2002:a17:902:2869:: with SMTP id e96mr124368695plb.203.1564712454435;
        Thu, 01 Aug 2019 19:20:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564712454; cv=none;
        d=google.com; s=arc-20160816;
        b=EbvcAbjW83UVLzwyIF+DBZVgE95YB5OM1KOaqrw4/FFvK1oJ42PCq4mq4S8zwspbxw
         SKE3LZo/nWsfJur97MEAhyIIhO8n8+18RWRfiYp2/F0e7utpaaYI0krsn8GnLxuIfEy1
         HW+RmwCI0sWqxayPx0lIQ1930IEaEOUVpPKclC/griGfM1zL+Elw8zChrRPwot76V2n4
         09wpJgRmPcHNf3PPLEiWpSbaH2pOPh7e8ehA+UjiBoG1mbs+yXbnAHEkSE85aD/3Wn3a
         SPCGmBAZ6GgKz8t3FuLNc97ItKfkYLUqi8P/kcyBx+6dB5xfb+s+olE0txHDT/p3tj2Z
         Bmhw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=vX/cYZVgYNT2AbdJObT1Q+WiZw8ZTg1ZKTd+D8FcO9M0WiyoK6gt59CE4akJZiTPru
         ErZuDrYhVPEpiHRyHjpaVcHQ6UHOS9sjqC1mZNcaW3c+AosjegS5HN2a9IqwWtxXrm4u
         1kZNQeoGd3wxW+7h8BzLNEHiKaqYccTLk6zwcZr9AEY0UzMavn6PxUkw3H7LfcuPpp4t
         2lsWsGZ+w8vW+n4VDGD/WmW10qHW3I2QThzgaqAtWlMkeFjwkSy0TXbYGScI6rNffZd/
         IjP4WM1Td7r9UTyYTL7PskVwS7TD3FK2/abU4frt19VimuQrWnxRtvdFEcD1itfW9eWs
         C7nw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bmiw3CX7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a1sor29177427pfc.63.2019.08.01.19.20.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Aug 2019 19:20:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=bmiw3CX7;
       spf=pass (google.com: domain of john.hubbard@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=john.hubbard@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=GAYBkmVoEF3i3+udFKn42Z4HyLG0jAAiACtL32v96bk=;
        b=bmiw3CX7eWARhNE7AvtkZmQS4x25Aeig4lpzknXcIaYlaD2lFjd7SScDpJpgYkkx7H
         M9zB+YKzWGQiUxpLMFNGr5C65PRt2twJ1gMudyUxXC2keVru4Xjo/FbRHcQrMN3Y+TrZ
         eo41sq59jY3La9DLko+7E0ikMqlCsHblNQuS0OdL1WxPMxgnPsNhJmLosVpKu/cSt2yk
         /jFkZ5J0l+DrkETHxtxwR7Cu6qeEDmLrh7LIOTNKe2v9mBpFbaPnHS0W/dcoeyOSz4Iu
         4HCVwyMi41Z2O7etDQGq6Zv3vzS7McPz5uoywJBAMCcGAE7RrRQ8O1qBbeYiWwc/8w4w
         LKxQ==
X-Google-Smtp-Source: APXvYqxC0ya0xWU0ncqxEWJISgZVi9PxJ3dzG7YEhtGnuj+4PZQMAaeHdCEV26ObbLm8aGFRS+hMhQ==
X-Received: by 2002:aa7:9481:: with SMTP id z1mr57240070pfk.92.1564712454191;
        Thu, 01 Aug 2019 19:20:54 -0700 (PDT)
Received: from blueforge.nvidia.com (searspoint.nvidia.com. [216.228.112.21])
        by smtp.gmail.com with ESMTPSA id u9sm38179744pgc.5.2019.08.01.19.20.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Thu, 01 Aug 2019 19:20:53 -0700 (PDT)
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
	"Aneesh Kumar K . V" <aneesh.kumar@linux.ibm.com>,
	Huang Ying <ying.huang@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Rik van Riel <riel@surriel.com>,
	Souptick Joarder <jrdr.linux@gmail.com>,
	Will Deacon <will.deacon@arm.com>
Subject: [PATCH 27/34] mm/memory.c: convert put_page() to put_user_page*()
Date: Thu,  1 Aug 2019 19:19:58 -0700
Message-Id: <20190802022005.5117-28-jhubbard@nvidia.com>
X-Mailer: git-send-email 2.22.0
In-Reply-To: <20190802022005.5117-1-jhubbard@nvidia.com>
References: <20190802022005.5117-1-jhubbard@nvidia.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
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

Cc: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Cc: Huang Ying <ying.huang@intel.com>
Cc: Jérôme Glisse <jglisse@redhat.com>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@surriel.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Will Deacon <will.deacon@arm.com>
Signed-off-by: John Hubbard <jhubbard@nvidia.com>
---
 mm/memory.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/memory.c b/mm/memory.c
index e2bb51b6242e..8870968496ea 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -4337,7 +4337,7 @@ int __access_remote_vm(struct task_struct *tsk, struct mm_struct *mm,
 						    buf, maddr + offset, bytes);
 			}
 			kunmap(page);
-			put_page(page);
+			put_user_page(page);
 		}
 		len -= bytes;
 		buf += bytes;
-- 
2.22.0

