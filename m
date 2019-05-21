Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1578AC04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 19:36:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B50C3217F9
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 19:36:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B50C3217F9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2CFE96B0003; Tue, 21 May 2019 15:36:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 280AE6B0006; Tue, 21 May 2019 15:36:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 16EE36B0007; Tue, 21 May 2019 15:36:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id E60F76B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 15:36:02 -0400 (EDT)
Received: by mail-qk1-f197.google.com with SMTP id q17so16512571qkc.23
        for <linux-mm@kvack.org>; Tue, 21 May 2019 12:36:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:organization:message-id:date:user-agent
         :mime-version:in-reply-to:content-transfer-encoding:content-language;
        bh=/+7dl/WLdNAxeHLDcOPiBUKNTVlCImsyZziFDrAXxUk=;
        b=TiEGZWBNjUBHzx17y65gpwYRO2sxjeO7ogERVS4zzqkYkMNGEjOdRH6GKow2WoK4nm
         7gL9aEOKBccrH2x3JvbFDWBaXJ1l50yFuRy98VgcEl4IVxTb5BEEVkf9U2ePJBTFO3OZ
         jOIMVXpYeNezdsYZLJ8bvGN7GIXHz8sjtQbYaA2aJVaCpGez2tqJVLFxxfpfk6Q/4sMJ
         rY25ChbTO5dWfJMlh2HU0Le3bjWjawkSa5wFTx7xSVcb0eB4oFNwZejse0ArwvvxEjPQ
         egi8cR3qexPgr3oCqAJLgO+dWi9CufridbJRQZk1D78+v+D6vtJzSnUW5pIlAn/eRJjQ
         svvw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAWOb+BHVIPYU2YzN6OEA5vm2HpBQaIM33c9X10RZ7SFGoUBfIP6
	sq/ChTpVLQojkQoJIHsAbN4/LB2L44q6UvxrpSoXWPJoygS48HKRJTJHbcaM2pO191V8IxMVbCZ
	RBoJdt7o2CD1qHBvyLuCF7dvoudr8W59jUTOCWPs+VHW2EiHxBpgY/aF7YiDJRpYDmQ==
X-Received: by 2002:a05:6214:1047:: with SMTP id l7mr18350906qvr.183.1558467362646;
        Tue, 21 May 2019 12:36:02 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwm++9G8+0G9vlrMkuMnDj+qTWQXP+4o7B7RSnxLP4sYtvowj4eD+0UYzYfs4haQGY7pQ7Q
X-Received: by 2002:a05:6214:1047:: with SMTP id l7mr18350853qvr.183.1558467361865;
        Tue, 21 May 2019 12:36:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558467361; cv=none;
        d=google.com; s=arc-20160816;
        b=crWXpBqzqLSO81JaYc8jq61wxFoXwzjsZXjyjhMTNWYYSZNvU+ZAoK2Tg5cqduU+QS
         Lv+f9rCVGi1vwU+b7eZwtjjMjSALR3+p9fHqTCVEtSbRbFMJc9cshG2bo3ZDVWh2hWZn
         g9IJQcRvH7m1h2nqdF1FpjFeZQ+n2Cm4NY1+DkSYXhSKSPl5xJs2aMh3/kyP5rbqOW0T
         hc4rW9WoT+SaOwqoETEoGMtn+E8xo49MIgcMps2v/tPbBYArce1nN19vzTFjA2xB8MsV
         mBgsIBmg8HqHz+3iH0jJMYpxAS/kI0YbXX+S4CqtZq5mzC27xOhrn08hll+c84pio1XM
         HgOQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:organization:from:references:cc:to
         :subject;
        bh=/+7dl/WLdNAxeHLDcOPiBUKNTVlCImsyZziFDrAXxUk=;
        b=COSFbiaLer0fQPRokscPmb9hMCO264gryLpLyyd9BjMWGsnR0xbIWBqMdo5fP5JGFd
         EX1oQ7PRBpuaYh9CqK2e44e3kXQRNSfB5rfnaFhPdk7xmbcsxrcr2Un6sTBlT1H6MH5o
         0uYVNPMDtasLwAH1A8knq2XlbJZMvtHlxx0GUYxbn66+5F1Lp5KLmBc0jgD3t2BR6o7f
         BNAy3hBiQkStdM/9dBSl/uUcM7k4nPmXa6Fof4eualQYydQfYVP0OlIa3jdSO4qvPLWh
         O91swI8DKL0Yxs6o1D+/pWIFG0wBED3mERX1yhYv1Dmkpf3YpmFbR4loQl+oiF5iISOX
         AWvQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id i64si1077682qkc.177.2019.05.21.12.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 12:36:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of longman@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=longman@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.phx2.redhat.com [10.5.11.13])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 02EA43078AAC;
	Tue, 21 May 2019 19:35:51 +0000 (UTC)
