Return-Path: <SRS0=Igro=TR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28AC1C04AB4
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 04:08:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A212820833
	for <linux-mm@archiver.kernel.org>; Fri, 17 May 2019 04:08:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GtFN8KxH"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A212820833
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F152E6B0005; Fri, 17 May 2019 00:08:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC5C86B0006; Fri, 17 May 2019 00:08:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DDB1A6B0007; Fri, 17 May 2019 00:08:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id BEF776B0005
	for <linux-mm@kvack.org>; Fri, 17 May 2019 00:08:28 -0400 (EDT)
Received: by mail-it1-f198.google.com with SMTP id z66so5340527itc.8
        for <linux-mm@kvack.org>; Thu, 16 May 2019 21:08:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=fbs2klJYRwSjh6U92tbSHWsFn2CAbHAkPfwjVASkuvs=;
        b=RXqiHJT+BANCGR/QRyWBQYZepUwepqnaE2Ll3DqkWfCgcvdkFtwu36Zqgok0SmrpEc
         3n6pRwQjUSHOzwcpUkRu97NtvtjeD8Xf4wvnxY+bjdnalJj9bE13R2IltDmSUdW62Mzw
         +y2dGfkwuCHTU1bHJUC1VarXUn2Ls/FZ//DJemz5PbLEv1JwNun1f7pC8TWBlPTmrc/C
         oNgkao2Q+KHUcthxFyhSrpqMJMhgfcsmZ4/oFGndKgnkmmkpGnFDHpe3GlD6vJXmMzv2
         MA4QRTd1a2SJmQ4gfA1nIk8cjj4Q/GjCwOLr561kIN1iSPlrtiIV6s+mAt6c/sLxfeyX
         Bk4g==
X-Gm-Message-State: APjAAAVUjUIrXcwumNyBs1xUJb4OOEFsDd2iHYXgnCZ7eLbxBeQeQUj7
	weqGWYPW9G2Ej8FYysL5FE2TZwplh2zUFjKn+gI5/tSo+Rk+6BSJIEj4UE0FU9VQk17yJkTP1TC
	TJtRrap5Bwf3NxvgNVO4Z/5coquDuJ6lvHrUUY/HXuk2141RmCicaDQwMlLTn6pPTJQ==
X-Received: by 2002:a6b:5116:: with SMTP id f22mr8100442iob.185.1558066108492;
        Thu, 16 May 2019 21:08:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyYUhXaYsasTPAWi/tgw5G8GllJc1JmKCEYbpZbjBynFhrGPUsQxKp/uA9Dok3NkH4W6FXC
