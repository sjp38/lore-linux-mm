Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 69FB46B02F6
	for <linux-mm@kvack.org>; Thu, 22 Feb 2018 11:44:31 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id c135so4338589qkb.10
        for <linux-mm@kvack.org>; Thu, 22 Feb 2018 08:44:31 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n29sor410025qtl.18.2018.02.22.08.44.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 22 Feb 2018 08:44:30 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180222144844.g4p2diu3cnbr7sx3@quack2.suse.cz>
References: <20180221030101.221206-1-shakeelb@google.com> <20180221030101.221206-4-shakeelb@google.com>
 <20180222134944.GK30681@dhcp22.suse.cz> <20180222144844.g4p2diu3cnbr7sx3@quack2.suse.cz>
From: Yang Shi <shy828301@gmail.com>
Date: Thu, 22 Feb 2018 08:44:29 -0800
Message-ID: <CAHbLzkpdQxxHqiexyR5OYHKuZEq4uzthY4Of+APQqyE+dk3ZOg@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] fs: fsnotify: account fsnotify metadata to kmemcg
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Michal Hocko <mhocko@kernel.org>, Shakeel Butt <shakeelb@google.com>, Amir Goldstein <amir73il@gmail.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Feb 22, 2018 at 6:48 AM, Jan Kara <jack@suse.cz> wrote:
> On Thu 22-02-18 14:49:44, Michal Hocko wrote:
>> On Tue 20-02-18 19:01:01, Shakeel Butt wrote:
>> > A lot of memory can be consumed by the events generated for the huge or
>> > unlimited queues if there is either no or slow listener. This can cause
>> > system level memory pressure or OOMs. So, it's better to account the
>> > fsnotify kmem caches to the memcg of the listener.
>>
>> How much memory are we talking about here?
>
> 32 bytes per event (on 64-bit) which is small but the number of events is
> not limited in any way (if the creator uses a special flag and has
> CAP_SYS_ADMIN). In the thread [1] a guy from Alibaba wanted this feature so
> among cloud people there is apparently some demand to have a way to limit
> memory usage of such application...

Yes, I'm the guy from Alibaba :-) We did run into such issue
occasionally, then I proposed the patch to account fsnotify kmem in
memcg although we fixed the bug in user space applications later.
However, such accounting still sounds useful to me.

>
>> > There are seven fsnotify kmem caches and among them allocations from
>> > dnotify_struct_cache, dnotify_mark_cache, fanotify_mark_cache and
>> > inotify_inode_mark_cachep happens in the context of syscall from the
>> > listener. So, SLAB_ACCOUNT is enough for these caches.
>> >
>> > The objects from fsnotify_mark_connector_cachep are not accounted as
>> > they are small compared to the notification mark or events and it is
>> > unclear whom to account connector to since it is shared by all events
>> > attached to the inode.
>> >
>> > The allocations from the event caches happen in the context of the event
>> > producer. For such caches we will need to remote charge the allocations
>> > to the listener's memcg. Thus we save the memcg reference in the
>> > fsnotify_group structure of the listener.
>>
>> Is it typical that the listener lives in a different memcg and if yes
>> then cannot this cause one memcg to OOM/DoS the one with the listener?
>
> We have been through these discussions already in [1] back in November :).
> I can understand the wish to limit memory usage of an application using
> unlimited fanotify queues. And yes, it may mean that it will be easier for
> an attacker to get it oom-killed (currently the malicious app would drive
> the whole system oom which will presumably take a bit more effort as there
> is more memory to consume). But then I expect this is what admin prefers
> when he limits memory usage of fanotify listener.
>
> I cannot tell how common it is for producer and listener to be in different
> memcgs. From Alibaba request it seems it happens...

For our usecase, we didn't have producers and listeners in the
different memcgs (Please see the original discussion here
https://lkml.org/lkml/2017/10/20/819). The different memcg accounting
problem is raised by Amir since the accounting might be unfair if the
listeners don't consume events and heuristic if producer and listener
are in the different memcgs.

However, we don't have strong demand on this from our perspective for
the time being. So, I didn't continue to move forward on this
approach.

Regards,
Yang


>
>                                                                 Honza
>
> [1] https://lkml.org/lkml/2017/10/27/523
> --
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
