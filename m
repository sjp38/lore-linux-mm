Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B074C4646C
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 32D8F205ED
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 00:13:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Xn8tQ4Ka"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 32D8F205ED
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E0D026B0007; Mon, 24 Jun 2019 20:12:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC0C58E0003; Mon, 24 Jun 2019 20:12:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BEB6F8E0002; Mon, 24 Jun 2019 20:12:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 88E276B0007
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 20:12:59 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id y5so10580312pfb.20
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=iZ5OLpaex2zBFIsKaoTlQnbM4DyYsD7gp2i9fg48VSVr3p6+6r/Nz4UJuQ2Srmq6gk
         zN3+06/oklo67Xb5cD+2e8dvS9js0wxCTEWZ12Un0jBrTByxreYJFIf6E/K0hpWXoyEG
         mUwa3nhOLrR/SxfuS9NmeUN+DUNHk2xlnEQl6al0I7x76Zi/jEr652xXeELZ/fJqeIRL
         gZ+0eXdCjxoFM2UbAj/LG8BIDrj76XIwcxZ0fKtD1WMnTvfpFTRW5AdkBKYFQtIc25Ce
         3g8TFd6VT+o8TxA/DExz56tX7ehPuKBKvB+9z8ikz3q7P5GfXxgNJ96adaoj8Oa0ShDJ
         AuqA==
X-Gm-Message-State: APjAAAXlr6qB+k7ZOkOQnK84FhEdnJhsaHOGhB3g30DzMfjMNsi8zMMZ
	Vw5dABPF3NYuPvXficscjt3znxcmDmxnONuYyrXTUmLOliDiKtbeJSlvMD8Ny+1ExySSwZ5dcm+
	kURsF+2sWjScAABeCsgfG+9hGmvmyiajXTzY2EV7CY6CsA3MbLtY+pG/wfHlzg15bVQ==
X-Received: by 2002:a17:90a:ab0b:: with SMTP id m11mr28876803pjq.73.1561421579067;
        Mon, 24 Jun 2019 17:12:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVZevcd22eOt5JA764j5aEbq1dUxXzWd/YVYL+XpF+8N1wR97eXMVVg2rZsN4RoyIhToLE
X-Received: by 2002:a17:90a:ab0b:: with SMTP id m11mr28876748pjq.73.1561421578414;
        Mon, 24 Jun 2019 17:12:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561421578; cv=none;
        d=google.com; s=arc-20160816;
        b=PG1lZhhgcasl9Alzn4Bsy/4Oc38SwrMk8dDOhgf3xRNpT9bhAwOHa5lZcEhuz844nx
         tYf57O4LN3gQRSLKccteVdf21TMWyo0fKkhb7SZMs73pcJ+PswWARJZglMNQ4c9wEZ2L
         /ZLnhMNKRKRvfGN+V8lewIl7nPPKVHc+6UfDVz2GZCAGuPN7ci3HzQVC1xhBrxpWiX2X
         XloclHTjKrHekO5gbJH6Y4kOnwYY6XodPwRgMigOooKQ36B2T8HF77M0BGyoYQP02IPL
         ZfPljVNVEDRvgy2+2jfESu6Hq4b5bFhvdnpPq6GCsQUeBrrVur77+t0nNwcqxeF/ptZ9
         wFqw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=f2or+E+Xq0BRc0iUyvRyQgmM9yeHJZrehq57EmPtpKkVjfjxNebtBkkCRsjMrIGxru
         Wgf86ym5a9/WJM1LenpAhQGUfsqtxi1vjOa3V0IZhk7NXm1EmFrpSA87fO6ZFDFysMuA
         8VKL4yTUKmr+2PHZgBLiZ8TvwW0lyHDOxpGVNsJWbQ6BNTxReNlzC3bWmR6ixq4ygVDU
         jN4S8SFjhgdGsJzl9DiHjHtcdbB9rpSQ02nFCkh5C8bZmFF8JOSK89arPcwXJ4O7/V0i
         QMexgZ+EYCW6K8eaVtJC3inLQ4oyVmWcsBQab29nLyTn2EYovXhkapa6KMstWNAirDHb
         +qzw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Xn8tQ4Ka;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id f17si943435pjq.18.2019.06.24.17.12.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 17:12:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Xn8tQ4Ka;
       spf=pass (google.com: domain of prvs=1079b839a8=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1079b839a8=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5P08SIt029551
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=Xn8tQ4KaSTAaKIrmEDK3g/qzHWbvSllORMtOv+5HabJUKfKEJ0HB8+eoHS3xJ4uFOPSZ
 y2S8Ruf83O1MB6fgymW4amomT+HuhZMUrVvHB5llYgz5qJE2UPUrG5ToGfp8bRoB9rrj
 DnUANIts4NU0oCOdc8XJK+Deh959QBDK+EA= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2tb56ugu40-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 17:12:57 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Mon, 24 Jun 2019 17:12:56 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 924A462E206E; Mon, 24 Jun 2019 17:12:52 -0700 (PDT)
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
Subject: [PATCH v9 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Mon, 24 Jun 2019 17:12:41 -0700
Message-ID: <20190625001246.685563-2-songliubraving@fb.com>
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
 mlxlogscore=921 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906250000
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

