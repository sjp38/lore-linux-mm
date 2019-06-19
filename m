Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 669DBC31E5D
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2DC1D20B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ID5ajaKM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2DC1D20B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B43748E0008; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AF3278E0003; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 944A08E0009; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6DF798E0008
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:34 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id a13so16501616ybm.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=dhUKP3pweBve5jEl9pyVN6bP2b9W9cQjo4xYKr65fIFogGygEOWlaBcbhnMepnF12V
         VBnjLHTfji1soHHRbyJ6pdJUuyISLy1kOTrvkF3ITJRJuTYB33V4N8ZBgrM7rmvux2CH
         tlz3TPcCqp1U0OyRmbzrqMI8Z/TTZt0UXG/dgvOTnXSJeAv9/bkWvMFiY2b+Ep/cBgF9
         IO4uSWmTPDueb1meKaxcv16c+3Kb07Qfl6Z9NJ9+qtNURQEAxSM76NPbUq9Sv49brQXP
         9n1W+ZlZmW6xbkMHyDLiUhxiAENEh/EWdVrhXcd2o9ihqsAUSdb9oj/2g6kQac0NlKGt
         2pCA==
X-Gm-Message-State: APjAAAX2d5eZDDurnjuzn10x6n/wbw+9JEg8lEytEHD4Ad0g1pdWur9i
	umOqkXbRMGDqa2VYBeR3Jc26brJRQIJSwQ7JJyfesGFj4gqed8/VNK39z0P1jDWYZJW58ZVom9C
	zNq430HC+66H+VWhPzNxsVE25G6bvfqqCEKd2eYnKdlmqKYbkzekKMES0WbVAR+kAJg==
X-Received: by 2002:a81:638a:: with SMTP id x132mr4377255ywb.463.1560925474192;
        Tue, 18 Jun 2019 23:24:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw4/YvRhjli/vnvYCU1IyfgBWY+SC1R5jZs2hlNdjlG1LKt76E45DRrGs1kN09rE68lsJA+
X-Received: by 2002:a81:638a:: with SMTP id x132mr4377239ywb.463.1560925473710;
        Tue, 18 Jun 2019 23:24:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925473; cv=none;
        d=google.com; s=arc-20160816;
        b=oJu4bRPSnbGpxSuDqw5Oi7rOLzui2Eicy1zQ33D1vlA3K5710hY+mvyzpAe5yUGTuO
         g5qFKY5DpUdsJPWNhd6Dd089xJrGfwBYKElricDK9KQPjdehvNLmeKiNC37ETx9hJQ72
         kMx0rQuF47h1EYjhrbqVvMMpcmNpOrFC+Ir+vIzueDol+lTkoDnLkZ+GpO2waj73fQYl
         CWoXU+VeqjRTt1WwoiMWLKGKRFgp/BKcpSuTBntKUHI3TRksyQEsAeuAMea0L+PJeD+V
         BbWIhbRZawD/LHDqgAF4/pySxLGKssIWWLa8Vn/BEgS3MEX+fuQd0SlGYlLQiGnB4oA5
         WSng==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=Lrk3755YBYNKXFB1KxytYcaMli764/PdHX+tnsiqSFbdJFzPoMIcpa7APvmJm6UfV7
         N4gLtuP35BbpWxEGm7PpsyLM7GyJNBIfQH7q+pesCca0DYKDiAUZ0ozu2VytrScYDkVh
         SlJdXdY/bfuu/UQuA2kNTZnOU+JPF/dWMBXjAbXm8aVlMrgap/GQkfiYLLzjnayDUJgR
         ZwsYBebPQSq6Q1lcxjQsT2tOhBVVWSE7bn4zCy3+1CLO2Xt9CpZ7U9bwjCDFq0lVPL2p
         kYfBqeGSKQ7t8E6UjouD6ISFyfix/072yFauGylnMpcDeXEYrq+JT3LdHWfVDVNbaZLS
         DjFA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ID5ajaKM;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d64si2116582ybb.259.2019.06.18.23.24.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ID5ajaKM;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5J6LNfk025885
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:33 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=ID5ajaKMn4YJkmbkush1oz0lfEupmjXRHK5U5hR0MieBzthFF1YAYiVfcvcf8x/fijZa
 3Hs87+5dHuKkai1QaU0paRiQSKWBcjR1/kyga0/1ijehRFooZTQOmmkhuDajl72+dHss
 w8y1oC01uMIZwLdkWzO005bg2pAB3XUZleo= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2t77yfhbr1-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:33 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Tue, 18 Jun 2019 23:24:32 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 4A58762E30AA; Tue, 18 Jun 2019 23:24:32 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Tue, 18 Jun 2019 23:24:19 -0700
Message-ID: <20190619062424.3486524-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190619062424.3486524-1-songliubraving@fb.com>
References: <20190619062424.3486524-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-19_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=845 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
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

