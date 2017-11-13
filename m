Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id B44806B0033
	for <linux-mm@kvack.org>; Mon, 13 Nov 2017 14:10:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id f85so15597230pfe.7
        for <linux-mm@kvack.org>; Mon, 13 Nov 2017 11:10:31 -0800 (PST)
Received: from out0-237.mail.aliyun.com (out0-237.mail.aliyun.com. [140.205.0.237])
        by mx.google.com with ESMTPS id o186si14066175pga.260.2017.11.13.11.10.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Nov 2017 11:10:30 -0800 (PST)
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
 <20171030124358.GF23278@quack2.suse.cz>
 <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
 <20171031101238.GD8989@quack2.suse.cz>
 <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <10924085-6275-125f-d56b-547d734b6f4e@alibaba-inc.com>
Date: Tue, 14 Nov 2017 03:10:22 +0800
MIME-Version: 1.0
In-Reply-To: <20171109135444.znaksm4fucmpuylf@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>
Cc: amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 11/9/17 5:54 AM, Michal Hocko wrote:
> [Sorry for the late reply]
> 
> On Tue 31-10-17 11:12:38, Jan Kara wrote:
>> On Tue 31-10-17 00:39:58, Yang Shi wrote:
> [...]
>>> I do agree it is not fair and not neat to account to producer rather than
>>> misbehaving consumer, but current memcg design looks not support such use
>>> case. And, the other question is do we know who is the listener if it
>>> doesn't read the events?
>>
>> So you never know who will read from the notification file descriptor but
>> you can simply account that to the process that created the notification
>> group and that is IMO the right process to account to.
> 
> Yes, if the creator is de-facto owner which defines the lifetime of
> those objects then this should be a target of the charge.
> 
>> I agree that current SLAB memcg accounting does not allow to account to a
>> different memcg than the one of the running process. However I *think* it
>> should be possible to add such interface. Michal?
> 
> We do have memcg_kmem_charge_memcg but that would require some plumbing
> to hook it into the specific allocation path. I suspect it uses kmalloc,
> right?

Yes.

I took a look at the implementation and the callsites of 
memcg_kmem_charge_memcg(). It looks it is called by:

* charge kmem to memcg, but it is charged to the allocator's memcg
* allocate new slab page, charge to memcg_params.memcg

I think this is the plumbing you mentioned, right?

Thanks,
Yang

> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
