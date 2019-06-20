Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23958C48BE5
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CDFD92082C
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 20:54:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="LpDJTpfq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CDFD92082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5E0CE8E0002; Thu, 20 Jun 2019 16:54:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 591B98E0001; Thu, 20 Jun 2019 16:54:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4809A8E0002; Thu, 20 Jun 2019 16:54:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 18C398E0001
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 16:54:00 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 65so2281186plf.16
        for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:54:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=nt4uKorF9OoiCxGN9kcSocphG0034YgQuyn+rRZuGzJEQlqIHwj82I/1UmqmNeXGIL
         85BdSyI8R9w+2inQ/VraybYHu8jPpm77PsiGks2sg0evqDgeb1NiDKXtGhM9HQuw1WsO
         e1T0wW2pCDMGh+5E5bLNeB9YdpzMQAEgHR07gxbMtMAz3tX40IhyOUh194iptddL2EAM
         Q+G6pGafJJoxDbLxB2uXu45Co1q966Gg8z8+F5L60NBxZFMZmDjlRxHo/uF5uEaUkrph
         zRMJsRTwjxZylvcJ6/sb/lBz2OkFoYDdf3cbcM4JrKIg3RWjKdhC3PHoe3RU/R2UTjCq
         6JYA==
X-Gm-Message-State: APjAAAWh5eNf58dGjsjxK+X3wFU2NybnA7zwolAgo1pQUMK8cVaJa6tb
	gj2p6jGCXHxFEdK1rxSwCZGpr12BRxSTrhtcNwzp6Wj/Ucn5zLQ1sMbnWZJR0mi9DE9uNcchLst
	Lr1Hx+/OFmBkVTK86Q+bTCFYO3r+WIy0kvNRWA/QtU85032JHFCKjrvv7z5jHdoNhZA==
X-Received: by 2002:a17:90a:228b:: with SMTP id s11mr1576970pjc.23.1561064039638;
        Thu, 20 Jun 2019 13:53:59 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfdQZX5z3gGNQFhM/v6/rV2IqcDvcBTme3V3/aAmdrdyeqIvoV5CnzTViU/KB8osmmXchS
X-Received: by 2002:a17:90a:228b:: with SMTP id s11mr1576940pjc.23.1561064039039;
        Thu, 20 Jun 2019 13:53:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561064039; cv=none;
        d=google.com; s=arc-20160816;
        b=WzdkbBmz6LxC3rO99G1zNLIqlySvfmiJbyRVZzmg3HX07oBFbth1cinXdQWjFpc43G
         OxVc0bn8R9wHSL9scb90CggrqwaVlnjEqH9rXM37VMr34W9PYf/XOQlY5CpiyRB7YFtm
         EkjqbYyPhXm0Slrx63ENy9oVtORLh1ZRVkUDcbxTbXML1j4wAPFskM3YmxKUax2X2uol
         fwzDFXqoLR+NUU452UCgskma+4P8UgDT8G7Gx4sy5B46mHVRS2o+1cKVL7FU9Zqr1gbq
         XXuRDQrQVTapwlh96cK5kldg9gpmRA4ANDZHiDKYTS64T13Ypj+90rbeSk73ywjHUufW
         kxtg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=PkiGDzpDGzBd86DEPnNqOqdi7KFs6flpB0m5piluBYhkF/8SErJOYrKu6c84eij+xI
         1fenmTR70OTioK2Eod80ODLQ/xmGgW2xcyljymDGlJwvD/rImhzzOhvWAbDzEc49MmeL
         4NUTLPqDroDkTK/G4BekTHLXUIwd1HqFB9no18Uf+Ex0G5HeLF8Y7aJUjZOlRgJKIbG4
         f0oyaYNEYbN8v9sUhSSLj7mvX6ftwVtmHkyDWzXioBkYZkVVTLJua3oSfrtS6acCemrl
         z+peINw73K41YGQZp4SipYkvb8rDExonZL0kXqKOBAlWAhbriZzT6lGzCrhrq2sZAizx
         id6Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LpDJTpfq;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l24si508957pff.185.2019.06.20.13.53.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jun 2019 13:53:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=LpDJTpfq;
       spf=pass (google.com: domain of prvs=107476d203=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=107476d203=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5KKnoce005791
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:53:58 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=LpDJTpfqcAQZyhceb25XcDEeRRD76idUGMP2YCehfhWBdS6UgC5jlKKOaxVp8kKYkZvJ
 iQYqcb7yNzHAvf259bDRxivY5bQWyoJ82yfIN4bsvN1C0sFdbKbNm7GwYccgyHsskI/G
 ZjVOQcms0Zki8NUcysf2+xqYg30DxS1q9+M= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t867ftg0d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 20 Jun 2019 13:53:58 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 20 Jun 2019 13:53:57 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id E8D0762E2A35; Thu, 20 Jun 2019 13:53:55 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v5 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Thu, 20 Jun 2019 13:53:43 -0700
Message-ID: <20190620205348.3980213-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190620205348.3980213-1-songliubraving@fb.com>
References: <20190620205348.3980213-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_14:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=926 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200149
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

