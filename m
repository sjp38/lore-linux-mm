Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 59AA96B0003
	for <linux-mm@kvack.org>; Mon,  4 Jun 2018 04:42:02 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id b31-v6so20116313plb.5
        for <linux-mm@kvack.org>; Mon, 04 Jun 2018 01:42:02 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q6-v6sor8779326pgs.73.2018.06.04.01.42.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 04 Jun 2018 01:42:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <57176788.6562837.1527828823442.JavaMail.zimbra@redhat.com>
References: <f054219d-6daa-68b1-0c60-0acd9ad8c5ab@i-love.sakura.ne.jp>
 <1730157334.5467848.1527672937617.JavaMail.zimbra@redhat.com>
 <20180530104637.GC27180@dhcp22.suse.cz> <1684479370.5483281.1527680579781.JavaMail.zimbra@redhat.com>
 <20180530123826.GF27180@dhcp22.suse.cz> <20180531152225.2ck6ach4lma4zeim@armageddon.cambridge.arm.com>
 <20180531184104.GT15278@dhcp22.suse.cz> <1390612460.6539623.1527817820286.JavaMail.zimbra@redhat.com>
 <57176788.6562837.1527828823442.JavaMail.zimbra@redhat.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 4 Jun 2018 10:41:39 +0200
Message-ID: <CACT4Y+ZE_qbnqzjnhbrk=vhLqijKZ5x1QbtbJSyNuqA3htFgFA@mail.gmail.com>
Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chunyu Hu <chuhu@redhat.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org, Linux-MM <linux-mm@kvack.org>, Akinobu Mita <akinobu.mita@gmail.com>

