Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0FB656B0033
	for <linux-mm@kvack.org>; Mon, 30 Oct 2017 12:40:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id r6so12190561pfj.14
        for <linux-mm@kvack.org>; Mon, 30 Oct 2017 09:40:25 -0700 (PDT)
Received: from out4434.biz.mail.alibaba.com (out4434.biz.mail.alibaba.com. [47.88.44.34])
        by mx.google.com with ESMTPS id n3si9783716pld.602.2017.10.30.09.40.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Oct 2017 09:40:23 -0700 (PDT)
Subject: Re: [PATCH v2] fs: fsnotify: account fsnotify metadata to kmemcg
References: <1509128538-50162-1-git-send-email-yang.s@alibaba-inc.com>
 <20171030124358.GF23278@quack2.suse.cz>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <76a4d544-833a-5f42-a898-115640b6783b@alibaba-inc.com>
Date: Tue, 31 Oct 2017 00:39:58 +0800
MIME-Version: 1.0
In-Reply-To: <20171030124358.GF23278@quack2.suse.cz>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: amir73il@gmail.com, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 10/30/17 5:43 AM, Jan Kara wrote:
> On Sat 28-10-17 02:22:18, Yang Shi wrote:
>> If some process generates events into a huge or unlimit event queue, but no
>> listener read them, they may consume significant amount of memory silently
>> until oom happens or some memory pressure issue is raised.
>> It'd better to account those slab caches in memcg so that we can get heads
>> up before the problematic process consume too much memory silently.
>>
>> But, the accounting might be heuristic if the producer is in the different
>> memcg from listener if the listener doesn't read the events. Due to the
>> current design of kmemcg, who does the allocation, who gets the accounting.
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> ---
>> v1 --> v2:
>> * Updated commit log per Amir's suggestion
> 
> I'm sorry but I don't think this solution is acceptable. I understand that
> in some cases (and you likely run one of these) the result may *happen* to
> be the desired one but in other cases, you might be charging wrong memcg
> and so misbehaving process in memcg A can effectively cause a DoS attack on
> a process in memcg B.

Yes, as what I discussed with Amir in earlier review, current memcg 
design just accounts memory to the allocation process, but has no idea 
who is consumer process.

Although it is not desirable to DoS a memcg, it still sounds better than 
DoS the whole machine due to potential oom. This patch is aimed to avoid 
such case.

> 
> If you have a setup in which notification events can consume considerable
> amount of resources, you are doing something wrong I think. Standard event
> queue length is limited, overall events are bounded to consume less than 1
> MB. If you have unbounded queue, the process has to be CAP_SYS_ADMIN and
> presumably it has good reasons for requesting unbounded queue and it should
> know what it is doing.

Yes, I agree it does mean something is going wrong. So, it'd better to 
be accounted in order to get some heads up early before something is 
going really bad. The limit will not be set too high since fsnotify 
metadata will not consume too much memory in *normal* case.

I agree we should trust admin user, but kernel should be responsible for 
the last defense when something is really going wrong. And, we can't 
guarantee admin process will not do something wrong, the code might be 
not reviewed thoroughly, the test might not cover some extreme cases.

> 
> So maybe we could come up with some better way to control amount of
> resources consumed by notification events but for that we lack more
> information about your use case. And I maintain that the solution should
> account events to the consumer, not the producer...

I do agree it is not fair and not neat to account to producer rather 
than misbehaving consumer, but current memcg design looks not support 
such use case. And, the other question is do we know who is the listener 
if it doesn't read the events?

Thanks,
Yang

> 
> 								Honza
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
