Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 57AB96B025E
	for <linux-mm@kvack.org>; Mon, 21 Nov 2016 19:17:59 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so3105576pgq.7
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:17:59 -0800 (PST)
Received: from mail-pg0-x241.google.com (mail-pg0-x241.google.com. [2607:f8b0:400e:c05::241])
        by mx.google.com with ESMTPS id g2si25188322pfj.214.2016.11.21.16.17.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Nov 2016 16:17:58 -0800 (PST)
Received: by mail-pg0-x241.google.com with SMTP id x23so196257pgx.3
        for <linux-mm@kvack.org>; Mon, 21 Nov 2016 16:17:58 -0800 (PST)
Subject: Re: [RESEND] [PATCH v1 1/3] Add basic infrastructure for memcg
 hotplug support
References: <1479253501-26261-1-git-send-email-bsingharora@gmail.com>
 <1479253501-26261-2-git-send-email-bsingharora@gmail.com>
 <20161116090129.GA18225@esperanza>
 <3accc533-8dda-a69c-fabc-23eb388cf11b@gmail.com>
 <20161121083616.GC18431@esperanza>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <2395f702-8246-4ce6-ca23-7d71ce872507@gmail.com>
Date: Tue, 22 Nov 2016 11:17:53 +1100
MIME-Version: 1.0
In-Reply-To: <20161121083616.GC18431@esperanza>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@tarantool.org>
Cc: mpe@ellerman.id.au, hannes@cmpxchg.org, mhocko@kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Andrew Morton <akpm@linux-foundation.org>


>>
>> The iterator internally takes rcu_read_lock() to avoid any side-effects
>> of cgroups added/removed. I suspect you are also suggesting using get_online_mems()
>> around each call to for_each_online_node
>>
>> My understanding so far is
>>
>> 1. invalidate_reclaim_iterators should be safe (no bad side-effects)
>> 2. mem_cgroup_free - should be safe as well
>> 3. mem_cgroup_alloc - needs protection
>> 4. mem_cgroup_init - needs protection
>> 5. mem_cgroup_remove_from_tress - should be safe
> 
> I'm not into the memory hotplug code, but my understanding is that if
> memcg offline happens to race with node unplug, it's possible that
> 
>  - mem_cgroup_free() doesn't free the node's data, because it sees the
>    node as already offline
>  - memcg hotplug code doesn't free the node's data either, because it
>    sees the cgroup as offline
> 
> May be, we should surround all the loops over online nodes with
> get/put_online_mems() to be sure that nothing wrong can happen.
> They are slow path, anyway.
> 

Makes sense, agreed

Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