X-Received: by 2002:a6b:5116:: with SMTP id f22mr8100415iob.185.1558066107816;
        Thu, 16 May 2019 21:08:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558066107; cv=none;
        d=google.com; s=arc-20160816;
        b=EnZ9NjNQbtkQqzOttbaujVrc+FmRpudq0DdSz3Jf9kRnASLgxH5ueEJMSnvrXh5qj5
         NTDnVUHLLIPAfZbQBczwZlog2lng2Ub3X6PZoUzWZwkTrM8wsigRjQjk7PrSlopMhkFO
         8KewdPe4NcR+8t71Vq8yM+YSBZ3B53UOks5PSO1WhiFXe01yL2wew60+c+vsqYcaO+LA
         Gz1uLWUK81n36gtaaf2kgX5eykNYHBfHWF24URVuAcbZ9HFDISxv3ueYJVDRIexbWutM
         XgAvF5nWAm0DKUOdqDKtqYYRNKvmXqD3dDfJJlUYEU8i1yrrjDieC7lT10jGXfQYpEnC
         ZUYg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=fbs2klJYRwSjh6U92tbSHWsFn2CAbHAkPfwjVASkuvs=;
        b=TUGR9B31xpuIP4WgJzMdaRKcL3Ex+9j78pK2bEg6yZPgOX/OqjwDcHpsvUpLzHQcAH
         cmGJ63PnXhtkomoBDQLvPyhV7Oy/oHtitgUsoJEcGEFQu7XZY6zcgDF+WHKquNBSkpuc
         mmw5E1ruku8yJkOuKGNu40IB7Q2KKsy0TR+Kj1cKqOkNyj9v8a0VtWRFGPOFGXHLRHra
         tZTCAfoyscy/GEO/kpDWsnMlSNXm5iq+8PjQUBR63SOT2BTvL23X7F1v/zVjVctvijcj
         T6YUtF2r2Hpe/YVK+EKzwFYx84ImUt3Ajr5A7h9YqfffeAvkojPQIVN12S5zDY8u4Jm2
         KCQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GtFN8KxH;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id d2si4611048jaa.97.2019.05.16.21.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 May 2019 21:08:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GtFN8KxH;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4H44FtQ155156;
	Fri, 17 May 2019 04:08:24 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id; s=corp-2018-07-02;
 bh=fbs2klJYRwSjh6U92tbSHWsFn2CAbHAkPfwjVASkuvs=;
 b=GtFN8KxHn6BoVU9RO4RbeGh9sRr4R5Oqr7OqunHBPO0lQAOucqb2LpUXXiro7vHZBTpl
 zn18pgC9Ba/pf8L/cAM2wqXlfUTy/kH0wctwMu+ijNvbOCB09Xx4LTYN9GoTMsBVKNTa
 RpqfKvYj/5mGspglKTyxP8OSob8A7li66BNNR/n2bRooyGDYJTzIgQ1k1sHzcDb1j4r6
 F59pNJl70JWFYpgmMrHQvLi5OkjzSRywaXlkYQG1B2mrvXCyvItJbSXjelKlaninmeQA
 igjxy5kXNurF9PKFc7MYWrKOFbbkoAwPrz8gzAU102QwDIbmOiZpZd5p4Cljgyga+WV3 ng== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2sdntu76t2-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 May 2019 04:08:24 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x4H47PEL073951;
	Fri, 17 May 2019 04:08:23 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by aserp3020.oracle.com with ESMTP id 2sgp33ca87-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Fri, 17 May 2019 04:08:23 +0000
Received: from abhmp0022.oracle.com (abhmp0022.oracle.com [141.146.116.28])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x4H48Lbi020359;
	Fri, 17 May 2019 04:08:22 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Fri, 17 May 2019 04:08:21 +0000
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH] mm, memory-failure: clarify error message
Date: Thu, 16 May 2019 22:08:15 -0600
Message-Id: <1558066095-9495-1-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=954
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1905170025
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9259 signatures=668687
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=984 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1905170025
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Some user who install SIGBUS handler that does longjmp out
therefore keeping the process alive is confused by the error
message
  "[188988.765862] Memory failure: 0x1840200: Killing
   cellsrv:33395 due to hardware memory corruption"
Slightly modify the error message to improve clarity.

Signed-off-by: Jane Chu <jane.chu@oracle.com>
---
 mm/memory-failure.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index fc8b517..14de5e2 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -216,10 +216,9 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
 	short addr_lsb = tk->size_shift;
 	int ret;
 
-	pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory corruption\n",
-		pfn, t->comm, t->pid);
-
 	if ((flags & MF_ACTION_REQUIRED) && t->mm == current->mm) {
+		pr_err("Memory failure: %#lx: Killing %s:%d due to hardware memory "
+			"corruption\n", pfn, t->comm, t->pid);
 		ret = force_sig_mceerr(BUS_MCEERR_AR, (void __user *)tk->addr,
 				       addr_lsb, current);
 	} else {
@@ -229,6 +228,8 @@ static int kill_proc(struct to_kill *tk, unsigned long pfn, int flags)
 		 * This could cause a loop when the user sets SIGBUS
 		 * to SIG_IGN, but hopefully no one will do that?
 		 */
+		pr_err("Memory failure: %#lx: Sending SIGBUS to %s:%d due to hardware "
+			"memory corruption\n", pfn, t->comm, t->pid);
 		ret = send_sig_mceerr(BUS_MCEERR_AO, (void __user *)tk->addr,
 				      addr_lsb, t);  /* synchronous? */
 	}
-- 
1.8.3.1

