Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39BD1C4646B
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:12:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3CBA205ED
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:12:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Bjb3xuQs"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3CBA205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8B5386B0006; Mon, 24 Jun 2019 20:12:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 868C68E0003; Mon, 24 Jun 2019 20:12:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 755F08E0002; Mon, 24 Jun 2019 20:12:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f197.google.com (mail-yb1-f197.google.com [209.85.219.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5476B6B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:12:58 -0400 (EDT)
Received: by mail-yb1-f197.google.com with SMTP id g23so13885681ybj.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=DjrJM26pHIYAL/LGrkQvra+C3vD+M/19/OoIRlnYaDtcys352txOoSVjAe9+9hr9RC
         riM779k/1sqz4RA7T0lllVw1DQkGm4TX+vHD2pQzSwHtQiRyRSxx8gXGYtjUnVaMIaDE
         H0e4j9GSxpkI67mtKhDJqHKZ1Por3msTbp/5tEcUECO2idgt2QSurnFpcseYuzvD6AF9
         /eJXKVxk6po3fMcvSAx2Az9y95ItD+43RN/RFoxNU1h+mquj8qRknaQe7nthzMBLyYET
         lcu21+w4Pa3VoxJo9sYci1BI+0JrJs65d/CfsTJ0iubvRSK/ukor+RHAXNfBcq7Lx9Al
         CjFw==
X-Gm-Message-State: APjAAAXiW0djvvLWCg3+HlQ7eIIUZUoNLa1NSv5mCNhlWyhmwX4EYx1X
	ZuyAHdRQBvgL8Q91SCC5UM66EPBFfNuL4cf490zCOh2FjSbC5MzAPqYx4CiG59jQRE0ze5OXzm/
	mijYqTlJU4H7TeRrFE6wPyElgxcgbAn4xIzS3Y5TMNn7abUwuhhpMV4iqTN22g0XRmg==
X-Received: by 2002:a0d:d9c8:: with SMTP id b191mr3279782ywe.186.1561421577970;
        Mon, 24 Jun 2019 17:12:57 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxi/K8cEnKT2bxi7UB+C2PD4NG/gjQYQtoLNl6IEaIyeZ/qj7FlvPQrhqoDo3l8kuAwIT+V
X-Received: by 2002:a0d:d9c8:: with SMTP id b191mr3279771ywe.186.1561421577530;
        Mon, 24 Jun 2019 17:12:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561421577; cv=none;
        d=google.com; s=arc-20160816;
        b=MjiSu9vj+eX9wvEM5OS3ihU/Q5cC/Z3FbbTb1hYhDg1DFVi/Qt4BsBZZesuD2liBYT
         NygECtYvHoTcO6hpQCriZ35SEkoVKMwLZ6VlZOCnSVDXJo7uj2jFGMEIwiYdxGNDL8Ud
         TtaPfT4o3j1blcWFNDD3Dzkf6j/50OXN+K8NQZJRa4OiVRvZ1IOjfX++rxUY7jxvT4zU
         LmpoNErP+F/DqqLQx5UhfDGTkg9+2+L8/9UulGvBKPx6L3UNqMhtKI05wtMFltC1ySPQ
         NS5GPnCBEq2NxRaa92ZGuQL3ySOsPIcKMgKqKTSGrxxkMfCgZDQEeCd+eEzbBPgDQpZ7
         ZyyA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=s6+lFgHjaN4WAQm7hyBX7S+sX4X8F9H8V4ceDwAGy+ZGFzEWu/0BDjUTQY9uVOr5aN
         eP7wea9bVsuqD72atDv/ludZaFqGKLxq1EGWd8tWHBhzqM2W590z9SGmyIl2SHYnU/dH
         9byGQ6JZdqmYyhiyIGF+rIfbPB7nwkQn7xsrB5cDJEmHkxSM4dSZrbtWjmoTrTu1gzZN
         DwjApxabz/NUmt+SZ6ApBC+OLW78/WC/RaKPvX8SmKinugpjoLpPVTrA/1u7HRhdmU89
         TbDZZ0rZuszgVdJVquZfoC23TCf5oPNzi8hDPM8yfO1K7yYNr5suASTzyZ8GEt1Qaduh
         N3Lg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Bjb3xuQs;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id 66si4359971ybm.237.2019.06.24.17.12.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 17:12:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Bjb3xuQs;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5P08sK9031652
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
 b=Bjb3xuQs6YXfMYORrs2euWeYoJm3krK9tGMMWXiCR+iwQp37+xprNLGkO4fpNz36Nb1d
 /G0eoHEN0j01YC6AaXkViVvCwmNcYyAAUiHNaAyE/Rmi0WPXOtFl3Mlgj4PN1DvfVJMd
 PMHCwZSAqf7XdgtPSf2dw/C8Fnj7doJLkDY= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2tb3gw98wn-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:57 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 24 Jun 2019 17:12:56 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id EB6A462E206E; Mon, 24 Jun 2019 17:12:55 -0700 (PDT)
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
Subject: [PATCH v9 2/6] filemap: update offset check in filemap_fault()
Date: Mon, 24 Jun 2019 17:12:42 -0700
Message-ID: <20190625001246.685563-3-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190625001246.685563-1-songliubraving@fb.com>
References: <20190625001246.685563-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-24_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=797 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250000
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

