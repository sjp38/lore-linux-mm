Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 0193482F65
	for <linux-mm@kvack.org>; Tue,  6 Oct 2015 04:03:18 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so62909342pad.1
        for <linux-mm@kvack.org>; Tue, 06 Oct 2015 01:03:17 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id xm2si47031287pbb.66.2015.10.06.01.03.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA256 bits=128/128);
        Tue, 06 Oct 2015 01:03:17 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <20150922160608.GA2716@redhat.com>
	<20150923205923.GB19054@dhcp22.suse.cz>
	<alpine.DEB.2.10.1509241359100.32488@chino.kir.corp.google.com>
	<20150925093556.GF16497@dhcp22.suse.cz>
	<201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
Date: Tue, 06 Oct 2015 02:55:18 -0500
In-Reply-To: <CA+55aFw=OLSdh-5Ut2vjy=4Yf1fTXqpzoDHdF7XnT5gDHs6sYA@mail.gmail.com>
	(Linus Torvalds's message of "Fri, 2 Oct 2015 15:01:06 -0400")
Message-ID: <87k2r0ph21.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: can't oom-kill zap the victim's memory?
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>

Linus Torvalds <torvalds@linux-foundation.org> writes:

> On Fri, Oct 2, 2015 at 8:36 AM, Michal Hocko <mhocko@kernel.org> wrote:
>>
>> Have they been reported/fixed? All kernel paths doing an allocation are
>> _supposed_ to check and handle ENOMEM. If they are not then they are
>> buggy and should be fixed.
>
> No. Stop this theoretical idiocy.
>
> We've tried it. I objected before people tried it, and it turns out
> that it was a horrible idea.
>
> Small kernel allocations should basically never fail, because we end
> up needing memory for random things, and if a kmalloc() fails it's
> because some application is using too much memory, and the application
> should be killed. Never should the kernel allocation fail. It really
> is that simple. If we are out of memory, that does not mean that we
> should start failing random kernel things.
>
> So this "people should check for allocation failures" is bullshit.
> It's a computer science myth. It's simply not true in all cases.
>
> Kernel allocators that know that they do large allocations (ie bigger
> than a few pages) need to be able to handle the failure, but not the
> general case. Also, kernel allocators that know they have a good
> fallback (eg they try a large allocation first but can fall back to a
> smaller one) should use __GFP_NORETRY, but again, that does *not* in
> any way mean that general kernel allocations should randomly fail.
>
> So no. The answer is ABSOLUTELY NOT "everybody should check allocation
> failure". Get over it. I refuse to go through that circus again. It's
> stupid.

Not to take away from your point about very small allocations.  However
assuming allocations larger than a page will always succeed is down
right dangerous.  Last time this issue rose up and bit me I sat down and
did the math, and it is ugly.  You have to have 50% of the memory free
to guarantee that an order 1 allocation will succeed.

So quite frankly I think it is only safe to require order 0 alloctions
to succeed.  Larger allocations do fail in practice, and it causes real
problems on real workloads when we try and loop forever waiting for
something that will never come.

My analysis from when it bit me.

commit 96c7a2ff21501691587e1ae969b83cbec8b78e08
Author: Eric W. Biederman <ebiederm@xmission.com>
Date:   Mon Feb 10 14:25:41 2014 -0800

    fs/file.c:fdtable: avoid triggering OOMs from alloc_fdmem
    
    Recently due to a spike in connections per second memcached on 3
    separate boxes triggered the OOM killer from accept.  At the time the
    OOM killer was triggered there was 4GB out of 36GB free in zone 1.  The
    problem was that alloc_fdtable was allocating an order 3 page (32KiB) to
    hold a bitmap, and there was sufficient fragmentation that the largest
    page available was 8KiB.
    
    I find the logic that PAGE_ALLOC_COSTLY_ORDER can't fail pretty dubious
    but I do agree that order 3 allocations are very likely to succeed.
    
    There are always pathologies where order > 0 allocations can fail when
    there are copious amounts of free memory available.  Using the pigeon
    hole principle it is easy to show that it requires 1 page more than 50%
    of the pages being free to guarantee an order 1 (8KiB) allocation will
    succeed, 1 page more than 75% of the pages being free to guarantee an
    order 2 (16KiB) allocation will succeed and 1 page more than 87.5% of
    the pages being free to guarantee an order 3 allocate will succeed.
    
    A server churning memory with a lot of small requests and replies like
    memcached is a common case that if anything can will skew the odds
    against large pages being available.
    
    Therefore let's not give external applications a practical way to kill
    linux server applications, and specify __GFP_NORETRY to the kmalloc in
    alloc_fdmem.  Unless I am misreading the code and by the time the code
    reaches should_alloc_retry in __alloc_pages_slowpath (where
    __GFP_NORETRY becomes signification).  We have already tried everything
    reasonable to allocate a page and the only thing left to do is wait.  So
    not waiting and falling back to vmalloc immediately seems like the
    reasonable thing to do even if there wasn't a chance of triggering the
    OOM killer.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
