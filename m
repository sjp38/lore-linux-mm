Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,UNPARSEABLE_RELAY,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F6A1C76186
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:35:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 399CB21911
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 22:35:37 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ogZBgpU9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 399CB21911
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id EE0538E0012; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E90F98E0002; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D7FA88E0012; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f71.google.com (mail-io1-f71.google.com [209.85.166.71])
	by kanga.kvack.org (Postfix) with ESMTP id B316B8E0002
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 18:35:35 -0400 (EDT)
Received: by mail-io1-f71.google.com with SMTP id 132so52660185iou.0
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 15:35:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=r28z8MC+FBAjy3qs30Pzm+4vXP36lmFOt4duHG2H+q8=;
        b=k+2J24JDJaOkmzAsVBdbRKtidqWg+YmNqHCgE0d6ty6i6hivZ3vqq5I3MzARtdTzGh
         7tbNhk6+GcZrno3XzkAnp7AnnGjijgiiF+guqNJ+8CxLdd+5HOae92UlKlD5loehO1c9
         fBzt7na5fHzd3YLHamSM6OjRWQbdT55Hj6V1tlemjh8OQjzM0nc7dPonakLefZ1RbvnW
         kkYChwXdJDNtCHALpCHY2LFR7dILU7jdynEnFIP8EI4fYXc0fSGHxj4fmiWGlcKh3oOD
         QOUQknRnYUnqvFrRFYyT+uFEBJrSvvNvDkXr1gRJrVYN4dhL6VaLuJqh4JrIaGsNu4oY
         qGqQ==
X-Gm-Message-State: APjAAAWOeKj7PwcUVS9kNgVzIrNsHu6DFYeZlXRS+m0NemlChhT+p7zg
	fvY+7rDgJjA4kdpn50G8dYlZddwQsp/tM2tppMbe+qSlkwy8c9aMmGs4XmJSeVt3fRu31QwFK33
	9zxVZ+Slq+OZVxBbyIEO6RXrD+oLrN5HQKT4t6AM+22Utui6G21dFZ8Arbi/Bn+8jiQ==
X-Received: by 2002:a05:6638:38a:: with SMTP id y10mr90011027jap.104.1564007735502;
        Wed, 24 Jul 2019 15:35:35 -0700 (PDT)
X-Google-Smtp-Source: APXvYqytbhuarJ+V1YPfNuk7JdsfIXpXESpkkCLU5rxzyRhrATeZMlcTkazza2WrncwYMgubwLPI
X-Received: by 2002:a05:6638:38a:: with SMTP id y10mr90010916jap.104.1564007734083;
        Wed, 24 Jul 2019 15:35:34 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564007734; cv=none;
        d=google.com; s=arc-20160816;
        b=D2L1j7LYDYmpVKZkP6MsHNyok9P7oArXnCjDGEjYynqpGCe2J3k70TmW5fqJvvRcnZ
         M+50xflRD26ga/SvlIycRXkzGr7xKven60PcWL+ThfcaJxXqyMsovs0VneNEYu/kBduY
         JILOhQIAfiYOQALsV7HCZhKyX3Mqq2I0Sau0lg8728rXaKJ4jkum4cFYpgzZIlUgBeQ3
         12bUs9sDRgqk9t8MJIHVW/onN2wqZaVCGO7uYzy/6YaN5k3DKnC6Gm52ZPjgEY/7F42W
         7XNFHaV8dI1RO7ZfekuaVISDkv+JX5o3nJ+F549TrctfZkQIODThtyd8oVYRsuvHlXtd
         gjsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=r28z8MC+FBAjy3qs30Pzm+4vXP36lmFOt4duHG2H+q8=;
        b=wibfMoAm0FJvQPLbqBDKIhvXcXPTfxQo2WOqsLCXOorBaaLtzvlKNikJH/S+X/DV5h
         cJAkYga5MArYld0Wscil83ELZBoiTBqHFIgVTpxN93fjOgoAnQCZ85uK3VjmJSJ3kSQW
         fCBxXZ9A75WMa7239a9kEtMB95tfbAoS+eiNavlGVmns8cBuLPmxUOekW4rppA834Kz+
         40F6JttkRECpW04ktOmsbqOcBy5Suhk+ymn0VtZ8YKXxSkXYoK+S/7vAQAg/VVngc6sY
         cTSpFQ0FcHrw5wfgkLbHGA6+K7gfMcvUf4iqh4I3/UK8sbKATHbWiYNBafeqbKDPyeGA
         6zng==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ogZBgpU9;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a20si61262005ios.80.2019.07.24.15.35.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Jul 2019 15:35:34 -0700 (PDT)
