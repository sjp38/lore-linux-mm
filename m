Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 42EFBC31E4B
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 05FAC20645
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 17:58:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Wt1FUbG5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 05FAC20645
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 40E6C8E0004; Thu, 13 Jun 2019 13:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 321608E0009; Thu, 13 Jun 2019 13:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 03A408E0007; Thu, 13 Jun 2019 13:58:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC1258E0004
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 13:58:06 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f25so14960295pfk.14
        for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=K1KEBZIxufjXuMIz4uKAgBe015eGsoeqZgBeu+CYQRtlcRcWy6CsNHRLAVQuCRFir4
         JGjl65kyaefGwqIoeTSzYfLC0uTmm841MDw+x2M8oFHG8jzWTrfjJz9fiprEsgyVp9Dm
         q0zLFV92T0eezhyupT4BltHLaOE0V4GnZIl4sJcPpbpBenDvxgt1KVvB4Za0OY6FcDM+
         j+pLTr2DUnbkdqEkDJQkJp6+JS9a8tExk5RxClLhagDhlb8xsJe3eBsqbOtuNVGlV2HT
         +mMJTi0myq6jPGm8suqH5xxIJ5Q++dkNvlj1T9CVurVCvDZjC6gSrTJ1MKia1oQGwgAw
         n/dg==
X-Gm-Message-State: APjAAAVW0Zry6cfUS+QR+CoM4K3Tunkg1pZJhGQ+ShUmKAdeTxqVqyOS
	+r2vVbW+ZD1DtmLne9DolGygwv2cn7I9Acf3jpHW9yI/I4rRF/ssszjxkYO7Os1VMiBUixhYCNR
	2Vh7//bWqH7S5kaZH01t4IwYzmCJ12ug3kLJTAlAXBJ5s8g0/i9jCHqKF5TEm1v2nSQ==
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr31173681ple.192.1560448686364;
        Thu, 13 Jun 2019 10:58:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzE8NnHKXXT4xclP5RIOEEK9XOeYitlTWZgphC+ei5ZrOZRU52Tw28Rpt24w0wKlEY5p4gT
X-Received: by 2002:a17:902:44f:: with SMTP id 73mr31173634ple.192.1560448685756;
        Thu, 13 Jun 2019 10:58:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560448685; cv=none;
        d=google.com; s=arc-20160816;
        b=VHlGDkuwIV0Yl7Dois409zCzQhKLQRfHbZ/+c0VIKZWVMIG6zH2lDgcncXu3qchh16
         T7lHlTU69W083yOgCqv2UMzoc5dYL8XRjbPLQ4hTrfmHucbX8+Tp4Fm578MK7nFHk+/0
         BLT8EahVLWDh/f8iN/kO22psCTlaWo32xBK4iIgWKKKELde2n5hA+d7oBY2EEwRAJkLT
         q+tqch78iF1EhO5F8Nlh6EsLIBwQj6DPHCHZedEmmCBWbveZR3mbddF4+IHdyi07/CeF
         vQfoMHJsv/LProWt8fZZUqSPoLsfVjLDzciUzkqdjlNasChY+UAa4a+fPHXA7Ip4FoBp
         4QfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
        b=zwbkhQNEIKGrzKAx8X88zUpve/ZMjEipZNaWsL6q2y6iPd7gCo7kYR8+0uh/4Una34
         4jIADkBmJgMYgih04SKEM3wNuDl64HqJEW5SBEYVl2bilY06WCrpPsG7q3bzDOreP/n2
         CMhRhsMSi3wev9nkmYkZ3lYvccQPNbqBptJZWpv2WhiP5g/z0TL8UQ/bZheaah7MhbNT
         uMzgShkSt7e1VMKZ1ZBBb3tFo3/b/rfh+z/vwAY3+oyXcUZLczgUZ2MLPjfID9z9p5Rh
         M+gukLJ18mlrnllV2XvprnRTrXrvcmOxWVtxsOioWFLr8G/+4zxmaPTFLi7qQGp16Gpt
         hWNA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Wt1FUbG5;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d21si199458pfn.113.2019.06.13.10.58.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jun 2019 10:58:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Wt1FUbG5;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5DHvkL5025828
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:05 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=IZysbkBOWuoojpHfDDSz6omhgc5cHCXvaawoTaDfhK0=;
 b=Wt1FUbG5zYZH20fMhnUz0i8kVLVYdntEjTXnRGetNks+vBCiC1z0LcTNTFA2sEK7lvvt
 H2ykAxthK3KG9X5EQzeJ/GYOfbf9C01EyjwczI8Xy6RVbTT4oEGZajqxktRjj1vN+K0U
 nJ+S1yGus6Kj/9MNS6P9sQzCYl+JT+9iqj8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t3h8dt21s-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 10:58:05 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 13 Jun 2019 10:58:03 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 31CE662E1C18; Thu, 13 Jun 2019 10:58:02 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <oleg@redhat.com>, <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 4/5] uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
Date: Thu, 13 Jun 2019 10:57:46 -0700
Message-ID: <20190613175747.1964753-5-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613175747.1964753-1-songliubraving@fb.com>
References: <20190613175747.1964753-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=727 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130132
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

