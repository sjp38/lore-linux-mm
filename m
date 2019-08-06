Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC7B6C433FF
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:27:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7D3D020C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:27:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="QnEK1uGV"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7D3D020C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30D8D6B000A; Tue,  6 Aug 2019 13:27:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BF5D6B000C; Tue,  6 Aug 2019 13:27:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1ADBA6B000D; Tue,  6 Aug 2019 13:27:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id E4F7F6B000A
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:27:56 -0400 (EDT)
Received: by mail-oi1-f200.google.com with SMTP id j22so35493212oib.7
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:27:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=APGgD2qTHotK94otaKMSFu+Fqn3rhhV5q78cD+VLKR8=;
        b=GfJaNngG7302YwR4yQoh/p5K8w6tQ82cRUIOqRTCRWrfN0lfEvqZAOEf8/QBbOf1x8
         5VdzgVJ4e7z2dykmVBrMfCQKG8i5g2QHKqHzxfPie3wwjO40hnt+D7Eti80noYRaM4M2
         a67lW6dA5HzHYIH00QXlcOP4rVMWpyu/HpdeMSFhTewCSWhT57FVeGC7d/fC4hUjp5PX
         mk7rA9opEHU+uIbWLjEPol5mRSXOMOn6IoCbByGpZg1YM/uWupVJxnykzIsxhwhNhze4
         JEsVH31oxrGn5lyapYBrBIEt37reum0uTH7FOuECRdv26fYGn4elvOgufGc5wH6ermVK
         oahg==
X-Gm-Message-State: APjAAAVlt+//QyhE/8pm+4Cyp4PDETE56IUmhB3a/6It+c3MRL/6AIzB
	sIt34kyC80/QG91jlS66XurrBr2tZhrbNBAxcv8LjCp/dv3qJZSvb3HClCHvqIPvvx1EYdre46N
	K9vWd3RO23eWhAQp+L3cVD3Uz/PqOGL37z5nJnjFHzVbczssCCaezbjtzTnJLYY10Xw==
X-Received: by 2002:a02:c916:: with SMTP id t22mr5260958jao.24.1565112476615;
        Tue, 06 Aug 2019 10:27:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyTcOOAlstaCzGNNjIMBgtrIxWtMsATHO5vn6lVevP/VawmnYhb+iduam0f6pak67UyAJnE
X-Received: by 2002:a02:c916:: with SMTP id t22mr5260896jao.24.1565112475815;
        Tue, 06 Aug 2019 10:27:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565112475; cv=none;
        d=google.com; s=arc-20160816;
        b=NDN2oZCp9OpsGgtqzpTcyLUSgyCaAtg39TSxB44EfsSOCQibjqchRcKo0PpvBj0Gl8
         xQ74y557ZugtghS5d3F8jLSxh+WKwqzZ4FaFyp5b+JaJWfp+Xl0csyBAGDSZPEIyCnwm
         TocZGCm0A9ABlbHtXMUBmmgQhE6nIh39WxfGU7n4JzflxTwEZ5+HCFT1TbvhVFbba2B4
         cf72loZ+yqlJq1B/ZDRtk4gVT273BfvtG/vx73m0PKbYZCG/3mSoWboYeFaKXh0ZyYN+
         1mSEyMUf2JU+hvbemlqB5Zn9pNp/fMju46wczgkWXB68IYZduSaREFRzA4rFVElbs84J
         52Yw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=APGgD2qTHotK94otaKMSFu+Fqn3rhhV5q78cD+VLKR8=;
        b=mW6h8bYn9WSdQilxuw2Xz7YRpOMiNcxItqHS9RKH3lFfkTlkVa4QxGHJdlNDxBLXtg
         f/xeBS6cAoZblPYmdzGKoj+Q2rHngWtBEJOZcdkCwLIMEbf0CIQ5V/kSrxxf0ylX3QZY
         W6AmBLKTuxzxP2u9ZdmdaWiOc8mUD87kK9YLCZEoF70U9oZ4PYbOUCLWQn+gVzUjV4gy
         k80WWoC7/OpX3oL3QNsle/b6ApuA/jNXKT4gXCKq6L99zgOyMY1Mhm3gpIsjDjyY7F/9
         qVPyFyIpR4qKYxH7c+6Le8lPIgmLNIqfwwsEYagCRkZmmVrC9YvqZ1s2VGivucWXXkYI
         GT0w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QnEK1uGV;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d12si28389302ion.86.2019.08.06.10.27.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:27:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=QnEK1uGV;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H9w4u089314;
	Tue, 6 Aug 2019 17:27:53 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=APGgD2qTHotK94otaKMSFu+Fqn3rhhV5q78cD+VLKR8=;
 b=QnEK1uGVZXTycSp9FE6Ag63qxyOk1FWl0DfANEu1driBxn4Nty6leZahrJCPvQzTWw09
 /hIu5odh1DzcOd6j+f4bmMsFusyYdz73GAjYWtvjGRG6L9c8z2uYhcvh65hdZ0C1xIWC
 QLAdniVNlDORQb6b0rFBzzJgjVB4HzSpKvQyadTXsWYkj9Mo8DvHA5qDrKMCJj9Hl/N+
 mj0u4rNZHWrtTU8zNcMSla70HI+T+KPo9uPRhdPi4xI6MepsEyj1J8jn8PijVHmbCIyv
 QdeKkj6akVb0qj6WAOw3VTu7nZzxcS4Ob4VkB/9KNyDZAZK72HbkRJSJgeHlHKVsd12b uA== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2u51ptyp8y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:27:53 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H8OHC141125;
	Tue, 6 Aug 2019 17:25:52 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by aserp3020.oracle.com with ESMTP id 2u75776nhj-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:25:52 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x76HPoNN018667;
	Tue, 6 Aug 2019 17:25:50 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 10:25:50 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v4 2/2] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if mmaped more than once
