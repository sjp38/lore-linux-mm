Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9A75C48BE3
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8701420881
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="lRKaScX8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8701420881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B28A8E0007; Fri, 21 Jun 2019 20:01:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 365C48E0001; Fri, 21 Jun 2019 20:01:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DD048E0007; Fri, 21 Jun 2019 20:01:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id DEF028E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:01:33 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id d3so4989143pgc.9
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=sJABK1zpDg7Ft2uXH4vAnIUzHhjbvzrUfLcW5nvbJCGPrSef3Hx+S+MAx8fTe6mdaG
         2rKGhzV4LzPjYYm7I3FZ14e/oRcUO4NcFx4tm2QWlsSsysZPFX1O1U50oan9qnrB8scH
         VFcL8QkY78TS5Sdg6fzfOwsb9gbwQhO1KseM5lu6vX1ivKeLfBTGsnYvIejp0Aw5/1tA
         TY5FawOA84RmUCh2anAWcWLXbkl0R76/M82XWjj4mQjxk2DW7f4EtcHPNzBU/XV9ksLL
         IM++VRMoKtNDU1fihL1HkduzbhdvlT7x5RQruEP4g7QpV1QgS+BSS6wgrF/eQIRO6SLi
         Jq5Q==
X-Gm-Message-State: APjAAAXI9QPHcSLJ4+S9AKAnZF75PQSde44Lg0P3G8edU8whEDXvNDDq
	/Kv7SkCTAVztcHyGv3xkNDh7QGsVz8NCD2gIEn4qUohAAOPXsWkqr2OJLOgIkLebrqv1Ymyabj/
	fZ7iN3X6XBQo4pb8iKe9L3YOX7TSj6UnKyGD8liwCKXLfJicyRR2zglE++FNW//EXVw==
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr14010604plt.248.1561161693586;
        Fri, 21 Jun 2019 17:01:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyQ6m82j9bWX/vHqZxCG5VBOc/zXTT3WGcW4XotgiYtgY/bn1JJVOWOyeXBoTzuQv+lmPhS
X-Received: by 2002:a17:902:70c3:: with SMTP id l3mr14010548plt.248.1561161693033;
        Fri, 21 Jun 2019 17:01:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161693; cv=none;
        d=google.com; s=arc-20160816;
        b=RobfB206U0FEmk2JDij29b/rkKeaFSVCncQ3o9ahrnFHfEe4d8uNMqLi8GfF8S04c6
         0YoOmXjGvwcEX8BvNFZCy3OGaQfvFA57dp1gZs7V8a6UJMP6nPcQgSz4ZD/MBAN2u3Xp
         Loz9Mu37uVWwsX963WVnwnbbgVGz+TjIUnIaUfLv66Rd1YTcpAzl5PhG91WjkaQVVjAQ
         CBDsJG6dJLQ0WpKyu7Ugr90jXTa3Ti3sC+CGXQRWGf1aCNQFu3ELOsqkZzQZLGYGNEed
         LWvKAUs8XzFlBcdSFgNJUOIjfP0B/0imjiHXoZHE22ek4WcojMmEHGs+CM9X3wfe1fGj
         jMpQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=U7378p/jxE8mPZJ3HdfAPaUng/xB3JDX1aCG7d705jH6CC+70rqZxYU1o5yYgcP6YL
         b7lZTM4PKTjJx4NQ2RzjfeyuyVOGeYGr+TihNLfVjruYdSj0uFjH8jBajTrT52QqMX/s
         AkLkp0zEj7sYmT9LeV5PjgIXJlm002/o+I8XcShC3ZVYPlylUg4aylVsyoDtgAoqQ9eO
         IUhFeKP+0kJcN1UwO1eXOCKJyw3GimzXXn4TmhUqZWScEgsteE47rPsutUcKq3ahNVRh
         AKKM6MlFLHEROIL/tGeG5Lv3y2ka8c//kIjqJq6PIDtYibPJEDh+H13gXnvaicbJMcdE
         Q6Sw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lRKaScX8;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id m63si4024752pld.385.2019.06.21.17.01.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:01:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lRKaScX8;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNseqQ018820
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:32 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
 b=lRKaScX8kRdJ9jxl9lJwhSZxaoYO8XtSXrxKFfReMH3oL3f6tFB7wD3OirK8h+dC2qdU
 sGJovoq9+SNK3fdYYFXO+UV7qXhcL81lNR/RiJzqO61dy+J6TD18GKmTJHh3GP45quCE
 0A8AtF92OBqf4NtUDbLsHc1dV5/zvzKhbKE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t91rg1q9d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:32 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:01:31 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id A354762E2D56; Fri, 21 Jun 2019 17:01:25 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 4/5] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Fri, 21 Jun 2019 17:01:08 -0700
Message-ID: <20190622000109.914695-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000109.914695-1-songliubraving@fb.com>
References: <20190622000109.914695-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=728 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches uses newly added FOLL_SPLIT_PMD in uprobe. This enables easy
regroup of huge pmd after the uprobe is disabled (in next patch).

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 kernel/events/uprobes.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index f7c61a1ef720..a20d7b43a056 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -153,7 +153,7 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 {
 	struct mm_struct *mm = vma->vm_mm;
 	struct page_vma_mapped_walk pvmw = {
-		.page = old_page,
+		.page = compound_head(old_page),
 		.vma = vma,
 		.address = addr,
 	};
@@ -165,8 +165,6 @@ static int __replace_page(struct vm_area_struct *vma, unsigned long addr,
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, mm, addr,
 				addr + PAGE_SIZE);
 
-	VM_BUG_ON_PAGE(PageTransHuge(old_page), old_page);
-
 	if (!orig) {
 		err = mem_cgroup_try_charge(new_page, vma->vm_mm, GFP_KERNEL,
 					    &memcg, false);
@@ -483,7 +481,7 @@ int uprobe_write_opcode(struct arch_uprobe *auprobe, struct mm_struct *mm,
 retry:
 	/* Read the page with vaddr into memory */
 	ret = get_user_pages_remote(NULL, mm, vaddr, 1,
-			FOLL_FORCE | FOLL_SPLIT, &old_page, &vma, NULL);
+			FOLL_FORCE | FOLL_SPLIT_PMD, &old_page, &vma, NULL);
 	if (ret <= 0)
 		return ret;
 
-- 
2.17.1

