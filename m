Return-Path: <SRS0=BXMS=UN=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 532DBC31E4B
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 113F32177E
	for <linux-mm@archiver.kernel.org>; Fri, 14 Jun 2019 18:22:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="RrSrlZ1M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 113F32177E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A1E866B000E; Fri, 14 Jun 2019 14:22:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9D0C96B0266; Fri, 14 Jun 2019 14:22:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7D66D6B0269; Fri, 14 Jun 2019 14:22:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id 590A36B000E
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 14:22:19 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id z4so3606330ybo.4
        for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=d/SnzBiETAoMzu5ZiUQdyMJB3iluqJaW8Ccsc1YOxOE=;
        b=EoFiv4Sm+6cZoDP7HtxBKvQDo2sluPbvMsPpqbKE0ymrrRs5Q8MGImMkkfo6SY88Hq
         B6fNzjHBJdvubmVaxGJYDoJx+Ns3YP2cSNDSF59oHb85S4zVkotpGID4ECscIGRjX0oO
         X1/EPy6UElyTZ+x22yb1f3rzCbzU1h4lTaRPNY17lUblsxLxov58mhPftXgV0nebLC7a
         RtbrthZS4lXKAxloddY4lAvYMNiLFJo0yTSJDXgtV0xNpleM0kc2JiN6j64ahb6blk2c
         yI2YDKdinHMx2Sc9X+UZR2xyCgaVV6cX8zHlyywZ50OBwzOd9wk0eK4IAVy8nQKJOBBd
         7mWg==
X-Gm-Message-State: APjAAAXOs5B9tKCmsG6dUHS/+bw6RVupMbN5Hy6VvRw/3CFFCBPJwD1Y
	I6mrzxEunPzso9ZCMUPQune5MkZH0HRa4ScWCwHUrWt8DgHLvkLGwv1V7p92LNeOJySqiZIlr7n
	NB1kXanU8Yr10Xq6QGxupwxB99+z8yX46HAqcQ8cI7TBI/iPc3A+GRfP7ckG1JhvQrg==
X-Received: by 2002:a25:4253:: with SMTP id p80mr50898774yba.173.1560536539101;
        Fri, 14 Jun 2019 11:22:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxHHywGWXvlc2SER6Yo3O/jvc4w1VQBo8Lpb+gfeFpX/sQF5mq3z2cohnkz2aXo3fUxykq5
X-Received: by 2002:a25:4253:: with SMTP id p80mr50898750yba.173.1560536538630;
        Fri, 14 Jun 2019 11:22:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560536538; cv=none;
        d=google.com; s=arc-20160816;
        b=MPOoxMJ6ea8xPWP39oKI36XKyYBIXA7QWULs/U6Tl9IboMIohWd1/r+5at9CAiJCL4
         ihyj/YLc5653AfHGpKwmtOM292KXH/AK6FxNupdfTt22j1W9/6X4KG1vN3bNb16f2fJI
         FOOLhvswJahJHQcdEv6LP9EqObvp+uVOUmu+u4kJnQARmpZbD3gAPsS/cx0s4SCDBT9b
         JKsYZEaHBC7WjQwSAD26ig4shaljOfkB6FLmTRjoaIon5uccsdF8uMEM0HlWtUQ1iKXJ
         0J2L0braFE6WsRcnY8fMcEdB+jPXJpmhR0YRKVsEfo6x4u4FkG11GsCYiljRXgDm3ADo
         bfsg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=d/SnzBiETAoMzu5ZiUQdyMJB3iluqJaW8Ccsc1YOxOE=;
        b=OKo7BYEHITgS5oEm684A+gZY2lJnmLCX3WYlvEBoTkBW9/bIR2js3SwwkREoTFxThB
         C0FbO/UWujYj0ttIf1kPAig4Y2N3GmD4VTdHfbfQO6I9DY0yUXnW4XyIaoBjycUBu8sJ
         AOzGelW/gfEMuR47WEH9pwqKw80nsYvj650hgUHbRtjPGK0c8hUg0hz9kzKgzyksVlz2
         KOnVaOWVyO+cL6/8o3Q4vfCa6W0dJYHUu5Zx8ZE9jb4GRbfsrvi8XjhFwONRIzzV4SNU
         rTaPvDAEM0jfp30O3qlOYL9bE2eD04WCaRwZiskokQgolWyJD9HfEtOn8oCFlzvq+B5A
         lvvA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RrSrlZ1M;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id u62si1177874yba.2.2019.06.14.11.22.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Jun 2019 11:22:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=RrSrlZ1M;
       spf=pass (google.com: domain of prvs=10681bb08d=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10681bb08d=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5EIJUoJ027483
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=d/SnzBiETAoMzu5ZiUQdyMJB3iluqJaW8Ccsc1YOxOE=;
 b=RrSrlZ1MhjgdfjOrMl0jR/4YA06O+m1vlXy07sbG98V5b6PJLoZpyBLzwdnsyPRzn8aq
 H12EzN2Ga/KUo/AQph9HBl3oWBoLoLUvMcaWLjb8rmrUJkDPyWVhBZ9xulVxDBURWn6v
 R0Jiir3gVMMjKofeumYuOFoL3Ik2fVKWdP8= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2t4915spmm-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 14 Jun 2019 11:22:18 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::4) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 14 Jun 2019 11:22:10 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 6BD4962E1CF4; Fri, 14 Jun 2019 11:22:09 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <chad.mynhier@oracle.com>, <mike.kravetz@oracle.com>,
        Song Liu
	<songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v2 1/3] mm: check compound_head(page)->mapping in filemap_fault()
Date: Fri, 14 Jun 2019 11:22:02 -0700
Message-ID: <20190614182204.2673660-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190614182204.2673660-1-songliubraving@fb.com>
References: <20190614182204.2673660-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-14_07:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=847 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906140145
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, filemap_fault() avoids trace condition with truncate by
checking page->mapping == mapping. This does not work for compound
pages. This patch let it check compound_head(page)->mapping instead.

Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index df2006ba0cfa..f5b79a43946d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2517,7 +2517,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		goto out_retry;
 
 	/* Did it get truncated? */
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(compound_head(page)->mapping != mapping)) {
 		unlock_page(page);
 		put_page(page);
 		goto retry_find;
-- 
2.17.1

