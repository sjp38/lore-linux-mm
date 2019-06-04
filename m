Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 02A98C282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B210D23CF3
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="oQFRwoGG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B210D23CF3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 62EF46B0273; Tue,  4 Jun 2019 12:51:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5B7F26B0274; Tue,  4 Jun 2019 12:51:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 458F56B0276; Tue,  4 Jun 2019 12:51:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 285066B0273
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:51:55 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id k134so19724367ywe.7
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=MR6fp4k0GSjen+IjWvEdAVeV4aJcgnyY2DTlkJp1kX0=;
        b=sWHWk+pvH1uw6UVZfM3tG4ln1v46DILX1DW2XEE1BWopC3TExR22dzvq3sHAF2QfvN
         bepScKzesArO/PdvYniewF9CBwL+3tUpmaaUDwEbn+YWS7nwzDUxzICjQZD4TzMDGpzT
         1dXMfPrJiTPLt6dbmpu4cInvXVuxT+h4+eohw608CHkUVetEFPI/9itjvqEIKESa4le2
         dUaB3y7MFaFoGtasX0bxu1NvjZPUp/VxWtvXnyMpWP2BxCC204WVy76o71dWKTwQ6JKF
         1DvAG73tnBFHEcVFq5bD2iykmh9sq3/MRsYAQNKu+QZFSHcdbxQTTezJeweu0V1xcWJ/
         JbXA==
X-Gm-Message-State: APjAAAVwWUz02H6dUwyI3k5/hXbqJnZ8bi0bOelVkLQYWifGTdSyHsIk
	10bFtkhGQaq1JiNMvuUsRVpltPDxqHsEWbIkU2l1IVzNMC6sy0FcBnn3mCYo2EJc4rURwLkEoEC
	6jDnQs19G6ELEcOKQh8QxCbyPQ2/YHUTmcxUWQqyrCps9jO6NaUm0SlBY9c2vpQpCRw==
X-Received: by 2002:a25:af89:: with SMTP id g9mr15916020ybh.483.1559667114886;
        Tue, 04 Jun 2019 09:51:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwVMXXp3DUlHInt2hzyhVEKO1TCJ2v5+LBzk53MDFbg4BdneJDvkHL5/D5DgS65n2okWxTI
X-Received: by 2002:a25:af89:: with SMTP id g9mr15915999ybh.483.1559667114295;
        Tue, 04 Jun 2019 09:51:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559667114; cv=none;
        d=google.com; s=arc-20160816;
        b=oq5c4LQslzFTltSe8xHlc3n2DFbi+JL6IrgFHcE+s74MlI8eyQESAYEUDowzskGJHE
         fFgjpcrYWS1wJR02qcgwEsmM+Pye7aoIgyOSsiG8LNPnNmRPVawd6alaCGW3P5bX9gYk
         lh60bYa2HPScwlcqmdk8T+376mJs7iSG/4V84ScVUYaFAtQFLte4hOD5ExwY7QRbplcA
         dibSY8ggVjUZ+hrCYUfGf9fyF/oT0Kno6n6innIHGwOluhdAd5w7g9/uJcwdH30q8ugh
         mIri929RvyImKPUNQXvYbRldhlApJD/frP3UAZzrM6lxypyIhkQU7XK3XbX17VwHLHpM
         Nrcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=MR6fp4k0GSjen+IjWvEdAVeV4aJcgnyY2DTlkJp1kX0=;
        b=rX5HYTC6rKRhBDllMKDa2D9JM0xMZFNMklCTYBn5vGEbNeWOWruA4fRzxzi9mnm3Yv
         yiX8ciaV/0Ga2FTon1thkTP9rvG3t8mi3toV4XxPrvNfgjvNTyPRkJK5llAB11ggS7be
         H3xXQFQ5QgQu3nlYOOCQA1y/WtZP4pR8aq7iaY9g1f9Ni7MYGfernuUKwyaTVbn49nSI
         7tQxq+g2CbhVpUN+uzaDLunQhYD5/KLADaRix86t936YlOh1yB1gCJ/uwbWN+nN+sMAd
         BEodvGyfOTUg0+Adi35oZ9swzyuxwF4VgBtoxT/QUAn4zpY0Q5nD9naShF8TCOuSV2AL
         wVtw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oQFRwoGG;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id x83si1156538ywa.193.2019.06.04.09.51.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:51:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=oQFRwoGG;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x54Gd82U023788
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 09:51:53 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=MR6fp4k0GSjen+IjWvEdAVeV4aJcgnyY2DTlkJp1kX0=;
 b=oQFRwoGG5Aj4+OVviID7vM+knNq4x1P90EH6YS1PoN1K9BuhMEwB63zAQuwYWGL21OKU
 X/8XNBDCMyFfD16zbPVw8iOkAnaTnnH2HWFhVYIC8iRG6YevuOlSN9+cZAWCYHlQA7kp
 V9lKC1P4J2NDJsD5oDYk+KEDQkgY4eNZMtQ= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2swr7ms081-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:52 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 09:51:52 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id D993D62E1EE3; Tue,  4 Jun 2019 09:51:48 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <peterz@infradead.org>, <oleg@redhat.com>, <rostedt@goodmis.org>,
        <mhiramat@kernel.org>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp v2 3/5] mm, thp: introduce FOLL_SPLIT_PMD