Received-SPF: pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) client-ip=156.151.31.86;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@oracle.com header.s=corp-2018-07-02 header.b=ogZBgpU9;
       spf=pass (google.com: domain of jane.chu@oracle.com designates 156.151.31.86 as permitted sender) smtp.mailfrom=jane.chu@oracle.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=oracle.com
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OMYF5A084308;
	Wed, 24 Jul 2019 22:35:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=from : to : cc :
 subject : date : message-id : in-reply-to : references; s=corp-2018-07-02;
 bh=r28z8MC+FBAjy3qs30Pzm+4vXP36lmFOt4duHG2H+q8=;
 b=ogZBgpU9Dikvu0Xp6hQpACPjL3RUauMXt9dUN3sEovxdJ663/UPFt/zsNj+5V8e5o5zc
 c+UiAf6a36VyVkQ63gc9z26UFddPly7/n8N1g89q44pxhqELv7y/k89ElUHeaiGM/2/i
 fULWfumHwYB4VuqJuro9ostK6azHoqR4jGj0okgTowOewarpLU9ue0Y3qnKaDCQMqAw2
 PuB6qhHhQAEKYm7yVJV4UbWUnWUNRkRLdY7uRIBeShRmBBXxVDoLjlFM7g922mZtDhPF
 4C0qeuAYfSTi7CpJwgV8+lTEim1cg5ueY59ssk+m436mxVGbePbKIlIvH+FA17iqCgh3 Lg== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
	by userp2130.oracle.com with ESMTP id 2tx61c05p8-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 22:35:31 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
	by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x6OMWLsd036789;
	Wed, 24 Jul 2019 22:33:31 GMT
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userp3030.oracle.com with ESMTP id 2tx60xys91-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
	Wed, 24 Jul 2019 22:33:30 +0000
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x6OMXTIB009759;
	Wed, 24 Jul 2019 22:33:29 GMT
Received: from brm-x32-03.us.oracle.com (/10.80.150.35)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Wed, 24 Jul 2019 15:33:29 -0700
From: Jane Chu <jane.chu@oracle.com>
To: n-horiguchi@ah.jp.nec.com, linux-mm@kvack.org,
        linux-kernel@vger.kernel.org
Cc: linux-nvdimm@lists.01.org
Subject: [PATCH v2 1/1] mm/memory-failure: Poison read receives SIGKILL instead of SIGBUS if mmaped more than once
Date: Wed, 24 Jul 2019 16:33:23 -0600
Message-Id: <1564007603-9655-2-git-send-email-jane.chu@oracle.com>
X-Mailer: git-send-email 1.8.3.1
In-Reply-To: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
References: <1564007603-9655-1-git-send-email-jane.chu@oracle.com>
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1906280000 definitions=main-1907240241
X-Proofpoint-Virus-Version: vendor=nai engine=6000 definitions=9328 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1906280000
 definitions=main-1907240241
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
 mm/memory-failure.c | 62 ++++++++++++++++++++++-------------------------------
 1 file changed, 26 insertions(+), 36 deletions(-)

diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d9cc660..bd4db33 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -199,7 +199,6 @@ struct to_kill {
 	struct task_struct *tsk;
 	unsigned long addr;
 	short size_shift;
-	char addr_valid;
 };
 
 /*
@@ -304,43 +303,43 @@ static unsigned long dev_pagemap_mapping_shift(struct page *page,
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
+
 	get_task_struct(tsk);
 	tk->tsk = tsk;
 	list_add_tail(&tk->nd, to_kill);
@@ -366,7 +365,7 @@ static void kill_procs(struct list_head *to_kill, int forcekill, bool fail,
 			 * make sure the process doesn't catch the
 			 * signal and then access the memory. Just kill it.
 			 */
-			if (fail || tk->addr_valid == 0) {
+			if (fail || tk->addr == -EFAULT) {
 				pr_err("Memory failure: %#lx: forcibly killing %s:%d because of failure to unmap corrupted page\n",
 				       pfn, tk->tsk->comm, tk->tsk->pid);
 				do_send_sig_info(SIGKILL, SEND_SIG_PRIV,
@@ -432,7 +431,7 @@ static struct task_struct *task_early_kill(struct task_struct *tsk,
  * Collect processes when the error hit an anonymous page.
  */
 static void collect_procs_anon(struct page *page, struct list_head *to_kill,
-			      struct to_kill **tkc, int force_early)
+				int force_early)
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
@@ -457,7 +456,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
 			if (!page_mapped_in_vma(page, vma))
 				continue;
 			if (vma->vm_mm == t->mm)
-				add_to_kill(t, page, vma, to_kill, tkc);
+				add_to_kill(t, page, vma, to_kill);
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -468,7 +467,7 @@ static void collect_procs_anon(struct page *page, struct list_head *to_kill,
  * Collect processes when the error hit a file mapped page.
  */
 static void collect_procs_file(struct page *page, struct list_head *to_kill,
-			      struct to_kill **tkc, int force_early)
+				int force_early)
 {
 	struct vm_area_struct *vma;
 	struct task_struct *tsk;
@@ -492,7 +491,7 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 			 * to be informed of all such data corruptions.
 			 */
 			if (vma->vm_mm == t->mm)
-				add_to_kill(t, page, vma, to_kill, tkc);
+				add_to_kill(t, page, vma, to_kill);
 		}
 	}
 	read_unlock(&tasklist_lock);
@@ -501,26 +500,17 @@ static void collect_procs_file(struct page *page, struct list_head *to_kill,
 
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

