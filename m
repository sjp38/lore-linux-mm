Return-Path: <SRS0=cFM0=SE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77BDAC4360F
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 290CA2082C
	for <linux-mm@archiver.kernel.org>; Tue,  2 Apr 2019 20:44:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="1Db4i7+5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 290CA2082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B486A6B027A; Tue,  2 Apr 2019 16:44:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ACFC66B027B; Tue,  2 Apr 2019 16:44:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 971CA6B027C; Tue,  2 Apr 2019 16:44:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 78BB86B027A
	for <linux-mm@kvack.org>; Tue,  2 Apr 2019 16:44:40 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id e126so11760838ioa.8
        for <linux-mm@kvack.org>; Tue, 02 Apr 2019 13:44:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=fAYAxmDQUAFF/V4uXClSMnViHRm6i0GISHNgrEn8/T0=;
        b=nYyp5NHLktVn6P1cfxUZUL94qwHXcjVvqsRleKpVm4h0NsjM9NCtTSzMyyq7e9wb19
         lrYUU3ClkvTGN2UimrWJIqNFV3NLToQjwdM/qJ50el8UlOhpddfYVKoZsJT1ow0M7gSz
         Ys8IjJFnJ5x5ZSpPAv+6jfBR9gKQdXXR8GRG7acySL38b7Y1L/rpUGJNcXxilvqN2yZ7
         qXZMOXoDPFJ1kvrCzrI7MblDg5Mlc0U9KboeBOkMrtphIzaVmIXNuXGPE2ZThXgGMYS7
         UegdiiRy3XxhydsM3JPYp2C34Dc4wpVczWW/QxJ1h7luEbb0IhDokgR56INy4tE0jfQo
         3URA==
X-Gm-Message-State: APjAAAU9uTcuzS22flr/e6dXrEwjmjIYQI6oUgFELGtZeeR89EKU8GGY
	A0w+9+4K8MaIUyLyHASjVUy6gCG4QEGWD3fyYjZtSyAxB2C/qQlU17Av58ysPzGfiuyXl8tV/Kx
	MYi2lHAHQNhG0XsFYu0ji97LXSniFGpmXDu1/l8QdgFGPVwzQPKWC/KF473jvetqK/g==
X-Received: by 2002:a6b:7108:: with SMTP id q8mr32709347iog.85.1554237880270;
        Tue, 02 Apr 2019 13:44:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwKZQ3XEXcr3F/nlh9kFRrHnmok/ZGXhEExvmSfe/9psibXI2u0e152KwSTVK+S+KBGcytt
