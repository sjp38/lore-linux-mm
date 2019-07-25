Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3747C76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:01:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5C287229F9
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:01:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="SljRE8Qj"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5C287229F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E4D76B0007; Thu, 25 Jul 2019 18:01:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5459A8E0003; Thu, 25 Jul 2019 18:01:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3E5FA6B0010; Thu, 25 Jul 2019 18:01:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id 18E1B6B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:01:52 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id k21so56426002ioj.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:01:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=USs7rUihppQ+KmFVpj5iXh+Jz7d53J97VjHquobjd/U=;
        b=R7Lt3XdDBUwgwV11K/2YieT6pZvno8FKkVXh6vDGmWMeuftvRqYCjxjkOEoq46fQ41
         uGGZm0hxNugYYw9uH5Y2oLsbsRQg4OCHnOkGdD5LBSrL4i1uDX0V2l1J5Ymfj2qPBVqP
         878wbHd8AXCc3n4IVcliv9ebV+Q+rSSMDSJo101zIBinPX5HOaidTl5Z/oEx9L53PBh1
         reH5BRAPVoIMMwZOviieBTXO31g5zPeQDY8fh9LaZANFziolXzFlIxJRwqB7SqICuQY0
         a4AFn1m1OHkLuk0BKF2fBB5YddPIWoChW45p7znL7DJ0f5nPtYFBIJBP4dpMnnH40BDc
         bb5Q==
X-Gm-Message-State: APjAAAX/GDmNE2qnmLoKFJ/1UPlCskKUzmYTcgkDj4ZOwXr80xM4eFDm
	eVbwttm4L3FP3Jvl42P8pmAtvTBC102x8bgHg5tE3XUssKTROzG54+Dxja+vhkN4skwJ0TQoLU4
	Kdpc4ZcYoJvEXSt55prBekB7MGKURUw5Ibk/RIJHOVIMhTUYeBlrmx6s6ntfvugiFmQ==
X-Received: by 2002:a6b:7017:: with SMTP id l23mr80977927ioc.159.1564092111865;
        Thu, 25 Jul 2019 15:01:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzPohZAQMKj/eCY1uHLz0D+zUbfeCpxh+Ire1gsLjB6tbUTnLh0h35xbNCb7wdiiMngWC2G
X-Received: by 2002:a6b:7017:: with SMTP id l23mr80977844ioc.159.1564092111021;
        Thu, 25 Jul 2019 15:01:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564092111; cv=none;
        d=google.com; s=arc-20160816;
        b=win5gfMpRaMj5HSFNMD0vBoTab/7pShCKdnOA0oW0O00POO+054VieK2Ya8ftnT2Mx
         KUTJiugH3Hsk2ow2xZg2fJSw78Ye0Au4ixzJJ3r0WuJUemxs+dj2mDY3UGf4ONEq6Vdw
         50Yl3SFhq9otG28zFVEcYDi9/s80x/I+EVjaYeap6owf5vtX/5oAaEelLfpiPlFcG/Mh
         /BL0I5s7TGTdcVEG8nrQPlNjaCUxjL8+KW2QsWEayLU8MQhdGZbVOpkY3DTy/s2MpHMW
         br6gHCIU8HWowgb952I0GXUtkNbiS3ScSDyG45FpFVji0obDs5MwVXXHvSdxbi4w3HdV
         qR3w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=USs7rUihppQ+KmFVpj5iXh+Jz7d53J97VjHquobjd/U=;
        b=QZJuiAbpf802iY+jzLFca6ycGzio7phUqI7lcWC082KmGaU81GXZua/oTJdXry47Ow
         Ai6hREzVMQvUzKDPFfV/JrIxOA4Gm+HMzAVpce9JFpwATA8mbJ3rb1HHUDNFVNws9/90
         c6Phg9eZdyF8PVJgTj/vcm+/AOPi/XEv+RUsENNaTcEbT2np7fTllSUviExJMHEtrGy4
         otR2WMdVjpccrepwygUQ/hEMf3pSE5FxPlYodwGqriPX4oOZkFqPNu5FHDJCFtzkQEuf
         5QTBNwM04roU7U3G7HKLIFxDNIccUkbKFitXLGeZfacKC1GW8mW4sCfPPXzHbIoftf+6
         znlA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SljRE8Qj;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id z20si67180411ioe.153.2019.07.25.15.01.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 15:01:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=SljRE8Qj;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PLoH8w134030;
	Thu, 25 Jul 2019 22:01:48 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=USs7rUihppQ+KmFVpj5iXh+Jz7d53J97VjHquobjd/U=;
 b=SljRE8Qj9gelicXhw/gG/A2koi2CSJTQqQ2xnTXwrmS4qkCOMfxcHsnfXu4PQbigWPwi
 n3I1jeVIFAwKNjos8gZnUUV9IS3nz0CcfnjMoNVjxlZrsad8yeVRaEIBnQDRBhKLC1zd
 sRg6qVs5+JC3e6zUmd0AvUNwjvRRvNTPeOg6pd5AMe8+TAID0WGFcWm0jncw13TEN6a1
 n5CFt0TML+sYFWSxSTcTo9sZksgO+adab+Uox6n7Jr+NoSKFH5O7rqP2GhcCjbS1d1D1
 Z+OmTmhhDtJ4TMWdhd7fEKdM53CBvr74PZNLmgHFzKiGQUmgpfcpWUaGDC1pQSooZhMK cw== 
Received: from userp3020.oracle.com (userp3020.oracle.com [156.151.31.79])
	by aserp2120.oracle.com with ESMTP id 2tx61c6r0y-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 22:01:47 +0000
Received: from pps.filterd (userp3020.oracle.com [127.0.0.1])
	by userp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PLqP8Z107764;
	Thu, 25 Jul 2019 22:01:47 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
	by userp3020.oracle.com with ESMTP id 2tycv78jmg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 22:01:47 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6PM1k4u021541;
	Thu, 25 Jul 2019 22:01:46 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 25 Jul 2019 15:01:46 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v3 2/2] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if mmaped more than once
Date: Thu, 25 Jul 2019 16:01:41 -0600
Message-Id: <1564092101-3865-3-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
References: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250263
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250263
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
index 51d5b20..f668c88 100644
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

