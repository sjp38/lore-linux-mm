Return-Path: <SRS0=424v=UT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6FA6AC43613
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:57:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0E6F92147A
	for <linux-mm@archiver.kernel.org>; Thu, 20 Jun 2019 01:57:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="AL0NzN6l"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0E6F92147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8496F6B0003; Wed, 19 Jun 2019 21:57:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7FA4E8E0002; Wed, 19 Jun 2019 21:57:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6E9208E0001; Wed, 19 Jun 2019 21:57:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4EFCD6B0003
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 21:57:20 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id l62so1396745ywb.21
        for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:57:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:smtp-origin-hostprefix:from
         :smtp-origin-hostname:to:cc:smtp-origin-cluster:subject:date
         :message-id:mime-version;
        bh=+/SdHB7KTGzamIbn5TjrBtcRS6GmTWgvRz7EXzPcbm0=;
        b=Z9qcAi2hMGTzyiLebnIcO6FCDDe4pqeuJOOERSTBqn7HvPG0YE01mkT9Lzf692F8xw
         LrUHZprWST7psLHJ5T+KzzKNdfYFp2dId9z/bEMPG2uMZsWeMupGc3FU8kh2xVrxioiv
         GPI6aV1zpAvjErHdBR/lrN3Dmn5bWMA1iupA5WIYfMS0QjwGywnuRHsiKDhi2w4YOVJ8
         Tlv26HCkiPXUpEj5ZnOx9Ryu2SPsgtOlEohCOM9T3XewfGxFVR91aXaXR/blo53rBP/U
         XQRs8wXuzC3VFAqRT0vqQRja5vK7/c7R/SEG/qhdDZlGZ5L6c0CaVp11gWGipg6hPFBI
         gXBA==
X-Gm-Message-State: APjAAAXAQUw7C3mL5D7ARVa6LchUo33mWE5uLZK2NmKsYgMNuoA7TIl9
	WcUeQ2VOoQ6N8P6TQ6BwFaLi0WzoWJrXUFBzOQTGAFXnMp09Rdzer7danIR2xgrceYYbWUdQhNr
	sDi/ScXz5LruIjma5KhiCFy9bmOeF0oVM1H5WUKFgo9g0zZYBfGVUIiUhFlPiiTYIyg==
X-Received: by 2002:a81:3c56:: with SMTP id j83mr8636276ywa.141.1560995839986;
        Wed, 19 Jun 2019 18:57:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqw1GzM6IMOHWNjOmB9g4/aYZXuqZjZyzT5PTFNDFSVYH8sAOC4EYfjhFhqHdMUEmHaPezOx
