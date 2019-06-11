Return-Path: <SRS0=/KmR=UK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_HIGH,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F717C31E47
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2965A20872
	for <linux-mm@archiver.kernel.org>; Tue, 11 Jun 2019 23:18:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="nGjePryA"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2965A20872
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5196B000E; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B85F46B026B; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 963866B0010; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A7616B000E
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 19:18:24 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id z4so14031786ybo.4
        for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=nplAGvztvw22AKN56QTMhELHdT1v5h5cxoHCBLrrDqI=;
        b=Wgbha9YNwxewOWDhuv55Ml7NHS9uV0S8HYrj1PBkkSQ/DHc7zsAo0MZ9qvBf6AtSoI
         09auUxnG5eWnefHH7CYxtR+KeQBmBMgNQtsDdCmJ4hhMmm0J1y4sTn5gal1J6oF0meUz
         jR5HUuQgyDW0DWa5kHzg8cQIw8bklE/QpwrPbvedaObu/uVqv+mB7QSBXms5XHTnlkIZ
         UqalJZKi68+VP9MPM+jNDJfO0UqZLiedWYENg413Scls2iillaNUoiyAllydg8M/nY4j
         jiMn6kEcLeMPWj6lLxjykXXp8STthDwcfqhHOMeQDnoRpCHf+kSaQXMjM6fgzLUylrQU
         WZfA==
X-Gm-Message-State: APjAAAXN42IPToEaEct6mzXOyloMiFIXdTH4rTvbvxNdfYPzr4gWMJuE
	KrJm95wEdItoczRbe5qMf07UEAD+xpMtTtfspjzCfBqDEC5Az1r9zNL1025xNqedlusYWhxGaTN
	hplTwntEl4PIzJ1EAi+TcZfRq+XHqEkIfgVf/MIDA3iobpbMaI9SR40bbWUTE279rOQ==
X-Received: by 2002:a25:ef43:: with SMTP id w3mr37970268ybm.411.1560295104072;
        Tue, 11 Jun 2019 16:18:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxhMXPNE6ia+3g6BWUCgIIx7vzgvsJ2964VFFep1dmtVrrjS+mNazHLJU9CYR0P3e2Qb52t
X-Received: by 2002:a25:ef43:: with SMTP id w3mr37970248ybm.411.1560295103350;
        Tue, 11 Jun 2019 16:18:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560295103; cv=none;
        d=google.com; s=arc-20160816;
        b=RFT0ykg11BQyj+D1zCH31e5iCyfIObZm3Ev0Tt1rpkthD8KS9z/lqxaOEhGZ8ZfgK0
         KwWwDsgXqKx3GvXfpNk0Nzt1vzcbwJNr61SZyoXTIg0UsgQOG1eD5FA5m5QMvXdBfoXB
         ZHQ336D9kae2XNqZf+raep5maip871AAJ9fXhwT9REN6PkJL1P301FuXea0aCZAIgCUi
         mZgPgH/WISJjyySQyKu4xoNLLwxmCPO8XYTlKNN7thr2V/UpOF5qdf/H+1d40C9QLNT3
         iJMHkH/n8G6siJ5+bDHFOlRHVBMWUuCnjWQ9wbr48rmaieHC6W4fDIA8hRl55GkztwAR
         Qyjw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=nplAGvztvw22AKN56QTMhELHdT1v5h5cxoHCBLrrDqI=;
        b=wgsIrm+Dt+0aF7x6pSkeQk3cr1R1CDrK4HOdCvMe8Ztvz3BQsBExdDQvkAbYp0YS5M
         1WeLasvbKNRq8USaw7PA871dl+JMAi89BTL9TtTj8vgSQkGAefhvuZCPqCpb7DWSB0VE
         vFT5qHhNjBPzElgFVyNyaaCaoLJS8yftMztc+azqXQ7Dnko1VesFvLCwrU95rhpY+imA
         PPRbm9LPhvBufjdQXTjqWxaLgeEwhPEp0zBzBn+pTzwDBxZTbj9pNZUGL8UjvkG+GcAJ
         3nlMxD7yUXj4fAQcS0Im3m5M0L72nxBInrax6LM7N9Ua2/vdrLosWYyQVimqy8NsRUis
         XDcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nGjePryA;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id l80si4736539ywl.337.2019.06.11.16.18.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jun 2019 16:18:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=nGjePryA;
       spf=pass (google.com: domain of prvs=106579ac2e=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=106579ac2e=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x5BN8Ubt022343
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:23 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=nplAGvztvw22AKN56QTMhELHdT1v5h5cxoHCBLrrDqI=;
 b=nGjePryAVos7TNaTWm7Id2mKsFVe++WTr9Nx9tvWflQTJRXzdEZ7izOhgXCWOrU/hMd0
 6nQ0ltd9AFZiFoYBID3dSUrtudltOGCtZ5QcdFLz1SG3Fb3izAuKX7H2AHxa0jysu9Yi
 M8M71Rx5vvpj7yVk3ONEglGL1MVrxKcR5iE= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2t2f4rhk2p-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 11 Jun 2019 16:18:23 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Tue, 11 Jun 2019 16:18:21 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 3ED11130CBF71; Tue, 11 Jun 2019 16:18:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Shakeel Butt
	<shakeelb@google.com>, Waiman Long <longman@redhat.com>,
        Roman Gushchin
	<guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v7 06/10] mm: don't check the dying flag on kmem_cache creation
Date: Tue, 11 Jun 2019 16:18:09 -0700
Message-ID: <20190611231813.3148843-7-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190611231813.3148843-1-guro@fb.com>
References: <20190611231813.3148843-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-11_11:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=777 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906110151
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

There is no point in checking the root_cache->memcg_params.dying
flag on kmem_cache creation path. New allocations shouldn't be
performed using a dead root kmem_cache, so no new memcg kmem_cache
creation can be scheduled after the flag is set. And if it was
scheduled before, flush_memcg_workqueue() will wait for it anyway.

So let's drop this check to simplify the code.

Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 5e7638f495d1..9383104651cd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -640,7 +640,7 @@ void memcg_create_kmem_cache(struct mem_cgroup *memcg,
 	 * The memory cgroup could have been offlined while the cache
 	 * creation work was pending.
 	 */
-	if (memcg->kmem_state != KMEM_ONLINE || root_cache->memcg_params.dying)
+	if (memcg->kmem_state != KMEM_ONLINE)
 		goto out_unlock;
 
 	idx = memcg_cache_id(memcg);
-- 
2.21.0

