Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 73A03C48BE1
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27FFD2064B
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 17:28:14 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="WtVAiSL4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27FFD2064B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0AD476B0007; Thu, 20 Jun 2019 13:28:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 011168E0002; Thu, 20 Jun 2019 13:28:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DCE348E0001; Thu, 20 Jun 2019 13:28:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id B19056B0007
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:28:12 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id o135so3621456ywo.16
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=p96op37WrfEV+OVQe7FHjSG2knRLYf3E94bNHd0vAIoINphJ6zvF3I3UkxrvOfZbLh
         1kQvMbMvH4nCop/1ZtvYZxhOwTVk/OCuCZNV1Tr7ScpU/O5ZoqdJXDYs5w2jJ7ahoMUP
         hgBFO7E43WoFR2T3sH+WnghpES4eV9t3c77ot5gwj9rEXtVCZr+i4naVEiAEUWtPluNn
         LCwcPI6sChxasVnVUy9NxHYR6lvNrU9eIgaPl8H7p2iEz3ZEH7hSIF5IaeDoZd4xhBXi
         lNIVjCupSzStj+geXgtnzc10jHx7C2XUntipY0DvqQisAeIHNrNlWSl9fAdW84nnanRn
         wQBg==
X-Gm-Message-State: APjAAAXrYxrzE3hdJBaN3dNhUjC6Z2BT+zhC0cny/yeDfLFpRAPyBMFh
	xedaC/hoo2Mi52Uo4hfgh1DQhWeGcmxmEpmT9ylThpU2wkb2/5MKGVL6J+SY+hpS8MKaCCed0Xt
	lX/1hH+RnClpMSuHGmT+F5UUaaN1s9CawbW7H41sltckZx5dlzr6OeAnbPw8UPiy/Hg==
X-Received: by 2002:a25:38ce:: with SMTP id f197mr58318073yba.300.1561051692485;
        Thu, 20 Jun 2019 10:28:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHR9oWXdXWak8i+hJXGbL/s3l4F5FqbdOaH2XdmBltvVKT2usj3jXUhhSRr6FSsbPFomew
X-Received: by 2002:a25:38ce:: with SMTP id f197mr58318060yba.300.1561051692003;
        Thu, 20 Jun 2019 10:28:12 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561051691; cv=none;
        d=google.com; s=arc-20160816;
        b=bmKz722Qte3Iv/tFs1OTkidCz4ESA/VCh9KDGvLPndULgBATNBMKJ3h3Fc2EmarSxd
         Go0CNCdZQJUJP9t80iUCP+NtNCpVbMZuefZ0eOdcfymPIuozE3aVrUwjPr0JlWAKEmEK
         f9GTtfH8Tiejgn39eU44MFwflxWNNV/QL86sFAfgskmmVVhpLYX+KVcdTFYg7WZ8loGq
         iisgh5cfFolOHig9PZkMf7En2W6xSadG5FeyE+47BcKQPLle+VQd5l1Qvb6wbnsmNGDn
         4ab5bTWeF0wN9iMZ3G98wbKi/HTlFuGkfr18c5tjnE9fh0ENXWPtE335O4t/rwhEHXvK
         Ma8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=uunFY1wNU9KdsoDoH+9rjgO9u4UhXPlg/aP7Lpo1gZiGA7yG+CcpNmk05TL5PIz7AZ
         YUG+Gq4qUugpKdrw97sdT+pduWTN4nWfYlgPFl3A1Q9ry07tFHGd3fmYVi56PGYII7+g
         3XbOVynDwFQzNZJeaRAxa7pDvOFYDNKJ15r1vTm3b+pxYr6qq+hTyS27AVD2SLv8CLBb
         7AwOxwG7bNkTx9XTiL9ABumQYuPA8GVnAd6rn9uQCKTYwNa4bVtT9OiCeJup7kNFTyLA
         qqPizMPh+Uswt3k7aciAmAzkKN8zba4TWzUEOQvAlYWd58DXavhXZK9NVEa5Sv2uo1Hf
         yhOQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WtVAiSL4;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id j64si34544ybb.150.2019.06.20.10.28.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 10:28:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=WtVAiSL4;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KHJiEV021867
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:11 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=WtVAiSL4pkv5AjfkhFLdw/fL37uvBfV7B+EkD4ddcNFBFJ7XMDUe/dOAdTFyx0zJCoBV
 sKDERts9lAuagNccRtxrTSKyqSJXY8n/b1GmBIQgMBoExqn59o5Z9k2aWCS+MdBBNy3T
 CRqvw4Gu6Ov1NuidnapPV9xDlfmID5F+Z1A= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 2t8aj98ykt-3
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 10:28:11 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 10:28:09 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 7FD8F62E2004; Thu, 20 Jun 2019 10:28:05 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v4 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Thu, 20 Jun 2019 10:27:47 -0700
Message-ID: <20190620172752.3300742-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620172752.3300742-1-songliubraving@fb.com>
References: <20190620172752.3300742-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_12:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=926 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200124
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