X-Received: by 2002:a81:3c56:: with SMTP id j83mr8636253ywa.141.1560995839181;
        Wed, 19 Jun 2019 18:57:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560995839; cv=none;
        d=google.com; s=arc-20160816;
        b=mEglTTl+NicL8wOeA9VvvXJpngDEBbYKiPpNCCKwDe7/PZhLGeYVKxv9zj/yNg4Oq/
         qYq1D9U5iMNc4nmnHEMikUyQW723/ztW0GlNgTvmazBBnMBusmiqTpO6JO486uqd901v
         Y+P/upXy8bhDB2fySs9AWV5IAGUHnAteJz2N9W1HiT6XcYNkrSH5qAUR239f+UmeF+aO
         eQ/B5A/7gl3tbwXPnJdERfpz64tpwpOXVGw7z0GUMdKyCNHX+324OzbMkV0ZkO+uUE/6
         8azIS3H0oY9/SM603hen2yV8EqZkkBh9ezOJEtyYQHjs1dE2UwKgpBgdS/z1/cKUkfmC
         BfEA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:message-id:date:subject:smtp-origin-cluster:cc:to
         :smtp-origin-hostname:from:smtp-origin-hostprefix:dkim-signature;
        bh=+/SdHB7KTGzamIbn5TjrBtcRS6GmTWgvRz7EXzPcbm0=;
        b=KCQEh5ROjYnYRU30od9zkBLtoWueS8D0p5uKG373lfczdVYKbk1zvLtHyQzJGeK6ii
         S+4Y7vbFKbUh8oGp/BbnHo3lOMSr0vEfw9LZldRJjVnXoiXUxxvBeV7sHt++IHXKcAjn
         MkWfH9YNX9/Po+s81TxYWVEEMoAPfuxAEcu0bCTKvRLKljnCaJ5LG4rPsijtbROId80H
         NX3Vn8HUxF+adRiXnGo0lQavmVXnVQinm0eG+AUMpXaZ1USNSRwfqgoOHJ7Xtk3yNs2P
         257Yz5lkCJ+FmIQfnZYpfIjfWe4fGrc++G4Bf1m23lYqijft+es3Ld3/KyyAFL8aSgfS
         RgyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AL0NzN6l;
       spf=pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1074ecebd6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id c69si6856247ybh.408.2019.06.19.18.57.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Jun 2019 18:57:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=AL0NzN6l;
       spf=pass (google.com: domain of prvs=1074ecebd6=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1074ecebd6=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x5K1qG3g022277
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:57:18 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : mime-version : content-type; s=facebook;
 bh=+/SdHB7KTGzamIbn5TjrBtcRS6GmTWgvRz7EXzPcbm0=;
 b=AL0NzN6lFUaLYFwZsib0dZUzudUEPHs6p6TfVeSGxQpo1dWWgqbpX+z3nVRkdol3t/Li
 Yem476XAjsR34HJkpgrTXkYhniZzqapKfM14FBwk7bHyVjttxNRREvw7QpvXAFuxKppG
 E86SPMLgCo5OIf1FJV9hxoh4wE4vWsjQ3yo= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by m0001303.ppops.net with ESMTP id 2t7rtd9qd5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 19 Jun 2019 18:57:18 -0700
Received: from mx-out.facebook.com (2620:10d:c0a8:1b::d) by
 mail.thefacebook.com (2620:10d:c0a8:82::f) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Wed, 19 Jun 2019 18:57:17 -0700
Received: by devvm2643.prn2.facebook.com (Postfix, from userid 111017)
	id A3B86136DAADA; Wed, 19 Jun 2019 18:55:56 -0700 (PDT)
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
	<guro@fb.com>, Christoph Lameter <cl@linux.com>,
        Michal Hocko
	<mhocko@suse.com>, David Rientjes <rientjes@google.com>,
        Joonsoo Kim
	<iamjoonsoo.kim@lge.com>,
        Pekka Enberg <penberg@kernel.org>
Smtp-Origin-Cluster: prn2c23
Subject: [PATCH] mm: memcg/slab: properly handle kmem_caches reparented to root_mem_cgroup
Date: Wed, 19 Jun 2019 18:55:54 -0700
Message-ID: <20190620015554.1888119-1-guro@fb.com>
X-Mailer: git-send-email 2.17.1
X-FB-Internal: Safe
MIME-Version: 1.0
Content-Type: text/plain
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-20_01:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906200013
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

As a result of reparenting a kmem_cache might belong to the root
memory cgroup. It happens when a top-level memory cgroup is removed,
and all associated kmem_caches are reparented to the root memory
cgroup.

The root memory cgroup is special, and requires a special handling.
Let's make sure that we don't try to charge or uncharge it,
and we handle system-wide vmstats exactly as for root kmem_caches.

Note, that we still need to alter the kmem_cache reference counter,
so that the kmem_cache can be released properly.

The issue was discovered by running CRIU tests; the following warning
did appear:

[  381.345960] WARNING: CPU: 0 PID: 11655 at mm/page_counter.c:62
page_counter_cancel+0x26/0x30
[  381.345992] Modules linked in:
[  381.345998] CPU: 0 PID: 11655 Comm: kworker/0:8 Not tainted
5.2.0-rc5-next-20190618+ #1
[  381.346001] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[  381.346010] Workqueue: memcg_kmem_cache kmemcg_workfn
[  381.346013] RIP: 0010:page_counter_cancel+0x26/0x30
[  381.346017] Code: 1f 44 00 00 0f 1f 44 00 00 48 89 f0 53 48 f7 d8
f0 48 0f c1 07 48 29 f0 48 89 c3 48 89 c6 e8 61 ff ff ff 48 85 db 78
02 5b c3 <0f> 0b 5b c3 66 0f 1f 44 00 00 0f 1f 44 00 00 48 85 ff 74 41
41 55
[  381.346019] RSP: 0018:ffffb3b34319f990 EFLAGS: 00010086
[  381.346022] RAX: fffffffffffffffc RBX: fffffffffffffffc RCX: 0000000000000004
[  381.346024] RDX: 0000000000000000 RSI: fffffffffffffffc RDI: ffff9c2cd7165270
[  381.346026] RBP: 0000000000000004 R08: 0000000000000000 R09: 0000000000000001
[  381.346028] R10: 00000000000000c8 R11: ffff9c2cd684e660 R12: 00000000fffffffc
[  381.346030] R13: 0000000000000002 R14: 0000000000000006 R15: ffff9c2c8ce1f200
[  381.346033] FS:  0000000000000000(0000) GS:ffff9c2cd8200000(0000)
knlGS:0000000000000000
[  381.346039] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  381.346041] CR2: 00000000007be000 CR3: 00000001cdbfc005 CR4: 00000000001606f0
[  381.346043] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  381.346045] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
[  381.346047] Call Trace:
[  381.346054]  page_counter_uncharge+0x1d/0x30
[  381.346065]  __memcg_kmem_uncharge_memcg+0x39/0x60
[  381.346071]  __free_slab+0x34c/0x460
[  381.346079]  deactivate_slab.isra.80+0x57d/0x6d0
[  381.346088]  ? add_lock_to_list.isra.36+0x9c/0xf0
[  381.346095]  ? __lock_acquire+0x252/0x1410
[  381.346106]  ? cpumask_next_and+0x19/0x20
[  381.346110]  ? slub_cpu_dead+0xd0/0xd0
[  381.346113]  flush_cpu_slab+0x36/0x50
[  381.346117]  ? slub_cpu_dead+0xd0/0xd0
[  381.346125]  on_each_cpu_mask+0x51/0x70
[  381.346131]  ? ksm_migrate_page+0x60/0x60
[  381.346134]  on_each_cpu_cond_mask+0xab/0x100
[  381.346143]  __kmem_cache_shrink+0x56/0x320
[  381.346150]  ? ret_from_fork+0x3a/0x50
[  381.346157]  ? unwind_next_frame+0x73/0x480
[  381.346176]  ? __lock_acquire+0x252/0x1410
[  381.346188]  ? kmemcg_workfn+0x21/0x50
[  381.346196]  ? __mutex_lock+0x99/0x920
[  381.346199]  ? kmemcg_workfn+0x21/0x50
[  381.346205]  ? kmemcg_workfn+0x21/0x50
[  381.346216]  __kmemcg_cache_deactivate_after_rcu+0xe/0x40
[  381.346220]  kmemcg_cache_deactivate_after_rcu+0xe/0x20
[  381.346223]  kmemcg_workfn+0x31/0x50
[  381.346230]  process_one_work+0x23c/0x5e0
[  381.346241]  worker_thread+0x3c/0x390
[  381.346248]  ? process_one_work+0x5e0/0x5e0
[  381.346252]  kthread+0x11d/0x140
[  381.346255]  ? kthread_create_on_node+0x60/0x60
[  381.346261]  ret_from_fork+0x3a/0x50
[  381.346275] irq event stamp: 10302
[  381.346278] hardirqs last  enabled at (10301): [<ffffffffb2c1a0b9>]
_raw_spin_unlock_irq+0x29/0x40
[  381.346282] hardirqs last disabled at (10302): [<ffffffffb2182289>]
on_each_cpu_mask+0x49/0x70
[  381.346287] softirqs last  enabled at (10262): [<ffffffffb2191f4a>]
cgroup_idr_replace+0x3a/0x50
[  381.346290] softirqs last disabled at (10260): [<ffffffffb2191f2d>]
cgroup_idr_replace+0x1d/0x50
[  381.346293] ---[ end trace b324ba73eb3659f0 ]---

