Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 40D796B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 06:32:21 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id l188so18336909lfg.2
        for <linux-mm@kvack.org>; Tue, 23 May 2017 03:32:21 -0700 (PDT)
Received: from forwardcorp1o.cmail.yandex.net (forwardcorp1o.cmail.yandex.net. [37.9.109.47])
        by mx.google.com with ESMTPS id d137si9437319lfd.200.2017.05.23.03.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 03:32:19 -0700 (PDT)
Subject: Re: [PATCH] mm/oom_kill: count global and memory cgroup oom kills
References: <149520375057.74196.2843113275800730971.stgit@buzz>
 <CALo0P1123MROxgveCdX6YFpWDwG4qrAyHu3Xd1F+ckaFBnF4dQ@mail.gmail.com>
 <ecd4a7ea-06c0-f549-a1bf-6d2d3c0af719@yandex-team.ru>
 <alpine.DEB.2.10.1705230044590.50796@chino.kir.corp.google.com>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <0f67046d-cdf6-1264-26f6-11c82978c621@yandex-team.ru>
Date: Tue, 23 May 2017 13:32:17 +0300
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1705230044590.50796@chino.kir.corp.google.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Roman Guschin <guroan@gmail.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, hannes@cmpxchg.org



On 23.05.2017 10:49, David Rientjes wrote:
> On Mon, 22 May 2017, Konstantin Khlebnikov wrote:
> 
>> Nope, they are different. I think we should rephase documentation somehow
>>
>> low - count of reclaims below low level
>> high - count of post-allocation reclaims above high level
>> max - count of direct reclaims
>> oom - count of failed direct reclaims
>> oom_kill - count of oom killer invocations and killed processes
>>
> 
> In our kernel, we've maintained counts of oom kills per memcg for years as
> part of memory.oom_control for memcg v1, but we've also found it helpful
> to complement that with another count that specifies the number of
> processes oom killed that were attached to that exact memcg.
> 
> In your patch, oom_kill in memory.oom_control specifies that number of oom
> events that resulted in an oom kill of a process from that hierarchy, but
> not the number of processes killed from a specific memcg (the difference
> between oc->memcg and mem_cgroup_from_task(victim)).  Not sure if you
> would also find it helpful.
> 

This is worth addition. Let's call it "oom_victim" for short.

It allows to locate leaky part if they are spread over sub-containers within common limit.
But doesn't tell which limit caused this kill. For hierarchical limits this might be not so easy.

I think oom_kill better suits for automatic actions - restart affected hierarchy, increase limits, e.t.c.
But oom_victim allows to determine container affected by global oom killer.

So, probably it's worth to merge them together and increment oom_kill by global killer for victim memcg:

	if (!is_memcg_oom(oc)) {
		count_vm_event(OOM_KILL);
		mem_cgroup_count_vm_event(mm, OOM_KILL);
	} else
		mem_cgroup_event(oc->memcg, OOM_KILL);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
