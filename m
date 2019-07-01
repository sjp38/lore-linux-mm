Return-Path: <SRS0=jfnU=U6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.0 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 945BCC06510
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:32:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 582F3206A3
	for <linux-mm@archiver.kernel.org>; Mon,  1 Jul 2019 10:32:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 582F3206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E8BF68E0006; Mon,  1 Jul 2019 06:32:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3E038E0002; Mon,  1 Jul 2019 06:32:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D04D28E0006; Mon,  1 Jul 2019 06:32:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f205.google.com (mail-pg1-f205.google.com [209.85.215.205])
	by kanga.kvack.org (Postfix) with ESMTP id 984C98E0002
	for <linux-mm@kvack.org>; Mon,  1 Jul 2019 06:32:26 -0400 (EDT)
Received: by mail-pg1-f205.google.com with SMTP id s4so7410189pgr.3
        for <linux-mm@kvack.org>; Mon, 01 Jul 2019 03:32:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=hAAPf9o3GFQ98ap/3N6Z0MHRNPvvF/o7ljIAlON1qEM=;
        b=OCZhtvOXNalHQDcFQxQndnu2dEXZvCTRITpxZ6eVy9bEEWEazLc2QF+w55F3Cko18D
         sO+hvMOVSOuhZ8g5StNYxfiQBqnK+RjPcG9GwFUKLfJvPjP3JEXs8HxbtUBuOpOsOTVn
         2DeO4tI0e0NJ7ka3TsE4K/oENsppMAxdtU1rnCeehsQc032xeS1Wc6eCpqCqQMohMaNE
         TNiyOrsUXGIBQXkIbXJDc0P5dlppXVjI9VLo2Oujp8d8OXpwDfJY44rcGoeTb29RGG7R
         PGAQ5kfXsjQwyb0StW7Y3S972Jw/IuVUz8TxlKGk3cCP2prrmUpWPbQO7h9DQHzbEuM+
         iaxg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAVj27URC1GFlMxX9lpt4AppEdo7tz7ACfhWixBVGxzzAYLYwVUE
	YjDNdQ94O/MY+4h97nYXObVo2355jFzHPtjCs2+vGlNVLnJMWiG8RhAvc/23St54GChzSxOP0TN
	uFfaKBVMwwKJp074zw2DW8BDDj3cGMqTPp2ULMYvsE5vXlOmvmYIWwB9fS4mWCwJwWw==
X-Received: by 2002:a17:902:f64:: with SMTP id 91mr27500043ply.247.1561977146309;
        Mon, 01 Jul 2019 03:32:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTaFhz03hSCEQ+jhDfY9/UBMv0V3j7alzK8+KjOJyTkce71bBZvCwstQYMR44cAgeEDQba
