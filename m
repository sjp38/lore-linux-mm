Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ADF00C19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5954E2084C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="h+0IcRmz"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5954E2084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 020AA6B0006; Thu,  1 Aug 2019 14:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F14216B0007; Thu,  1 Aug 2019 14:43:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E01AF6B0008; Thu,  1 Aug 2019 14:43:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id C14E96B0006
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:43:03 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id e12so53216623ywe.6
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=U9VgRs98GbU87xGfDbgwnxYoI5hIm/KB7jgPU3pbj0k=;
        b=dHkpAsaK4PRByflNztpatigRtLYKPx5+yhkDlZLKQMZwybffCNAdSXaTZQq5ERZB/Y
         8sc+oPCSMPYORCj+HnzRz5RJskQO/W3phn31yFCUIg2XYlY9a8Bv2ggctmbP5VPrHlpG
         9Oi2wDmiudlMNgO2O5/vt9VeDGQqLoeOlVxXLR+iuTwT74Pxats+ClGnEHXPh2FuqzXr
         duJn1jCH3nzMZa6zThNsRI8IYXBIn6ogUdn7lvyBkvAenAt4qA0Mtv0yio2ZIMghtV30
         01xbIjSMByAXyAYFFzgWT23YdKbCYwnYdwSx1A1Thm0swNNeBE5xYzZTWzdJaefwnZTX
         8inw==
X-Gm-Message-State: APjAAAUTm3XNTdIYx1VLSAqXkmdUttz5+0hG9WRucxYYUORHmrD+MLR9
	C89jirDCeF1pissw/Xu7ZG6UDK4lKCGdYhvT+Z2KF7BQualSwKK3pnoJ/TTCshPrC1Zt6YqmUPu
	y4KuCTWmghNWiaqm3e+71N2uOEV9iURAtmQSuZ4AW9j0ny4QEbBASAH/lK0uYD9Cx3A==
X-Received: by 2002:a25:8392:: with SMTP id t18mr65366418ybk.161.1564684983547;
        Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyxONNHGyYEZnJYNIf3xbrU45rQMmpdW9K3M53MkDaNE+i4Bn/uDKrC/Lb6gOmT0uSECpQV
X-Received: by 2002:a25:8392:: with SMTP id t18mr65366392ybk.161.1564684983046;
        Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684983; cv=none;
        d=google.com; s=arc-20160816;
        b=J4Gdo8JLIgO9cI3BmC+MJR9ZKm9Xp9U1LIFa6kZwkOBNfSPJBD80/ImroF5hokXjHQ
         L9g7vwD4PIz8q/GlzA2SWJmXWsasWnvU5emOX7d5r2JzZBFWDEVfBXDurRTt3ItYYngY
         NjJMJfu8VgKl90yWKNEV77wb5sLTrH9rdGgvOoWISgj/0pKK/zmTOESR45mQjankGHn8
         1T5w3ChgAAScVeTQDxShyne8dIFaDRQeuVbJlRYBn23Awq1xbRgyjYNQG7C6PUmuEKoF
         NhVc6ayOeXCi8mBl1rf6ADqsJ6/39DuMIGijJ5PL87Ntm2bST8VFXGW4VaBToL12z/vQ
         6F2g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=U9VgRs98GbU87xGfDbgwnxYoI5hIm/KB7jgPU3pbj0k=;
        b=CcQkofqFmId8brUikkMwSa4ZF6ndmrG4fGGg87RuvtXkgDbd1UqlezcKbKi1qrhQKZ
         krQ5wknpjqnC22kbK1VwwEblHUSEI4AtoGJxvb6UBEwmvVGuev+WgKeQ6hS5IT47p/46
         qHCwVKePIoQN8SLP9Abjs7ygVdR+TsSkYwMe/MNN0RMqcn+AhtVbtLh7hUgegs5FtlHr
         yKb2qFvatyqYG5QlJUi2abhY1sRFnZ7DkYLQuf6ZdPhJ5KQmCzz6Hzn2lSFdCT1nBz9D
         VrR0dcy0omDShnQKxQwk+kT1dCjZbVZMJrTcC6lQd/gkowZzWTdoxjna3Oln+XAnt5po
         hQZw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=h+0IcRmz;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p188si26681923ywg.204.2019.08.01.11.43.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=h+0IcRmz;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x71IfrtN019367
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:43:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=U9VgRs98GbU87xGfDbgwnxYoI5hIm/KB7jgPU3pbj0k=;
 b=h+0IcRmzWSwWGwzzn7mE9a8id0EgPb+kaehHVQVuXTNWvHk7/bt94DL0hmDrKCw9wNzS
 r6KkPql6FPRNoVfypIR1Xb3b5z6qtpg3uKka+aiKZNoabIlKI0BOEVIWtZ29tBYmu6z5
 F88sGWzHcdUkPwHSA2r0ms/6KdFB1uCCbpM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2u449ggauj-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:02 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 1 Aug 2019 11:42:59 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id B26D962E1E18; Thu,  1 Aug 2019 11:42:56 -0700 (PDT)
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
Subject: [PATCH v10 1/7] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Thu, 1 Aug 2019 11:42:38 -0700
Message-ID: <20190801184244.3169074-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190801184244.3169074-1-songliubraving@fb.com>
References: <20190801184244.3169074-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=884 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Currently, filemap_fault() avoids race condition with truncate by
checking page->mapping == mapping. This does not work for compound
pages. This patch let it check compound_head(page)->mapping instead.

Acked-by: Rik van Riel <riel@surriel.com>
Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 7161fb937e78..d0bd9e585c2f 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -2537,7 +2537,7 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
 		goto out_retry;
 
 	/* Did it get truncated? */
-	if (unlikely(page->mapping != mapping)) {
+	if (unlikely(compound_head(page)->mapping != mapping)) {
 		unlock_page(page);
 		put_page(page);
 		goto retry_find;
-- 
2.17.1

