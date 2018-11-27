Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id D10B86B44C0
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 19:36:41 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id c3so10177934eda.3
        for <linux-mm@kvack.org>; Mon, 26 Nov 2018 16:36:41 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y24sor1553577edc.21.2018.11.26.16.36.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 26 Nov 2018 16:36:40 -0800 (PST)
Date: Tue, 27 Nov 2018 00:36:38 +0000
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH] mm: use this_cpu_cmpxchg_double in put_cpu_partial
Message-ID: <20181127003638.2oyudcyene6hb6sb@master>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <20181117013335.32220-1-wen.gang.wang@oracle.com>
 <5BF36EE9.9090808@huawei.com>
 <CADZGycb=kxdqSdbdXNWwmgyWp2CtC3-UFmy1-PqtdgS2BrmyjA@mail.gmail.com>
 <476b5d35-1894-680c-2bd9-b399a3f4d9ed@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <476b5d35-1894-680c-2bd9-b399a3f4d9ed@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang Wang <wen.gang.wang@oracle.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, zhong jiang <zhongjiang@huawei.com>, Christopher Lameter <cl@linux.com>, penberg@kernel.org, David Rientjes <rientjes@google.com>, iamjoonsoo.kim@lge.com, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Mon, Nov 26, 2018 at 08:57:54AM -0800, Wengang Wang wrote:
>
>
>On 2018/11/25 17:59, Wei Yang wrote:
>> On Tue, Nov 20, 2018 at 10:58 AM zhong jiang <zhongjiang@huawei.com> wrote:
>> > On 2018/11/17 9:33, Wengang Wang wrote:
>> > > The this_cpu_cmpxchg makes the do-while loop pass as long as the
>> > > s->cpu_slab->partial as the same value. It doesn't care what happened to
>> > > that slab. Interrupt is not disabled, and new alloc/free can happen in the
>> > > interrupt handlers. Theoretically, after we have a reference to the it,
>> > > stored in _oldpage_, the first slab on the partial list on this CPU can be
>> > > moved to kmem_cache_node and then moved to different kmem_cache_cpu and
>> > > then somehow can be added back as head to partial list of current
>> > > kmem_cache_cpu, though that is a very rare case. If that rare case really
>> > > happened, the reading of oldpage->pobjects may get a 0xdead0000
>> > > unexpectedly, stored in _pobjects_, if the reading happens just after
>> > > another CPU removed the slab from kmem_cache_node, setting lru.prev to
>> > > LIST_POISON2 (0xdead000000000200). The wrong _pobjects_(negative) then
>> > > prevents slabs from being moved to kmem_cache_node and being finally freed.
>> > > 
>> > > We see in a vmcore, there are 375210 slabs kept in the partial list of one
>> > > kmem_cache_cpu, but only 305 in-use objects in the same list for
>> > > kmalloc-2048 cache. We see negative values for page.pobjects, the last page
>> > > with negative _pobjects_ has the value of 0xdead0004, the next page looks
>> > > good (_pobjects is 1).
>> > > 
>> > > For the fix, I wanted to call this_cpu_cmpxchg_double with
>> > > oldpage->pobjects, but failed due to size difference between
>> > > oldpage->pobjects and cpu_slab->partial. So I changed to call
>> > > this_cpu_cmpxchg_double with _tid_. I don't really want no alloc/free
>> > > happen in between, but just want to make sure the first slab did expereince
>> > > a remove and re-add. This patch is more to call for ideas.
>> > Have you hit the really issue or just review the code ?
>> > 
>> > I did hit the issue and fixed in the upstream patch unpredictably by the following patch.
>> > e5d9998f3e09 ("slub: make ->cpu_partial unsigned int")
>> > 
>> Zhong,
>> 
>> I took a look into your upstream patch, while I am confused how your patch
>> fix this issue?
>> 
>> In put_cpu_partial(), the cmpxchg compare cpu_slab->partial (a page struct)
>> instead of the cpu_partial (an unsigned integer). I didn't get the
>> point of this fix.
>
>I think the patch can't prevent pobjects from being set as 0xdead0000 (the
>primary 4 bytes of LIST_POISON2).
>But if pobjects is treated as unsigned integer,
>
>2266???????????????????????????????????????????????? pobjects = oldpage->pobjects;
>2267???????????????????????????????????????????????? pages = oldpage->pages;
>2268???????????????????????????????????????????????? if (drain && pobjects > s->cpu_partial) {
>2269???????????????????????????????????????????????????????????????? unsigned long flags;
>

Ehh..., you mean (0xdead0000 > 0x02) ?

This is really a bad thing, if it wordarounds the problem like this.
I strongly don't agree this is a *fix*. This is too tricky.

>line 2268 will be true in put_cpu_partial(), thus code goes to
>unfreeze_partials(). This way the slabs in the cpu partial list can be moved
>to kmem_cache_nod and then freed. So it fixes (or say workarounds) the
>problem I see here (huge number of empty slabs stay in cpu partial list).
>
>thanks
>wengang
>
>> > Thanks,
>> > zhong jiang

-- 
Wei Yang
Help you, Help me
