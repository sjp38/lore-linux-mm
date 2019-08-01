Return-Path: <SRS0=cJsh=V5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 06E9CC19759
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:35:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A6692080C
	for <linux-mm@archiver.kernel.org>; Thu,  1 Aug 2019 23:35:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="Dj1WtyOk"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A6692080C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E5E8C6B0003; Thu,  1 Aug 2019 19:35:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E0F6C6B0005; Thu,  1 Aug 2019 19:35:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D00276B0006; Thu,  1 Aug 2019 19:35:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f199.google.com (mail-yb1-f199.google.com [209.85.219.199])
	by kanga.kvack.org (Postfix) with ESMTP id B22B86B0003
	for <linux-mm@kvack.org>; Thu,  1 Aug 2019 19:35:24 -0400 (EDT)
Received: by mail-yb1-f199.google.com with SMTP id 63so53312746ybl.12
        for <linux-mm@kvack.org>; Thu, 01 Aug 2019 16:35:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=Un50rz4AkQGnA7qv/Fky6wZ72tOuuQdKmBd33a8bA7c=;
        b=N/xzwfmS3Ek3bwqOgAZgXyiE0p54Tz4cDMN5Rz4TKzIx/fPlC7ZDdPAqJJszQYrnvT
         1pdhQoXm98FS7D7TURrgHIonnv6QtlzSgR3zOBj3v2A3hPbLFqwkk65wdyUVkpusX+5I
         WG9R0sfXmjKUNu67C/8lFOGidPsNyNVEroFvB1b2jfSwRSaIxHeqmoM3zaUEW8cMM7fL
         us8IYoffweAdBnmowDWgnieDd3vE27yDuwjPRdqfIrgzRw8R+hklQZWFxKQfn4svUU7s
         TSvmsoX8GNnVIHXON7jSEi+QrzZZ73IKyM7ORtvh5Ozj+Y9nmbhXO6ZqqENmUSHDL5ms
         cSHg==
X-Gm-Message-State: APjAAAUPpzvxNei53Yo4AjKrg8M8lE2+UmaL9hL2eXVIHGz/tawA70ic
	5EVsUeiuTb/4pcTVGzBCIw6Pfg98Xk2uO8d+B9Wcs2lfaVFLxRWzZCwZs8oPDCUvEHKs3sW8zxt
	X9KuFV8guCEGnXFL3Mi2c/ScgmFa5slfPXxXO/2euPlrPH87ycR4/rkzv70+2nb5/VA==
X-Received: by 2002:a5b:f4d:: with SMTP id y13mr36781649ybr.88.1564702524420;
        Thu, 01 Aug 2019 16:35:24 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyvrDNC5cQUNBPs+ds7iL/mgKdFhpzaQYJa3tRaZOJyh8yNUUlUGOmtv8aXq+xjXAUcXWCm
