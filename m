Return-Path: <SRS0=OmxZ=TI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_HIGH,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A771C04A6B
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:41:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BBA2620850
	for <linux-mm@archiver.kernel.org>; Wed,  8 May 2019 20:40:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="q0QmNMek"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BBA2620850
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B0686B000C; Wed,  8 May 2019 16:40:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37B336B0010; Wed,  8 May 2019 16:40:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F0C266B000D; Wed,  8 May 2019 16:40:53 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id A5E386B000C
	for <linux-mm@kvack.org>; Wed,  8 May 2019 16:40:53 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id a97so86089pla.9
        for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:53 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:in-reply-to:references:mime-version;
        bh=M3mL2Ve/kfONZivBQEHTZBNx9Zf4Go/ST+iIz38LOH4=;
        b=qWD+GngjRb0s2S3T3yzNayWd+5iBer9EMNC5+fFFRRtjuqToKAmJ1l+nYu6gKvD+R6
         osoPzidW/ijhCEhcvKSOWiWOzNTe2LhkEv76byK0I5Jib1q82eNPeXnraFwcshVjY+BS
         29WGGwl/CNUtRpInzTFMay8WOw6B3ROAZTHcWxYzyIhH+/uEErn6KXKeUzCBs1JMU+uA
         tc4k1QGnadFBuxpmwgyCKY1wdDB5nABZXrVAvPlUTOtKdbZ2dbncLudYR3vqRsMKMkoJ
         unmlZjdcmd6s6Ph7j8ZvMp7BFMxXxod1MgasPtHV3Id2KPuOnSGpAvbg3MiyLrrefOvf
         9Tug==
X-Gm-Message-State: APjAAAUgy2znQvrRKDnWBaZya9k/tmr3JRDKiVjvDKLtEfd6XmSYzCl5
	Dq/8RpRhfsh7upmcWRBRg3KobCkC5rjdYXqBHjPEeCyHigbFhMGPsxM1ZnoXActADuBvU0qR1jn
	zpr4euijkqXUf4KW64ayNihJWopNa+My6ynvYSjjAY5l4ExVenQmsqRomOVPrHyclPw==
X-Received: by 2002:a17:902:364:: with SMTP id 91mr49277203pld.72.1557348053319;
        Wed, 08 May 2019 13:40:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzodJJczLtqFpiV6Fiy/uSkm8cA7m83+SIsNTp2Aod350w1P9TinySZcVTBR/7wd0qLO6sz
X-Received: by 2002:a17:902:364:: with SMTP id 91mr49277136pld.72.1557348052530;
        Wed, 08 May 2019 13:40:52 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557348052; cv=none;
        d=google.com; s=arc-20160816;
        b=lwlIxw0awEMy/OzSRsapV8pgO1vIdk9RmqdNPn6moEI0MIVviyMzg8qandMemrfP4q
         lXP9ln3o6hOQ5vcMJcotZPc57qEaNUjPyAVoarUKNRiT0Xw4J+lwAxUEN6oVRAhKyOqh
         HLmRATX9UFhHEB48LW2luvOCrPefIg+duieEcbVGyPUziRWWE+0YwYOpVI+5Dv15ycef
         S0BqVFYfbR4SgYL179Zpp4Q6UwAU346AuBg/yfLxLW0zR4KN7kOOhkJK4/O69ppL/CaK
         qKDjf1YcypL/O4uuXXxwUzCms4rUSLoE5y4onMLiMrZvSRiskQCwKXgUW/hB+PsuPKZD
         jk6A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:in-reply-to:message-id:date:subject
         :smtp-origin-cluster:cc:to:smtp-origin-hostname:from
         :smtp-origin-hostprefix:dkim-signature;
        bh=M3mL2Ve/kfONZivBQEHTZBNx9Zf4Go/ST+iIz38LOH4=;
        b=NhZwxLwDGKA8b8VUQMfDrGQsvGUrN0O9pQ1+Ullwh5UJR2Tb70uxeFjcZBZOfnSyJB
         faMCDJGym4a6DFWW9JYCBYY5S65kEe5Y522JlmQzePf1BB063RnhXJKGUlSQTIMq1zfo
         Dc835iUJMPlwGl9XEXzdM1pwvN8gmnyYjnEfX7ThL0nysEqglzNCvX3QEg11uLHARhmu
         zY2VDGCbURw42G2HW3pBbnhbpVrzTladJbuaV8j3iWWxsr72QCAT93z/3e0CHcrwAoek
         7QRyHVA+R0YAhgIPWHt0lsX00OrdaVkxssCDgU7JP3LkDAacw7jjYp0vudSfABgsKFdi
         m93Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=q0QmNMek;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id q86si24499985pfi.197.2019.05.08.13.40.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 May 2019 13:40:52 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=q0QmNMek;
       spf=pass (google.com: domain of prvs=0031b2e447=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=0031b2e447=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x48KeVEC023320
	for <linux-mm@kvack.org>; Wed, 8 May 2019 13:40:51 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : in-reply-to : references : mime-version :
 content-type; s=facebook; bh=M3mL2Ve/kfONZivBQEHTZBNx9Zf4Go/ST+iIz38LOH4=;
 b=q0QmNMek/9n6tqCcO+epeVgDd/whCZ15XILswuvC6FgxcQiz5zBckYB/zurQXID5IzkE
 6nefIA2S9VUCRGzEvo6CoNnm+BUX7E68nCmIaJgU2t++Rh5c1W4xCo4nS/Bkik1Mwkdl
 t8cmZt8JtbJ2IBe6Eq+/C7ytksYoclIyOiA= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2sc0p91d9f-10
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 May 2019 13:40:51 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Wed, 8 May 2019 13:40:48 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 1CDB811CDBD04; Wed,  8 May 2019 13:25:00 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>,
        Shakeel Butt
	<shakeelb@google.com>
CC: <linux-mm@kvack.org>, <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Johannes Weiner <hannes@cmpxchg.org>,
        Michal Hocko
	<mhocko@kernel.org>, Rik van Riel <riel@surriel.com>,
        Christoph Lameter
	<cl@linux.com>,
        Vladimir Davydov <vdavydov.dev@gmail.com>, <cgroups@vger.kernel.org>,
        Roman Gushchin <guro@fb.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v3 7/7] mm: fix /proc/kpagecgroup interface for slab pages
