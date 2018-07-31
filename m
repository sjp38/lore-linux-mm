Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4BDBB6B0005
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 19:39:12 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id a26-v6so9984430pgw.7
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 16:39:12 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id f8-v6si14328601plb.381.2018.07.31.16.39.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 16:39:11 -0700 (PDT)
Date: Tue, 31 Jul 2018 16:39:08 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
Message-Id: <20180731163908.603d7a27c6534341e1afa724@linux-foundation.org>
In-Reply-To: <20180730153113.GB4567@cmpxchg.org>
References: <6dbc33bb-f3d5-1a46-b454-13c6f5865fcd@virtuozzo.com>
	<20180413113855.GI17484@dhcp22.suse.cz>
	<8a81c801-35c8-767d-54b0-df9f1ca0abc0@virtuozzo.com>
	<20180413115454.GL17484@dhcp22.suse.cz>
	<abfd4903-c455-fac2-7ed6-73707cda64d1@virtuozzo.com>
	<20180413121433.GM17484@dhcp22.suse.cz>
	<20180413125101.GO17484@dhcp22.suse.cz>
	<20180726162512.6056b5d7c1d2a5fbff6ce214@linux-foundation.org>
	<20180727193134.GA10996@cmpxchg.org>
	<20180729192621.py4znecoinw5mqcp@esperanza>
	<20180730153113.GB4567@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Vladimir Davydov <vdavydov.dev@gmail.com>, Michal Hocko <mhocko@kernel.org>, Kirill Tkhai <ktkhai@virtuozzo.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 30 Jul 2018 11:31:13 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:

> Subject: [PATCH] mm: memcontrol: simplify memcg idr allocation and error
>  unwinding
> 
> The memcg ID is allocated early in the multi-step memcg creation
> process, which needs 2-step ID allocation and IDR publishing, as well
> as two separate IDR cleanup/unwind sites on error.
> 
> Defer the IDR allocation until the last second during onlining to
> eliminate all this complexity. There is no requirement to have the ID
> and IDR entry earlier than that. And the root reference to the ID is
> put in the offline path, so this matches nicely.

This patch isn't aware of Kirill's later "mm, memcg: assign memcg-aware
shrinkers bitmap to memcg", which altered mem_cgroup_css_online():

@@ -4356,6 +4470,11 @@ static int mem_cgroup_css_online(struct
 {
 	struct mem_cgroup *memcg = mem_cgroup_from_css(css);
 
+	if (memcg_alloc_shrinker_maps(memcg)) {
+		mem_cgroup_id_remove(memcg);
+		return -ENOMEM;
+	}
+
 	/* Online state pins memcg ID, memcg ID pins CSS */
 	atomic_set(&memcg->id.ref, 1);
 	css_get(css);