On Fri, Jun 1, 2018 at 6:53 AM, Chunyu Hu <chuhu@redhat.com> wrote:
> ----- Original Message -----
>> From: "Chunyu Hu" <chuhu@redhat.com>
>> To: "Catalin Marinas" <catalin.marinas@arm.com>
>> Cc: "Michal Hocko" <mhocko@suse.com>, "Tetsuo Handa" <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org,
>> dvyukov@google.com, linux-mm@kvack.org, "Akinobu Mita" <akinobu.mita@gmail.com>
>> Sent: Friday, June 1, 2018 9:50:20 AM
>> Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
>>
>>
>>
>> ----- Original Message -----
>> > From: "Michal Hocko" <mhocko@suse.com>
>> > To: "Catalin Marinas" <catalin.marinas@arm.com>
>> > Cc: "Chunyu Hu" <chuhu@redhat.com>, "Tetsuo Handa"
>> > <penguin-kernel@i-love.sakura.ne.jp>, malat@debian.org,
>> > dvyukov@google.com, linux-mm@kvack.org, "Akinobu Mita"
>> > <akinobu.mita@gmail.com>
>> > Sent: Friday, June 1, 2018 2:41:04 AM
>> > Subject: Re: [PATCH] kmemleak: don't use __GFP_NOFAIL
>> >
>> > On Thu 31-05-18 16:22:26, Catalin Marinas wrote:
>> > > Hi Michal,
>> > >
>> > > I'm catching up with this thread.
>> > >
>> > > On Wed, May 30, 2018 at 02:38:26PM +0200, Michal Hocko wrote:
>> > > > On Wed 30-05-18 07:42:59, Chunyu Hu wrote:
>> > > > > From: "Michal Hocko" <mhocko@suse.com>
>> > > > > > want to have a pre-populated pool of objects for those requests.
>> > > > > > The
>> > > > > > obvious question is how to balance such a pool. It ain't easy to
>> > > > > > track
>> > > > > > memory by allocating more memory...
>> > > > >
>> > > > > This solution is going to make kmemleak trace really nofail. We can
>> > > > > think
>> > > > > later.
>> > > > >
>> > > > > while I'm thinking about if fault inject can be disabled via flag in
>> > > > > task.
>> > > > >
>> > > > > Actually, I'm doing something like below, the disable_fault_inject()
>> > > > > is
>> > > > > just setting a flag in task->make_it_fail. But this will depend on if
>> > > > > fault injection accept a change like this. CCing Akinobu
>> > > >
>> > > > You still seem to be missing my point I am afraid (or I am ;). So say
>> > > > that you want to track a GFP_NOWAIT allocation request. So
>> > > > create_object
>> > > > will get called with that gfp mask and no matter what you try here your
>> > > > tracking object will be allocated in a weak allocation context as well
>> > > > and disable kmemleak. So it only takes a more heavy memory pressure and
>> > > > the tracing is gone...
>> > >
>> > > create_object() indeed gets the originating gfp but it only cares
>> > > whether it was GFP_KERNEL or GFP_ATOMIC. gfp_kmemleak_mask() masks out
>> > > all the other flags when allocating a struct kmemleak_object (and adds
>> > > some of its own).
>> > >
>> > > This has worked ok so far. There is a higher risk of GFP_ATOMIC
>> > > allocations failing but I haven't seen issues with kmemleak unless you
>> > > run it under heavy memory pressure (and kmemleak just disables itself).
>> > > With fault injection, such pressure is simulated with the side effect of
>> > > rendering kmemleak unusable.
>> > >
>> > > Kmemleak could implement its own allocation mechanism (maybe even
>> > > skipping the slab altogether) but I feel it's overkill just to cope with
>> > > the specific case of fault injection. Also, it's not easy to figure out
>> > > how to balance such pool and it may end up calling alloc_pages() which
>> > > in turn can inject a fault.
>>
>>
>> it would benefit kmemleak trace, I see in my test that kmemleak even can work
>> in
>> user pressure cases, such as in my test, stress-ng to consume
>> nearly all the swap space. kmemleak is still working. but 1M objects pool
>> is consuming around 400M + memory. So this is just a experiment try, as you
>> said, how to balance it's size is the issue or ther issues has to be
>> resolved,
>> such as when to add pool, the speed, how big, and so on ...
>>
>> And I fault injected 20000 times fail_page_alloc, and 2148 times happened
>> in create_object, and in such a case, kmemleak is till working after the
>> 2000+ calloc failures.
>>
>> [root@dhcp-12-244 fail_page_alloc]# grep create_object /var/log/messages | wc
>> -l
>> 2148
>>
>> [60498.299412] FAULT_INJECTION: forcing a failure.
>> name fail_page_alloc, interval 0, probability 80, space 0, times 2
>>
>> So this way is not just for fault injection, it's about making kmemleak
>> a bit stronger under memory failure case. It would be an exciting experience
>> we
>> see if kmemleak still work even after mem pressure, as a user, I experienced
>> the good usage.
>>
>>
>> > >
>> > > Could we tweak gfp_kmemleak_mask() to still pass __GFP_NOFAIL but in a
>> > > compatible way (e.g. by setting __GFP_DIRECT_RECLAIM) when fault
>> > > injection is enabled?
>>
>> Maybe I can have a try on this..
>
> looks like I tried this in my first report thread, and it failed. As it
> can sleep in irq() ..
>
> https://marc.info/?l=linux-mm&m=152482400222806&w=2
>
>>
>> > >
>> > > Otherwise, I'd prefer some per-thread temporary fault injection
>> > > disabling.
>>
>> I tried in make_it_fail flag, kmemleak can avoid fault injection, but I
>> can see kmemleak diabled itself...
>>
>> >
>> > Well, there are two issues (which boil down to the one in the end) here.
>> > Fault injection or a GFP_NOWAIT or any other weaker than GFP_KERNEL
>> > context is something to care about. A weaker allocation context can and
>> > will lead to kmemleak meta data allocation failures regardless of the
>> > fault injection. The way how those objects are allocated directly in the
>> > allacator context makes this really hard and inherently subtle. I can
>> > see only two ways around. Either you have a placeholder for "this object
>> > is not tracked so do not throw false positives" or have a preallocated
>> > pool to use if the direct context allocation failes for whatever reason.
>> > Abusing __GFP_NOFAIL is simply a crude hack which will lead to all kind
>> > of problems.



FWIW this problem is traditionally solved in dynamic analysis tools by
embedding meta info right in headers of heap blocks. All of KASAN,
KMSAN, slub debug, LeakSanitizer, asan, valgrind work this way. Then
an object is either allocated or not. If caller has something to
prevent allocations from failing in any context, then the same will be
true for KMEMLEAK meta data.

On a related note, we could also consider switching to
lib/stackdepot.c for alloc stack memorization to reduce header size.
stackdepot is not 100% proof against allocation failures in atomic
contexts, but it does eager memory preallocation and seems to work
well in practice.
