Return-Path: <SRS0=rpDk=UV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0EF92C43613
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:05:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B9B6320656
	for <linux-mm@archiver.kernel.org>; Sat, 22 Jun 2019 00:05:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DdeLBro7"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B9B6320656
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 229868E0007; Fri, 21 Jun 2019 20:05:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1DCC98E0001; Fri, 21 Jun 2019 20:05:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 054EF8E0007; Fri, 21 Jun 2019 20:05:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC9658E0001
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 20:05:40 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id e25so4177648pfn.5
        for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=o4/yqFlv32zlBu3St4mGRnQupfTx4yogeyDXgxYIDCwTgdWGNTrgP8VxEKbtYAVokW
         RLXJU7sKQRM9gu/Zi7og3es5p/vfwMH2btth6mhTozsPTyMhyeYrUlAiABFCLgOhKXAs
         I2TWH/SW0DwkrR9HCzHLC8d/VnDRJ8lqH36uSZnjLS6aLiS2VC26aBgJKw/jjh0mLdeQ
         ocnIIlWplizB5/Bpa1b3QCIxVh2EjIQdhESpb3L1BgSIup8ureBXDBtjZRJG6BQVVCEI
         OydPp0OtixMi6hK+OCb14b98kEde/juL++F2g1ZDbSEFnnoTxhyeqlir08zXF47gJbgH
         aE4g==
X-Gm-Message-State: APjAAAXG/PdYrqm0x/AN3aKk94w3VsEm3cSY6YWNxR59obnko92LTRbS
	+ojJdkYCC08vo3DnSc5eL0wN5XRvFvRAruqCxIQHgyexK5pR6t2k4X7UBMpRSn9DfJOBIylkQBf
	0/vb8HTw353NuC9lyPlraL9vIZifSDS7o5W188zvuFYWygrKawc/6CDZxeDrp74YDXg==
X-Received: by 2002:a17:902:7793:: with SMTP id o19mr73236252pll.110.1561161940453;
        Fri, 21 Jun 2019 17:05:40 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzH/SQbt3DXf+EqMApEAJwR1YtcK07J/8Eyw8xv666cwY6WFt/sqhGqij8fAf5kgB4YRqu7
X-Received: by 2002:a17:902:7793:: with SMTP id o19mr73236151pll.110.1561161938949;
        Fri, 21 Jun 2019 17:05:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561161938; cv=none;
        d=google.com; s=arc-20160816;
        b=alIeIV/XYNqOoBTqyWyq8jA+DQ7FUf8QQhswgl23TsrAK5a2c6Qu956h2+f95gPobW
         4KVG/od4VgyrMf8aTstOpPcTf8u4/cwjPvd3zETCIlo3PzkqhE+5/BqTxl9svLWLyuwD
         bu7K8tUMJbJv1TnjCeKlPNFRVVwSsFFCe08oij/uIaVssHxPMaEljKeNIixarv9pkc1I
         Ihf1eILtq2GpnLKZoGR4ud/jOXQ7dtM7VDCZwrD73JGsuD+wVFLbTFlTwiDCNYn5oxsT
         7Knix2c+Cnk8W2t5RMv5Y02/b3/VIs7dxz05+IIJ8iyMJgQNWGGHlGqlw5j0jGKHE7Hi
         TNUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
        b=azyD7SMr9i7nXD0hngViSSS4C2Dq9/qkPvnHXS8P3Gpqu47QYX6Cgx6s5SoWHmZp5m
         Z42yizruikfyWQfTV0w607hHgBc7eb1Rp/SEQh46tRrGJN3lFxYt3Ca92QXYSnvevCv6
         PxHjZSkXx02tf1gQUGgV3EdG5LFa8wWV3XrDBVeXhUOYneQaqZWsJeREyG83x6Jo00Y9
         Uwc5JQhO027GHJ19pkk7NtcnNQLSjoQh9eUp8x2BSi/T3r8FzEl0jl+ziDvtoY1NYBd2
         rrvXWuIwqoS3/Roe57CcwP+qQ1DIkJqCLdRqGhRQa/J3McnAwtInJzJTMZ9+GAyaRYYd
         gbvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DdeLBro7;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id o4si3749190pgi.160.2019.06.21.17.05.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jun 2019 17:05:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DdeLBro7;
       spf=pass (google.com: domain of prvs=1076a8f7d5=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1076a8f7d5=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5LNubfo026471
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=z7orUW1w2AFawDH57ZTLvYALJSDsMI3HPUuppHQ+jCM=;
 b=DdeLBro7s+f3+XblTN5J2RqMc3lasE1XneaauOlUUJsvJ+FD5czrEBrNSIlbbBbJqB0C
 Xvbqhjd+VA6KrWHpNpNqJVVrAzGovUeRD7emQV4nfjOF7BrUvA7MljybdOirg2QNVR+G
 cFzngT+bC7hG7ORgGbaPjxyd0LOMQE4p5cg= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t99btr0ps-16
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 21 Jun 2019 17:05:38 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::126) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 21 Jun 2019 17:05:23 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id A946E62E2D56; Fri, 21 Jun 2019 17:05:22 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>, <linux-fsdevel@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v6 2/6] filemap: update offset check in filemap_fault()
Date: Fri, 21 Jun 2019 17:05:08 -0700
Message-ID: <20190622000512.923867-3-songliubraving@fb.com>
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
 mlxlogscore=801 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906210182
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

