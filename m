Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id D63646B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 08:28:43 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id r58-v6so13336085otr.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 05:28:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 67-v6si14312378otl.401.2018.05.31.05.28.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 05:28:42 -0700 (PDT)
Date: Thu, 31 May 2018 08:28:41 -0400 (EDT)
From: Chunyu Hu <chuhu@redhat.com>
Reply-To: Chunyu Hu <chuhu@redhat.com>
Message-ID: <1565920114.5787741.1527769721089.JavaMail.zimbra@redhat.com>
In-Reply-To: <20180531113508.GO15278@dhcp22.suse.cz>
References: <CA+7wUswp_Sr=hHqi1bwRZ3FE2wY5ozZWZ8Z1BgrFnSAmijUKjA@mail.gmail.com> <f3d58cbd-29ca-7a23-69e0-59690b9cd4fb@i-love.sakura.ne.jp> <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com> <20180530104637.GC27180@dhcp22.suse.cz> <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com> <20180530123826.GF27180@dhcp22.suse.cz> <2074740225.5769475.1527763882580.JavaMail.zimbra@redhat.com> <20180531113508.GO15278@dhcp22.suse.cz>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org, catalin marinas <catalin.marinas@arm.com>, Akinobu Mita <akinobu.mita@gmail.com>



----- Original Message -----
> From: "Michal Hocko" <mhocko@suse.com>
> To: "Chunyu Hu" <chuhu@redhat.com>
> Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> "catalin marinas" <catalin.marinas@arm.com>, "Akinobu Mita" <akinobu.mita@gmail.com>
> Sent: Thursday, May 31, 2018 7:35:08 PM
> Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> 
> On Thu 31-05-18 06:51:22, Chunyu Hu wrote:
> > 
> > 
> > ----- Original Message -----
> > > From: "Michal Hocko" <mhocko@suse.com>
> > > To: "Chunyu Hu" <chuhu@redhat.com>
> > > Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>,
> > > malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> > > "catalin marinas" <catalin.marinas@arm.com>, "Akinobu Mita"
> > > <akinobu.mita@gmail.com>
> > > Sent: Wednesday, May 30, 2018 8:38:26 PM
> > > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> > > 
> > > On Wed 30-05-18 07:42:59, Chunyu Hu wrote:
> > > > 
> > > > ----- Original Message -----
> > > > > From: "Michal Hocko" <mhocko@suse.com>
> > > > > To: "Chunyu Hu" <chuhu@redhat.com>
> > > > > Cc: "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>,
> > > > > malat@debian.org, dvyukov@google.com, linux-mm@kvack.org,
> > > > > "catalin marinas" <catalin.marinas@arm.com>
> > > > > Sent: Wednesday, May 30, 2018 6:46:37 PM
> > > > > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
> > > > > 
> > > > > On Wed 30-05-18 05:35:37, Chunyu Hu wrote:
> > > > > [...]
> > > > > > I'm trying to reuse the make_it_fail field in task for fault
> > > > > > injection.
> > > > > > As
> > > > > > adding
> > > > > > an extra memory alloc flag is not thought so good,  I think adding
> > > > > > task
> > > > > > flag
> > > > > > is either?
> > > > > 
> > > > > Yeah, task flag will be reduced to KMEMLEAK enabled configurations
> > > > > without an additional maint. overhead. Anyway, you should really
> > > > > think
> > > > > about how to guarantee trackability for atomic allocation requests.
> > > > > You
> > > > > cannot simply assume that GFP_NOWAIT will succeed. I guess you really
> > > > 
> > > > Sure. While I'm using task->make_it_fail, I'm still in the direction of
> > > > making kmemleak avoid fault inject with task flag instead of page alloc
> > > > flag.
> > > > 
> > > > > want to have a pre-populated pool of objects for those requests. The
> > > > > obvious question is how to balance such a pool. It ain't easy to
> > > > > track
> > > > > memory by allocating more memory...
> > > > 
> > > > This solution is going to make kmemleak trace really nofail. We can
> > > > think
> > > > later.
> > > > 
> > > > while I'm thinking about if fault inject can be disabled via flag in
> > > > task.
> > > > 
> > > > Actually, I'm doing something like below, the disable_fault_inject() is
> > > > just setting a flag in task->make_it_fail. But this will depend on if
> > > > fault injection accept a change like this. CCing Akinobu
> > > 
> > > You still seem to be missing my point I am afraid (or I am ;). So say
> > > that you want to track a GFP_NOWAIT allocation request. So create_object
> > > will get called with that gfp mask and no matter what you try here your
> > > tracking object will be allocated in a weak allocation context as well
> > > and disable kmemleak. So it only takes a more heavy memory pressure and
> > > the tracing is gone...
> > 
> > Michal,
> > 
> > Thank you for the good suggestion. You mean GFP_NOWAIT still can make
> > create_object
> > fail and as a result kmemleak disable itself. So it's not so useful, just
> > like
> > the current __GFP_NOFAIL usage in create_object.
> > 
> > In the first thread, we discussed this. and that time you suggested we have
> > fault injection disabled when kmemleak is working and suggested per task
> > way.
> > so my head has been stuck in that point. While now you gave a better
> > suggestion
> > that why not we pre allocate a urgent pool for kmemleak objects. After
> > thinking
> > for a while, I got  your point, it's a good way for improving kmemleak to
> > make
> > it can tolerate light allocation failure. And catalin mentioned that we
> > have
> > one option that use the early_log array as urgent pool, which has the
> > similar
> > ideology.
> > 
> > Basing on your suggestions, I tried to draft this, what does it look to
> > you?
> > another strong alloc mask and an extra thread for fill the pool, which
> > containts
> > 1M objects in a frequency of 100 ms. If first kmem_cache_alloc failed, then
> > get a object from the pool.
> 
> I am not really familiar with kmemleak code base to judge the
> implementation. Could you be more specific about the highlevel design
> please? Who is the producer and how does it sync with consumers?

