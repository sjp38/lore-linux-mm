Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DATE_IN_FUTURE_06_12,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5619DC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:03:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1B552212F5
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 13:03:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1B552212F5
Authentication-Results: mail.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=vmware.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B708B6B0007; Mon, 24 Jun 2019 09:02:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AFA048E0003; Mon, 24 Jun 2019 09:02:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 972BC8E0002; Mon, 24 Jun 2019 09:02:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 642146B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 09:02:59 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d3so9353561pgc.9
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 06:02:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version;
        bh=WlB3EgfbNvNkzCBJJCkZdYVxKpEST/NPutqyeaBnRhg=;
        b=MHIaWdT6V0uOBxxEtH3tdRMiXbFEmCH8SqHVkw/2VMp4PnkrejTwP3kg7IRWAuSPtt
         zv1NO0EpX+7kIkq/6V4Rmu2NW9SRf+sIITZe7CpQItt5w/zDqO4FwllgkfaIXkV5s/Oa
         7SNjwhZGHxlk+l7vPIPIqhkZ/EDZLOI6qwXRgTU4dTEJzTE2PsEyNeUgrAPhOdRrMvsS
         HYOBsybhznVCHnK+a5Iq17Z5dbe1KjpsZcZyW5Y+vvu3+ORblPHbf+xZYEi++uuZ46Jj
         MvN12ANBualEisiuIVI6xLMDtazaHoJ2DMfso4gHBl0ZyaNLnBLdDAVeOEovhTOcBmD3
         H64A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
X-Gm-Message-State: APjAAAUYEEGg29qndTU9I5fvgon04Ix2JUyUNNP+l/lkKlE5ivMgng6s
	i37h+lM4VXdJL5O+eSIkEnhmAYZTJNk2pXSFk7/90mZObo3t6JByXjSGSyEgTngeTdkdoXtF6Yc
	Xe4eg018TBXo6x6T9R6SOroveQaJeOqNlBHrfoNhl64c0wWwLxxq0LePhrSQtV/+TtA==
X-Received: by 2002:a17:90a:d983:: with SMTP id d3mr24322989pjv.88.1561381379097;
        Mon, 24 Jun 2019 06:02:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzCgtf6QxHXH6C1HDWDuzpnGBKaj/2bySKu85TqciWW5tkfLlKi4A8KvyZmVNB0oM2jgW5b
X-Received: by 2002:a17:90a:d983:: with SMTP id d3mr24322906pjv.88.1561381378408;
        Mon, 24 Jun 2019 06:02:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561381378; cv=none;
        d=google.com; s=arc-20160816;
        b=U47sRwdmd5nUnpK8PNtGlcAvf8sX7jAAC+DzcvWUGJDjYrFatOZf3gF/ncYnh7EU/0
         xaFV/nnAOFJK+OjXiPUp/vY5VaQ3sj7lAMAaVSGLCYUKNsDhUx3p3zL1IpQEBN1pwaBL
         U3pUhTx77l/AJryVuEKlNPQxeEZ7z00JDg5770yNqq6pt36DJaIfxrYMIrHvnJryJm2k
         DXl5y65GYVfF8EScFCQUlpUGm9LuKTkf1o5SRyn5mYMeHTkfV+Wog9uTjmZ0kGUz4GpO
         51g09U0kAThQMjt9PV8FrXOcSsdbJl5gRipHx9tByGOTIyHoos7SgEidLx54iiDW46z0
         oq3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject:cc:to
         :from;
        bh=WlB3EgfbNvNkzCBJJCkZdYVxKpEST/NPutqyeaBnRhg=;
        b=wMFp98DTOTQLAUQl2WL3x6BjHyAyBGDjergq0dan3tCi/RRcuPUAF5f7v4vAOg57TK
         UwUmUmV/sTClHV+9Wlem+px42s7/A48zA6GVQWtSsXCD5xPFlOSIGg3hCYw0Dnuz4Kak
         ugmuuwiMdjFjRTaXtkaoaPHjsXv9eeGfUuy5BvDS610PVc1Vv1G4OBYPoE7PXB/lJOY/
         eCaLeX684rczNBvKHASapwvuUFMkbe0RCveHqqNHQyqcqGEPKGuf6rcAigtY0G4Tys1s
         wa80anXGoVwQTavtZlYm2pAVSo3UIF5ZnJ4QRRpLEIpmpwKTzrOhB36xy65ptdRzqDPS
         G/ew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id v7si11880352pfb.132.2019.06.24.06.02.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Jun 2019 06:02:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) client-ip=208.91.0.190;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of akaher@vmware.com designates 208.91.0.190 as permitted sender) smtp.mailfrom=akaher@vmware.com;
       dmarc=pass (p=QUARANTINE sp=NONE dis=NONE) header.from=vmware.com
Received: from sc9-mailhost3.vmware.com (10.113.161.73) by
 EX13-EDG-OU-002.vmware.com (10.113.208.156) with Microsoft SMTP Server id
 15.0.1156.6; Mon, 24 Jun 2019 06:02:56 -0700
Received: from akaher-lnx-dev.eng.vmware.com (unknown [10.110.19.203])
	by sc9-mailhost3.vmware.com (Postfix) with ESMTP id 8452E412C5;
	Mon, 24 Jun 2019 06:02:51 -0700 (PDT)
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
Subject: [PATCH v4 2/3][v4.9.y] coredump: fix race condition between mmget_not_zero()/get_task_mm() and core dumping
Date: Tue, 25 Jun 2019 02:33:04 +0530
Message-ID: <1561410186-3919-2-git-send-email-akaher@vmware.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1561410186-3919-1-git-send-email-akaher@vmware.com>
References: <1561410186-3919-1-git-send-email-akaher@vmware.com>
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

