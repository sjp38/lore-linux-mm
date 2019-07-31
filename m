Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2F0A1C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 18:33:41 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E4F5C206B8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 18:33:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Rcc1vkKI"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E4F5C206B8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 76E1E8E0003; Wed, 31 Jul 2019 14:33:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71F028E0001; Wed, 31 Jul 2019 14:33:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BEE58E0003; Wed, 31 Jul 2019 14:33:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3C93C8E0001
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 14:33:40 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id f11so51152616ywc.4
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:33:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=bRpkMB+IavxhRux4OXH4DLu7NlF/d2cpuzrzUbrtFGI=;
        b=MA6IZYZPiq1M2gqebqJZuCr0r4MbLI1YgX20TBko4MpWiffR85pEKstjnn9MRFhvoW
         hmBjeJ9pFYq6CYXYLeF2LrT7ChhqWP2ZpA1sqquOj/2ABbGmPV4VwVQMfvQ6cgMyq74m
         WjfNv767TlmxC/EXSEPaVH54ITlSa2hFs0OuJnifurWkZOeQA/H0jdUmvXiWjwxFoPVP
         z1CqlS7oWoBzQlu8sTFgwCqDTTjVf0CFJ04u+DJE6vw6BoRmLj6lj+nMnDK0tAqlo2YP
         NaG9rlxpJivuJoa2kjDHm1KkaVqTqes/qJH/O9mplvJd3pbjKmX9VdxiC1N2rpwGyLnG
         HjsA==
X-Gm-Message-State: APjAAAXKQCKTs/M1m++K5Y18A3LCqs9zhRp1mU31Zn5pIuhMSiY0SyVy
	UXXhxsnv/P/U6iejSOWSeubNXLT526ZvHjuQZcnxnL5qQCfLl3vz4e+GTPzaaSErIMbz9HLnqIe
	bKep/qVJq/OGtsQ1TBZrGAxO0D25XIzyAN8xXN/+Bo4ppcKtP9YfQETTf/kzd2A8COw==
X-Received: by 2002:a25:2d43:: with SMTP id s3mr52024627ybe.209.1564598019829;
        Wed, 31 Jul 2019 11:33:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwk6h6tanADCwSXvGf7du3X+8SZD6Fq3kn/CaRhJlvtkfusWaHf0sOHRVJS3amkyHzSPvPG
X-Received: by 2002:a25:2d43:: with SMTP id s3mr52024594ybe.209.1564598019065;
        Wed, 31 Jul 2019 11:33:39 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564598019; cv=none;
        d=google.com; s=arc-20160816;
        b=v/1Uwk4DSTnpniJA3BcDg9n0GDGXcMWLRfjBj9jjA/f5OpVfIuG5TCO6MGLANE9rpm
         ClKpH5mqxmoKQ1xXOEXw56D6+c4XxacwiQRKt2oISJKNbgpmym/XOvTp9odjsuxbAVfr
         OzRVUsuaNqUoUDtpURncdbnrf/R53/UYt3UwftYkMZSwm9w3CZuLYXIUC0wVZOxFPTok
         tpWdGxloL85kcOIJkI0ZWvY06hCGOvCOfLIo4JEMBBM0J9dN1s+xknW/39pLA9CFdrTW
         RSncMRCJRYCuGJfC3kQkYdfhwc3S4ELTHtF7xuJdt1b4VVUHskxbcO7W6XD5O976eUl1
         f7pg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=bRpkMB+IavxhRux4OXH4DLu7NlF/d2cpuzrzUbrtFGI=;
        b=DcnhZ5zcwhyXw7+ems+MYQWDVRuUDR0lh8CiFFRa6kjMbXAQyo36k3RUp79Q+LsYEk
         puSkFqdm2EUIHqQVRKJPras0Cga/4zzYDtiQLxspSwb2va3spBSkmOrIbj9bSTRMhVQ3
         ZCz1fo7blkcRAZEwJHu3syB5AiORQs/y02r3daMAZ96CyAM572t/apkZw5fzRqQZfT3P
         IDeLGb1d3S9PwrLrYhyTc1+OS/0Sr4f5nVT95Q/xp0SgY6SNeEB6KY9V94KD/6DVINj6
         Vn3V6zxJtYlK0ff5F07aMC/DAawiBzUo6zy6KuCKgJAcePj8Bd0E9FfWKIjhy5cPSU16
         QDCA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Rcc1vkKI;
       spf=pass (google.com: domain of prvs=3115c6337e=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3115c6337e=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d30si3755728ybi.136.2019.07.31.11.33.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Jul 2019 11:33:39 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3115c6337e=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Rcc1vkKI;
       spf=pass (google.com: domain of prvs=3115c6337e=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3115c6337e=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6VIWs6K020733
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:33:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=bRpkMB+IavxhRux4OXH4DLu7NlF/d2cpuzrzUbrtFGI=;
 b=Rcc1vkKI62WNwXRCQyABJMLu8U90g3ObOaBIJFUyfU+JoKhJYh8LFAsowvQyvDWbpc+C
 BbnI81+p52tmz8vU/k5ad4M/wplt+GZtZcgCSFLe6YD9+bdnxk/CHXDrPgoAwy6DQFNu
 tIT0AG8NJnl1lfVg3/raftTXv1YgZWQyqyY= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2u2wn6um94-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:33:38 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 31 Jul 2019 11:33:37 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 129EE62E1BBA; Wed, 31 Jul 2019 11:33:36 -0700 (PDT)
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
Subject: [PATCH v2 0/2] khugepaged: collapse pmd for pte-mapped THP
Date: Wed, 31 Jul 2019 11:33:29 -0700
Message-ID: <20190731183331.2565608-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-31_09:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=570 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907310187
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

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
 mm/khugepaged.c            | 138 +++++++++++++++++++++++++++++++++++++
 3 files changed, 159 insertions(+)

--
2.17.1

