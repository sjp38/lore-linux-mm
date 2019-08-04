Return-Path: <SRS0=U/7Q=V7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0AB1C31E40
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 19:59:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6A1902075C
	for <linux-mm@archiver.kernel.org>; Sat,  3 Aug 2019 19:59:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6A1902075C
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 1AF816B0006; Sat,  3 Aug 2019 15:59:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 187A46B0007; Sat,  3 Aug 2019 15:59:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 09D096B0008; Sat,  3 Aug 2019 15:59:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id C68756B0006
	for <linux-mm@kvack.org>; Sat,  3 Aug 2019 15:59:05 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id j12so43653752pll.14
        for <linux-mm@kvack.org>; Sat, 03 Aug 2019 12:59:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=hAAPf9o3GFQ98ap/3N6Z0MHRNPvvF/o7ljIAlON1qEM=;
        b=SeFOC8oSNJmo4+yFNTjNKD1M40PDujesETPH+AYGQaRBYSBoUITg9U1ZjWa5fOE0Il
         WAf4ZYJadSD+CjFyAmxl+tIilS6plT5RLbRUcDMxbMdgZ9xdeQ5FDpsdvKbfFAzeJtdN
         b//ncTJ4Izf+5KamgIQaIB82FjtQz8OUf4/k/nMQTBj7cKL4goFYJ3E9MKHQk5lsORq9
         XD+hcnwR0Frfjwf3sepJKVpdjCk7OdL+kO42w2XJtcdUOTBaLVc9xBfE4ne2swdn7xU+
         KKARG+VK/vGNi9Du9eTpkYm4xOdl37mWnpqP3TFiUA9MZVbZYcptaoPqQGK6XhkrOtmr
         7WUA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAW7ylFi5ZqBYBMFa1dijD8C942V2laX8pRA//LpS4huv1bFU9LJ
	ZUFjMSUpVKxDOScGAXK+Kn3KlujlCQ1l7DsI3jjVHAejSvme1kEWBIslG+LhIgSjHKP5kHcMb+2
	hMb97Rw9Z+Lv9S55Ls5HG8cS4AzN9ssPNbG5x60E+FpkgttblZRCBQlPne+XAhnz09Q==
X-Received: by 2002:a17:902:8689:: with SMTP id g9mr127932603plo.252.1564862345384;
        Sat, 03 Aug 2019 12:59:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwe0wcVAxfEM6Esolnb/Alg4wA00TvLN0XOnD9w4nkDTAtqfuGoJvMCcUnyNmErdw0Q3Hl0
X-Received: by 2002:a17:902:8689:: with SMTP id g9mr127932564plo.252.1564862344263;
        Sat, 03 Aug 2019 12:59:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564862344; cv=none;
        d=google.com; s=arc-20160816;
        b=rPmmt5dLjX1Ns4yIlecasCqPSjTHz++joxRLlwVrlGkGCE4IBdd0+kontd6A7csedL
         uWkkqj8GmXIJPMp2PZYPeuRlrPUPKLQ1nC+DAvrBIZKPLcI74O3GJOktGuJ+JSNoYIEd
         vJRLGl1Yk1bJ/5MLngRSv3ZLxTvdaM4U6LAWKzPoFWjgpBZag6qKzmfrYxWmBI0eIxDU
         rY4Ldu56eD/SlQ6tjDZBZev6jfARD/aX+2ZqoQpAEBMmgd7i4QOdwnSsaN8s+Co+WV5X
         PrHfyV5zpMVwqURGYg0ObymEfURS20I8bXisH+fUu7xAlp/lDQkHdY7kJzwksv0lkCVC
         SY3g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=hAAPf9o3GFQ98ap/3N6Z0MHRNPvvF/o7ljIAlON1qEM=;
        b=KV2XbFmAYWyQqfhfQqwcSb49QemY9kk6X6j5EM0XQ4/e/1XvcoXSCYOtOtTa6d3ez8
         n58TnJ44qILiLqwGlJ2XfGWKtLu1spA7FBr8YSdfnKex+nIx66QfIRr6+pREGpMao8c9
         OOQrvmIqWC++jbikYDUcbfj6o8I0sBsfUAgdtbc8ay1sHyDtu9s+81sNuau5EtOGVEHy
         Afe/Azvjt9Fs3att7GVHmYX3cnmgow/Pbfc3Y8Fo8HU0WOofKwGvM2ag1l0XFscvH9p1
         sJ44MGLY+dtNE5JpBMYrCY3P0qCGjNruK+z47XxKpA2wv3p4W7+yRgbGX+41Q2ErEnzl
         yjUA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id p125si40279576pfp.35.2019.08.03.12.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 03 Aug 2019 12:59:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost2.vmware.com (10.113.161.72) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Sat, 3 Aug 2019 12:58:57 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost2.vmware.com (Postfix) with ESMTP id 3A639B26C6;
	Sat,  3 Aug 2019 15:58:56 -0400 (EDT)
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
	<stable@vger.kernel.org>, <akaher@vmware.com>, <srinidhir@vmware.com>,
	<bvikas@vmware.com>, <srivatsab@vmware.com>, <srivatsa@csail.mit.edu>,
	<amakhalov@vmware.com>, <vsirnapalli@vmware.com>
Subject: [PATCH v6 2/3][v4.9.y] infiniband: fix race condition between infiniband mlx4, mlx5  driver and core dumping
Date: Sun, 4 Aug 2019 09:29:26 +0530
Message-ID: <1564891168-30016-2-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1564891168-30016-1-git-send-email-akaher@vmware.com>
References: <1564891168-30016-1-git-send-email-akaher@vmware.com>
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

