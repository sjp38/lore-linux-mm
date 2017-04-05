Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 979C46B03A9
	for <linux-mm@kvack.org>; Wed,  5 Apr 2017 06:42:30 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g19so1029481wrb.4
        for <linux-mm@kvack.org>; Wed, 05 Apr 2017 03:42:30 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w63si5373013wrc.239.2017.04.05.03.42.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Apr 2017 03:42:29 -0700 (PDT)
Date: Wed, 5 Apr 2017 12:42:25 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/4] mm/vmalloc: allow to call vfree() in atomic context
Message-ID: <20170405104224.GH6035@dhcp22.suse.cz>
References: <20170330102719.13119-1-aryabinin@virtuozzo.com>
 <2cfc601e-3093-143e-b93d-402f330a748a@vmware.com>
 <a28cc48d-3d6f-b4dd-10c2-a75d2e83ef14@virtuozzo.com>
 <20170404094148.GJ15132@dhcp22.suse.cz>
 <d28bc808-0aab-d36a-f401-9925680fd131@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d28bc808-0aab-d36a-f401-9925680fd131@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Thomas Hellstrom <thellstrom@vmware.com>, akpm@linux-foundation.org, penguin-kernel@I-love.SAKURA.ne.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, chris@chris-wilson.co.uk, hch@lst.de, mingo@elte.hu, jszhang@marvell.com, joelaf@google.com, joaodias@google.com, willy@infradead.org, tglx@linutronix.de, stable@vger.kernel.org

On Wed 05-04-17 13:31:23, Andrey Ryabinin wrote:
> On 04/04/2017 12:41 PM, Michal Hocko wrote:
> > On Thu 30-03-17 17:48:39, Andrey Ryabinin wrote:
> >> From: Andrey Ryabinin <aryabinin@virtuozzo.com>
> >> Subject: mm/vmalloc: allow to call vfree() in atomic context fix
> >>
> >> Don't spawn worker if we already purging.
> >>
> >> Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> > 
> > I would rather put this into a separate patch. Ideally with some numners
> > as this is an optimization...
> > 
> 
> It's quite simple optimization and don't think that this deserves to
> be a separate patch.

I disagree. I am pretty sure nobody will remember after few years. I
do not want to push too hard on this but I can tell you from my own
experience that we used to do way too many optimizations like that in
the past and they tend to be real head scratchers these days. Moreover
people just tend to build on top of them without understadning and then
chances are quite high that they are no longer relevant anymore.

> But I did some measurements though. With enabled VMAP_STACK=y and
> NR_CACHED_STACK changed to 0 running fork() 100000 times gives this:
> 
> With optimization:
> 
> ~ # grep try_purge /proc/kallsyms 
> ffffffff811d0dd0 t try_purge_vmap_area_lazy
> ~ # perf stat --repeat 10 -ae workqueue:workqueue_queue_work --filter 'function == 0xffffffff811d0dd0' ./fork
> 
>  Performance counter stats for 'system wide' (10 runs):
> 
>                 15      workqueue:workqueue_queue_work                                     ( +-  0.88% )
> 
>        1.615368474 seconds time elapsed                                          ( +-  0.41% )
> 
> 
> Without optimization:
> ~ # grep try_purge /proc/kallsyms 
> ffffffff811d0dd0 t try_purge_vmap_area_lazy
> ~ # perf stat --repeat 10 -ae workqueue:workqueue_queue_work --filter 'function == 0xffffffff811d0dd0' ./fork
> 
>  Performance counter stats for 'system wide' (10 runs):
> 
>                 30      workqueue:workqueue_queue_work                                     ( +-  1.31% )
> 
>        1.613231060 seconds time elapsed                                          ( +-  0.38% )
> 
> 
> So there is no measurable difference on the test itself, but we queue
> twice more jobs without this optimization.  It should decrease load of
> kworkers.

And this is really valueable for the changelog!

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