Reported-by: Andrei Vagin <avagin@gmail.com>
Signed-off-by: Roman Gushchin <guro@fb.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Shakeel Butt <shakeelb@google.com>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: Waiman Long <longman@redhat.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>
---
 mm/slab.h | 17 +++++++++++++----
 1 file changed, 13 insertions(+), 4 deletions(-)

diff --git a/mm/slab.h b/mm/slab.h
index a4c9b9d042de..c02e7f44268b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -294,8 +294,12 @@ static __always_inline int memcg_charge_slab(struct page *page,
 		memcg = parent_mem_cgroup(memcg);
 	rcu_read_unlock();
 
-	if (unlikely(!memcg))
+	if (unlikely(!memcg || mem_cgroup_is_root(memcg))) {
+		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
+				    (1 << order));
+		percpu_ref_get_many(&s->memcg_params.refcnt, 1 << order);
 		return true;
+	}
 
 	ret = memcg_kmem_charge_memcg(page, gfp, order, memcg);
 	if (ret)
@@ -324,9 +328,14 @@ static __always_inline void memcg_uncharge_slab(struct page *page, int order,
 
 	rcu_read_lock();
 	memcg = READ_ONCE(s->memcg_params.memcg);
-	lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
-	mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
-	memcg_kmem_uncharge_memcg(page, order, memcg);
+	if (likely(!mem_cgroup_is_root(memcg))) {
+		lruvec = mem_cgroup_lruvec(page_pgdat(page), memcg);
+		mod_lruvec_state(lruvec, cache_vmstat_idx(s), -(1 << order));
+		memcg_kmem_uncharge_memcg(page, order, memcg);
+	} else {
+		mod_node_page_state(page_pgdat(page), cache_vmstat_idx(s),
+				    -(1 << order));
+	}
 	rcu_read_unlock();
 
 	percpu_ref_put_many(&s->memcg_params.refcnt, 1 << order);
-- 
2.21.0

