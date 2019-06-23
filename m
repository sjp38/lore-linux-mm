Return-Path: <SRS0=ENxG=UW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 993BAC48BE8
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4FD9E20657
	for <linux-mm@archiver.kernel.org>; Sun, 23 Jun 2019 05:48:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="d5JMGC4A"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4FD9E20657
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D6ED48E0001; Sun, 23 Jun 2019 01:48:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CF6FD6B0008; Sun, 23 Jun 2019 01:48:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B20A98E0001; Sun, 23 Jun 2019 01:48:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 765E26B0007
	for <linux-mm@kvack.org>; Sun, 23 Jun 2019 01:48:02 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id k136so173727pgc.10
        for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=HCh2NjGTGQBCVfp/d7EvCScVN12/b1b++WiE94r0r87Gb0M8U0W6KaINsOpRNoimWp
         LOwf1TzAukUR24vKAj30HS5rXI05rS8k3xC4EWmNN7FSSi7YQTbgVMtJEZhqr+Y/A2L2
         H607n6SR6WjEMuFMnGDrYf+4acw3ByqJ1W4LI+FD9WZCWh9cx78HYZonMvNLkum+xOZT
         TtGc3DI07lZOKk8lhITnvwGe0fQQNod6NmPyW3ErjZ7NIxCGbYEh+P7WhOf/qP4UW9ZA
         64ZwBgcZmz0K27n64e8X0pfayi7Uh2YoLwxN6Zh1AdMraATlP8IpEA9Cb62VbtCtY1ZO
         QXsQ==
X-Gm-Message-State: APjAAAW0o4kTF5omD0AAL+pdNovafpGYHOZbIliIpUlyDRLe37RQTQkL
	djQT8g5D7vBBBYRoUzM546bsVqYOXSbanxgdlluJYYQyJ35M7BI/i2HeoVI26aCrR7UXCcMM003
	bWYSM9tKYtXmRIqpNqRnVPn35E01CxzGFYrz3U6lspLZ6Ppp35oWTsuVITQiqGb40vw==
X-Received: by 2002:a63:f50d:: with SMTP id w13mr26555187pgh.411.1561268882048;
        Sat, 22 Jun 2019 22:48:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxp5U48YvypJg1wuwJ7IQGJanw4pJ1EKZGeds7ZvEDsA6E+YLDIpqqGd7tZJ9ORfF6CV0SK
X-Received: by 2002:a63:f50d:: with SMTP id w13mr26555158pgh.411.1561268881349;
        Sat, 22 Jun 2019 22:48:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561268881; cv=none;
        d=google.com; s=arc-20160816;
        b=w9yDnJjSGyF7svjOwHFxyC5ASbssEMFaKEf4mWcPjWPepHMjRvkHU/ba0YSSmh5FGL
         PnBMXcE4kOndz9Tl/wiNuHEhxLVtAYrCnINJkk+xQkFqg0pSBREBipYXLvNthO1DX7w3
         +lGu6osg+M4mlQXGii4ONpPrFuPjhji6sSeG+cLp+kDx2bNqDZ28bakzqCYUfpI8799+
         mCJMnmzFBjZrCNZmNBJiPEHIY6FUrjT7gl5YAcI1D0paYHfyP2Os7OkWMyrmzVROX9nd
         W1+bzac+8Fy+wCntKTbiem5Rd3escxjDm0jNo8iUno25S8isJCHOsNCU39Vi3pWJi+Ap
         anfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=wFrerTufHKhK+TH2hLKbAZeAusehkHhlPNb47SwkyKSwD25mI3fibPQP1w4/aKpugv
         W2d42q8N4uZsAk08wAJVongyCi+V+fiXUNyP+5hPUqv+aIdqa22AiBL9HcTZt4Bb4u3x
         vCl7oYw0sf1iPWTQdZ0v/suJpfB5O8LFwCLBZXOg98NCltZHl8S0VbUBGBjnDauALyPg
         30mYvXnyarHIN2cLNLfxj3Y7uMPlN3kVbLq9cuogJ5LBrudeRh7bKYkdi/KTZ77WlxQp
         chl7ewZFbjHCvQ8j0VFBJQz/VKpbuz3MoGZ+upaSaxHoFT/awzeZsyq+5gEaL3yVDoxb
         5OZQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d5JMGC4A;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p62si7434307pjp.66.2019.06.22.22.48.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 22 Jun 2019 22:48:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=d5JMGC4A;
       spf=pass (google.com: domain of prvs=1077171f80=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1077171f80=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5N5gtC1018659
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:00 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=d5JMGC4AXGRT9DlNcP+QLU5cCQgnYo+oGcoi38z++C7ol4h64qzmUCFUo4x/vkC5s7AU
 fjJV185z5j+ZtriexMGle7aMOi+taWO7hPog5i+KJZg6cDW+RBQEazgQVVFE6gsYgzDi
 MpIiNAqySQfdOca/2K37f3aA7Qac+xinXUU= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t9kmja0xr-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 22 Jun 2019 22:48:00 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Sat, 22 Jun 2019 22:47:59 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 472D662E2CFB; Sat, 22 Jun 2019 22:47:56 -0700 (PDT)
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
Subject: [PATCH v7 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Sat, 22 Jun 2019 22:47:44 -0700
Message-ID: <20190623054749.4016638-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190623054749.4016638-1-songliubraving@fb.com>
References: <20190623054749.4016638-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-23_04:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=925 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906230050
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, filemap_fault() avoids trace condition with truncate by
checking page->mapping == mapping. This does not work for compound
pages. This patch let it check compound_head(page)->mapping instead.

Acked-by: Rik van Riel <riel@surriel.com>
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