Date: Tue, 4 Jun 2019 09:51:36 -0700
Message-ID: <20190604165138.1520916-4-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190604165138.1520916-1-songliubraving@fb.com>
References: <20190604165138.1520916-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040106
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patches introduces a new foll_flag: FOLL_SPLIT_PMD. As the name says
FOLL_SPLIT_PMD splits huge pmd for given mm_struct, the underlining huge
page stays as-is.

FOLL_SPLIT_PMD is useful for cases where we need to use regular pages,
but would switch back to huge page and huge pmd on. One of such example
is uprobe. The following patches use FOLL_SPLIT_PMD in uprobe.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 include/linux/mm.h |  1 +
 mm/gup.c           | 15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1bdaf1872492..8b5f4a9aea0b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2633,6 +2633,7 @@ struct page *follow_page(struct vm_area_struct *vma, unsigned long address,
 #define FOLL_COW	0x4000	/* internal GUP flag */
 #define FOLL_ANON	0x8000	/* don't do file mappings */
 #define FOLL_LONGTERM	0x10000	/* mapping lifetime is indefinite: see below */
+#define FOLL_SPLIT_PMD	0x20000	/* split huge pmd before returning */
 
 /*
  * NOTE on FOLL_LONGTERM:
diff --git a/mm/gup.c b/mm/gup.c
index 63ac50e48072..bdc350d95d99 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -398,7 +398,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 		spin_unlock(ptl);
 		return follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
-	if (flags & FOLL_SPLIT) {
+	if (flags & (FOLL_SPLIT | FOLL_SPLIT_PMD)) {
 		int ret;
 		page = pmd_page(*pmd);
 		if (is_huge_zero_page(page)) {
@@ -407,7 +407,7 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			split_huge_pmd(vma, pmd, address);
 			if (pmd_trans_unstable(pmd))
 				ret = -EBUSY;
-		} else {
+		} else if (flags & FOLL_SPLIT) {
 			if (unlikely(!try_get_page(page))) {
 				spin_unlock(ptl);
 				return ERR_PTR(-ENOMEM);
@@ -419,8 +419,17 @@ static struct page *follow_pmd_mask(struct vm_area_struct *vma,
 			put_page(page);
 			if (pmd_none(*pmd))
 				return no_page_table(vma, flags);
-		}
+		} else {  /* flags & FOLL_SPLIT_PMD */
+			pte_t *pte;
 
+			spin_unlock(ptl);
+			split_huge_pmd(vma, pmd, address);
+			pte = get_locked_pte(mm, address, &ptl);
+			if (!pte)
+				return no_page_table(vma, flags);
+			spin_unlock(ptl);
+			ret = 0;
+		}
 		return ret ? ERR_PTR(ret) :
 			follow_page_pte(vma, address, pmd, flags, &ctx->pgmap);
 	}
-- 
2.17.1

