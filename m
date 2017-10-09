Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BA056B0260
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:53:27 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l188so49276001pfc.7
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:53:27 -0700 (PDT)
Received: from out0-201.mail.aliyun.com (out0-201.mail.aliyun.com. [140.205.0.201])
        by mx.google.com with ESMTPS id f59si7527721plf.676.2017.10.09.11.53.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 11:53:26 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: oom: show unreclaimable slab info when
 unreclaimable slabs > user memory
References: <1507152550-46205-1-git-send-email-yang.s@alibaba-inc.com>
 <1507152550-46205-4-git-send-email-yang.s@alibaba-inc.com>
 <20171006093702.3ca2p6ymyycwfgbk@dhcp22.suse.cz>
 <ff7e0d92-0f12-46fa-dbc7-79c556ffb7c2@alibaba-inc.com>
 <20171009063316.qjmunbabyr2nzh52@dhcp22.suse.cz>
 <20171009063642.nykrjazifntrj5zz@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <2a24ae2a-e2f3-52b2-0763-2ce31ba18965@alibaba-inc.com>
Date: Tue, 10 Oct 2017 02:53:18 +0800
MIME-Version: 1.0
In-Reply-To: <20171009063642.nykrjazifntrj5zz@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/8/17 11:36 PM, Michal Hocko wrote:
> On Mon 09-10-17 08:33:16, Michal Hocko wrote:
>> On Sat 07-10-17 00:37:55, Yang Shi wrote:
>>>
>>>
>>> On 10/6/17 2:37 AM, Michal Hocko wrote:
>>>> On Thu 05-10-17 05:29:10, Yang Shi wrote:
>> [...]
>>>>> +	list_for_each_entry_safe(s, s2, &slab_caches, list) {
>>>>> +		if (!is_root_cache(s) || (s->flags & SLAB_RECLAIM_ACCOUNT))
>>>>> +			continue;
>>>>> +
>>>>> +		memset(&sinfo, 0, sizeof(sinfo));
>>>>
>>>> why do you zero out the structure. All the fields you are printing are
>>>> filled out in get_slabinfo.
>>>
>>> No special reason, just wipe out the potential stale data on the stack.
>>
>> Do not add code that has no meaning. The OOM killer is a slow path but
>> that doesn't mean we should throw spare cycles out of the window.
> 
> With this fixed and the compile fix [1] folded, feel free to add my
> Acked-by: Michal Hocko <mhocko@suse.com>
> 
> [1] http://lkml.kernel.org/r/1507492085-42264-1-git-send-email-yang.s@alibaba-inc.com

Did some more thorough test and took the code a little deeper, it sounds 
!CONFIG_SLOB is not enough. Some data structure and functions depends on 
CONFIG_SLUB_DEBUG, i.e. kmem_cache_node->total_objects and 
node_nr_objs(), which are essential of get_slabinfo().

So, I'm supposed it makes more sense to protect the related slab stats 
code and the unreclaimable slabinfo dump with CONFIG_SLAB || 
CONFIG_SLUB_DEBUG.

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
