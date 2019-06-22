Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DCDEAC48BE0
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:05:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 903B120881
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:05:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Ot34M4pG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 903B120881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 363878E0002; Fri, 21 Jun 2019 20:05:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3125C8E0001; Fri, 21 Jun 2019 20:05:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 200998E0002; Fri, 21 Jun 2019 20:05:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id DF5D38E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:05:25 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id y7so5324021pfy.9
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=RUcitjrliXkm6xyf/tbv2FLktihtaLLHj4zHEfJID2EtMTSSwnP9J9CJolOMVqaM9M
         t4WkC+fABHSarM2INmcOQwe9LISzyiVSZEALeT/HOd1pn5o9uawYseZCfUL4iGma8bcl
         4nWjFF24HFHHUFyVsLHV+QK1qCt5UC9N0mAm3VKom+7yA/80VEhid/8U5Jd2J6sKbc+V
         ObALMDKU4DJ7z9OBrTXT+hkDvWKbNtYHMYyokQTsc6RJMd/pGxcpvWg9t46pVdW3Izih
         qaZ1DMHdPTms85yPzCQL8OTf280YGeOXKSeiR48WyTlha3Xd21PytYazr25KnrM+4oR3
         DgeA==
X-Gm-Message-State: APjAAAV/ayM3ASatConS6hR+oGwJkYqrUw1o4P2uBO+C1DsmiGT12cWo
	DGUPobhie8OnU2UE2fAEwiDbbrtzGGxl9HFbKIWAepvV/Ks8REMZAZQWiGYpzsRgnpzmei7ysIG
	ilY/t15rw3p+5b+zdn1brHfNaPdcIj1QAyNbHcNY5E1QXWTtrweg+2jSBgxPTkcULnA==
X-Received: by 2002:a63:4105:: with SMTP id o5mr21635880pga.308.1561161925476;
        Fri, 21 Jun 2019 17:05:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy1js7B/r8Spj06GD/J0v3rb490c+xaa44/swQ3Hbj3cyOPvuR40i/OZzXjyaX9mfYxUqZC
X-Received: by 2002:a63:4105:: with SMTP id o5mr21635786pga.308.1561161924264;
        Fri, 21 Jun 2019 17:05:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161924; cv=none;
        d=google.com; s=arc-20160816;
        b=Iy1+bhjwptuHgZWMwrDUUjhz/6e1ZdDR5qns6TowHf+j9BOuNUgTNPviffGXMZit+d
         2NOMfOgzxtwra2IGNMVS2tHS3pKc7cnMBDlnwJORMNAI+Qz21fOqvG4asWDy8lOOBAyL
         KWv7VupK1SvS4G84cfTeRu2rrHCr0cpXvX/VY2+E6plPGRP6AtcLfqlQsoTNPoCG/x9n
         MIMOaLhS4sPmGBlcmR1Cl+YwDzluzDY4unV5uDBPdumzWTrImkyj/aiFHO/Gkl/gvBoJ
         HbEKzJ5jkQDSxvB/lss38ScMrq4UiKLsudpde1aVWWjqqCrINkdEOX7njCXX5it1xmgq
         n7Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
        b=BDBxc6fOEn5xrnNeGk32Rdcg0w21SB32Cf1+OhmqfjnZH5YpL9vi5B0ygIFQQXRBGi
         EW2fc8H5UkabfztLNxsovqHcrGQ1wWXu51XHGW+3KN2jFw9aXqlUdFVZrPKWhd4oTeVY
         Gkzu+hFWY7TniRc3bFQZ7XdCipiEfEGttEtsjbULvNBJM7UCJY8F8iaVG+bQSoG4wIV8
         vMVClmZcI5592IO9aju11z9PL9laSpl9bwZ/K0ojIdyf41AuPaisu6u7hV/+2moLtjgv
         XfYUpDE3x18PHzrDegsSTmH/R0PC/x/R/1PwiPx6NDjOTNvtZopK/4yyzWx61xBngMNG
         qN8g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ot34M4pG;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id j14si3955772pfe.183.2019.06.21.17.05.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:05:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Ot34M4pG;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNsfcH018841
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:23 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=EqtD9pgjSn3RpeCA8R1A7DD1Wom8eSWCEiXrtl71yV4=;
 b=Ot34M4pGIBjEv7uH8XSL69Ax226lIXalnxy1je4+lnAicyxhR2+EdWYHGIdnEAtC5s46
 70XsPwKD2rAcTTXHA+RZpFxs8hRZcfhoAp2yyNFxIEEqWk/znsTaB3VKL/naG5gS8/7q
 C7ojZeLOTssgN8avSzUbFrCij9EdvTmyDAs= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t91rg1qm5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:23 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::127) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:05:22 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 8299662E2D56; Fri, 21 Jun 2019 17:05:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 1/6] filemap: check compound_head(page)->mapping in filemap_fault()
Date: Fri, 21 Jun 2019 17:05:07 -0700
Message-ID: <20190622000512.923867-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190622000512.923867-1-songliubraving@fb.com>
References: <20190622000512.923867-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-21_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=922 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

