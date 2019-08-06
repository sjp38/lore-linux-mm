Return-Path: <SRS0=yRuK=WC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5DD93C31E40
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:25:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0EB3420C01
	for <linux-mm@archiver.kernel.org>; Tue,  6 Aug 2019 17:25:56 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="hBknxIUa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0EB3420C01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DBFE6B0007; Tue,  6 Aug 2019 13:25:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8657C6B0008; Tue,  6 Aug 2019 13:25:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6DEBB6B000A; Tue,  6 Aug 2019 13:25:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ot1-f71.google.com (mail-ot1-f71.google.com [209.85.210.71])
	by kanga.kvack.org (Postfix) with ESMTP id 418166B0007
	for <linux-mm@kvack.org>; Tue,  6 Aug 2019 13:25:56 -0400 (EDT)
Received: by mail-ot1-f71.google.com with SMTP id d13so49998325oth.20
        for <linux-mm@kvack.org>; Tue, 06 Aug 2019 10:25:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=Wehduxv3rRQK2E7/irEvOjIfxwzfa7zL656bjo3lVcY=;
        b=r42c244aHXoiP3AcuZ3MiwARoe7g2cc3w37jOSmLNRhA0YUh6NlxsfpelqpANhlZdp
         ZvAIm6h5h8YEzwVZTBQpzsgn1c0EQIrH8I2rDwKAMrZ76ru6haatSGcoM57R+ahjeeiM
         8HEB2HePCkCyvHoCmm5JKJJAtqJ08AcoHXXSozgrr2MYl5HPTqblkQnvoj5TemNkaaYo
         d219mBlDvg8jt/HSoZIeqglzIeonSVSVvpdCq0ec4wMYX7dk2HBp1x+Dz4M3YgDk67fR
         QX9gcSnPG+eYoDEE8qYJY+RZyoIwnh5+RkExVpPU10JpMeNYjDIVDZ6BObYlLHnU1HH1
         RQNg==
X-Gm-Message-State: APjAAAXlZMXEspql62gsLVtJzIMSwcvR1LZHWheY6i8Ezx0e7SZk1VR6
	3EulzAPqyXhnNLI8oB3VMWUPY9UGECkQzZd+0ImJADAjMTT9t39oKFX25Sn5NofRi7zIxuYy+7O
	H3HYqRFMmgufR1t2bBJX1Xlb/OPKzLzICN1tjQx55eeDr6RB0Imz/xxYv5S7v7CzS7w==
X-Received: by 2002:a5e:c302:: with SMTP id a2mr4288435iok.62.1565112355924;
        Tue, 06 Aug 2019 10:25:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxjwOccqoA4VhG+kdh52Quh40haLd6ADQJsZ1WYgq7pnJNupp9vXkiXB9FZdFETQOK9/z7j
X-Received: by 2002:a5e:c302:: with SMTP id a2mr4288388iok.62.1565112355261;
        Tue, 06 Aug 2019 10:25:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565112355; cv=none;
        d=google.com; s=arc-20160816;
        b=H8HJhmxkrWZ2jgOCHPQZyNXhcG/wQMLe41SnMx3O2CXoRHrSvqKR/bET6Rxs3QTip9
         IazsM8tXelfxWXIZK182UI5FPcrH3AsKUXXENT3LDVmmoSAfY0x22lDvyTor5aRxo/sr
         0iFCqKkxRip1mMAAV8wFcxz+cfJdojTLtcDjsNN6uzB6TdJ9VK5d2XkGT5Rud+qGSpLp
         zz5DgOuJvONlKJrFAvHKH7COpSlRbONKttKfFDrJrd/+QAFIHCIJLDUVsz9zRTSkhUNW
         LPFHZxlueKtF3CjR5pvyVqAk9jWGdA+blO48bUW7DIDdZjot6x18oAfvyPMtJrQg/TXH
         pK1Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=Wehduxv3rRQK2E7/irEvOjIfxwzfa7zL656bjo3lVcY=;
        b=ZGUHPAfJYdkbA7UGhCCgNDjKHQvdDp2xK6dz7GUyXdHLTIT8vqB6xORVaz8DNHxih7
         hR189THnjKYz3fPgdjEWIVWhK/zAUduogdp44PMeO69tVl/2DE9sCmZyGRHRBQmD8UI9
         7kOp0SHsL1Bf31+T9KdN03tNkDj7lqEVOOPFv3B8UwgWvUQUCmA5/Jxzum4KoPWceCAG
         cG0iIymPU7Tv15WtBF5DuFJh/p/qz9uBKFG4S+yfwx6+L3z1qBOT7z9jJFe4hNGBxm4q
         i+2EABNJHIWeYh6tH+0LrW6icgexiWwh+Tvs4JOxL+WPu88G2pVqBG46ps4jRVsSqs6S
         ZxHw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hBknxIUa;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id n28si101496646jac.89.2019.08.06.10.25.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Aug 2019 10:25:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) client-ip=141.146.126.78;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=hBknxIUa;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 141.146.126.78 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H9Ipb161050;
	Tue, 6 Aug 2019 17:25:52 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=Wehduxv3rRQK2E7/irEvOjIfxwzfa7zL656bjo3lVcY=;
 b=hBknxIUazqQ/wOMEAxX01bZsUVuXvxlyO1N+0qKl94WEryTvqPeXObRSc32gqFSQAL62
 UQOkmWB0thwiyDWYfW+Dxcjp2iUJid2d0EFP9GF5inTIXcNtpipmO4fOfb/1e15sAo8x
 3cO1kTl99VB5L813rDMfLXILyzoqiU7wpcxdqG2/5BQVco6f/Jm00YTqz+Ibg/LHzzJd
 XfgVKP1rMsj2IsWSZcKvp0oJTFREKswS+eGx2UQKed2eH8qea+yZxJECWPhh6cYP2w2p
 q/A/4BZRbg+8u2RYrbxP5Yk+niKSUA+fD7A3T8SfEkj+xkAElK8rSSgHwUXkt1bguqBf dw== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by aserp2120.oracle.com with ESMTP id 2u527pqgqp-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:25:52 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x76H8NZp068899;
	Tue, 6 Aug 2019 17:25:51 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userp3030.oracle.com with ESMTP id 2u7666qy69-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Tue, 06 Aug 2019 17:25:51 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x76HPooi011529;
	Tue, 6 Aug 2019 17:25:50 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Tue, 06 Aug 2019 10:25:50 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v4 1/2] mm/memory-failure.c clean up around tk pre-allocation
Date: Tue,  6 Aug 2019 11:25:44 -0600
Message-Id: <1565112345-28754-2-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1565112345-28754-1-git-send-email-jane.chu@oracle.com>
References: <1565112345-28754-1-git-send-email-jane.chu@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=940
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1908060156
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9341 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=994 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1908060156
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

