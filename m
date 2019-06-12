Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1E6B2C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C13E0215EA
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 22:06:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="d5Nfvqxa"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C13E0215EA
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 05D676B000E; Wed, 12 Jun 2019 18:06:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E3ABC6B0010; Wed, 12 Jun 2019 18:06:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CDACE6B0266; Wed, 12 Jun 2019 18:06:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id A83766B000E
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 18:06:19 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id r142so16760613ybc.0
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=mJVdksI83pcAr/2dwtDaBJBK6Rf/MpbqiwJ18bpKuB4=;
        b=ANpmDg08iqOtO+r2l6oPk77TvFPyv+r4QDLBe1kJ/Q9DXAlbr8JFtPM0D2uREImOP0
         OuHvFvmjxVomFiZmtV8WzRTq3uuNJOx+o7+wbHeE2RI1+9lvcfz/RUG8ckUyb8lkeNBN
         n859TIzH4sWC6/G9FAntvAh297kL0mfW/TdmrXLiOmRc3KYp59nXsDv1YciSKvYV53O0
         ivNJoWKWjYm8k7+nNdJtqICXF0X8Tm4ppi7XwV2GJsu6f+vubViJlR7Tr+9iYew5e11t
         l8Y49MsN0FtFX7u/JEVVUpvDqJQlaX7BI2p9ajPxeY0UNimGgLD3ZbRWpOnT4ofQ6DCr
         8npA==
X-Gm-Message-State: APjAAAXUJ8w+AD0YlPPvrDMblrQhYOMMzTS/s7AIW7uKgytzy4d7DYee
	1EpPJPsnbm/vk9SRTIP1gkfNtJ4IVDlSduzkCxssKkLkoJ69PVzfNLn6rxvAgjJXfArCJwQX0rb
	ZeU+fA26Pd0lbMQuiMtrPL7bLps1PXKmHuUZSNtUqzIuFd4x60VxcN/I3SnLK51BXUw==
X-Received: by 2002:a25:d34e:: with SMTP id e75mr30563910ybf.385.1560377179390;
        Wed, 12 Jun 2019 15:06:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwjxwkAVnnqNCfy04/TvH3E9Hi/qpXqmlCDsCZImaHftahcW/T1q8NCOV29BA+BBXXnRo6l
X-Received: by 2002:a25:d34e:: with SMTP id e75mr30563870ybf.385.1560377178687;
        Wed, 12 Jun 2019 15:06:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560377178; cv=none;
        d=google.com; s=arc-20160816;
        b=IKHZtbzSOuFftpUk6FbEVLG7+nffmcgV9MWb9lmRmtuHHxtPafiPkh9qbk/vGpn0Qk
         5fIBBJW5HpNhbv3/4s/jx5JPt8H7SJlIIDIWLrQGw0489ZIi88YoFBlD/UnA/DG2uJIQ
         jxynXSY5MOeICD1DPY/fkxmgBgkFYdXcgeR4CI4SUS8IEZSjwRBRRB8qsUO9n3GM2kYv
         fllj5ntUdxinoXEaPe0B2xNwDv99hETczIH40qBaCRXdbfloF8LfjPWBYSaQiWMJ+70m
         SZuE08oFkvK5vi7mVmgxh1i46+5oSbmnAS+mstmhrJ8o9Gbt6u4skuPkP+undIjIez8E
         SFJQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=mJVdksI83pcAr/2dwtDaBJBK6Rf/MpbqiwJ18bpKuB4=;
        b=nmJaiWge7sETQ69oyK8SBwcx6v0qReEF2PJ+l+HWfEpeoGdJF2+n/4jPo4MLD1BLNy
         RG61k5djHhPfTNqMqo8d+f8Cmrt2JVPod8TgybKx5xwDQTkQou7WFl7ehmczoWRs1Rlm
         tdudWf3c05VldWY1TARuOfe/5NHPFXcrlr5tyMU/bT64TXH0CSJuSASFaGpJ0TySjgwp
         j31iIL7xdrXfV9bto0KyGhIGz+AopaVrfQdvVSD1VrcwiSDG3l5FT2YW2WkoB9pSML2A
         wG5UjkKM3HCaCZkFfHXckN20V5U8iS0yJm4HEMfMNp0kgss58940BGebG2WkAHPgou5q
         FPJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d5Nfvqxa;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id o11si304692ywm.41.2019.06.12.15.06.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 15:06:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d5Nfvqxa;
       spf=pass (google.com: domain of prvs=106696cf5d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106696cf5d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5CM38ri013351
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=mJVdksI83pcAr/2dwtDaBJBK6Rf/MpbqiwJ18bpKuB4=;
 b=d5NfvqxaVKUz9etwwx4Nb7+wyFk01khAYRPNJLsjj2+STh6cFzBwfLiq29ym6MB+KcFW
 Mb7+x8G8WPMbUgRhGd1tNxEEDPcZC6e6UZ8RmBnva888nfZe+vsx5zFRF2Ka93ILxqsL
 qm5as3D/b87YltgWMuCZEUdCA4BzLdNRgTU= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2t356213fd-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 15:06:18 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::5) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 15:06:16 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 8320F62E2085; Wed, 12 Jun 2019 15:03:23 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 0/5] THP aware uprobe
Date: Wed, 12 Jun 2019 15:03:14 -0700
Message-ID: <20190612220320.2223898-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-12_13:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906120153
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

This set (plus a few THP patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Changes since v2:
1. For FOLL_SPLIT_PMD, populated the page table in follow_pmd_mask().
2. Simplify logic in uprobe_write_opcode. (Oleg Nesterov)
3. Fix page refcount handling with FOLL_SPLIT_PMD.
4. Much more testing, together with THP on ext4 and btrfs (sending in
   separate set).
5. Rebased up on Linus's tree:
   commit 35110e38e6c5 ("Merge tag 'media/v5.2-2' of git://git.kernel.org/pub/scm/linux/kernel/git/mchehab/linux-media")

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
 include/linux/mm.h      |  8 ++++++
 kernel/events/uprobes.c | 54 ++++++++++++++++++++++++++--------
 mm/gup.c                | 38 ++++++++++++++++++++++--
 mm/huge_memory.c        | 64 +++++++++++++++++++++++++++++++++++++++++
 mm/ksm.c                | 18 ------------
 mm/util.c               | 13 +++++++++
 7 files changed, 169 insertions(+), 33 deletions(-)

--
2.17.1

