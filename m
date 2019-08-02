Return-Path: <SRS0=eSYi=V6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C418C32750
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:22:55 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EE6392086A
	for <linux-mm@archiver.kernel.org>; Fri,  2 Aug 2019 19:22:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="dj10JLqr"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EE6392086A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7D7F36B0003; Fri,  2 Aug 2019 15:22:54 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 788406B0005; Fri,  2 Aug 2019 15:22:54 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5DB876B0007; Fri,  2 Aug 2019 15:22:54 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 252116B0003
	for <linux-mm@kvack.org>; Fri,  2 Aug 2019 15:22:54 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id m17so39100512pgh.21
        for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:22:54 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=19Ja20qRJPcfJ8p53GQiWI0ZYQb3kQ8wKj9C14D15zo=;
        b=FBqYBHlfJa/dVkeR+Ud7QMTXf7nSV5eAhEHiLmXWo0MAQ1zjTclVSuHKFPztFBa4ou
         YH9SXl8wBTzOBJFHPjc2GqdMuBv1+gnAJNfmR/JOM94k91jLj1rRBnt/m+w4MpLa87ub
         hA7BLyEGLunTMr6Zvs17+f/DVcZ+Qw8KUWSyRYQHtQgwOPrm1CE6OxuSJacNLYuBhRNh
         LkUGc3ZdDKqmJxGNp44NRmu9DoddpHe2Qj17gsOMYt/q4/zVxrUJB/VJF07LO6EttnBH
         JgzedPNPu3b6yiiYywzcMl/U6lCqJ17Uc3baVsv7nkb73dQlLhBVYSpOlV9cxMxTJMTa
         7b0w==
X-Gm-Message-State: APjAAAU7RPgXfp/bil0ERQ51hQFjHldTPt2Ko8Joccax280cqLtkGY5O
	Z2gWe6HjxqN9T8Cl9xZXlD8FwUTZSEaKLDwLHFME87EAWHGZ28zENirfGlcJM6jkY91Zbhk/sUh
	JhKAKxPTGDH1r59qcBRfDAhCV33wDGRalxjhpUnLVX+HQ166ZkDBSE7rwqOhEeLuCvQ==
X-Received: by 2002:a17:90a:f98a:: with SMTP id cq10mr5819273pjb.43.1564773773825;
        Fri, 02 Aug 2019 12:22:53 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwRJw46RbN3iZEyGFXHk7IQ3SIzt4lrqFTxV9BMtZy0kDa8yUtDD/QCeL9BpOiVG+/K39ms
X-Received: by 2002:a17:90a:f98a:: with SMTP id cq10mr5819231pjb.43.1564773773049;
        Fri, 02 Aug 2019 12:22:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564773773; cv=none;
        d=google.com; s=arc-20160816;
        b=VT+oZw2bZm9zN4nJyAupDJIO3mJSt6vYgpj0MNuufU8oh5gH/iVu5Z6f/o2KfwwTeZ
         Q5u4ywRb6LtgfurTnT3ky1AkJ43Vn/Vyvii4svKH9kes6vSl8yB+st2Sn4tlILdBVy8/
         4hQMLS29qPEFKvS8Sx2r9lac2YKZ0U/r7o+FbycM105dQlpgkaOu/f+kyXk1uRQM1ThI
         Pj9eAWcHCo+Z+sBvHGKOTEEv2cgKi4f3VQRWjUju3Vdlv/WQTHVOclLbDE0GZPAI5Ndw
         GebJWtlc70P+ZVvHcIhBzHE6X+EyFyvU/gaU9g5RgWw94IcSUnwYh+7QNBkmaW4nE8Ee
         9x7Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=19Ja20qRJPcfJ8p53GQiWI0ZYQb3kQ8wKj9C14D15zo=;
        b=QvC6vCRAMW6GvFjK2grGzi44AAAhqGpTnyQQZuf/x2Z0hXR6Jo249CY5k0DDsVMjiR
         x1vABlmdBqBKclmZAC9NrioeXRKeurD7t5E/UuSVzIe/zkqJ5dNDHIOuo+DVScsKIR+D
         HvE7sCEY8iO3CuIC3BSj5KezyFWDqm4LXunE4P9k8jJzea9ILNK2/CUEHavD5ydK4t3n
         ERAlh/V57VPZazSaeBeOLf9osMTN4uNbTvjNIvi4KZW6iOg/DiOzQns2Lg4Aczo5RyME
         g0aMLPA8Gkn88S4cZEM5PW55BiiMUoZeKOK9sqipt3cDBwlUaUOplcnG4iGvVi2BRQpE
         aa3Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dj10JLqr;
       spf=pass (google.com: domain of prvs=31176506d8=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31176506d8=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id k13si38043093pgj.525.2019.08.02.12.22.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Aug 2019 12:22:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=31176506d8=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=dj10JLqr;
       spf=pass (google.com: domain of prvs=31176506d8=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=31176506d8=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044012.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x72JJqFj022956
	for <linux-mm@kvack.org>; Fri, 2 Aug 2019 12:22:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=19Ja20qRJPcfJ8p53GQiWI0ZYQb3kQ8wKj9C14D15zo=;
 b=dj10JLqr4TfBGwCeyDo/3BMpKggBGMOPO+uvDx1zGiGrxvKvORY5RcF/eebwabL4khdX
 KUGZg43cUkrqp0VajwiIkwPNtKUFyyRNgJ9kfnis1SdSSRq4mUVLf09M9lo8sKdw0CIB
 019IhIbD7iDU9LacYmcloNto77/2U8Abrdo= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2u4s2tgj9n-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Aug 2019 12:22:52 -0700
Received: from mx-out.facebook.com (2620:10d:c081:10::13) by
 mail.thefacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA) id 15.1.1713.5;
 Fri, 2 Aug 2019 12:22:51 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id 6989B153186A0; Fri,  2 Aug 2019 12:22:47 -0700 (PDT)
Smtp-Origin-Hostprefix: devvm
From: Roman Gushchin <guro@fb.com>
Smtp-Origin-Hostname: devvm2643.prn2.facebook.com
To: Andrew Morton <akpm@linux-foundation.org>, <linux-mm@kvack.org>
CC: Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>,
        Roman Gushchin
	<guro@fb.com>, Michal Hocko <mhocko@suse.com>,
        Hillf Danton
	<hdanton@sina.com>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH v2] mm: memcontrol: switch to rcu protection in drain_all_stock()
Date: Fri, 2 Aug 2019 12:22:41 -0700
Message-ID: <20190802192241.3253165-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-08-02_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=912 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1908020203
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

This can happen if drain_all_stock() races with drain_local_stock()
performed on the remote cpu as a result of a work, scheduled
by the previous invocation of drain_all_stock().

The race is a bit theoretical and there are few chances to trigger
it, but the current code looks a bit confusing, so it makes sense
to fix it anyway. The code looks like as if css_tryget() and
css_put() are used to protect stocks drainage. It's not necessary
because stocked pages are holding references to the cached cgroup.
And it obviously won't work for works, scheduled on other cpus.

So, let's read the stock->cached pointer and evaluate the memory
cgroup inside a rcu read section, and get rid of
css_tryget()/css_put() calls.

v2: added some explanations to the commit message, no code changes

Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Hillf Danton <hdanton@sina.com>
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

