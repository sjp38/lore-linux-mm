Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 133EFC43613
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD885208C3
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:57 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="fuYxqoDm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD885208C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DBB336B000D; Sun, 23 Jun 2019 01:48:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D2A408E0006; Sun, 23 Jun 2019 01:48:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B96B48E0006; Sun, 23 Jun 2019 01:48:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 97B9C6B000D
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:55 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id j144so11042177ywa.15
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=mWaK7+Tws2dKkTI8FVVeQO88BGeP22tJYxWtGJecPd3Hkc0SOPWO9pW1o7Pnmt5zLj
         3sypflM8HcSDkh5Yt0vWobvjP8wPYF2UnmPhhZI/qDw0ymp1YSiY6lhpiGqXnr9XiFtp
         K6bVl1pR3Vyr59eeN1B//cNvDjQlckbYrgEyRoIxvZlM0ACVfTvdIqIT+X6AEFk7JUfL
         GDDeGe5fzf1+Fq6B2hqJ2i9lz4qlyumPg5cfRanerL4INszXerz3gtDGx0cVoS53A4J5
         dcxrAU/3b+L23tBmTwsKizBvAg1zP0dFtLuSVEqsjggZPz4+eHXNql+67GSd8NzKaiXW
         rG+w==
X-Gm-Message-State: APjAAAU8B6zO7zJnL1vSLQtvy7brW/reSZfYFBirHCzZtoNpdaJEc6bo
	mM4rvxLjEXvO/N9DmPvxuzejLf9S3I4XUDtw0BQXeqwHDcFrV6rRl0FErUKl9eAEuZdwDNcpyEK
	qx7kbC+Ivea8CwU1GFcmlcW6Ur0cd45eyWfVZ05pBi4+HYxd/yawTEyOf3wPNGK2qsQ==
X-Received: by 2002:a81:e0f:: with SMTP id 15mr69676366ywo.288.1561268935386;
        Sat, 22 Jun 2019 22:48:55 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztsxavSlT5dZUinl5yoCIJu/BH2V0dSb376AWEJpYKxd+7KVvQN60k9kNkwkfYfX2P4T+N
X-Received: by 2002:a81:e0f:: with SMTP id 15mr69676358ywo.288.1561268934861;
        Sat, 22 Jun 2019 22:48:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268934; cv=none;
        d=google.com; s=arc-20160816;
        b=fvc6mBNv3L1NEDw/6ykLVjbIBRuyEenOG88r79fzjbSiwgCfCNAaFX3NRkfr591Cvd
         8IGirLgnWJkInpOZtbcKhsNp5rF1oV1Q7q/Fuh1klRK0qz1IXhjGdvfV6Hu51xVtw/7p
         dJ8REY4qBDR0Q3Hac9cadRvcflIfV+C6M4DL+FbaB4DeMJTYYYse/QwFQU4bw2fWuBq4
         G70FQU0QE6kMbVA9hEQRYi4gNfcUx2IaiLniJTftL7664MN7587UDvjTSPTnIl3xS/m2
         p+rIX53bWr3Z1m5gQcqvdu5nF/M/1K5ujdk6VMh91TSlJhGKY6Ln+xlAKRQmXMupnHca
         YfvQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=mXq03vqV2zNVqfPM+vDtMsqAjRkt6/ld6DfrJl/lYq3LpuHKluPy8V255sq9/ycUrV
         yzaYkPZTwig5J/9jTrqmBPCgoiyiXlqmnk5BtYyzLbMLXQKGMzq3YfkL6jpaeQa1RKsP
         hESw+CvSX/bgZGkEt4xrSCSCQG2KAmEu/Kvntas9LAcs2/udorhWRsz/jLzB09EfivNQ
         oosOEhPlppTStGMIYQqz4kHfPQVysxGsp7trYle9CbiHTnNibPQEO0XR50a/PCagcMmE
         ka0c6XBSpsTSz6r1PxH8lPd0I4laZTkvE4KLmzhqagOMw/7H3DfxGvNqcPC7oRY3qHg5
         LyEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fuYxqoDm;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o205si2656539ywo.208.2019.06.22.22.48.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=fuYxqoDm;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5mrFK021094
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:54 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
 b=fuYxqoDml0m23kIXQduWqGuENzNdgDgevHC2MiuhD3dp+y2xjbc4brzUharJJS5buJqD
 0mcyGuX5KyeVD9xo69HXJOItTlyqBApEtG32g9MSLGZQQ1uWoU0FgRaNpJt2TQ78Zixr
 YzkAqi31hMPZSI1dD0rI5W5/MOaWgwBunnk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9hubt441-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:54 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::128) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Sat, 22 Jun 2019 22:48:53 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 34E9D62E2CFB; Sat, 22 Jun 2019 22:48:52 -0700 (PDT)
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
Subject: [PATCH v6 4/6] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Sat, 22 Jun 2019 22:48:27 -0700
Message-ID: <20190623054829.4018117-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054829.4018117-1-songliubraving@fb.com>
References: <20190623054829.4018117-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=715 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230051
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