X-Received: by 2002:a6b:7108:: with SMTP id q8mr32709298iog.85.1554237879003;
        Tue, 02 Apr 2019 13:44:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554237879; cv=none;
        d=google.com; s=arc-20160816;
        b=l3pKmYd/GG1srds0k8zYolkg4MD42+ZpwuNsBj+6d9B1uw1dibdfaHCOwQZYIPvCtN
         HZLjGFMlpwgoCkelOV0WOeD+1QbcfCDBheckAIyVhVijYWNHKM6tYyl53KD0K1kc9msa
         B0GIhzQZFyY1H4ahBvVDvJALfH59v4SRkW35VKtZL/AgZZVLiC5ecXNCHo4vsTBc0m24
         Z+yaZzTM0uxuf+6ihuxbeKNbBJQjbY5Nhf8Gv4jfZs7f1iCFAeXKItZ6ynvZrKti8kFm
         eTGe6aAuej3VeG7HjV96Lyx8MtnbFxJWY0pHlbSaHym2Rw/IG/KnnTqu5cBbDZ6gGPIw
         HnIQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=fAYAxmDQUAFF/V4uXClSMnViHRm6i0GISHNgrEn8/T0=;
        b=O3EHHd1VIAK57nB1PVj4pME+GaFEVsTwWMo1rNYXFGKGrdDQOuFbzLlZ0KMaYngIvg
         WhAQuPk6t8pECucEo9XxyUJyDx8ywc4iwA4UtGwV3vYHUpa39S87gE6/yQonD01054wj
         KqOWvOS2R9Jk4kUWpMDwTAIu42TQKlwZamKRqvTo8P0ryBEc28OLDKMF87REhXMWFRE4
         P+VhosFs724io3A3L2pyg5EMW9DEVl/kslAjBD46R8RKoA53ogEUG04yrb3OQN5RmeP1
         pl2dSP76YPPR+HensvWPml16FKaoJ2HDxAUOmCquSP07QMOE3jevRnxGUSaJJc0G+vTT
         CnXg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1Db4i7+5;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id m2si6936875ioj.9.2019.04.02.13.44.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Apr 2019 13:44:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=1Db4i7+5;
       spf=pass (google.com: domain of daniel.m.jordan@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=daniel.m.jordan@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32Kd3or163977;
	Tue, 2 Apr 2019 20:44:32 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references : mime-version :
 content-transfer-encoding; s=corp-2018-07-02;
 bh=fAYAxmDQUAFF/V4uXClSMnViHRm6i0GISHNgrEn8/T0=;
 b=1Db4i7+5QTdvuvzmOABCOx/rKduKmOFCPGRVprrFpS4dMFTzLojfS7ykp8TBYOzgp6zY
 8P35z5ZLaWeBPaHuenEidBxoo2DL5tmyrNWrdyFhv4XeDZAq5KtPCKKdaA2NY1HjuW0b
 UuvnV3+uYld/y+6agytQUQm2fU3HwT7sOULBUeaR5XyYYSJrmn85pitVdxeCDkBtHkan
 Eejglhyb4LcN/RILi+Mo3LVfwShqb//q1rCvklXxwVJuxd0TCmDsWlN0sCjdC000J1cN
 BT8XsWnEWY+bD0/jjXtxx7WlF8eSrJlpiSlwZhHMb1njCz6VzdqdcpH6zqpx3ASn5w7L 6w== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2rj0dnm0cb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:44:32 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32KfgSY004926;
	Tue, 2 Apr 2019 20:42:31 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2rm8f4qkf5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 02 Apr 2019 20:42:30 +0000
Received: from abhmp0009.oracle.com (abhmp0009.oracle.com [141.146.116.15])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x32KgN95019599;
	Tue, 2 Apr 2019 20:42:28 GMT
Received: from localhost.localdomain (/73.60.114.248)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 02 Apr 2019 13:42:23 -0700
From: Daniel Jordan <daniel.m.jordan@oracle.com>
To: akpm@linux-foundation.org
Cc: daniel.m.jordan@oracle.com, Alexey Kardashevskiy <aik@ozlabs.ru>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Christoph Lameter <cl@linux.com>, Davidlohr Bueso <dave@stgolabs.net>,
        Michael Ellerman <mpe@ellerman.id.au>,
        Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org,
        linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org
Subject: [PATCH 5/6] powerpc/mmu: drop mmap_sem now that locked_vm is atomic
Date: Tue,  2 Apr 2019 16:41:57 -0400
Message-Id: <20190402204158.27582-6-daniel.m.jordan@oracle.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
References: <20190402204158.27582-1-daniel.m.jordan@oracle.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=29 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020138
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=29 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020138
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With locked_vm now an atomic, there is no need to take mmap_sem as
writer.  Delete and refactor accordingly.

Signed-off-by: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: Alexey Kardashevskiy <aik@ozlabs.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Christoph Lameter <cl@linux.com>
Cc: Davidlohr Bueso <dave@stgolabs.net>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Paul Mackerras <paulus@samba.org>
Cc: <linux-mm@kvack.org>
Cc: <linuxppc-dev@lists.ozlabs.org>
Cc: <linux-kernel@vger.kernel.org>
---
 arch/powerpc/mm/mmu_context_iommu.c | 27 +++++++++++----------------
 1 file changed, 11 insertions(+), 16 deletions(-)

diff --git a/arch/powerpc/mm/mmu_context_iommu.c b/arch/powerpc/mm/mmu_context_iommu.c
index 8038ac24a312..a4ef22b67c07 100644
--- a/arch/powerpc/mm/mmu_context_iommu.c
+++ b/arch/powerpc/mm/mmu_context_iommu.c
@@ -54,34 +54,29 @@ struct mm_iommu_table_group_mem_t {
 static long mm_iommu_adjust_locked_vm(struct mm_struct *mm,
 		unsigned long npages, bool incr)
 {
-	long ret = 0, locked, lock_limit;
+	long ret = 0;
+	unsigned long lock_limit;
 	s64 locked_vm;
 
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
-	locked_vm = atomic64_read(&mm->locked_vm);
 	if (incr) {
-		locked = locked_vm + npages;
 		lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
-		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
+		locked_vm = atomic64_add_return(npages, &mm->locked_vm);
+		if (locked_vm > lock_limit && !capable(CAP_IPC_LOCK)) {
 			ret = -ENOMEM;
-		else
-			atomic64_add(npages, &mm->locked_vm);
+			atomic64_sub(npages, &mm->locked_vm);
+		}
 	} else {
-		if (WARN_ON_ONCE(npages > locked_vm))
-			npages = locked_vm;
-		atomic64_sub(npages, &mm->locked_vm);
+		locked_vm = atomic64_sub_return(npages, &mm->locked_vm);
+		WARN_ON_ONCE(locked_vm < 0);
 	}
 
-	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%ld %ld/%ld\n",
-			current ? current->pid : 0,
-			incr ? '+' : '-',
-			npages << PAGE_SHIFT,
-			atomic64_read(&mm->locked_vm) << PAGE_SHIFT,
+	pr_debug("[%d] RLIMIT_MEMLOCK HASH64 %c%lu %lld/%lu\n",
+			current ? current->pid : 0, incr ? '+' : '-',
+			npages << PAGE_SHIFT, locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
 
 	return ret;
 }
-- 
2.21.0

