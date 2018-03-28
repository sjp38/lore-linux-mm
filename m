Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id E10B96B0027
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 10:49:44 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id c5so1527683pfn.17
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 07:49:44 -0700 (PDT)
Received: from EUR03-AM5-obe.outbound.protection.outlook.com (mail-eopbgr30135.outbound.protection.outlook.com. [40.107.3.135])
        by mx.google.com with ESMTPS id 75si2560888pga.647.2018.03.28.07.49.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 28 Mar 2018 07:49:43 -0700 (PDT)
Subject: Re: [PATCH 06/10] list_lru: Pass dst_memcg argument to
 memcg_drain_list_lru_node()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
References: <152163840790.21546.980703278415599202.stgit@localhost.localdomain>
 <152163853059.21546.940468208501917585.stgit@localhost.localdomain>
 <20180324193253.y653nm4z6sh7u2kd@esperanza>
 <0fe02df4-3d55-2ee3-95af-156ac63f29be@virtuozzo.com>
Message-ID: <b7d605c5-6fda-c846-e5f6-c3b4bb32684e@virtuozzo.com>
Date: Wed, 28 Mar 2018 17:49:34 +0300
MIME-Version: 1.0
In-Reply-To: <0fe02df4-3d55-2ee3-95af-156ac63f29be@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov.dev@gmail.com>
Cc: viro@zeniv.linux.org.uk, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, tglx@linutronix.de, pombredanne@nexb.com, stummala@codeaurora.org, gregkh@linuxfoundation.org, sfr@canb.auug.org.au, guro@fb.com, mka@chromium.org, penguin-kernel@I-love.SAKURA.ne.jp, chris@chris-wilson.co.uk, longman@redhat.com, minchan@kernel.org, hillf.zj@alibaba-inc.com, ying.huang@intel.com, mgorman@techsingularity.net, shakeelb@google.com, jbacik@fb.com, linux@roeck-us.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@infradead.org

On 26.03.2018 18:30, Kirill Tkhai wrote:
> On 24.03.2018 22:32, Vladimir Davydov wrote:
>> On Wed, Mar 21, 2018 at 04:22:10PM +0300, Kirill Tkhai wrote:
>>> This is just refactoring to allow next patches to have
>>> dst_memcg pointer in memcg_drain_list_lru_node().
>>>
>>> Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
>>> ---
>>>  include/linux/list_lru.h |    2 +-
>>>  mm/list_lru.c            |   11 ++++++-----
>>>  mm/memcontrol.c          |    2 +-
>>>  3 files changed, 8 insertions(+), 7 deletions(-)
>>>
>>> diff --git a/include/linux/list_lru.h b/include/linux/list_lru.h
>>> index ce1d010cd3fa..50cf8c61c609 100644
>>> --- a/include/linux/list_lru.h
>>> +++ b/include/linux/list_lru.h
>>> @@ -66,7 +66,7 @@ int __list_lru_init(struct list_lru *lru, bool memcg_aware,
>>>  #define list_lru_init_memcg(lru)	__list_lru_init((lru), true, NULL)
>>>  
>>>  int memcg_update_all_list_lrus(int num_memcgs);
>>> -void memcg_drain_all_list_lrus(int src_idx, int dst_idx);
>>> +void memcg_drain_all_list_lrus(int src_idx, struct mem_cgroup *dst_memcg);
>>
>> Please, for consistency pass the source cgroup as a pointer as well.
> 
> Ok

Hm. But we call it from memcg_offline_kmem() after cgroup's kmemcg_id is set
to parent memcg's kmemcg_id:

        rcu_read_lock(); /* can be called from css_free w/o cgroup_mutex */
        css_for_each_descendant_pre(css, &memcg->css) {
                child = mem_cgroup_from_css(css);
                BUG_ON(child->kmemcg_id != kmemcg_id);
                child->kmemcg_id = parent->kmemcg_id;
                if (!memcg->use_hierarchy)
                        break;
        }
        rcu_read_unlock();

        memcg_drain_all_list_lrus(kmemcg_id, parent);

It does not seem we may pass memcg to memcg_drain_all_list_lrus()
or change the logic or order. What do you think?

Kirill
