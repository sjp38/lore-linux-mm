Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E237AC4646B
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9CCC520674
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 22:30:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="UMhjMbAp"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9CCC520674
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 362956B0007; Mon, 24 Jun 2019 18:30:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 273538E0003; Mon, 24 Jun 2019 18:30:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C8BC8E0002; Mon, 24 Jun 2019 18:30:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id D496A6B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 18:30:03 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id v83so17698346ybv.17
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=kFezXImE62IAA1aivsjfuJdxRV49RqFoU1DT0iqVnNozYY0AGLZvzvSOzpdp4FORH0
         s8O/0GDKnCYqgx/ZRPS+w0IkrLG7huPlytdj/fpNIX1kY/YGVnHTiNPwVYC840wxdk/B
         IzrmP9HV4tR9lmSRdaR3bSeQTD8FV5GF4KHFh3LAGG8nd2wZLv+h/Q/iECaKwKD0esip
         OjvLT2hRI9pTSfy8lHSiDAVqVsSY+It1lne57gyoo4JpEulTREIvZ6/LVRd2isNorkI+
         kLEHhHUYFma3mByPcAFgr9rrzozPl8avyPrP6JS9Vnlg5tFFpGoIBFspkKqj1SI9c46m
         Pksg==
X-Gm-Message-State: APjAAAWiZpam0ImZRmZ3r1X+g2jOX8816DxVALwtmbURGqZjJzCF+SRN
	+X5OQKlJreAjZVg9QQpcr2bFY3vuT7FrMaVnU1QxHDOt4wK/AXcATugrB32CLsg+3HdTALohPp7
	Q56Eb6+d9tCPdgi+IfGzZPZIvFemK7jk6kNemnPtC+SvzJvMJnCs++CK4fFHRii9g4A==
X-Received: by 2002:a25:d47:: with SMTP id 68mr14080832ybn.75.1561415403599;
        Mon, 24 Jun 2019 15:30:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwY1cpaI8DD/9pcoBCNhQGJVj9ZMMco0B17qRWx1zefRVk6rD4fQfrS6aPAffsiM8vY9/27
X-Received: by 2002:a25:d47:: with SMTP id 68mr14080813ybn.75.1561415403098;
        Mon, 24 Jun 2019 15:30:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561415403; cv=none;
        d=google.com; s=arc-20160816;
        b=Q5TEdVaWSgKZAm1gVU0MJ/U3GVGAfOnb5+bBqKns6r1D/sFcHCUxL8H8bvPwIfQNph
         8tp6uinSNlbgQwof3zZUrOuKtb0dx8BC+TNz87JwfBqQHu4tFSXEQkyg5RbNtKd4vS7R
         CIlN6nSbH/X7fBaEV5WHEhX7Jc1QrzFxuMR37yWNB+30+qf+8nbvgPKnQsy/8X1acIgE
         5gHZQB2XgHdqjxHfJgrMVRa1VCv5je/DBYDQEggpum5fMR9eaAuZYcSKFkJTrqiafsPH
         I+NM7RmDQheQiN3JJdNeSAv9uLgtPZl2dkydyEFkcaeYZKMPXoTv0oKb6bM3OZZ3ysoP
         Z8eQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=OeC2OHH+2vFqM2Dw+4SZoUZPjoW8Rhy8/3vmvOViDJPV+LB+3LCLZbBwdepTPYsMVy
         fFvBBPMJcyPNfnBsZkFqhw5Iddkg+Jvsqb2wPPBToGQFbiiTy4FcNZZRrXuFtIx6wabb
         B7ppd7eMxJF49j1KLojJvg6SeaBiEbLoW4kB5zLQmP2xZHdkktXazTHfnwztKEkDX2Vw
         uvZijfbEsnnekxh20mElJR3njBQxvVJ7aynOT+wzkTJCtjF1LWuUf5odR/RfpJlGFjge
         JZt6aWzylvtd1TAONHgF1VE4MGPXTm288oivckcoKT6Ly5GAPlsEAlE8wGLS9bQkDByK
         J9cw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UMhjMbAp;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 82si4104819ybs.371.2019.06.24.15.30.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 15:30:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=UMhjMbAp;
       spf=pass (google.com: domain of prvs=1078cbd532=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1078cbd532=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5OMIYN6021032
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
 b=UMhjMbApjLP862682QVi0t9i6FsW/AFuvXqUNekJR8oZ7bQomxw8jtbXKo8GTlXYQNCZ
 QiyGfJtQ+xyIcxdVKn0/+n0VsGO95URd2QkSCVmLhn++McKMeCjccY6/XsSMZ7tYK3t3
 x3WKz7PGioAgn60vF8exXfTK6VIxBRFSyd8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2taxvpj5yd-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 15:30:02 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 24 Jun 2019 15:30:00 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 897BB62E206E; Mon, 24 Jun 2019 15:30:00 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, <hdanton@sina.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v8 2/6] filemap: update offset check in filemap_fault()
Date: Mon, 24 Jun 2019 15:29:47 -0700
Message-ID: <20190624222951.37076-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190624222951.37076-1-songliubraving@fb.com>
References: <20190624222951.37076-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=797 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906240176
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

With THP, current check of offset:

    VM_BUG_ON_PAGE(page->index != offset, page);

is no longer accurate. Update it to:

    VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);

Acked-by: Rik van Riel <riel@surriel.com>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index f5b79a43946d..5f072a113535 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2522,7 +2522,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		put_page(page);
 		goto retry_find;
 	}
-	VM_BUG_ON_PAGE(page->index != offset, page);
+	VM_BUG_ON_PAGE(page_to_pgoff(page) != offset, page);
 
 	/*
 	 * We have a locked page in the page cache, now we need to check
-- 
2.17.1

