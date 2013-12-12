Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f46.google.com (mail-yh0-f46.google.com [209.85.213.46])
	by kanga.kvack.org (Postfix) with ESMTP id EF5026B0035
	for <linux-mm@kvack.org>; Thu, 12 Dec 2013 13:42:41 -0500 (EST)
Received: by mail-yh0-f46.google.com with SMTP id l109so662696yhq.19
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:42:41 -0800 (PST)
Received: from mail-vb0-x229.google.com (mail-vb0-x229.google.com [2607:f8b0:400c:c02::229])
        by mx.google.com with ESMTPS id x18si19612253qef.89.2013.12.12.10.42.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 12 Dec 2013 10:42:40 -0800 (PST)
Received: by mail-vb0-f41.google.com with SMTP id m10so595834vbh.28
        for <linux-mm@kvack.org>; Thu, 12 Dec 2013 10:42:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20131212142156.GB32683@htj.dyndns.org>
References: <20131204054533.GZ3556@cmpxchg.org> <alpine.DEB.2.02.1312041742560.20115@chino.kir.corp.google.com>
 <20131205025026.GA26777@htj.dyndns.org> <alpine.DEB.2.02.1312051537550.7717@chino.kir.corp.google.com>
 <20131206190105.GE13373@htj.dyndns.org> <alpine.DEB.2.02.1312061441390.8949@chino.kir.corp.google.com>
 <20131210215037.GB9143@htj.dyndns.org> <alpine.DEB.2.02.1312101522400.22701@chino.kir.corp.google.com>
 <20131211124240.GA24557@htj.dyndns.org> <CAAAKZwsmM-C=kLGV=RW=Y4Mq=BWpQzuPruW6zvEr9p0Xs4GD5g@mail.gmail.com>
 <20131212142156.GB32683@htj.dyndns.org>
From: Tim Hockin <thockin@hockin.org>
Date: Thu, 12 Dec 2013 10:42:20 -0800
Message-ID: <CAAAKZwtuydFdiiSsKMuOUv3nr9trjuKvKoDO2aM0QsJKu1TMZA@mail.gmail.com>
Subject: Re: [patch 7/8] mm, memcg: allow processes handling oom notifications
 to access reserves
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Li Zefan <lizefan@huawei.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Cgroups <cgroups@vger.kernel.org>

On Thu, Dec 12, 2013 at 6:21 AM, Tejun Heo <tj@kernel.org> wrote:
> Hey, Tim.
>
> Sidenote: Please don't top-post with the whole body quoted below
> unless you're adding new cc's.  Please selectively quote the original
> message's body to remind the readers of the context and reply below
> it.  It's a basic lkml etiquette and one with good reasons.  If you
> have to top-post for whatever reason - say you're typing from a
> machine which doesn't allow easy editing of the original message,
> explain so at the top of the message, or better yet, wait till you can
> unless it's urgent.

Yeah sorry.  Replying from my phone is awkward at best.  I know better :)

> On Wed, Dec 11, 2013 at 09:37:46PM -0800, Tim Hockin wrote:
>> The immediate problem I see with setting aside reserves "off the top"
>> is that we don't really know a priori how much memory the kernel
>> itself is going to use, which could still land us in an overcommitted
>> state.
>>
>> In other words, if I have your 128 MB machine, and I set aside 8 MB
>> for OOM handling, and give 120 MB for jobs, I have not accounted for
>> the kernel.  So I set aside 8 MB for OOM and 100 MB for jobs, leaving
>> 20 MB for jobs.  That should be enough right?  Hell if I know, and
>> nothing ensures that.
>
> Yes, sure thing, that's the reason why I mentioned "with some slack"
> in the original message and also that it might not be completely the
> same.  It doesn't allow you to aggressively use system level OOM
> handling as the sizing estimator for the root cgroup; however, it's
> more of an implementation details than something which should guide
> the overall architecture - it's a problem which lessens in severity as
> [k]memcg improves and its coverage becomes more complete, which is the
> direction we should be headed no matter what.

In my mind, the ONLY point of pulling system-OOM handling into
userspace is to make it easier for crazy people (Google) to implement
bizarre system-OOM policies.  Example:

When we have a system OOM we want to do a walk of the administrative
memcg tree (which is only a couple levels deep, users can make
non-admin sub-memcgs), selecting the lowest priority entity at each
step (where both tasks and memcgs have a priority and the priority
range is much wider than the current OOM scores, and where memcg
priority is sometimes a function of memcg usage), until we reach a
leaf.

Once we reach a leaf, I want to log some info about the memcg doing
the allocation, the memcg being terminated, and maybe some other bits
about the system (depending on the priority of the selected victim,
this may or may not be an "acceptable" situation).  Then I want to
kill *everything* under that memcg.  Then I want to "publish" some
information through a sane API (e.g. not dmesg scraping).

This is basically our policy as we understand it today.  This is
notably different than it was a year ago, and it will probably evolve
further in the next year.

Teaching the kernel all of this stuff has proven to be sort of
difficult to maintain and forward-port, and has been very slow to
evolve because of how painful it is to test and deploy new kernels.

Maybe we can find a way to push this level of policy down to the
kernel OOM killer?  When this was mentioned internally I got shot down
(gently, but shot down none the less).  Assuming we had
nearly-reliable (it doesn't have to be 100% guaranteed to be useful)
OOM-in-userspace, I can keep the adminstrative memcg metadata in
memory, implement killing as cruelly as I need, and do all of the
logging and publication after the OOM kill is done.  Most importantly
I can test and deploy new policy changes pretty trivially.

Handling per-memcg OOM is a different discussion.  Here is where we
want to be able to extract things like heap profiles or take stats
snapshots, grow memcgs (if so configured) etc.  Allowing our users to
have a moment of mercy before we put a bullet in their brain enables a
whole new realm of debugging, as well as a lot of valuable features.

> It'd depend on the workload but with memcg fully configured it
> shouldn't fluctuate wildly.  If it does, we need to hunt down whatever
> is causing such fluctuatation and include it in kmemcg, right?  That
> way, memcg as a whole improves for all use cases not just your niche
> one and I strongly believe that aligning as many use cases as possible
> along the same axis, rather than creating a large hole to stow away
> the exceptions, is vastly more beneficial to *everyone* in the long
> term.

We have a long tail of kernel memory usage.  If we provision machines
so that the "do work here" first-level memcg excludes the average
kernel usage, we have a huge number of machines that will fail to
apply OOM policy because of actual overcommitment.  If we provision
for 95th or 99th percentile kernel usage, we're wasting large amounts
of memory that could be used to schedule jobs.  This is the
fundamental problem we face with static apportionment (and we face it
in a dozen other situations, too).  Expressing this set-aside memory
as "off-the-top" rather than absolute limits makes the whole system
more flexible.

> There'd still be all the bells and whistles to configure and monitor
> system-level OOM and if there's justified need for improvements, we
> surely can and should do that; however, with the heavy lifting / hot
> path offloaded to the per-memcg userland OOM handlers, I believe it's
> reasonable to expect the burden on system OOM handler being noticeably
> less, which is the way it should be.  That's the last guard against
> the whole system completely locking up and we can't extend its
> capabilities beyond that easily and we most likely don't even want to.
>
> If I take back a step and look at the two options and their pros and
> cons, which path we should take is rather obvious to me.  I hope you
> see it too.
>
> Thanks.
>
> --
> tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
