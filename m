Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 71F9FC76190
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:01:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2AA0122BF5
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 22:01:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="GhtfdZvu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2AA0122BF5
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9638C8E0002; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 914296B000E; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E2438E0002; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48F766B0007
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 18:01:51 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id e20so56043944ioe.12
        for <linux-mm@kvack.org>; Thu, 25 Jul 2019 15:01:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Wehduxv3rRQK2E7/irEvOjIfxwzfa7zL656bjo3lVcY=;
        b=L/7U8h4apGUb/0xcrHHqoU7ecRgqJWBDNGtpKohwNU6OVBRigWukRMfTB6bGGPDMlW
         o+1VJKkNBkuD0komaYzm1hAJerCteBBfMbDlnuCT7hmquRlGGDQ6JYkzcZxuEmfDe5Y1
         q3AhasvvVJwbZ+OSEIVy1h4PBGuVNXKu57o6B1X7ohhgHUft06PyCGVC01PhuB0Ps3Va
         K7TcjF/CkkVajUmFsthmXXNJjfpM3TZnboje6kOjaau69fDBOr0/TV/GgEXTaLW3+IXg
         TyUh4AUYILvxfGoXRMWAG0wSMeTjJi+lRt6HDTSAsZ5DVehtROKLW3qbIg3sEtRjcbY3
         d2Rw==
X-Gm-Message-State: APjAAAWW/JjVTbJinMTzQiItBSNd4VnbiSYzJw4nJx4rKLgQ1d0xNmVl
	E8Cg17Q/O0zw2G0WsLNvgrfE7OyH4FNe8GmudsIlqLwal7JV1tdgOz/7yAP2EgOVh5fI6up6H7e
	ykyBQ31WaBAEtUQzxP22Ap1h6XgpQVaoVJuKZNTfWiaj9+lOQRDl6m3r5P6Jkut2dlQ==
X-Received: by 2002:a6b:ef06:: with SMTP id k6mr11836944ioh.70.1564092111082;
        Thu, 25 Jul 2019 15:01:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzFjjgJp7ylssNGwC+oJP1bmEhmDw2/OE0ea12KuR+svMtTHg9keI4ggO2lM1fNp8YlGM5b
X-Received: by 2002:a6b:ef06:: with SMTP id k6mr11836842ioh.70.1564092110260;
        Thu, 25 Jul 2019 15:01:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564092110; cv=none;
        d=google.com; s=arc-20160816;
        b=HGxxSICzSNdq//trrB43s0+zLh9OQdIE55TnBfTpamgimYxEzw0Xhx2Bg62IAroDve
         vnLPw/67oSt7rT9SZyuYnAypsNr+5c12x5Stf3/FcaXmyXYeRITi9HaVx77mI1sIiXv2
         uxhFmv2JPqe4y/UChFOhdp/hbJKmDkRPAsRvDUWpZ7KhIWMJIUC/vbLM1y1iJcrQCOLr
         h02x0miQhgTonRHVcQ/bDxRGYhQQXKDbeMa7jzuoGVVsRUrJ7C05G8cwubOKaafmQRDo
         XPWLXLlCWPSvVFeRKhDFX1hoT0kT3oivD3j/CzbvnfU+e0Xjrx3KZZtmyNOupMxh25vk
         sQWQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Wehduxv3rRQK2E7/irEvOjIfxwzfa7zL656bjo3lVcY=;
        b=XMHVE1hM0BhdPomOcLbRBLLw9iWT2Np0CiYTgIaiIJW6O3vd5I6/cOpNFUVE0WufVR
         eEy+KrTRJOBOKj35ujZqtJu1vFMsC0VY+5gMgOSs0ZtYVk8Xig+TCruoV8hSFApPfzD+
         ipxefQy2lTAYvf5DBFNwAzYxPl4qWHtl8lir1f5lwMFbCDaWNGZxnvx6A2pLWQr7+ysS
         VVlVabmjQw9lGSFduq7BeQpfmNiGqApR9ndE2NJFW36m4eb1E08wuctfks2Fk68x6zhH
         80r91bnF7wx5rP8XcTkMP+DlPOHrm5M5cpt+t3ZjQDmR/lafRYipnRL64H+145i4jp2p
         ErmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GhtfdZvu;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id l26si64053195ioh.96.2019.07.25.15.01.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jul 2019 15:01:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=GhtfdZvu;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PLnjVN047526;
	Thu, 25 Jul 2019 22:01:47 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=Wehduxv3rRQK2E7/irEvOjIfxwzfa7zL656bjo3lVcY=;
 b=GhtfdZvuNUNRbc8Vg+Twnr3rIF2aJVHyoy9A1Nkp5MOGKkueLofl0az5WE7GrW2OW6k7
 nqD6hyY3lWV1dtvvkIG/Nyj94uSjW18m7qYuiFXwuF2/C2YIZro4VLo1AEIsuUpXs0ZG
 SaFGRAjp2/Qc24wBHqHbFX5Zm519HSKRzXOjpBg+d4Jbr3GegG8rZi75vG0F64us7A+d
 ftKYlo0nYjKzHySQ5oo/qU1x9OcJteprFl7AJEl1xmfqMo0tibm/eKyLlUfPLRhPHT/T
 c2Wla83gmr+2lPRukmodPR9FXb0/KOGHah41gvewrIsrvFZPVd6Rfh3FP1jAlN7/6lTL EQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
	by userp2130.oracle.com with ESMTP id 2tx61c6r9f-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 22:01:47 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
	by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6PLqMsG020509;
	Thu, 25 Jul 2019 22:01:46 GMT
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserp3020.oracle.com with ESMTP id 2tyd3nw50n-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Thu, 25 Jul 2019 22:01:46 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x6PM1jwF028641;
	Thu, 25 Jul 2019 22:01:45 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 25 Jul 2019 15:01:45 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v3 1/2] mm/memory-failure.c clean up around tk pre-allocation
