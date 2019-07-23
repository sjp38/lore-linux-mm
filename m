Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCDA8C76186
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:40:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8DAF92238C
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 23:40:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="nxXOuLKi"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8DAF92238C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2E1D86B0006; Tue, 23 Jul 2019 19:40:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2940A6B0007; Tue, 23 Jul 2019 19:40:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A8078E0002; Tue, 23 Jul 2019 19:40:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id EDC436B0006
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 19:40:42 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id c5so48637382iom.18
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 16:40:42 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=iTXW+qBxgmscyKRDm4rDkuaYwhXnZofHvZ2R9R8Uz4Y=;
        b=BP8DkxIghAGH3CMZrnX5zcpChs0GJyA95L/xfWnhFzEZbS8kw8dI1+ZdlpNwx7MzxE
         fDx+pncie1SYDAgdopgx1OYSrWQwlhXPxajpRlCRGjjwETZKhKusyhBjfIFtMpTatugY
         Pg2PH3vzwEvjMwadWNd5QRIaDcol+cNe9+FnbeM/iwRlL3V32dozCpX15EiIGKiXT7Xe
         OaRpdnBGG6uo6r0/t9+w8YnRWX2973XOJDFpL8U5OYrz02gI4UJSFBwtoAljSB7s1cvL
         dBNpBcB5tukEi4o21fJChe5SfAHKIwU5LQo46v8w8icuZybQ4JdAj9p308rAMrr+rBeB
         cpEQ==
X-Gm-Message-State: APjAAAUlufhx0ZlO4ZEfN0VNfbtbK2r/P0873ht+xoQzpZzCVJ8gEEzH
	f3HZaYfD3fXRObApWY40WbLMrWQMeLUuEr/22+2ZkFr4M9or9oMMFK4D+riIKz0QQIaOIA6mMTd
	j+o4pVOlor4kl2Y24ppQhYTYr6MpDTGw6M0rIuV1Er6WzYfZHJa5QBEm9Isp0i7EAgg==
X-Received: by 2002:a6b:5a0b:: with SMTP id o11mr25623919iob.98.1563925242507;
        Tue, 23 Jul 2019 16:40:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGQwQXwtg/kpaH4n3Su185YBPPAjA2IiiNVM8ZqePIMmtqoxCm8Fkr92SHC9jXOXtWEPCG
X-Received: by 2002:a6b:5a0b:: with SMTP id o11mr25623879iob.98.1563925241691;
        Tue, 23 Jul 2019 16:40:41 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563925241; cv=none;
        d=google.com; s=arc-20160816;
        b=EVtYp3hsNyLW3Y63SSmXZ7H+SpvjSXdr3qp+1R+fcMlVgYojehhciI8PbVn9m/erHw
         vGzcLX32VU9ClLcfY+ofboKxjwCrbHJOuYDc9sxza8/Hqpmx3RnoboYIZHKUnOQ3l8SB
         oMZQoL2JzzQ6FVOZkFeM13YEEabflUIKK5SUfblFEqRmWLI3hIT2aYBOx8tEFuIumCMD
         TwsgzlNGAV0Y0/MgcNIwaaw3gh5VpZlqdbsver9Zywll2enJUA6wtEUdvlEJV+pDOKHT
         8oli0k6UJU8mMquiN7BNDoOBrPBMdkRa5kH9AYBUISlwdE603sg2LGH26NtZzOKxVEm0
         G4pQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=iTXW+qBxgmscyKRDm4rDkuaYwhXnZofHvZ2R9R8Uz4Y=;
        b=XR5gXeiZxy15AHkyJtLVLqeeKU7RzwkaVW/I4IWqle6H0mHHVd92qNzA6zTFrdWAqF
         I+FpzcT5Gx2Onv+uPn5CcXIVVgHt2RiToGlGCH8ahGCTFbj2WXGTHT+1GiD62lCTgVnW
         /+qKttAzSjIVJm88gOks2QMnp6B4zbbM1ScnEgNMGtQv+gRCbhAruJnOC9ys49U/3Emm
         LP0J2+4qc+ncuY9c+jBgL8TQh7PAwxs68iURd9i7xvnBbOUh8nsiEHridhLCtbZUskxz
         6n9oVFAOdpw5QkYK/ruSduQI1rsbTkQIsLiINqjJ4I1jr3lQJGigPrKFLoOoII3CuvKq
         v9fg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nxXOuLKi;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id c4si59146884iok.137.2019.07.23.16.40.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Jul 2019 16:40:41 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) client-ip=156.151.31.85;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=nxXOuLKi;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.85 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6NNdoDw129407;
	Tue, 23 Jul 2019 23:40:38 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=iTXW+qBxgmscyKRDm4rDkuaYwhXnZofHvZ2R9R8Uz4Y=;
 b=nxXOuLKiK8KoaSaGs7WwtVuXIxEyT+156pDFlni3kjDMe2aGUD46IyZQ0/xQ5MywwPHD
 aaWqIhjaI2ew3auUiZTPhITyyJF/X1qqOCmzquOy+haoGTxs6WyWdaIjEHvILb2Lz8Fk
 eHB0EmIc8PTGBeYwa4c0bJZUfQfSgLsZfpLgANh5oCxrwlhqqCJkzy+x1zo+YtnXo4S/
 xDHSJephx28gkPt7u5yN7SSqS1Cyt+0Ehr666YrLCbHeK8roWc6j5OOQ28hq241R+9B0
 XXWrUZ/TIwOizrVD4vnYSDzi1mYSkvyC88Js5FLzhC6joSvwdf0EvuKQw3hfBB+QWyax xg== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2120.oracle.com with ESMTP id 2tx61bsseb-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Jul 2019 23:40:38 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6NNbZXj183349;
	Tue, 23 Jul 2019 23:38:37 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2tx60xh2f6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 23 Jul 2019 23:38:37 +0000
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6NNcaGA013920;
	Tue, 23 Jul 2019 23:38:36 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 23 Jul 2019 16:38:36 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if mmaped more than once
Date: Tue, 23 Jul 2019 17:38:30 -0600
Message-Id: <1563925110-19359-1-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9327 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907230244
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9327 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907230244
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
---
 mm/memory-failure.c | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d9cc660..7038abd 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -315,7 +315,6 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 
 	if (*tkc) {
 		tk = *tkc;
-		*tkc = NULL;
 	} else {
 		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
 		if (!tk) {
@@ -331,16 +330,21 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 		tk->size_shift = compound_order(compound_head(p)) + PAGE_SHIFT;
 
 	/*
-	 * In theory we don't have to kill when the page was
-	 * munmaped. But it could be also a mremap. Since that's
-	 * likely very rare kill anyways just out of paranoia, but use
-	 * a SIGKILL because the error is not contained anymore.
+	 * Indeed a page could be mmapped N times within a process. And it's possible
+	 * that not all of those N VMAs contain valid mapping for the page. In which
+	 * case we don't want to send SIGKILL to the process on behalf of the VMAs
+	 * that don't have the valid mapping, because doing so will eclipse the SIGBUS
+	 * delivered on behalf of the active VMA.
 	 */
 	if (tk->addr == -EFAULT || tk->size_shift == 0) {
 		pr_info("Memory failure: Unable to find user space address %lx in %s\n",
 			page_to_pfn(p), tsk->comm);
-		tk->addr_valid = 0;
+		if (tk != *tkc)
+			kfree(tk);
+		return;
 	}
+	if (tk == *tkc)
+		*tkc = NULL;
 	get_task_struct(tsk);
 	tk->tsk = tsk;
 	list_add_tail(&tk->nd, to_kill);
-- 
1.8.3.1

