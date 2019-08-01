Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3BECDC32753
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E8CC22084C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 18:43:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="lpapXaVx"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E8CC22084C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AA66A6B0007; Thu,  1 Aug 2019 14:43:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A591E6B0008; Thu,  1 Aug 2019 14:43:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8F93C6B000A; Thu,  1 Aug 2019 14:43:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 582366B0007
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 14:43:04 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id q14so46347918pff.8
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=lq7eKJkDsLmHUV4qu7iZTnjT46Y88VB+lwzmGkYti6U=;
        b=R16Kcfbaeu56iJJBsvYWsPQ/8CHOrGaYR0TIiO5jwcujn+Svu+KV6vo8OELCDKo4mz
         8lgKVZduGzGxyI8EshsN6XxAFjRcz+VSgEgOPTfKEH4TCZvMwlgyrAP/4+d+381yMw+q
         pUQEfIWm69ZUIEnJDkoMKER67Cr2HzwPMW1GAfyM3CtXLoxHPnoCPttll3NLlADF8lLY
         8UBD5GpV31rLw/ttFiT7UJOYd6sj39oI/rwiNABgCENBWsV2xhqM32kesFa361AwB1zv
         Lm89EZ/HQ06KJe9ykHPpnTnn5bQqlO6mPFHLtKJV0+28Q6LLE+VQ4wmU2vIFiPepM1WJ
         748w==
X-Gm-Message-State: APjAAAU3ba7OV6/kys1kErqLuIb4YXBNEJSlE+LU1Au22GvHMEKXqm6H
	eVkqTjpGb8ulBG8qt7FPtSWNvB65vX6gV/ayS1iuujfTeFMT/Scvct4x2+kFse20ejn0gGp/SWd
	TtKOM6msjxINlWDOh3q5aEZGCXUdxhdw58W4RNYlfWiJxNd+pMiKIL+NXBY8lXUv+MA==
X-Received: by 2002:a62:8745:: with SMTP id i66mr54165889pfe.259.1564684983997;
        Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzWl0u/op1TRLINOqRhuPhLhYFnuixW/FdKjAhUjIhFhjalpcM0cZH1zsu22DUplWrcuHLL
X-Received: by 2002:a62:8745:: with SMTP id i66mr54165848pfe.259.1564684983414;
        Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564684983; cv=none;
        d=google.com; s=arc-20160816;
        b=S9vqf4eWTVDKx6Sf1jtWSRsmdmDNIuHdG4tkUvpE1i8bc7178qav4X7Jh4WVfzHj15
         CypFRSxIOI0ztcmBx54wvZe8yG6UlsBek4M5KRZopWE7dATNV5QTO3i8Gfo3RsrNTsXP
         raR7SLeTE8dzLYFXJQPEfHdVwokI1T8Ya1+ZG3eIVFA55Xs1ubtZK9bbP2+r7NHymISg
         iYq+Pem2eFXxWPjpvHzsGTQ4SPYPGFAnEsMREgUs78IsFXUNyevPs/7dneEi5pgb8jqf
         yamsKx1fcJowXvNTNrH/f1q+WCX18bLXR0CMzBFbd4CCllzlEoB1Z9eUtCNZokPTPNVK
         A4uA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=lq7eKJkDsLmHUV4qu7iZTnjT46Y88VB+lwzmGkYti6U=;
        b=DtJhEQ/mIDA0ws4aeNHhuSoTnMzMO2Ra3DZ8HCsewiI4VymYBlAhOJSL/6vA5ZSpR0
         Hf8Uu699BJ/mIQT2Y2PnY7dUDo7Q7kfXw75bI/Oru04sxMLpL4NjSaWx7tzuZhXbLxFW
         SVaGcPOzXZk5fbXJ2/T8khO5NEBKt42x5my5a416/TEw69WcGHAMhZCRb4BfuifSZDI4
         5KdiMcb9LYxPvCz05GCa8NYJv/hf2q9HRH9gXJKvIxtFpr7W8e9KBkNGEWG9jP7jWTu9
         OGRtVxoBU8gy61iuyZ9K0sQgB1MeTmmOzbJrsdy+4ciUxHTxvgIpMzRiVXZS2jXC7hFZ
         x0wQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lpapXaVx;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id v186si35417782pgd.358.2019.08.01.11.43.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 11:43:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=lpapXaVx;
       spf=pass (google.com: domain of prvs=3116992784=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=3116992784=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71IgjR8026770
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 11:43:02 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=lq7eKJkDsLmHUV4qu7iZTnjT46Y88VB+lwzmGkYti6U=;
 b=lpapXaVxfIKHC/ZsfavKbczUogVos6FhHhByK2rkJHhxRup9QMEqFYJsHh7DbKfuyc36
 2vQssz0CJR1mpxFJ4VdxcLs884xwsE9DxoTuyHN9aqw5CzaB5pmyPJ+HQ/iMvR9ls3a/
 qy7zJyo/6NAkNfntRYgboDezLa9r7q7eri8= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u438rgmnr-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 11:43:02 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Thu, 1 Aug 2019 11:43:01 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 1961F62E1E18; Thu,  1 Aug 2019 11:43:01 -0700 (PDT)
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
Subject: [PATCH v10 2/7] filemap: check compound_head(page)->mapping in pagecache_get_page()
Date: Thu, 1 Aug 2019 11:42:39 -0700
Message-ID: <20190801184244.3169074-3-songliubraving@fb.com>
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
 mlxlogscore=750 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010194
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Similar to previous patch, pagecache_get_page() avoids race condition
with truncate by checking page->mapping == mapping. This does not work
for compound pages. This patch let it check compound_head(page)->mapping
instead.

Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Song Liu <songliubraving@fb.com>
---
 mm/filemap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index d0bd9e585c2f..aaee1ef96f6d 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -1644,7 +1644,7 @@ struct page *pagecache_get_page(struct address_space *mapping, pgoff_t offset,
 		}
 
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(compound_head(page)->mapping != mapping)) {
 			unlock_page(page);
 			put_page(page);
 			goto repeat;
-- 
2.17.1

