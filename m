Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 21F336B00C7
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 12:29:55 -0400 (EDT)
Received: by wibhm6 with SMTP id hm6so3177372wib.8
        for <linux-mm@kvack.org>; Tue, 11 Sep 2012 09:29:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <504EA6FE.7070405@linux.vnet.ibm.com>
References: <5044692D.7080608@linux.vnet.ibm.com>
	<5046B9EE.7000804@linux.vnet.ibm.com>
	<0000013996b6f21d-d45be653-3111-4aef-b079-31dc673e6fd8-000000@email.amazonses.com>
	<504812E7.3000700@linux.vnet.ibm.com>
	<20120906222933.GR2448@linux.vnet.ibm.com>
	<CAOJsxLFA1sk4KZkRuPL_giktSkFK_g7w-mGi_OEQ9fVXF2UVzw@mail.gmail.com>
	<504EA6FE.7070405@linux.vnet.ibm.com>
Date: Tue, 11 Sep 2012 19:29:53 +0300
Message-ID: <CAOJsxLE4TEOJwAnB6M1SKqB1=M9vttHjw5XjNwfgO_ZiaUHyBQ@mail.gmail.com>
Subject: Re: [PATCH] slab: fix the DEADLOCK issue on l3 alien lock
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Wang <wangyun@linux.vnet.ibm.com>
Cc: paulmck@linux.vnet.ibm.com, Christoph Lameter <cl@linux.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>

On Tue, Sep 11, 2012 at 5:50 AM, Michael Wang
<wangyun@linux.vnet.ibm.com> wrote:
> On 09/08/2012 04:39 PM, Pekka Enberg wrote:
>> On Fri, Sep 7, 2012 at 1:29 AM, Paul E. McKenney
>> <paulmck@linux.vnet.ibm.com> wrote:
>>> On Thu, Sep 06, 2012 at 11:05:11AM +0800, Michael Wang wrote:
>>>> On 09/05/2012 09:55 PM, Christoph Lameter wrote:
>>>>> On Wed, 5 Sep 2012, Michael Wang wrote:
>>>>>
>>>>>> Since the cachep and cachep->slabp_cache's l3 alien are in the same lock class,
>>>>>> fake report generated.
>>>>>
>>>>> Ahh... That is a key insight into why this occurs.
>>>>>
>>>>>> This should not happen since we already have init_lock_keys() which will
>>>>>> reassign the lock class for both l3 list and l3 alien.
>>>>>
>>>>> Right. I was wondering why we still get intermitted reports on this.
>>>>>
>>>>>> This patch will invoke init_lock_keys() after we done enable_cpucache()
>>>>>> instead of before to avoid the fake DEADLOCK report.
>>>>>
>>>>> Acked-by: Christoph Lameter <cl@linux.com>
>>>>
>>>> Thanks for your review.
>>>>
>>>> And add Paul to the cc list(my skills on mailing is really poor...).
>>>
>>> Tested-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>>
>> I'd also like to tag this for the stable tree to avoid bogus lockdep
>> reports. How far back in release history should we queue this?
> Hi, Pekka
>
> Sorry for the delayed reply, I try to find out the reason for commit
> 30765b92 but not get it yet, so I add Peter to the cc list.
>
> The below patch for release 3.0.0 is the one to cause the bogus report.
>
> commit 30765b92ada267c5395fc788623cb15233276f5c
> Author: Peter Zijlstra <peterz@infradead.org>
> Date:   Thu Jul 28 23:22:56 2011 +0200
>
>     slab, lockdep: Annotate the locks before using them
>
>     Fernando found we hit the regular OFF_SLAB 'recursion' before we
>     annotate the locks, cure this.
>
>     The relevant portion of the stack-trace:
>
>     > [    0.000000]  [<c085e24f>] rt_spin_lock+0x50/0x56
>     > [    0.000000]  [<c04fb406>] __cache_free+0x43/0xc3
>     > [    0.000000]  [<c04fb23f>] kmem_cache_free+0x6c/0xdc
>     > [    0.000000]  [<c04fb2fe>] slab_destroy+0x4f/0x53
>     > [    0.000000]  [<c04fb396>] free_block+0x94/0xc1
>     > [    0.000000]  [<c04fc551>] do_tune_cpucache+0x10b/0x2bb
>     > [    0.000000]  [<c04fc8dc>] enable_cpucache+0x7b/0xa7
>     > [    0.000000]  [<c0bd9d3c>] kmem_cache_init_late+0x1f/0x61
>     > [    0.000000]  [<c0bba687>] start_kernel+0x24c/0x363
>     > [    0.000000]  [<c0bba0ba>] i386_start_kernel+0xa9/0xaf
>
>     Reported-by: Fernando Lopez-Lezcano <nando@ccrma.Stanford.EDU>
>     Acked-by: Pekka Enberg <penberg@kernel.org>
>     Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
>     Link: http://lkml.kernel.org/r/1311888176.2617.379.camel@laptop
>     Signed-off-by: Ingo Molnar <mingo@elte.hu>
>
> It moved init_lock_keys() before we build up the alien, so we failed to
> reclass it.

I've queued the patch for v3.7. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