X-Received: by 2002:a5b:f4d:: with SMTP id y13mr36781621ybr.88.1564702523686;
        Thu, 01 Aug 2019 16:35:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564702523; cv=none;
        d=google.com; s=arc-20160816;
        b=OzbajwE9Z/p2V8WC2MXJbXbFbkNFZTZEIdSuAeEhPEHEhWfmcic1Lw6Tq7MDdDonOP
         IrCM2L6p8xj1wWOSxW1D14CrfmiOEYNgCEEdX7xQYX1m7xc1FJoCb/GpIsN8HdQQqQqc
         84HCwsqWCcpaWU/jNrS4fOuX0lc3w+X+9jhC878+otujfTx2YPdLUqmYO5/EZJmGd7CZ
         xamQag0b8xl87D47JkHSb0w91+a2wD11Dz/K1otAxPMOc1oibVOZSBr8u3VLoKn73Or9
         M5Lmb3WGSgy96SJbhmusccmpSeZlQ1TlpheK/ArDw/6Py2QVpv1he6jiqACFB2mTtpOB
         RZ/A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=Un50rz4AkQGnA7qv/Fky6wZ72tOuuQdKmBd33a8bA7c=;
        b=tfDGAeop+wgSjAMiqU0zaHp3dFwfk0QYyGXyyof5jFcXY0cwiHadpUNhGf2XMVviNv
         hzV864xsqn9zOxYzxsCeJM3ZU+kiBnEoBk3zTYbc4c7NQyFTkkjX7rEvR0wyjyHMdzcK
         vSUSzEi1Qn9GwP8Oc4bv7j3GCTRyJGfoZose0eqkPKtZhKRnwKNfo4vbtz69No9WZ1b3
         p1k2m43pfOy5xmnnAf9TptzBjpyThgnPcbKXeNp8YqtXCWV/kR1Pr0rx+Xk8dACNdzct
         IXqTO7opuSDts1jJmuYb38yoeuwv9VH7EuDaN4kbWCBjWidIyRaxTbVJ699TE2KdzEnC
         ajUg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Dj1WtyOk;
       spf=pass (google.com: domain of prvs=3116998605=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116998605=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id d143si23922206ywb.8.2019.08.01.16.35.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Aug 2019 16:35:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=3116998605=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=Dj1WtyOk;
       spf=pass (google.com: domain of prvs=3116998605=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=3116998605=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x71NXJSG030876
	for <linux-mm@kvack.org>; Thu, 1 Aug 2019 16:35:23 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=Un50rz4AkQGnA7qv/Fky6wZ72tOuuQdKmBd33a8bA7c=;
 b=Dj1WtyOkKewSBRltnFIVr4Xl03LbBk/9NrPgJhZC84w5hAWOS47b6oC6fWUmMZdIBz4Y
 4Sex11UKGuFT1FLzWg1XWwRP2EcUPVKk8jcxr48bNXJjRe+/exFOa1Fl0GdNK4SRGCub
 eLhYUH9xudJ+KgsXMS1Iq+OXc4OcWeXwg6Q= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u435b9kwg-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Aug 2019 16:35:23 -0700
Received: from ash-exhub202.TheFacebook.com (2620:10d:c0a8:83::6) by
 ash-exhub104.TheFacebook.com (2620:10d:c0a8:82::d) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 16:35:22 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:83::6) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Thu, 1 Aug 2019 16:35:22 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 568F01528F176; Thu,  1 Aug 2019 16:35:20 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>, Michal Hocko <mhocko@suse.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH] mm: memcontrol: switch to rcu protection in drain_all_stock()
Date: Thu, 1 Aug 2019 16:35:13 -0700
Message-ID: <20190801233513.137917-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-01_10:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=715 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908010250
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Commit 72f0184c8a00 ("mm, memcg: remove hotplug locking from try_charge")
introduced css_tryget()/css_put() calls in drain_all_stock(),
which are supposed to protect the target memory cgroup from being
released during the mem_cgroup_is_descendant() call.

However, it's not completely safe. In theory, memcg can go away
between reading stock->cached pointer and calling css_tryget().

So, let's read the stock->cached pointer and evaluate the memory
cgroup inside a rcu read section, and get rid of
css_tryget()/css_put() calls.

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
---
 mm/memcontrol.c | 17 +++++++++--------
 1 file changed, 9 insertions(+), 8 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 5c7b9facb0eb..d856b64426b7 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2235,21 +2235,22 @@ static void drain_all_stock(struct mem_cgroup *root_memcg)
 	for_each_online_cpu(cpu) {
 		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
 		struct mem_cgroup *memcg;
+		bool flush = false;
 
+		rcu_read_lock();
 		memcg = stock->cached;
-		if (!memcg || !stock->nr_pages || !css_tryget(&memcg->css))
-			continue;
-		if (!mem_cgroup_is_descendant(memcg, root_memcg)) {
-			css_put(&memcg->css);
-			continue;
-		}
-		if (!test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
+		if (memcg && stock->nr_pages &&
+		    mem_cgroup_is_descendant(memcg, root_memcg))
+			flush = true;
+		rcu_read_unlock();
+
+		if (flush &&
+		    !test_and_set_bit(FLUSHING_CACHED_CHARGE, &stock->flags)) {
 			if (cpu == curcpu)
 				drain_local_stock(&stock->work);
 			else
 				schedule_work_on(cpu, &stock->work);
 		}
-		css_put(&memcg->css);
 	}
 	put_cpu();
 	mutex_unlock(&percpu_charge_mutex);
-- 
2.21.0

