Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	MENTIONS_GIT_HOSTING,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 381A8C28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:51:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF94B24240
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 21:51:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="CTSBx0AN"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF94B24240
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 792986B026A; Wed, 29 May 2019 17:51:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 71B986B026D; Wed, 29 May 2019 17:51:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5BB756B026E; Wed, 29 May 2019 17:51:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id 36A426B026A
	for <linux-mm@kvack.org>; Wed, 29 May 2019 17:51:52 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id l27so3454590ywa.22
        for <linux-mm@kvack.org>; Wed, 29 May 2019 14:51:52 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=FTOBGhmmJw/qDkNfpjhfgKpi2Er1kt0BTXTCiptxm0Q=;
        b=mok88WeHdvQyBxH2mhZYxSr1RZaXvFG+BURS0ZA0DlSRtAPEpA0UhaJ4EVpIaAr2QH
         KVcF8ySGN7CUqxqAPP4248a9Yc9Iuli0K1jNENVnWjnQhHroqyd5jgp5oQnrfMJs482g
         kt6ucRiSHgOu1CgAhsvSJehV5uMVfnDKNlZbS+jrDQb5ZXjnsQovlnHO3paTyJ9xxofY
         HG6XBWyZS6F64YY3/7nyFxgKWy+nNMY90TBo3o52ueQmYVRhZMv5/AZiJJrl4c9lEeZn
         TlCSPBi1vYRG5i5rFJ9A9B3N0gzC/M81f7XXpOmK+IWR4k3zgUm+4x8x1BO42emvX3pW
         olig==
X-Gm-Message-State: APjAAAWwLVxqpWPM2ezhCzYij0YXYbrsfrl2MEaWguTZL+9YfTgP2UMH
	/GuMn9Qjj2oIA7JC2jOk6Wgtis9ox+csgzCMrcaYArWUglN2vOMd0XhnigZOfnEedD0+x5vRTJd
	2n0JM59iXpHxRnV4dwdEmStUOpqsqpvEYBsS4wRUvIQtkFerdWup13zzuCA/7xNNmrw==
X-Received: by 2002:a81:3d8f:: with SMTP id k137mr134806ywa.406.1559166711910;
        Wed, 29 May 2019 14:51:51 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxTzVSZaQnICKWAghJihFIPNQt9tHwxZ1qsj0qKZH9ReAh3rINFnsNyPrlB7GEqiyiNyK53
X-Received: by 2002:a81:3d8f:: with SMTP id k137mr134784ywa.406.1559166711339;
        Wed, 29 May 2019 14:51:51 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559166711; cv=none;
        d=google.com; s=arc-20160816;
        b=feLjRgp1lk0tWgr1rf2TUJMKsGqgX7twXsrWMqZ7LpeeR4PJLR5YMxPIw9+Z47N1Uw
         yyIa3sOAq11uzusoXxzfSVtrwVomau1WT34Hyhy1Ayyw5zoRqfuTSCnLCzF4D5WgDzba
         lmlDnlqKwfUup4hKExoJIhOnms2Y0/DYIUxAUcEQQh/D+5OWnwH4r024IuQdO4jjakOF
         nz0PJjfHEPfvK5mU7G8mdRu/ycTeVEVkQPvUAg0F5kHwM8F4NWxB4yXmJZxOC2jI9PeU
         xIHLZc9xI4s820KtTu7QXKktjpMXWcTd5PAtLXbQeP78ocxUKerZ6jrP4fLOXgWfO3DK
         /bxQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=FTOBGhmmJw/qDkNfpjhfgKpi2Er1kt0BTXTCiptxm0Q=;
        b=vTFQl2uV/4L/+aCoEIqA9mL+CGemSZ9GFOxdszEtjdRKM1/7gXRl3BC/uinJTQsmL+
         DzQ/iG+0wyiqeQpeiOaNTtC1S8WGF8A+s19snbaBez/bxdGduJxEuJ6lH04J2g8z7/5r
         urRYzcDbvoL7CU6XVMSWPLF79XqHqqsGjlOpGO6j0yMvc+zyHA83avx7z/fDHnleoaF3
         PR8DwxSjiIbBQiInr/sdwgDx23PeiWGgNvdJxjlyAM8kgAAlhSjrwMzYU5Znw/vX/GsS
         mZZRpRxvUdMJEr+fw6/u8cuLsmHhOg2Euk3Qi28+w0zUaMF1z/tyqut213E3jg5YCRRT
         TQLQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CTSBx0AN;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u133si169476ybb.218.2019.05.29.14.51.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 14:51:51 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=CTSBx0AN;
       spf=pass (google.com: domain of prvs=105246f206=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=105246f206=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4TLi7JD003165
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:51:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=FTOBGhmmJw/qDkNfpjhfgKpi2Er1kt0BTXTCiptxm0Q=;
 b=CTSBx0AN0CMs/2LzC4LCIEpX5ox5sYxXarKUXkAlCsUuMmVJx6cUamEFSQ86D+MaOu+T
 DiWAuoC+tl1jTGfsbZPjLseyUmWrky7JXEebptaz2Vk9FTSIfrsptej2xy7Q0kJ69VW/
 oZbLPHyXlnGwJEAEfGe9lrazSz2NlLJs6iE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssvdusetm-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 May 2019 14:51:50 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 29 May 2019 14:51:49 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 29C9062E1CA1; Wed, 29 May 2019 14:21:06 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-kernel@vger.kernel.org>, <linux-mm@kvack.org>
CC: <namit@vmware.com>, <peterz@infradead.org>, <oleg@redhat.com>,
        <rostedt@goodmis.org>, <mhiramat@kernel.org>,
        <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH uprobe, thp 0/4] THP aware uprobe
Date: Wed, 29 May 2019 14:20:45 -0700
Message-ID: <20190529212049.2413886-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=731 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290136
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set makes uprobe aware of THPs.

Currently, when uprobe is attached to text on THP, the page is split by
FOLL_SPLIT. As a result, uprobe eliminates the performance benefit of THP.

This set makes uprobe THP-aware. Instead of FOLL_SPLIT, we only split PMD
for uprobe. After all uprobes within the THP are removed, the PTEs are
regrouped into huge PMD.

Note that, with uprobes attached, the process runs with PTEs for the huge
page. The performance benefit of THP is recovered _after_ all uprobes on
the huge page are detached.

This set (plus a few small debug patches) is also available at

   https://github.com/liu-song-6/linux/tree/uprobe-thp

Song Liu (4):
  mm, thp: allow preallocate pgtable for split_huge_pmd_address()
  uprobe: use original page when all uprobes are removed
  uprobe: support huge page by only splitting the pmd
  uprobe: collapse THP pmd after removing all uprobes

 include/linux/huge_mm.h |  22 ++++++++-
 kernel/events/uprobes.c |  82 +++++++++++++++++++++++++------
 mm/huge_memory.c        | 104 ++++++++++++++++++++++++++++++++++++----
 mm/rmap.c               |   2 +-
 4 files changed, 183 insertions(+), 27 deletions(-)

--
2.17.1

