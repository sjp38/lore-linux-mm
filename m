Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82DF4C48BE9
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:43:38 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4570C20665
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 17:43:38 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4570C20665
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E1FCD6B0006; Mon, 24 Jun 2019 13:43:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD09E8E0003; Mon, 24 Jun 2019 13:43:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CBF3F8E0002; Mon, 24 Jun 2019 13:43:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id ABE656B0006
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 13:43:37 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id v58so17890007qta.2
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:43:37 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=elA606R+IaCLXLd8PRvcbOhh3L8eYi5ke0P4RLCssjE=;
        b=OI8eNXW5M6NiiQY/1yMZiEQ6MMzAB/JHi9DlxAqWiHRyhqhTlcQ9B58RXQ81pTYHnY
         /E5nT8IRKu2JaiXQKXOsDiRLabu4SolpUxbGIAZOHAEnCBvqtD7/uGuPc8po2fteHwKs
         mIXLMyJoWWIGIaWC3u1xAV5YWbO/Dy3pktCOWFFlY/d7Hki0vV5B2gRdpm1GoK4q/2x0
         gg0UsiINWidmAVAKFQqC7uVyhitGLDjOjUy/7af6nEJdy+nhssRyuPQ6WnYUccdXsxGJ
         gb8obfmL1aZkQryYY8p4AMUz2LX3Zbfm5kBeKGYJLRB9lZrAnFczjUh3memMvt7RhGk1
         b2Ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXUTsB9CkEdabSkmZXE0N9JzBrzM985YkY02ihyfRxpXhTX3eKg
	Thb5Bvy22lNvPkZQc6I528p1AfCfx0W6vtl+laDCOTBkTKgT4z3Mhk7ZkRSHbf41/QDYWuIR3Qd
	SFZwWgxdHsDhDEm74ZKC4gAPSIee+C59/JA8dcxEVTskgCyHgCpXGxZDAqqepCnpHDw==
X-Received: by 2002:aed:2e64:: with SMTP id j91mr112788865qtd.318.1561398217450;
        Mon, 24 Jun 2019 10:43:37 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwNDJWDtGq0Xa6Yb1xQ4RWeNGuvza8HZcY/sRHiRwKX7Y65mOhk1ePuq8SrGCg2ms28whfH
X-Received: by 2002:aed:2e64:: with SMTP id j91mr112788826qtd.318.1561398216571;
        Mon, 24 Jun 2019 10:43:36 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561398216; cv=none;
        d=google.com; s=arc-20160816;
        b=oFvTilLu3xD5I7agIduyOXwA3DIrKB4RsdeqRINrRtFiVNwa+/yDnTleUVVBXSyq9S
         ptCnco2IpP6LNZq8pF7NQJvUmC8Z3hPNlWfYCKh7hibYCE3ZITkjxdmQ+BNp5tTqojMb
         U6yB+ds7VoBFJeVxZi+muimT6TJEKjJunFvYvYmuLH2GVaaQnBJnPPG11WOChlAhSduA
         yKoSC5zHb+NpA1YRE8U2zYKBtTMMWTdFbgS6oQ3VLrdAo8dGELcvpBeNPK1omWdKOqBx
         y+JqBBSOSK0UKo7u5eeq7Zfdv6rbdHcS5mS67NNjhJ8dCSJJ7I+A7whGGQi1e5KyoHV9
         yzPQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=elA606R+IaCLXLd8PRvcbOhh3L8eYi5ke0P4RLCssjE=;
        b=CDZF+zvRZGC71J2CcLT7K/XB3Py2/A4+G2ZN2k6R6yOpB1TZkxVGS6y5jEKNhLX4PU
         AiDHhW6nlcBhsnA1aEFBK1FjJnHTzI0LxeN/mgG9QIMR550hOrI0ZHAHG50Jtkzupa2o
         zxTDcth0zU6zwqeHYa9v/jzZ4m50y/1cmEpYv0hM06cctrZdwu3fCP7IAe++LD9RuhGm
         TJs1THGC3FNe39rdnRPSmLuqdoYyxGvAbW29P6M79zl4kw09urAoRPgKZ6lVsOFum4f8
         7MfTR68U2eg761bk388u3I+RfwV1SQBzAvsRVEKKYiXbEhFOY/8bMFyD7KbSpOab+SeV
         403A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id h28si5452158qkl.149.2019.06.24.10.43.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Jun 2019 10:43:36 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id DB640C058CBD;
	Mon, 24 Jun 2019 17:43:17 +0000 (UTC)
Received: from llong.com (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 13DF95D9D3;
	Mon, 24 Jun 2019 17:43:14 +0000 (UTC)
From: Waiman Long <longman@redhat.com>
To: Christoph Lameter <cl@linux.com>,
	Pekka Enberg <penberg@kernel.org>,
	David Rientjes <rientjes@google.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jonathan Corbet <corbet@lwn.net>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@kernel.org>,
	Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: linux-mm@kvack.org,
	linux-doc@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Roman Gushchin <guro@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Andrea Arcangeli <aarcange@redhat.com>,
	Waiman Long <longman@redhat.com>
Subject: [PATCH 1/2] mm, memcontrol: Add memcg_iterate_all()
Date: Mon, 24 Jun 2019 13:42:18 -0400
Message-Id: <20190624174219.25513-2-longman@redhat.com>
In-Reply-To: <20190624174219.25513-1-longman@redhat.com>
References: <20190624174219.25513-1-longman@redhat.com>
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.14
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.32]); Mon, 24 Jun 2019 17:43:35 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Add a memcg_iterate_all() function for iterating all the available
memory cgroups and call the given callback function for each of the
memory cgruops.

Signed-off-by: Waiman Long <longman@redhat.com>
---
 include/linux/memcontrol.h |  3 +++
 mm/memcontrol.c            | 13 +++++++++++++
 2 files changed, 16 insertions(+)

diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 1dcb763bb610..0e31418e5a47 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -1268,6 +1268,9 @@ static inline bool mem_cgroup_under_socket_pressure(struct mem_cgroup *memcg)
 struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep);
 void memcg_kmem_put_cache(struct kmem_cache *cachep);
 
+extern void memcg_iterate_all(void (*callback)(struct mem_cgroup *memcg,
+					       void *arg), void *arg);
+
 #ifdef CONFIG_MEMCG_KMEM
 int __memcg_kmem_charge(struct page *page, gfp_t gfp, int order);
 void __memcg_kmem_uncharge(struct page *page, int order);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ba9138a4a1de..c1c4706f7696 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -443,6 +443,19 @@ static int memcg_alloc_shrinker_maps(struct mem_cgroup *memcg)
 static void memcg_free_shrinker_maps(struct mem_cgroup *memcg) { }
 #endif /* CONFIG_MEMCG_KMEM */
 
+/*
+ * Iterate all the memory cgroups and call the given callback function
+ * for each of the memory cgroups.
+ */
+void memcg_iterate_all(void (*callback)(struct mem_cgroup *memcg, void *arg),
+		       void *arg)
+{
+	struct mem_cgroup *memcg;
+
+	for_each_mem_cgroup(memcg)
+		callback(memcg, arg);
+}
+
 /**
  * mem_cgroup_css_from_page - css of the memcg associated with a page
  * @page: page of interest
-- 
2.18.1

