Return-Path: <SRS0=7ZCb=UD=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9B15AC282CE
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0CF7023D01
	for <linux-mm@archiver.kernel.org>; Tue,  4 Jun 2019 16:51:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Q5QPUKXw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0CF7023D01
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 962A66B0270; Tue,  4 Jun 2019 12:51:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 913726B0271; Tue,  4 Jun 2019 12:51:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7DB136B0272; Tue,  4 Jun 2019 12:51:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FCF26B0270
	for <linux-mm@kvack.org>; Tue,  4 Jun 2019 12:51:45 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id t141so20179133ywe.23
        for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=4vfw4x4g7qALuffQGrZlRhcm9jc5lU9DUJSs67h0A2c=;
        b=tmQ6EA9OtM8T8uxAoVWguOMKWsQALElexjiX8KojwnrPNqZiPjmKVTnbHWVb09jc2m
         pRFY2Alkmp8ZXgEQprWp+1txQWRX9Gx4kaRZM+2ChyetNPPaiRRUDmPeRr1YG9IJ1HRG
         QIAKnDree3zIupU6KbMypo8lL5EaXFlfLE96oWx1JxQtnHS7KKU58nPru2kVyJAwpBzF
         fzYL/3ARH15Eubxg6nGmX7A17lX4V0u49rdvvlLjOshR22agfO+C+U7MaYdObXQLtBDv
         fiYgmPWvNMnrJto8x5pclUpfRz4ig8yy3w2yAMC2SIJPMzwT9FjpC3yclp6Hu3MtVSwb
         uRqA==
X-Gm-Message-State: APjAAAXBzKIefvsmSatjZpcD+USgLk0/YcUFsaJEFikOwNdGzysptF2z
	bfFxjj8mNy2ta1Z5nhhnSaGKI/YrzabjJd1zQ7uJIT5Lj26SXTnFaVfPhcNIztWIvkJqQMtAjoi
	s/EOby/PIhFkZF2dXn5d99Xxr1ZCSCgsuBSdsYdJTZusJ9zHIzsFe7CF2UL54wVPHOg==
X-Received: by 2002:a81:31c5:: with SMTP id x188mr1741994ywx.429.1559667105084;
        Tue, 04 Jun 2019 09:51:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy9KwrbDQfZdvtCqgW96W3BTOqRnSMU5URMhdwFUbFCGyU40n+tRMJreedpF1o+v0/v5V5C
X-Received: by 2002:a81:31c5:: with SMTP id x188mr1741958ywx.429.1559667104093;
        Tue, 04 Jun 2019 09:51:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559667104; cv=none;
        d=google.com; s=arc-20160816;
        b=W8+avxIAteQCHVEzQWNR5KZQ5Y13cDauw1/V6U77guTlx6l5G5w8tjKANDKuiPkZsk
         gx1vKfu3cr647jxJ9+khkWKN1My9EN7ZasKXjFhCknD/MUFwfyv1DMirfV0f621bA6hp
         Us7upj3TEZ0aPbLaVi8jnWLM95wZk2j+mAlAs3cJyuz+Eh7kHEPVYEVSBYMqEhWZZVxY
         DRCLCrUzeqfPT44DLbM2007HVg/reCnslLRd3dBLkTpIP5lsJF5b2pYGbPw/d0x9EXYF
         VwAPdZNRG5mz1brTTqvh5p8tTB2xUrjrSB1V3oEplW0v5BX8sYU+LykUAs17VKVALTkv
         n5GQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=4vfw4x4g7qALuffQGrZlRhcm9jc5lU9DUJSs67h0A2c=;
        b=Ux+6E+nCr6bZ0py6cvjpceg9gzolQMH1sFcr/s4ZffCoRF4uDjTjR/0lchK9eMQ8SA
         FGEaAuGwx1/1H3tv82HNGzHYkXwdsEsuiVzECukJKZ0lRmzh6mkK5xeOLBy8T/DR3tNW
         00F7z89X+1A+hQ1wEjPgOpsYCXbxwWDCzG7bW3z7CFc0d3r6m6RB+QuayRwRQUm5mIxS
         RvQXCkXBsDDXr7sMDUgKhyVs6J3CHn+Q1FYMczJjmT6KTtBqhWMnt4QhdMysA1cqG7vY
         3+Ks+/jH8cC5p6hVY9y7wURWsppeU9brrspo4wN/o2122yKLrOLJ8SXspsgeJNbNgCrS
         q1Hw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Q5QPUKXw;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d201si5633289ybh.337.2019.06.04.09.51.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Jun 2019 09:51:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Q5QPUKXw;
       spf=pass (google.com: domain of prvs=1058d0e874=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1058d0e874=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x54GYNKr004052
	for <linux-mm@kvack.org>; Tue, 4 Jun 2019 09:51:43 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=4vfw4x4g7qALuffQGrZlRhcm9jc5lU9DUJSs67h0A2c=;
 b=Q5QPUKXw01xhg4VNX6yjKq0jMc29aUFKFAyxgzdCgQBWsY/syPVFNh6ke/CMLolWYzGr
 i/Hk3jAZ4/6tLdZNxhSdyi3z7JR2enaM+y6kWiKOUDaOCR5DZvnNWd5PEnT39gi8sXaT
 +pYk7BJ+LXrgvRw4VynjLgD2vdpOGbjhL1s= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2swska8qj5-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 04 Jun 2019 09:51:43 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 4 Jun 2019 09:51:42 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 5DD9362E1EE3; Tue,  4 Jun 2019 09:51:41 -0700 (PDT)
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
Subject: [PATCH uprobe, thp v2 0/5] THP aware uprobe
Date: Tue, 4 Jun 2019 09:51:33 -0700
Message-ID: <20190604165138.1520916-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-04_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=871 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906040106
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set makes uprobe aware of THPs.

Currently, when uprobe is attached to text on THP, the page is split by
FOLL_SPLIT. As a result, uprobe eliminates the performance benefit of THP.

This set makes uprobe THP-aware. Instead of FOLL_SPLIT, we introduces
FOLL_SPLIT_PMD, which only split PMD for uprobe. After all uprobes within
the THP are removed, the PTEs are regrouped into huge PMD.

Note that, with uprobes attached, the process runs with PTEs for the huge
page. The performance benefit of THP is recovered _after_ all uprobes on
the huge page are detached.

This set (plus a few small debug patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Changes since v1:
1. introduces FOLL_SPLIT_PMD, instead of modifying split_huge_pmd*();
2. reuse pages_identical() from ksm.c;
3. rewrite most of try_collapse_huge_pmd().

Song Liu (5):
  mm: move memcmp_pages() and pages_identical()
  uprobe: use original page when all uprobes are removed
  mm, thp: introduce FOLL_SPLIT_PMD
  uprobe: use FOLL_SPLIT_PMD instead of FOLL_SPLIT
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/huge_mm.h |  7 +++++
 include/linux/mm.h      |  8 +++++
 kernel/events/uprobes.c | 53 +++++++++++++++++++++++--------
 mm/gup.c                | 15 +++++++--
 mm/huge_memory.c        | 70 +++++++++++++++++++++++++++++++++++++++++
 mm/ksm.c                | 18 -----------
 mm/util.c               | 13 ++++++++
 7 files changed, 150 insertions(+), 34 deletions(-)

--
2.17.1

