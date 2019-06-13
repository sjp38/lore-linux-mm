Return-Path: <SRS0=7jwN=UM=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BD941C31E45
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:01 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7CF0520896
	for <linux-mm@archiver.kernel.org>; Thu, 13 Jun 2019 05:22:01 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="qNLowu2M"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7CF0520896
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D44956B0005; Thu, 13 Jun 2019 01:22:00 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CD1056B0006; Thu, 13 Jun 2019 01:22:00 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A86976B0007; Thu, 13 Jun 2019 01:22:00 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 725F96B0005
	for <linux-mm@kvack.org>; Thu, 13 Jun 2019 01:22:00 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id e16so13025304pga.4
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:22:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=d/SnzBiETAoMzu5ZiUQdyMJB3iluqJaW8Ccsc1YOxOE=;
        b=ZjT1H6FiALAebGyQmCSug7Q8KvfcqZR8/jqXGBy4j4elW/E7BnNjGEiPyFIRqc434B
         sxVO8Obi9GorV3qS5u9qbMV3L3TpfbtAPHkUs6kSNu9SkChcL6jm4ZyKNsJxBbwXEa3i
         6TGD88cROOVf8HAIgTwL6e/k7bWQVNSOMKprVQieOEwh1umr+Rv0RNSM2Ef905VSWj1s
         gyxvYLrWnuJOcx3kU93bwBy8yQ7ED9l18sIH2LX5G50H6QwV5/p9sBDEwWVBZBJFY2V6
         1xj2oSPVVOcw37zZZGFsGOezQI3gVIO6gUg0HDQByUDOvfcQAotiJDUqBGFfXIr1XJCV
         8pIQ==
X-Gm-Message-State: APjAAAWuZFU210U7CNJfOzXmsqQQHj38GlY6OfF9jzYfzuQulE9keEVP
	g94Irdamhlv7kNvuowAkwJTYi/cLKJXuczInxu0qbgDY8JiywmjPUmxhIsmA1Y+EltQLB/a7k8U
	1D+EJCeNI6j7Qrdx8xRpeXFw96o/uhIy+jtwYohK65NZs1TRPqsQsCnEj5OnabRgE0Q==
X-Received: by 2002:a17:90a:9dc5:: with SMTP id x5mr3087093pjv.110.1560403320089;
        Wed, 12 Jun 2019 22:22:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxvrE8Lu1ZuocPTtrwOYe6JXAAq5udUqFnau0UGLGRlnTciOD0CwZ/CsMrANxib8EW7xh5l
X-Received: by 2002:a17:90a:9dc5:: with SMTP id x5mr3087058pjv.110.1560403319383;
        Wed, 12 Jun 2019 22:21:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560403319; cv=none;
        d=google.com; s=arc-20160816;
        b=HAUmnEGIlvhQUQlcerxmBaMiAdzDZ3M0YTQQCumuGkkMZqhL4FUy6rvRyNpWMOzycs
         3GM8pCJoXdL5IVFYrGVjJgHyie5c0vbYYvWQXY6Atf1WKlRBECNIFNg4+ZjNhMh324pZ
         B8iIskL0r0/OtDQQBO2G6HQW3HRmsvIa6thPALDqauoW4bxFLxGSzfRpFWDGUQY/rNtc
         Pfy2vrM2NlXHG1KstzmFX8wCK6SOs5Pv/EACAjnVvumLgjvP+KXqOtyVhL3Vxf/RgU9e
         hIsw32do5atN+gYn/03sREJDPQmIyvfDnmwh0J0eXStf062fYBQ9FcpWCOnBCXIYDslT
         AKPw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=d/SnzBiETAoMzu5ZiUQdyMJB3iluqJaW8Ccsc1YOxOE=;
        b=FpV4rbej00N+OELkVBf2TWeO99DJvQsldxaN/WZ0rSA9vf0ZWv7CPad5xDKSoPFy1M
         DimF8VSSnoytOkYB0Ju/RYljnK8lS2sHVHrpDh5jJX8iMO2jnAA/UvZc5dfuskHjekX0
         J8LGm3mEh/QchPI3oiza4afjjZ0DzGBTiB3x9DKlnozEgckhrRAHJ3GykRALvX1D+Erp
         8hZicXw8Rs5hiBlSiBsMXzVYAAifT0bGQ1KfiYZvItylzxRrFqM6lCsHuo3oleAF1Z0z
         Lb5/myTh2Q7Rbuf4GLxLFezzN2XP1xKb1VRMqkgVYhS2GM8QvIvxVcLgkvi57rR2kBpu
         5hiQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qNLowu2M;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id l9si1976789pff.51.2019.06.12.22.21.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jun 2019 22:21:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=qNLowu2M;
       spf=pass (google.com: domain of prvs=1067aa1dbb=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=1067aa1dbb=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5D5KBqf031264
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:21:58 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=d/SnzBiETAoMzu5ZiUQdyMJB3iluqJaW8Ccsc1YOxOE=;
 b=qNLowu2My+mAUMHT61D5amu+0bJMO/jGuMyjUDhvI9+lgAsBM9SHh1DFyj89MKmDkU5/
 wIy1n/tuLLl6dmmiJ3AmaQuqOBcgRN9a58rMS3BczsZUTjNbtiV1zlUMm30TGdWDSiPj
 ZHuwGco0EtKVs5ynmeANIYj79jSg17YjqSA= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2t39snh318-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 22:21:58 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 12 Jun 2019 22:21:57 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id D1D4862E2FC5; Wed, 12 Jun 2019 22:21:56 -0700 (PDT)
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
Subject: [PATCH 1/3] mm: check compound_head(page)->mapping in filemap_fault()
Date: Wed, 12 Jun 2019 22:21:49 -0700
Message-ID: <20190613052151.3782835-2-songliubraving@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190613052151.3782835-1-songliubraving@fb.com>
References: <20190613052151.3782835-1-songliubraving@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-13_03:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=1 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=844 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906130043
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

