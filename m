Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id DB41C6B0038
	for <linux-mm@kvack.org>; Fri, 20 Oct 2017 17:07:25 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 76so11778629pfr.3
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 14:07:25 -0700 (PDT)
Received: from out0-219.mail.aliyun.com (out0-219.mail.aliyun.com. [140.205.0.219])
        by mx.google.com with ESMTPS id t18si950844plo.821.2017.10.20.14.07.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Oct 2017 14:07:24 -0700 (PDT)
Subject: Re: [RFC PATCH] fs: fsnotify: account fsnotify metadata to kmemcg
References: <1508448056-21779-1-git-send-email-yang.s@alibaba-inc.com>
 <CAOQ4uxhPhXrMLu18TGKDA=ezUVHara95qJQ+BTCio8BHm-u6NA@mail.gmail.com>
From: "Yang Shi" <yang.s@alibaba-inc.com>
Message-ID: <b530521e-5215-f735-444a-13f722d90e40@alibaba-inc.com>
Date: Sat, 21 Oct 2017 05:07:17 +0800
MIME-Version: 1.0
In-Reply-To: <CAOQ4uxhPhXrMLu18TGKDA=ezUVHara95qJQ+BTCio8BHm-u6NA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Jan Kara <jack@suse.cz>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>



On 10/19/17 8:14 PM, Amir Goldstein wrote:
> On Fri, Oct 20, 2017 at 12:20 AM, Yang Shi <yang.s@alibaba-inc.com> wrote:
>> We observed some misbehaved user applications might consume significant
>> amount of fsnotify slabs silently. It'd better to account those slabs in
>> kmemcg so that we can get heads up before misbehaved applications use too
>> much memory silently.
> 
> In what way do they misbehave? create a lot of marks? create a lot of events?
> Not reading events in their queue?

It looks both a lot marks and events. I'm not sure if it is the latter 
case. If I knew more about the details of the behavior, I would 
elaborated more in the commit log.

> The latter case is more interesting:
> 
> Process A is the one that asked to get the events.
> Process B is the one that is generating the events and queuing them on
> the queue that is owned by process A, who is also to blame if the queue
> is not being read.

I agree it is not fair to account the memory to the generator. But, 
afaik, accounting non-current memcg is not how memcg is designed and 
works. Please see the below for some details.

> 
> So why should process B be held accountable for memory pressure
> caused by, say, an FAN_UNLIMITED_QUEUE that process A created and
> doesn't read from.
> 
> Is it possible to get an explicit reference to the memcg's  events cache
> at fsnotify_group creation time, store it in the group struct and then allocate
> events from the event cache associated with the group (the listener) rather
> than the cache associated with the task generating the event?

I don't think current memcg design can do this. Because kmem accounting 
happens at allocation (when calling kmem_cache_alloc) stage, and get the 
associated memcg from current task, so basically who does the allocation 
who get it accounted. If the producer is in the different memcg of 
consumer, it should be just accounted to the producer memcg, although 
the problem might be caused by the producer.

However, afaik, both producer and consumer are typically in the same 
memcg. So, this might be not a big issue. But, I do admit such unfair 
accounting may happen.

Thanks,
Yang

> 
> Amir.
> 
>>
>> Signed-off-by: Yang Shi <yang.s@alibaba-inc.com>
>> ---
>>   fs/notify/dnotify/dnotify.c        | 4 ++--
>>   fs/notify/fanotify/fanotify_user.c | 6 +++---
>>   fs/notify/fsnotify.c               | 2 +-
>>   fs/notify/inotify/inotify_user.c   | 2 +-
>>   4 files changed, 7 insertions(+), 7 deletions(-)
>>
>> diff --git a/fs/notify/dnotify/dnotify.c b/fs/notify/dnotify/dnotify.c
>> index cba3283..3ec6233 100644
>> --- a/fs/notify/dnotify/dnotify.c
>> +++ b/fs/notify/dnotify/dnotify.c
>> @@ -379,8 +379,8 @@ int fcntl_dirnotify(int fd, struct file *filp, unsigned long arg)
>>
>>   static int __init dnotify_init(void)
>>   {
>> -       dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC);
>> -       dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC);
>> +       dnotify_struct_cache = KMEM_CACHE(dnotify_struct, SLAB_PANIC|SLAB_ACCOUNT);
>> +       dnotify_mark_cache = KMEM_CACHE(dnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
>>
>>          dnotify_group = fsnotify_alloc_group(&dnotify_fsnotify_ops);
>>          if (IS_ERR(dnotify_group))
>> diff --git a/fs/notify/fanotify/fanotify_user.c b/fs/notify/fanotify/fanotify_user.c
>> index 907a481..7d62dee 100644
>> --- a/fs/notify/fanotify/fanotify_user.c
>> +++ b/fs/notify/fanotify/fanotify_user.c
>> @@ -947,11 +947,11 @@ static int fanotify_add_inode_mark(struct fsnotify_group *group,
>>    */
>>   static int __init fanotify_user_setup(void)
>>   {
>> -       fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC);
>> -       fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC);
>> +       fanotify_mark_cache = KMEM_CACHE(fsnotify_mark, SLAB_PANIC|SLAB_ACCOUNT);
>> +       fanotify_event_cachep = KMEM_CACHE(fanotify_event_info, SLAB_PANIC|SLAB_ACCOUNT);
>>   #ifdef CONFIG_FANOTIFY_ACCESS_PERMISSIONS
>>          fanotify_perm_event_cachep = KMEM_CACHE(fanotify_perm_event_info,
>> -                                               SLAB_PANIC);
>> +                                               SLAB_PANIC|SLAB_ACCOUNT);
>>   #endif
>>
>>          return 0;
>> diff --git a/fs/notify/fsnotify.c b/fs/notify/fsnotify.c
>> index 0c4583b..82620ac 100644
>> --- a/fs/notify/fsnotify.c
>> +++ b/fs/notify/fsnotify.c
>> @@ -386,7 +386,7 @@ static __init int fsnotify_init(void)
>>                  panic("initializing fsnotify_mark_srcu");
>>
>>          fsnotify_mark_connector_cachep = KMEM_CACHE(fsnotify_mark_connector,
>> -                                                   SLAB_PANIC);
>> +                                                   SLAB_PANIC|SLAB_ACCOUNT);
>>
>>          return 0;
>>   }
>> diff --git a/fs/notify/inotify/inotify_user.c b/fs/notify/inotify/inotify_user.c
>> index 7cc7d3f..57b32ff 100644
>> --- a/fs/notify/inotify/inotify_user.c
>> +++ b/fs/notify/inotify/inotify_user.c
>> @@ -785,7 +785,7 @@ static int __init inotify_user_setup(void)
>>
>>          BUG_ON(hweight32(ALL_INOTIFY_BITS) != 21);
>>
>> -       inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC);
>> +       inotify_inode_mark_cachep = KMEM_CACHE(inotify_inode_mark, SLAB_PANIC|SLAB_ACCOUNT);
>>
>>          inotify_max_queued_events = 16384;
>>          init_user_ns.ucount_max[UCOUNT_INOTIFY_INSTANCES] = 128;
>> --
>> 1.8.3.1
>>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