Date: Wed, 8 May 2019 13:24:58 -0700
Message-ID: <20190508202458.550808-8-guro@fb.com>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20190508202458.550808-1-guro@fb.com>
References: <20190508202458.550808-1-guro@fb.com>
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-08_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Switching to an indirect scheme of getting mem_cgroup pointer for
!root slab pages broke /proc/kpagecgroup interface for them.

Let's fix it by learning page_cgroup_ino() how to get memcg
pointer for slab pages.

Reported-by: Shakeel Butt <shakeelb@google.com>
Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/memcontrol.c  |  5 ++++-
 mm/slab.h        | 21 +++++++++++++++++++++
 mm/slab_common.c |  1 +
 3 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 6e4d9ed16069..8114838759f6 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -494,7 +494,10 @@ ino_t page_cgroup_ino(struct page *page)
 	unsigned long ino = 0;
 
 	rcu_read_lock();
-	memcg = READ_ONCE(page->mem_cgroup);
+	if (PageSlab(page))
+		memcg = memcg_from_slab_page(page);
+	else
+		memcg = READ_ONCE(page->mem_cgroup);
 	while (memcg && !(memcg->css.flags & CSS_ONLINE))
 		memcg = parent_mem_cgroup(memcg);
 	if (memcg)
diff --git a/mm/slab.h b/mm/slab.h
index acdc1810639d..cb684fbe2cc2 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -256,6 +256,22 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s->memcg_params.root_cache;
 }
 
+static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
+{
+	struct kmem_cache *s;
+
+	WARN_ON_ONCE(!rcu_read_lock_held());
+
+	if (PageTail(page))
+		page = compound_head(page);
+
+	s = READ_ONCE(page->slab_cache);
+	if (s && !is_root_cache(s))
+		return rcu_dereference(s->memcg_params.memcg);
+
+	return NULL;
+}
+
 static __always_inline int memcg_charge_slab(struct page *page,
 					     gfp_t gfp, int order,
 					     struct kmem_cache *s)
@@ -338,6 +354,11 @@ static inline struct kmem_cache *memcg_root_cache(struct kmem_cache *s)
 	return s;
 }
 
+static inline struct mem_cgroup *memcg_from_slab_page(struct page *page)
+{
+	return NULL;
+}
+
 static inline int memcg_charge_slab(struct page *page, gfp_t gfp, int order,
 				    struct kmem_cache *s)
 {
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 36673a43ed31..0cfdad0a0aac 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -253,6 +253,7 @@ static void memcg_unlink_cache(struct kmem_cache *s)
 		list_del(&s->memcg_params.kmem_caches_node);
 		mem_cgroup_put(rcu_dereference_protected(s->memcg_params.memcg,
 			lockdep_is_held(&slab_mutex)));
+		rcu_assign_pointer(s->memcg_params.memcg, NULL);
 	}
 }
 #else
-- 
2.20.1