X-Received: by 2002:a17:902:f64:: with SMTP id 91mr27499958ply.247.1561977145275;
        Mon, 01 Jul 2019 03:32:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561977145; cv=none;
        d=google.com; s=arc-20160816;
        b=MvCYmA9R7v2A+KDnba8HVaQ+c6cn5f9qPecD/DSWcRBIAAFKZ9nTN0xhCli/3SmpN9
         4mYrU6deO7LBiNi9Fe9Rb9YxrRU6NbxEmHyfLujZ2uh6fm52ri/K0PcXSqKMAJjd0o35
         jg6meVcbADIIxq6mA6RwGMPAgrChWcZzKl5r0LA6RGbj6e2g4IBa2LjKAYsU4xzmkMSf
         3lexXaJ4ylevGuYYGMajkb9hoOom8+GHOBOmkSHkQZvScRdgJZUISLHGADAg4ep4hzVZ
         YLJOE/C2NtUVfoxsxwt/RZcN52cY/DLu+rsmRA6ZuFt2bfdInLNxf04Zlg7NZ7cS8pR5
         NzLQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=hAAPf9o3GFQ98ap/3N6Z0MHRNPvvF/o7ljIAlON1qEM=;
        b=l0eeXUZFDUdvSwndvsVsHCgofqE+CZIkNdcab9TzaQsX4xnk5q1nJq5To03vY08v08
         g8r8PN6aLyVP8z0ZqROezohLag5LEaaYOewfinxX98I98WgjCPA/O/XzzBmwFw19kTgr
         7LqYqCQYkByrKCDCgDLIJmPMkevDhgiT5+iNQ6G/joIEftxvbGJVVvQMXpanzzxJDoG7
         RhsStGD8z1bFWZz844MBrMRvED/SgpsLrj6059dRdr1WDthMuhFOLCOmdzxyzdMoBx6C
         M62c5dgXP+OIhvtYLbK5bT3EBDb4wlGOVXhDpyNLWc3pd9U6v1RnNOaiy9+P0nR4qsoN
         EqIg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-001.vmware.com (ex13-edg-ou-001.vmware.com. [208.91.0.189])
        by mx.google.com with ESMTPS id z13si9925295pgj.205.2019.07.01.03.32.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Jul 2019 03:32:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) client-ip=208.91.0.189;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.189 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-001.vmware.com (10.113.208.155) with Microsoft SMTP Server id
 15.0.1156.6; Mon, 1 Jul 2019 03:32:22 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 03F3E40FF9;
	Mon,  1 Jul 2019 03:32:17 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>, <gregkh@linuxfoundation.org>,
	<torvalds@linux-foundation.org>, <linux-fsdevel@vger.kernel.org>,
	<linux-mm@kvack.org>, <devel@driverdev.osuosl.org>,
	<linux-rdma@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<stable@vger.kernel.org>, <akaher@vmware.com>, <srivatsab@vmware.com>,
	<amakhalov@vmware.com>
Subject: [PATCH v5 2/3][v4.9.y] infiniband: fix race condition between infiniband mlx4, mlx5  driver and core dumping
Date: Tue, 2 Jul 2019 00:02:06 +0530
Message-ID: <1562005928-1929-2-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1562005928-1929-1-git-send-email-akaher@vmware.com>
References: <1562005928-1929-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-001.vmware.com: akaher@vmware.com does not
 designate permitted sender hosts)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is the extension of following upstream commit to fix
the race condition between get_task_mm() and core dumping
for IB->mlx4 and IB->mlx5 drivers:

commit 04f5866e41fb ("coredump: fix race condition between
mmget_not_zero()/get_task_mm() and core dumping")'

Thanks to Jason for pointing this.

Signed-off-by: Ajay Kaher <akaher@vmware.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
---
 drivers/infiniband/hw/mlx4/main.c | 4 +++-
 drivers/infiniband/hw/mlx5/main.c | 3 +++
 2 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/infiniband/hw/mlx4/main.c b/drivers/infiniband/hw/mlx4/main.c
index 8d59a59..7ccf722 100644
--- a/drivers/infiniband/hw/mlx4/main.c
+++ b/drivers/infiniband/hw/mlx4/main.c
@@ -1172,6 +1172,8 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	 * mlx4_ib_vma_close().
 	 */
 	down_write(&owning_mm->mmap_sem);
+	if (!mmget_still_valid(owning_mm))
+		goto skip_mm;
 	for (i = 0; i < HW_BAR_COUNT; i++) {
 		vma = context->hw_bar_info[i].vma;
 		if (!vma)
@@ -1190,7 +1192,7 @@ static void mlx4_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		/* context going to be destroyed, should not access ops any more */
 		context->hw_bar_info[i].vma->vm_ops = NULL;
 	}
-
+skip_mm:
 	up_write(&owning_mm->mmap_sem);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index b1daf5c..f94df0e 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1307,6 +1307,8 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 	 * mlx5_ib_vma_close.
 	 */
 	down_write(&owning_mm->mmap_sem);
+	if (!mmget_still_valid(owning_mm))
+		goto skip_mm;
 	list_for_each_entry_safe(vma_private, n, &context->vma_private_list,
 				 list) {
 		vma = vma_private->vma;
@@ -1321,6 +1323,7 @@ static void mlx5_ib_disassociate_ucontext(struct ib_ucontext *ibcontext)
 		list_del(&vma_private->list);
 		kfree(vma_private);
 	}
+skip_mm:
 	up_write(&owning_mm->mmap_sem);
 	mmput(owning_mm);
 	put_task_struct(owning_process);
-- 
2.7.4

