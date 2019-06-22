Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DC4CC43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 05:02:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5D4AA20843
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 05:02:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5D4AA20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 125836B0006; Sat, 22 Jun 2019 01:02:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0FD688E0002; Sat, 22 Jun 2019 01:02:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 012F08E0001; Sat, 22 Jun 2019 01:02:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C08EB6B0006
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 01:02:16 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id b24so4687282plz.20
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 22:02:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=WlB3EgfbNvNkzCBJJCkZdYVxKpEST/NPutqyeaBnRhg=;
        b=USUnqvGRXi2pgT4/PjZ6/nCu8Jl7CrSuUHk3zdrvlqgt+TffvPILTvlboTjGLS7An+
         SLEKHy84htjbcmbkdvCqUamE9n+2TqegPCA3q+aqYo97xEMtRdjDLZ4IfmVP2nMyZg3E
         dnMkNMv7+5XXmFiO5HTN+38jmMVDXUB+tPveSO2iv3m0sZbBwnz/mTND1unBxcYZfsNi
         ggS3MzuSCJ28DD/rR9nmePygfG28Hcvz7eDtJ03KJ6d3u0UMZ7TUoivh9DyEkNvPHhY5
         9QnkXVRBtNC125dNTQsL74zcOakmQO/4M8NW+v7KMIOPnGQSrHtXEoi2057xsnFPkbb9
         VC/A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUs3Cy6qUGt9A6+U8R5wkeRKf1UYCEvyUdamqGbazwTnw3C+mmu
	EUamMTL66dqcrzuRajvkRgha1DJlYbLZTRKozC91m7TKDVbDEaFpQEUQAQXMKZqaZ99mGrkWExM
	/DN++/B16df2hnR2kSwJsP7m6MarXbR2f5Tkv+qj3W+DEgX8YxWKHF+ca3qeLrRta3w==
X-Received: by 2002:a17:902:aa0a:: with SMTP id be10mr131797709plb.293.1561179736474;
        Fri, 21 Jun 2019 22:02:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxyLUwnWqTrhj6VQPWCvq+9SQd95LfQqOXnT5Ki+2BF4DwIuZU4soOYo5GHbM6ijdTVG8dX
X-Received: by 2002:a17:902:aa0a:: with SMTP id be10mr131797665plb.293.1561179735850;
        Fri, 21 Jun 2019 22:02:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561179735; cv=none;
        d=google.com; s=arc-20160816;
        b=Pzb2M0ThsZ9KfgQIZfXg3hf5LcHk+22ouXsc2mscRR/rJoITXKzXj+m/4yNJDhpEj3
         d1DCmdmwxDJzk7NMyUEdmwiIlAal1m7c834JCZTvIO9i/91kS81IZ7O3xlFalr3km++2
         KNhL5TogbbSUDGQX/Fx+9kKEx6tPVjOQEghUuLzwAUhJ1/XUhPdNxYNhaLFFqNhKkzHe
         9ylnFscoPoWF2/Ue+oQ3W/gJxDq08OVP9SeM/08C+xDOqd/DNC5gRLvZI422ntAVygCZ
         jCbrHBJw4Akbx0MlwsuVtWYyG/VXb4hTyrHsxX85SERdPEnsc652eWz7MrpCwarIv4nZ
         BGtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=WlB3EgfbNvNkzCBJJCkZdYVxKpEST/NPutqyeaBnRhg=;
        b=EAYhjajJd9mZ8T/Gp+GBKHblKoetijq6LXeS8evrp7+VUHlzT9y3BZ/BMEVX0zN6zs
         PG935M1Sg+n5Y3q1ILEs9tdINnYz2tTupYCvD8ACAQour3WWnTuFGbqa3PRxhih/LP0W
         szDYI7JKwdgCIP7aqh5pL6b/MjiPhfpdYWAMSzScKK1B+Z6cLBXv3XWNOHYQ2/GmzbNn
         avbYhh1FxmGZClasN6aF4D2XuWdqDvIjgu7sRPBlwn/cUbj8nyxbly7d2L7UJXITu7LO
         ysAGP577swgjakKmL3DJha5jue1XUyDs0wj7yExn/GgLs6JIO0pUet0LnSH5ypgpfm3H
         XiEw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id e1si4461992pjr.28.2019.06.21.22.02.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 21 Jun 2019 22:02:15 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Fri, 21 Jun 2019 22:02:11 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 07D5C416DE;
	Fri, 21 Jun 2019 22:02:08 -0700 (PDT)
From: Ajay Kaher <akaher@vmware.com>
To: <aarcange@redhat.com>, <jannh@google.com>, <oleg@redhat.com>,
	<peterx@redhat.com>, <rppt@linux.ibm.com>, <jgg@mellanox.com>,
	<mhocko@suse.com>
CC: <jglisse@redhat.com>, <akpm@linux-foundation.org>,
	<mike.kravetz@oracle.com>, <viro@zeniv.linux.org.uk>,
	<riandrews@android.com>, <arve@android.com>, <yishaih@mellanox.com>,
	<dledford@redhat.com>, <sean.hefty@intel.com>, <hal.rosenstock@gmail.com>,
	<matanb@mellanox.com>, <leonro@mellanox.com>,
	<linux-fsdevel@vger.kernel.org>, <linux-mm@kvack.org>,
	<devel@driverdev.osuosl.org>, <linux-rdma@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>,
	<akaher@vmware.com>, <srivatsab@vmware.com>, <amakhalov@vmware.com>
Subject: [PATCH v3 2/2][v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Sat, 22 Jun 2019 18:32:18 +0530
Message-ID: <1561208539-29682-2-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561208539-29682-1-git-send-email-akaher@vmware.com>
References: <1561208539-29682-1-git-send-email-akaher@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Received-SPF: None (EX13-EDG-OU-002.vmware.com: akaher@vmware.com does not
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

