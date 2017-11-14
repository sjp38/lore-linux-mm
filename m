Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id C87D06B0253
	for <linux-mm@kvack.org>; Tue, 14 Nov 2017 12:32:39 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id s28so13055456pfg.6
        for <linux-mm@kvack.org>; Tue, 14 Nov 2017 09:32:39 -0800 (PST)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTPS id a35si16846665pli.139.2017.11.14.09.32.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Nov 2017 09:32:38 -0800 (PST)
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
 <20171030124358.GF23278@quack2.suse.cz>
 <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz>
 <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
 <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com>
 <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <afa2dc80-16a3-d3d1-5090-9430eaafc841@alibaba-inc.com>
Date: Wed, 15 Nov 2017 01:32:16 +0800
MIME-Version: 1.0
In-Reply-To: <20171114093909.dbhlm26qnrrb2ww4@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Jan Kara <jack@suse.cz>, amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/14/17 1:39 AM, Michal Hocko wrote:
> On Tue 14-11-17 03:10:22, Yang Shi wrote:
>>
>>
>> On 11/9/17 5:54 AM, Michal Hocko wrote:
>>> [Sorry for the late reply]
>>>
>>> On Tue 31-10-17 11:12:38, Jan Kara wrote:
>>>> On Tue 31-10-17 00:39:58, Yang Shi wrote:
>>> [...]
>>>>> I do agree it is not fair and not neat to account to producer rather than
>>>>> misbehaving consumer, but current memcg design looks not support such use
>>>>> case. And, the other question is do we know who is the listener if it
>>>>> doesn't read the events?
>>>>
>>>> So you never know who will read from the notification file descriptor but
>>>> you can simply account that to the process that created the notification
>>>> group and that is IMO the right process to account to.
>>>
>>> Yes, if the creator is de-facto owner which defines the lifetime of
>>> those objects then this should be a target of the charge.
>>>
>>>> I agree that current SLAB memcg accounting does not allow to account to a
>>>> different memcg than the one of the running process. However I *think* it
>>>> should be possible to add such interface. Michal?
>>>
>>> We do have memcg_kmem_charge_memcg but that would require some plumbing
>>> to hook it into the specific allocation path. I suspect it uses kmalloc,
>>> right?
>>
>> Yes.
>>
>> I took a look at the implementation and the callsites of
>> memcg_kmem_charge_memcg(). It looks it is called by:
>>
>> * charge kmem to memcg, but it is charged to the allocator's memcg
>> * allocate new slab page, charge to memcg_params.memcg
>>
>> I think this is the plumbing you mentioned, right?
> 
> Maybe I have misunderstood, but you are using slab allocator. So you
> would need to force it to use a different charging context than current.

Yes.

> I haven't checked deeply but this doesn't look trivial to me.

I agree. This is also what I explained to Jan and Amir in earlier 
discussion.

Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
