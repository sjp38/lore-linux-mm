Return-Path: <SRS0=1eqM=US=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 92D40C31E49
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5800620B1F
	for <linux-mm@archiver.kernel.org>; Wed, 19 Jun 2019 06:24:40 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dqiJHgwk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5800620B1F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E01BD8E0009; Wed, 19 Jun 2019 02:24:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DB1C78E0003; Wed, 19 Jun 2019 02:24:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC7AE8E0009; Wed, 19 Jun 2019 02:24:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f72.google.com (mail-yw1-f72.google.com [209.85.161.72])
	by kanga.kvack.org (Postfix) with ESMTP id A353F8E0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 02:24:39 -0400 (EDT)
Received: by mail-yw1-f72.google.com with SMTP id p76so18064547ywg.5
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=GT7rjxgO438+mq79t++266fcjefGPY2yMpYsgoogFZE=;
        b=AmSiJtGk/7WhJAXSf/ox4xZhb1Y1UNl7sUfNtuZOHy3dpcfKOgkuPU257mv0/FJlY7
         WxJkFDYmmpK3ufO99kB4UeeMg6AXej3TTaD7OfvXYund1zlqb+Ib73K0FqX1YmV4wihP
         MVM/FzEcSe9LJP6cF+D6eV6xFvz1L9dLCfYNWiF+Po9FEatBkMU+gpO59/ygMe53A9wH
         bIKSQEg2D2Tj1qIHfs/+kyJl6hsBNzoFhBnoSlUgb9hT4pPsNhg4+7UBmg0jSqzPSHWU
         Wu4y34iBHfJuAPdO9dcLI0hwkr9mjKA6qdcuVBz51VzlofUacXz5OQHofm9J5r++aa93
         PH0Q==
X-Gm-Message-State: APjAAAUwj+SOD1pCzVnOF70y0uTy8F5m+YKa7WQiAugNlCVM6uKQbaHv
	WosyyEHHmU93BqQ9lHcuois4Efr+flyYVWISFW5rO88tjyZ/aoBf92LflUrzAjWGzKJdvGnmKz3
	U2Y2gxmXIeyM0mtVMqjFlgxKYrimL7oIol7VEgQ7TOTsCL8PrSntDCQLlpkwhpPs8fw==
X-Received: by 2002:a25:ade3:: with SMTP id d35mr19192531ybe.371.1560925479300;
        Tue, 18 Jun 2019 23:24:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzqWYAbbL4Gx3385JApZmfrKBDL3+PbAmAeGxc+E6xnZXKD2c28ep29zc1JleAh9hMKpP7Y
X-Received: by 2002:a25:ade3:: with SMTP id d35mr19192513ybe.371.1560925478789;
        Tue, 18 Jun 2019 23:24:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560925478; cv=none;
        d=google.com; s=arc-20160816;
        b=VvWs8/FUPMFNGPQo/vSXtse2fXwIXMR0ZDvMM0igzioDzJKRcgcCYbiEnlJ5TcKOR9
         sUGcmSEbrV4jjOZ7y7IKGeWLZUyWMZ/Lsxk3J1yFRMVHQMY0eMjyD3ynXn4GwE1B1G/C
         iN0fvunCu476WN652SZspAgIAhUvZx2MC6rycYMMypfeK9/U3YgxtWIxIR2IIeBuwy74
         wbowhk/fR1FOOHOkOGJmIeBdAdkm14ITu3bOtluzu7Z44uurrXxreCQltAML126FkS6t
         xsLytTzzVf9sYGxPfKEWAgz7D+GSDeB07alFWmCfVd7dZI2OyjBbW0vishlBI0YDbcD+
         umFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=GT7rjxgO438+mq79t++266fcjefGPY2yMpYsgoogFZE=;
        b=NRVYoyFxQLRA60h56r2YftwAsupJrpJT23U2kyaYKg5DY1Jyq1g/ocRJ6Rw7GRQ1Fx
         5zQDi45jcCp57PEN1fflQOJKWNLFw339DlFyfokJKxu5FLB8cBCABmeuBdaQdYPKzPLu
         5ox910+rpz/Yei0bR6YagBi+fioiexhQuQNK/wLX+C1J7XPSc5cU4uo0UCdLaEsnF0kM
         gG8MqjjHK+BYNojBV7ocjzIH0PIrKOR8kB9lNGlUGT2dWEhc1WPyNs6MxEWwN2M2RZ+c
         43piJcpS4LeVhGmOGBG8bR3fFAkLFjnSp7sB7NaMfj53UQ57oG9dzLCbSW8aAzmgv2hN
         aiRA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dqiJHgwk;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q78si5725402ywg.138.2019.06.18.23.24.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 23:24:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dqiJHgwk;
       spf=pass (google.com: domain of prvs=1073bc1fa3=songliubraving@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1073bc1fa3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5J6LSeP025894
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:38 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=GT7rjxgO438+mq79t++266fcjefGPY2yMpYsgoogFZE=;
 b=dqiJHgwkvzOBTMWTjSGed7XavOFK1kzLVqFkeZQUHqleMOfyRJEjg7p1pW0/Y9L0AsT9
 rMGb0ZeiF7WnF2k8eeZsQ4vMvTQftTg8XkcvMGjYKVyYYWuLPfA+ehp2FZAKod16xxl9
 66/T2e9tTffg/7L0ZywcDFCS7X3o288J9D4= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0001303.ppops.net with ESMTP id 2t77yfhbr5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 23:24:38 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 18 Jun 2019 23:24:37 -0700
Received: by devbig006.ftw2.facebook.com (Postfix, from userid 4523)
	id 9868562E30AA; Tue, 18 Jun 2019 23:24:36 -0700 (PDT)
Smtp-Origin-Hostprefix: devbig
From: Song Liu <songliubraving@fb.com>
Smtp-Origin-Hostname: devbig006.ftw2.facebook.com
To: <linux-mm@kvack.org>
CC: <matthew.wilcox@oracle.com>, <kirill.shutemov@linux.intel.com>,
        <kernel-team@fb.com>, <william.kucharski@oracle.com>,
        <akpm@linux-foundation.org>, Song Liu <songliubraving@fb.com>
Smtp-Origin-Cluster: ftw2c04
Subject: [PATCH v3 2/6] filemap: update offset check in filemap_fault()
Date: Tue, 18 Jun 2019 23:24:20 -0700
Message-ID: <20190619062424.3486524-3-songliubraving@fb.com>
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
 mlxlogscore=729 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906190052
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

