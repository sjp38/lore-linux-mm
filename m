Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BDAFDC433FF
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 78F242187F
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 23:18:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Zc85Mvjf"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 78F242187F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 048E86B0003; Fri,  2 Aug 2019 19:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F3D5A6B0005; Fri,  2 Aug 2019 19:18:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E2A546B0006; Fri,  2 Aug 2019 19:18:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id A804E6B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 19:18:23 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id r7so42515009plo.6
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:18:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=zP/oZCNmT3XfZ0O8wKdyr35FShYUm1XHrIrNthNeVsc=;
        b=hmqWkM5kzRsgFFmZccHXOqmm/NZ+lvszWsPhe5R6rK0vzd+QqcUCx+w6AJOBbBj+Jx
         c/SZkjKx1bXdjV2UcVKb2PFVk+X/c9Peijj/d8v9LfowSbbJ/Dqg+KRZ0ve6Bz21aGfC
         SyAQ4ILiJ/kgr+xm3yAhVsZp4gvYNM9kfDLs3sq+I6+B3UZ9MD8UZJ64HuODHk9JTqDU
         sN4DD6zNyYLtK+NVedKzMlupwESGAouTQ0dgdvr5t1nL9qhr5QA24fQGcj08yj0WENce
         UeiSBIBWCS5F7XmtPxwTTRxsnHKFDgcj6fwssVbNUemw++9+vx9OgcKlRyIcaD2vFAZS
         vyqg==
X-Gm-Message-State: APjAAAU9NHNBSwmGoVycH/P+HiN0LzzCO+TsKCr6wcM/yhlcNkE/r3Bq
	pI3Y2uXCxfBT98kz6in1kkjwpgNXd4LkkRDQFPRu5bnULB2x6+7TCwoPyBiBgzEQxc0YaM/amem
	yX/3f0v59d507SW6+ehRpmQfD0yQxVTsFg53pqUEA/QZjtDmjTT17CFcHV/xwJggATg==
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr50164800plp.126.1564787903234;
        Fri, 02 Aug 2019 16:18:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzkY6wMRPeyjgcyjR09exCTnClbEdNj8NbGdP676Ko/2r1oDQSITzMypE/w0lHYenY0yGt8
X-Received: by 2002:a17:902:9a95:: with SMTP id w21mr50164757plp.126.1564787902498;
        Fri, 02 Aug 2019 16:18:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564787902; cv=none;
        d=google.com; s=arc-20160816;
        b=XY7G1MgPs/PKiSSQd1uIHWcCJXqe+FbEBDGlBJ2Kho5uZZAytp2mCuJ8s5pKn9ohhc
         9pa3cIh8edESyzPuOi9owJu5CCoGE3aVX/jvThnTDOQNunqxkqYYF4T9gonNANViA3i5
         qXZgDXr/2IM/34RYO7Vj2pCgRdUCTeySCwgRzh+MUZArCjMbEtELdDVw86SFD3vXtZY4
         RBkq41CeEYE18epFdShrqchkK04Tf68Zltj8mHwA8xRe8XrdubvRuRkH2e0V2KPxM6G3
         B7g/rYbG91pQ1PgjA6dH5EN+oSCHLUIEUjsq+KOIuEre1LG4Yua/i3zpxZMA57dReKV0
         P84A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=zP/oZCNmT3XfZ0O8wKdyr35FShYUm1XHrIrNthNeVsc=;
        b=ZGZlemFwCzEfSeQenbAe67NoSkQc5ofxd4eh7TwNdUeo3DiJnsF5E1uVL7ckokIkQO
         DI2swR8MPHH2kEPaOyVPZ48ob4QTjvGBwgWyAhSPGIntUdf3EfA1Ul9xTHkOoyenREOR
         25BhSqumJkerUvq87mYLlH1+k0MdLwUke4y04EQW+2cvOeqNzre4FlRus9y1Vg2n3BsY
         r1F6b+ahFa4O/Fi3qwz4U0OIkJTZS9M+TOvM575QilE+oFFaAltT58XEtlubZg7qFPqK
         G6ICiZk+qd1IH1CiGh5RslCYigK2LxJ7ti7wVHWiZfzlIjbGpvaot/CtqjSXcpnxmyml
         6RQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Zc85Mvjf;
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id i32si7391136pje.44.2019.08.02.16.18.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 16:18:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Zc85Mvjf;
       spf=pass (google.com: domain of prvs=3117788d8b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3117788d8b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x72NHvf9026581
	for <linux-mm@kvack.org>; Fri, 2 Aug 2019 16:18:21 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=zP/oZCNmT3XfZ0O8wKdyr35FShYUm1XHrIrNthNeVsc=;
 b=Zc85MvjfmG7XFnhSGb9Y4KWBA8FVB+sNukkhmkmldF0TKh2dn/XSvkzKkQL8ppraWqo1
 hxH0rWzIMH1Uvok2GE1ZjqL630ak/Mcbt8xb6wy19ixrKtqahVpbugp1EoSqzQiGL0fg
 j8Zs22FgFDZyZVciTRaxIcgDTFoO3WLriUY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u4py09vqs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Aug 2019 16:18:21 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 2 Aug 2019 16:18:20 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6514562E2BEF; Fri,  2 Aug 2019 16:18:19 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>,
        <akpm@linux-foundation.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <oleg@redhat.com>, <kernel-team@fb.com>,
        <william.kucharski@oracle.com>, <srikar@linux.vnet.ibm.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 0/2] khugepaged: collapse pmd for pte-mapped THP
Date: Fri, 2 Aug 2019 16:18:15 -0700
Message-ID: <20190802231817.548920-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=646 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020241
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Changes v3 => v4:
1. Simplify locking for pte_mapped_thp (Oleg).
2. Improve checks for the page in collapse_pte_mapped_thp() (Oleg).
3. Move HPAGE_PMD_MASK to collapse_pte_mapped_thp() (kbuild test robot).

Changes v2 => v3:
1. Update vma/pmd check in collapse_pte_mapped_thp() (Oleg).
2. Add Acked-by from Kirill

Changes v1 => v2:
1. Call collapse_pte_mapped_thp() directly from uprobe_write_opcode();
2. Add VM_BUG_ON() for addr alignment in khugepaged_add_pte_mapped_thp()
   and collapse_pte_mapped_thp().

This set is the newer version of 5/6 and 6/6 of [1]. Newer version of
1-4 of the work [2] was recently picked by Andrew.

Patch 1 enables khugepaged to handle pte-mapped THP. These THPs are left
in such state when khugepaged failed to get exclusive lock of mmap_sem.

Patch 2 leverages work in 1 for uprobe on THP. After [2], uprobe only
splits the PMD. When the uprobe is disabled, we get pte-mapped THP.
After this set, these pte-mapped THP will be collapsed as pmd-mapped.

[1] https://lkml.org/lkml/2019/6/23/23
[2] https://www.spinics.net/lists/linux-mm/msg185889.html

Song Liu (2):
  khugepaged: enable collapse pmd for pte-mapped THP
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/khugepaged.h |  12 ++++
 kernel/events/uprobes.c    |   9 +++
 mm/khugepaged.c            | 125 ++++++++++++++++++++++++++++++++++++-
 3 files changed, 145 insertions(+), 1 deletion(-)

--
2.17.1