Received: from llong.remote.csb (dhcp-17-85.bos.redhat.com [10.18.17.85])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 26DA118786;
	Tue, 21 May 2019 19:35:46 +0000 (UTC)
Subject: Re: [PATCH v4 5/7] mm: rework non-root kmem_cache lifecycle
 management
To: Roman Gushchin <guro@fb.com>
Cc: Shakeel Butt <shakeelb@google.com>,
 Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>,
 LKML <linux-kernel@vger.kernel.org>, Kernel Team <Kernel-team@fb.com>,
 Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>,
 Rik van Riel <riel@surriel.com>, Christoph Lameter <cl@linux.com>,
 Vladimir Davydov <vdavydov.dev@gmail.com>, Cgroups <cgroups@vger.kernel.org>
References: <20190514213940.2405198-1-guro@fb.com>
 <20190514213940.2405198-6-guro@fb.com>
 <CALvZod6Zb_kYHyG02jXBY9gvvUn_gOug7kq_hVa8vuCbXdPdjQ@mail.gmail.com>
 <7d06354d-4542-af42-d83d-2bc4639b56f2@redhat.com>
 <20190521192320.GA6658@tower.DHCP.thefacebook.com>
From: Waiman Long <longman@redhat.com>
Organization: Red Hat
Message-ID: <e94301ee-b12d-597f-d195-6716b0af1363@redhat.com>
Date: Tue, 21 May 2019 15:35:45 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.6.1
MIME-Version: 1.0
In-Reply-To: <20190521192320.GA6658@tower.DHCP.thefacebook.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.13
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Tue, 21 May 2019 19:35:55 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/21/19 3:23 PM, Roman Gushchin wrote:
> On Tue, May 21, 2019 at 02:39:50PM -0400, Waiman Long wrote:
>> On 5/14/19 8:06 PM, Shakeel Butt wrote:
>>>> @@ -2651,20 +2652,35 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
>>>>         struct mem_cgroup *memcg;
>>>>         struct kmem_cache *memcg_cachep;
>>>>         int kmemcg_id;
>>>> +       struct memcg_cache_array *arr;
>>>>
>>>>         VM_BUG_ON(!is_root_cache(cachep));
>>>>
>>>>         if (memcg_kmem_bypass())
>>>>                 return cachep;
>>>>
>>>> -       memcg = get_mem_cgroup_from_current();
>>>> +       rcu_read_lock();
>>>> +
>>>> +       if (unlikely(current->active_memcg))
>>>> +               memcg = current->active_memcg;
>>>> +       else
>>>> +               memcg = mem_cgroup_from_task(current);
>>>> +
>>>> +       if (!memcg || memcg == root_mem_cgroup)
>>>> +               goto out_unlock;
>>>> +
>>>>         kmemcg_id = READ_ONCE(memcg->kmemcg_id);
>>>>         if (kmemcg_id < 0)
>>>> -               goto out;
>>>> +               goto out_unlock;
>>>>
>>>> -       memcg_cachep = cache_from_memcg_idx(cachep, kmemcg_id);
>>>> -       if (likely(memcg_cachep))
>>>> -               return memcg_cachep;
>>>> +       arr = rcu_dereference(cachep->memcg_params.memcg_caches);
>>>> +
>>>> +       /*
>>>> +        * Make sure we will access the up-to-date value. The code updating
>>>> +        * memcg_caches issues a write barrier to match this (see
>>>> +        * memcg_create_kmem_cache()).
>>>> +        */
>>>> +       memcg_cachep = READ_ONCE(arr->entries[kmemcg_id]);
>>>>
>>>>         /*
>>>>          * If we are in a safe context (can wait, and not in interrupt
>>>> @@ -2677,10 +2693,20 @@ struct kmem_cache *memcg_kmem_get_cache(struct kmem_cache *cachep)
>>>>          * memcg_create_kmem_cache, this means no further allocation
>>>>          * could happen with the slab_mutex held. So it's better to
>>>>          * defer everything.
>>>> +        *
>>>> +        * If the memcg is dying or memcg_cache is about to be released,
>>>> +        * don't bother creating new kmem_caches. Because memcg_cachep
>>>> +        * is ZEROed as the fist step of kmem offlining, we don't need
>>>> +        * percpu_ref_tryget() here. css_tryget_online() check in
>>> *percpu_ref_tryget_live()
>>>
>>>> +        * memcg_schedule_kmem_cache_create() will prevent us from
>>>> +        * creation of a new kmem_cache.
>>>>          */
>>>> -       memcg_schedule_kmem_cache_create(memcg, cachep);
>>>> -out:
>>>> -       css_put(&memcg->css);
>>>> +       if (unlikely(!memcg_cachep))
>>>> +               memcg_schedule_kmem_cache_create(memcg, cachep);
>>>> +       else if (percpu_ref_tryget(&memcg_cachep->memcg_params.refcnt))
>>>> +               cachep = memcg_cachep;
>>>> +out_unlock:
>>>> +       rcu_read_lock();
>> There is one more bug that causes the kernel to panic on bootup when I
>> turned on debugging options.
>>
>> [   49.871437] =============================
>> [   49.875452] WARNING: suspicious RCU usage
>> [   49.879476] 5.2.0-rc1.bz1699202_memcg_test+ #2 Not tainted
>> [   49.884967] -----------------------------
>> [   49.888991] include/linux/rcupdate.h:268 Illegal context switch in
>> RCU read-side critical section!
>> [   49.897950]
>> [   49.897950] other info that might help us debug this:
>> [   49.897950]
>> [   49.905958]
>> [   49.905958] rcu_scheduler_active = 2, debug_locks = 1
>> [   49.912492] 3 locks held by systemd/1:
>> [   49.916252]  #0: 00000000633673c5 (&type->i_mutex_dir_key#5){.+.+},
>> at: lookup_slow+0x42/0x70
>> [   49.924788]  #1: 0000000029fa8c75 (rcu_read_lock){....}, at:
>> memcg_kmem_get_cache+0x12b/0x910
>> [   49.933316]  #2: 0000000029fa8c75 (rcu_read_lock){....}, at:
>> memcg_kmem_get_cache+0x3da/0x910
>>
>> It should be "rcu_read_unlock();" at the end.
> Oops. Good catch, thanks Waiman!
>
> I'm somewhat surprised it didn't get up in my tests, neither any of test
> bots caught it. Anyway, I'll fix it and send v5.

In non-preempt kernel rcu_read_lock() is almost a no-op. So you probably
won't see any ill effect with this bug.

>
> Does the rest of the patchset looks sane to you?

I haven't done a full review of the patch, but it looks sane to me from
my cursory look at it. We hit similar problem in Red Hat. That is why I
am looking at your patch. Looking forward to your v5 patch.

Cheers,
Longman

