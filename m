Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id A49086B0005
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 05:35:29 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id k15so7176194ioc.4
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 02:35:29 -0700 (PDT)
Received: from EUR02-VE1-obe.outbound.protection.outlook.com (mail-eopbgr20113.outbound.protection.outlook.com. [40.107.2.113])
        by mx.google.com with ESMTPS id b123-v6si1115666iti.91.2018.04.13.02.35.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 02:35:28 -0700 (PDT)
Subject: Re: [PATCH] memcg: Remove memcg_cgroup::id from IDR on
 mem_cgroup_css_alloc() failure
References: <152354470916.22460.14397070748001974638.stgit@localhost.localdomain>
 <20180413085553.GF17484@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <ed75d18c-f516-2feb-53a8-6d2836e1da59@virtuozzo.com>
Date: Fri, 13 Apr 2018 12:35:22 +0300
MIME-Version: 1.0
In-Reply-To: <20180413085553.GF17484@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov.dev@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 13.04.2018 11:55, Michal Hocko wrote:
> On Thu 12-04-18 17:52:04, Kirill Tkhai wrote:
> [...]
>> @@ -4471,6 +4477,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
>>  
>>  	return &memcg->css;
>>  fail:
>> +	mem_cgroup_id_remove(memcg);
>>  	mem_cgroup_free(memcg);
>>  	return ERR_PTR(-ENOMEM);
>>  }
> 
> The only path which jumps to fail: here (in the current mmotm tree) is 
> 	error = memcg_online_kmem(memcg);
> 	if (error)
> 		goto fail;
> 
> AFAICS and the only failure path in memcg_online_kmem
> 	memcg_id = memcg_alloc_cache_id();
> 	if (memcg_id < 0)
> 		return memcg_id;
> 
> I am not entirely clear on memcg_alloc_cache_id but it seems we do clean
> up properly. Or am I missing something?

memcg_alloc_cache_id() may allocate a lot of memory, in case of the system reached
memcg_nr_cache_ids cgroups. In this case it iterates over all LRU lists, and double
size of every of them. In case of memory pressure it can fail. If this occurs,
mem_cgroup::id is not unhashed from IDR and we leak this id.

After further iterations, all IDs may be occupied, and there won't be able to create
a memcg in the system ever. You may reproduce the situation with the patch:

[root@localhost ~]# cd /sys/fs/cgroup/memory/
[root@localhost memory]# mkdir 1
mkdir: cannot create directory `1': Cannot allocate memory
[root@localhost memory]# for i in {1..65535}; do mkdir 1 2>/dev/null; done
[root@localhost memory]# mkdir 1
mkdir: cannot create directory `1': No space left on device

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 3e7942c301a8..5e17bfee9e6f 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2156,6 +2156,7 @@ static int memcg_alloc_cache_id(void)
 	err = memcg_update_all_caches(size);
 	if (!err)
 		err = memcg_update_all_list_lrus(size);
+	err = -ENOMEM;
 	if (!err)
 		memcg_nr_cache_ids = size;
 
@@ -4422,7 +4423,7 @@ mem_cgroup_css_alloc(struct cgroup_subsys_state *parent_css)
 {
 	struct mem_cgroup *parent = mem_cgroup_from_css(parent_css);
 	struct mem_cgroup *memcg;
-	long error = -ENOMEM;
+	long error = -ENOSPC;
 
 	memcg = mem_cgroup_alloc();
 	if (!memcg)

ENOSPC was added to the second hunk to show that the function fails on IDR allocation.

Kirill
