Return-Path: <SRS0=FoEm=V2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1DC6EC76186
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:43:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D58A42073F
	for <linux-mm@archiver.kernel.org>; Mon, 29 Jul 2019 05:43:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="A8b/82fs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D58A42073F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 721528E0005; Mon, 29 Jul 2019 01:43:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6D12E8E0002; Mon, 29 Jul 2019 01:43:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5C13A8E0005; Mon, 29 Jul 2019 01:43:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3C20A8E0002
	for <linux-mm@kvack.org>; Mon, 29 Jul 2019 01:43:43 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id w6so46157797ybo.2
        for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:43:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=XvNEAXSYk797t3wYKn6N5VrcNz0WTBZX3qvsbOv7a4c=;
        b=cZlH1LoKH5Ll6ppB/am2yc7YMEZFifKjib13IrfApHLJJTTaxmug3ius4IId2/mCIl
         OKWi4VO+eqbIk4VCbFvUFzGmhEgdSyWcxa3GsMorvn1/a6iV2RYPk9Eq2jQMGhiH1L/4
         Sto4JBRrSb5ny5YWv20blrbEcNA2S/CwF2oyN0OuuxHuGMyvy5SKgCjiTujVpLjJx0sG
         l1uwrQXEVLYEIwiDC9Pr9pVKhzvO0FtqP0ewJxVkGmq7XpsdBox/itQhE8HYuGD428Xz
         t68MWJ9mqWwR8vjEEz8pOEOMLHL0gHQjclKB94Csis9c1xYTh+xdntn6yfb3A9ds5jvf
         +oOg==
X-Gm-Message-State: APjAAAVhM09qtgAQMAOD9GMWLZtqNOoq1MnJzsbDSDQKZcGmcflqSBf5
	yeoCKj7BaeoMjXeNZcd0ZCwDS7iiGY8bLC6b8u7xv4c0m93CBYaqV2wFmr4tv9f834SiX4qm5xD
	deAaYoOKiXf5IbLZzInUbgT9CQKtLX8piFv4MVxxJ1BsUi75EOLgC6meCL7dM6f496Q==
X-Received: by 2002:a81:710a:: with SMTP id m10mr39492836ywc.277.1564379022895;
        Sun, 28 Jul 2019 22:43:42 -0700 (PDT)
X-Google-Smtp-Source: APXvYqypmOTfXI5OTTN/WVs0LO2R7x7sfWkSFhodd4GM7ZWylzrpierRaohwvCsCP0QMlGjv1JVr
X-Received: by 2002:a81:710a:: with SMTP id m10mr39492827ywc.277.1564379022378;
        Sun, 28 Jul 2019 22:43:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564379022; cv=none;
        d=google.com; s=arc-20160816;
        b=AIjYopa7ZJLz0RJc57jSG95gO5DlhdQKV9M8gXX76CRB2+ucV19hQowuEsetzr6t2U
         bP+J3DF/axZoBc4HEAbfPEHB5iPbuRN0I3qTLk4PyTO0FcQHDy9KrmBhz3TuQ3Oz0Bos
         DckGSqy3xfKgOIR5zvJVIhHFfJpc4tI691awtQGICDTRFFPq5tpqR4xwcOmqvKPwhICL
         ja7awgmV61yXDUa9abVAojfGrHJ5MTdSQHxQBHuBPBQeMwKT/4e6iZlHld8Z/5lrUrw/
         3yJWVuSQgvt53/utDUcA9hlxoAzfZW6Jcq6UdSPtHGaw1++0Qo9ApH5+iPq0CCaQx4R1
         IsJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=XvNEAXSYk797t3wYKn6N5VrcNz0WTBZX3qvsbOv7a4c=;
        b=NCVojqxhItSHBpCZTbns1+LqX+ZKbw6UzLqZToJtOYO0zEm0NUFjcXKyS1jOwO1cSM
         /wYtte5fLQPk9WAWHI0SWFIKfeSQdc9+uwJ+ZxPa4zRbhYwTf4cfg6uq54I25FLeQKxO
         P+h/xm2svovE/VXh4jcA8dH83J+oZYdx2JEn1win1I8/pP+Szm9dyS5+Ddl2ncfrSq9a
         zdvzwmEyuUIVnFhmQNyIDCYcEzKfJc1ghgP6iEtPNFvUoKDOFs1fEe72EEJrejOCma/E
         uQNkX9720rRGs05dReQ0JGihecF7TZN7FRnq3J+vYXjUAbWeycKQeh1l64W1tzFTChqD
         y43g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="A8b/82fs";
       spf=pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3113871558=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id a18si2565712ybn.357.2019.07.28.22.43.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 28 Jul 2019 22:43:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="A8b/82fs";
       spf=pass (google.com: domain of prvs=3113871558=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3113871558=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x6T5g17Z023383
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:43:42 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=XvNEAXSYk797t3wYKn6N5VrcNz0WTBZX3qvsbOv7a4c=;
 b=A8b/82fs2baZD13oePcPAjzSlGKD56bvl+KGs1VwPWHL7UtnsAQ61RS5p268oY93FiUW
 EOzHr/W7yCC1z6nF3GH/3T7ehRQg6KYxPhR2wATX456Xxb9Y+hLFUm1VjondE85DW8HV
 usu3OQJH8my43Ci+btBCAcAkT6bkMn3Uvns= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2u1tf1022x-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 28 Jul 2019 22:43:42 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Sun, 28 Jul 2019 22:43:40 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id CA78A62E2BC0; Sun, 28 Jul 2019 22:43:38 -0700 (PDT)
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
Subject: [PATCH 0/2] khugepaged: collapse pmd for pte-mapped THP
Date: Sun, 28 Jul 2019 22:43:33 -0700
Message-ID: <20190729054335.3241150-1-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-29_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=546 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907290068
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This set is the newer version of 5/6 and 6/6 of [1]. v9 of 1-4 of
the work [2] was recently picked by Andrew.

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

 include/linux/khugepaged.h |  15 ++++
 kernel/events/uprobes.c    |   9 +++
 mm/khugepaged.c            | 136 +++++++++++++++++++++++++++++++++++++
 3 files changed, 160 insertions(+)

--
2.17.1