Date: Thu, 25 Jul 2019 16:01:40 -0600
Message-Id: <1564092101-3865-2-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
References: <1564092101-3865-1-git-send-email-jane.chu@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=930
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907250263
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9329 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=983 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907250263
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

add_to_kill() expects the first 'tk' to be pre-allocated, it makes
subsequent allocations on need basis, this makes the code a bit
difficult to read. Move all the allocation internal to add_to_kill()
and drop the **tk argument.

Signed-off-by: Jane Chu <jane.chu@oracle.com>
---
 mm/memory-failure.c | 40 +++++++++++++---------------------------
 1 file changed, 13 insertions(+), 27 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d9cc660..51d5b20 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -304,25 +304,19 @@ static unsigned long dev_pagemap_mapping_shift(struct page *page,
 /*
  * Schedule a process for later kill.
  * Uses GFP_ATOMIC allocations to avoid potential recursions in the VM.
- * TBD would GFP_NOIO be enough?
  */
 static void add_to_kill(struct task_struct *tsk, struct page *p,
 		       struct vm_area_struct *vma,
-		       struct list_head *to_kill,
-		       struct to_kill **tkc)
+		       struct list_head *to_kill)
 {
 	struct to_kill *tk;
 
-	if (*tkc) {
-		tk = *tkc;
-		*tkc = NULL;
-	} else {
-		tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
-		if (!tk) {
-			pr_err("Memory failure: Out of memory while machine check handling\n");
-			return;
-		}
+	tk = kmalloc(sizeof(struct to_kill), GFP_ATOMIC);
+	if (!tk) {
+		pr_err("Memory failure: Out of memory while machine check handling\n");
+		return;
 	}
+
 	tk->addr = page_address_in_vma(p, vma);
 	tk->addr_valid = 1;
 	if (is_zone_device_page(p))
@@ -341,6 +335,7 @@ static void add_to_kill(struct task_struct *tsk, struct page *p,
 			page_to_pfn(p), tsk->comm);
 		tk->addr_valid = 0;
 	}
+
 	get_task_struct(tsk);
 	tk->tsk = tsk;
 	list_add_tail(&tk->nd, to_kill);
@@ -432,7 +427,7 @@ static struct task_struct *task_early_kill(struct task_struct *tsk,
  * Collect processes when the error hit an anonymous page.
  */
 static void collect_procs_anon(struct page *page, struct list_head *to_kill,
-			      struct to_kill **tkc, int force_early)
+				int force_early)
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
@@ -457,7 +452,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 			if (!page_mapped_in_vma(page, vma))
 				continue;
 			if (vma->vm_mm == t->mm)
-				add_to_kill(t, page, vma, to_kill, tkc);
+				add_to_kill(t, page, vma, to_kill);
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -468,7 +463,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
  * Collect processes when the error hit a file mapped page.
  */
 static void collect_procs_file(struct page *page, struct list_head *to_kill,
-			      struct to_kill **tkc, int force_early)
+				int force_early)
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
@@ -492,7 +487,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 			 * to be informed of all such data corruptions.
 			 */
 			if (vma->vm_mm == t->mm)
-				add_to_kill(t, page, vma, to_kill, tkc);
+				add_to_kill(t, page, vma, to_kill);
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -501,26 +496,17 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 
 /*
  * Collect the processes who have the corrupted page mapped to kill.
- * This is done in two steps for locking reasons.
- * First preallocate one tokill structure outside the spin locks,
- * so that we can kill at least one process reasonably reliable.
  */
 static void collect_procs(struct page *page, struct list_head *tokill,
 				int force_early)
 {
-	struct to_kill *tk;
-
 	if (!page->mapping)
 		return;
 
-	tk = kmalloc(sizeof(struct to_kill), GFP_NOIO);
-	if (!tk)
-		return;
 	if (PageAnon(page))
-		collect_procs_anon(page, tokill, &tk, force_early);
+		collect_procs_anon(page, tokill, force_early);
 	else
-		collect_procs_file(page, tokill, &tk, force_early);
-	kfree(tk);
+		collect_procs_file(page, tokill, force_early);
 }
 
 static const char *action_name[] = {
-- 
1.8.3.1