OK. 

To better describe. We know that, kmemleak_object is meta object for kmemleak
trace, and each time kmem_cache_alloc(or other) success, the another following
kmem_cache_alloc would be called (in create_object() to get a kmemleak_object 
and this must succeed, otherwise kmemleak would generate too many false positives
as a result of losing track to a memory block which could contain pointer to 
other objects. so kmemleak trace choose to disable itself when getting such
a allocation failure. 

When facing fault injection, this would become an issue that kmemleak would
easily disable itself when fault injected. And  memory allocation can
happen in irq context, so the followed kmemleak_alloc can't choose a
very strong way for allocation (such as blackable). So we can prepare
a dynamic kmemleak_object pool. And the design is in fact rather straight,
by maintaining a list of kmemleak_object. 

So the reproducer is a new kernel thread. which do a kmemleak_object(contains
list member itself, so easy to link) allocation every 100ms, in a strong
allocation way (can sleep and reclaim), to the pool_object_list, and the max
length of the list is 1024*1024 (1M).
 
  [pool_thread (reproducer)]                   
    pool_object_list<-->kmemleak_object<-->kmemleak_object...<-->...

And the consumer is create_object(). it can pick one from the list when
got failure in first weak allocation. 

  [task doing memory alloc (consumer)]
    kmem_cache_alloc()
        create_object() 
           kmem_cache_alloc()
             (fail ?)--Yes ---> (get kmemleak_object from the pool_object_lsit)
                     |_ No ---> got kmemleak_object
                  [insert kmemleak_object to rb tree]

And consumer and producer are synced with spinlock kmemleak_object_lock(maybe
call pool_object_lock)

  [spin lock]
  kmemleak_object_lock

Hope I described it clear...

-- 
Regards,
Chunyu Hu
