Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5CD0CC43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0D62220821
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:01:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RhJzdLbw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0D62220821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B064D8E0002; Fri, 21 Jun 2019 20:01:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB7C68E0001; Fri, 21 Jun 2019 20:01:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9A4B28E0002; Fri, 21 Jun 2019 20:01:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 758588E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:01:18 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id l1so5454599ybj.18
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=bBRE1O8+pjz3c8Ua3BJkmiLOIIW1HMGbjn13HDJ4cYs=;
        b=hm3Wmtu4Hk4B20jsJxqjfBvz0WWOYjKOnyh9RlkRdgu50t09fZAjilaSkPLyGeNZMN
         pq3zu+3WJj6lRq8087c86JQeun7ZoLGRW1bC1JcZG9iuYzOHUKjK+Djaglq9YmuYiWM+
         j/STHQO0Lvqfcc91u07MvlGUYCTu/Tv1TTceeqc2vTokvN9/3cllcazJ8ZjksS3gpMUP
         on6S5u5OLO1M7oNIuGszNGSl04nAYw+WPujl/HqJ92B/hdpTMlCqRG/FrNBgOt4rR9TN
         yOa0MbqftnTwcrsNmEG2IhJLME23wAsic40RS04iDsufl/wFnvMcBki3nG9H7PdBF/cR
         3M9Q==
X-Gm-Message-State: APjAAAVxEIyUoRgsQKOAjXQEkOf0pe2nCgNYo1y+0VVc2Q9KxeuHUD2l
	NVIHXat4x24cebR640p9CYALjR5Q9DjnMVfMRTxrVz1CFPhmYrs+WP4wmq2wEB1lYXBhL04AU+9
	Qi4mZwSoDC2ASTGPauWDPH56k0MUJ7+6OFWIAAnQUth0HQzOzivJfJbsP+udHUeINFg==
X-Received: by 2002:a0d:ddca:: with SMTP id g193mr11842607ywe.476.1561161678246;
        Fri, 21 Jun 2019 17:01:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx7/g1dAwVD7CyE8/YLi99ja1wVGlGsWvCLVdSMWtVG3CLmPCADYMenm6I85eyLwgO4pAbr
X-Received: by 2002:a0d:ddca:: with SMTP id g193mr11842560ywe.476.1561161677512;
        Fri, 21 Jun 2019 17:01:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161677; cv=none;
        d=google.com; s=arc-20160816;
        b=KKCKoB3SxYei5xt72Yo2m0VLA9Ht023gOAxDuGAOzF+2aPetResEXndajYlhcU2rlU
         Ai6VN74HqBMRtCtH4iRs5n259lh6cexDBVydZbLXZs9uS8ipEQ5uMM/qXfuo9SuNhnF+
         PSDjmebUpJuTgc4bVAfXFbKz8jGQsu433DC4sx3wqW3wMoPRpe2WUsS3LKFh3VHWE3dO
         N+EKmdq3ly6KnBhvageLrXngUF4OJFc+JBKk3aKOZDUpBsDWxUPzH/5Zh5aV3Oach9bS
         t9HXMOB6O1giDOb+WRYRU/SdgKhsbfOXbg4GaZ5UQpCNd/w3OM0XGj9NV8d/m2eYAWKQ
         0lyg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=bBRE1O8+pjz3c8Ua3BJkmiLOIIW1HMGbjn13HDJ4cYs=;
        b=cn4baxKcloJ0R+oUP0CWdOTJCtJUPkCP8aH9kNTxdxn2cniuUnyHiNKWNyfyI1VRAz
         mwjhleQ9bbuONItGqjPN5nuuiVFaCHBg1I86QS1Qoihz4N1YJ3t/h7Bkk6o8fzpntWLZ
         obtUDMu8j9bNSZdLTJCfhhgmLpoFsVM24VhbXBVCcQb6D3iBk2T6N+kzLMIsv+jQW4WZ
         +q1UGUwkmpQWZ2CtuiuiWOwGOSmB5pqNkp3sGRl6aOH+iEdqMk2sWEDFGGWg4Jo52On5
         3MbxkNl3N2FXLDt9agqvWLPnxO38qzLyCg/bKj+F6ZgXvZMQ9OUpA6M1opAM1nCkKmuy
         gGmw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RhJzdLbw;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s83si1723368ywb.130.2019.06.21.17.01.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:01:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RhJzdLbw;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNqmRA020809
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:17 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=bBRE1O8+pjz3c8Ua3BJkmiLOIIW1HMGbjn13HDJ4cYs=;
 b=RhJzdLbwaxGsy2NmLUQezl1a3vhBHT8k+xp0aNcrs61uq9CRNSWtotehWDzKrdNaJqWO
 JrN3qf5pNnb+NW69plClLsKP4rhB21hYZlA0h91+yJQdpZhHs/TPeUfeqHyNHSMquy0F
 XH5tEF4Njv42kOAEOJVZldinRlTIONJe6Sw= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t8uemtyvn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:01:17 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 21 Jun 2019 17:01:16 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1A23B62E2D56; Fri, 21 Jun 2019 17:01:15 -0700 (PDT)
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
Subject: [PATCH v5 0/5] THP aware uprobe
Date: Fri, 21 Jun 2019 17:01:04 -0700
Message-ID: <20190622000109.914695-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

Changes v4 => v5:
1. Propagate pte_alloc() error out of follow_pmd_mask().

Changes since v3:
1. Simplify FOLL_SPLIT_PMD case in follow_pmd_mask(), (Kirill A. Shutemov)
2. Fix try_collapse_huge_pmd() to match change in follow_pmd_mask().

Changes since v2:
1. For FOLL_SPLIT_PMD, populated the page table in follow_pmd_mask().
2. Simplify logic in uprobe_write_opcode. (Oleg Nesterov)
3. Fix page refcount handling with FOLL_SPLIT_PMD.
4. Much more testing, together with THP on ext4 and btrfs (sending in
   separate set).
5. Rebased.

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
 kernel/events/uprobes.c | 54 +++++++++++++++++++++++++-------
 mm/gup.c                |  8 +++--
 mm/huge_memory.c        | 69 +++++++++++++++++++++++++++++++++++++++++
 mm/ksm.c                | 18 -----------
 mm/util.c               | 13 ++++++++
 7 files changed, 145 insertions(+), 32 deletions(-)

--
2.17.1