Date: Tue,  6 Aug 2019 11:25:45 -0600
Message-Id: <1565112345-28754-3-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1565112345-28754-1-git-send-email-jane.chu@oracle.com>
References: <1565112345-28754-1-git-send-email-jane.chu@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060156
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060156
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Mmap /dev/dax more than once, then read the poison location using address
from one of the mappings. The other mappings due to not having the page
mapped in will cause SIGKILLs delivered to the process. SIGKILL succeeds
over SIGBUS, so user process looses the opportunity to handle the UE.

Although one may add MAP_POPULATE to mmap(2) to work around the issue,
MAP_POPULATE makes mapping 128GB of pmem several magnitudes slower, so
isn't always an option.

Details -

ndctl inject-error --block=10 --count=1 namespace6.0

./read_poison -x dax6.0 -o 5120 -m 2
mmaped address 0x7f5bb6600000
mmaped address 0x7f3cf3600000
doing local read at address 0x7f3cf3601400
Killed

Console messages in instrumented kernel -

mce: Uncorrected hardware memory error in user-access at edbe201400
Memory failure: tk->addr = 7f5bb6601000
Memory failure: address edbe201: call dev_pagemap_mapping_shift
dev_pagemap_mapping_shift: page edbe201: no PUD
Memory failure: tk->size_shift == 0
Memory failure: Unable to find user space address edbe201 in read_poison
Memory failure: tk->addr = 7f3cf3601000
Memory failure: address edbe201: call dev_pagemap_mapping_shift
Memory failure: tk->size_shift = 21
Memory failure: 0xedbe201: forcibly killing read_poison:22434 because of failure to unmap corrupted page
  => to deliver SIGKILL
Memory failure: 0xedbe201: Killing read_poison:22434 due to hardware memory corruption
  => to deliver SIGBUS

Signed-off-by: Jane Chu <jane.chu@oracle.com>
Suggested-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/memory-failure.c | 22 +++++++++++++---------
 1 file changed, 13 insertions(+), 9 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 51d5b20..bd4db33 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -199,7 +199,6 @@ struct to_kill {
 	struct task_struct *tsk;
 	unsigned long addr;
 	short size_shift;
-	char addr_valid;
 };
 
 /*
@@ -318,22 +317,27 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 	}
 
 	tk->addr = page_address_in_vma(p, vma);
-	tk->addr_valid = 1;
 	if (is_zone_device_page(p))
 		tk->size_shift = dev_pagemap_mapping_shift(p, vma);
 	else
 		tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
 
 	/*
-	 * In theory we don't have to kill when the page was
-	 * munmaped. But it could be also a mremap. Since that's
-	 * likely very rare kill anyways just out of paranoia, but use
-	 * a SIGKILL because the error is not contained anymore.
+	 * Send SIGKILL if "tk->addr == -EFAULT". Also, as
+	 * "tk->size_shift" is always non-zero for !is_zone_device_page(),
+	 * so "tk->size_shift == 0" effectively checks no mapping on
+	 * ZONE_DEVICE. Indeed, when a devdax page is mmapped N times
+	 * to a process' address space, it's possible not all N VMAs
+	 * contain mappings for the page, but at least one VMA does.
+	 * Only deliver SIGBUS with payload derived from the VMA that
+	 * has a mapping for the page.
 	 */
-	if (tk->addr == -EFAULT || tk->size_shift == 0) {
+	if (tk->addr == -EFAULT) {
 		pr_info("Memory failure: Unable to find user space address %lx in %s\n",
 			page_to_pfn(p), tsk->comm);
-		tk->addr_valid = 0;
+	} else if (tk->size_shift == 0) {
+		kfree(tk);
+		return;
 	}
 
 	get_task_struct(tsk);
@@ -361,7 +365,7 @@ static void kill_procs(struct list_head *to_kill, int forcekill, bool fail,
 			 * make sure the process doesn't catch the
 			 * signal and then access the memory. Just kill it.
 			 */
-			if (fail || tk->addr_valid == 0) {
+			if (fail || tk->addr == -EFAULT) {
 				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
 				       pfn, tk->tsk->comm, tk->tsk->pid);
 				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
-- 
1.8.3.1

