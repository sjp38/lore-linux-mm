Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9D88C6B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 04:30:18 -0400 (EDT)
Received: by bwz24 with SMTP id 24so2675913bwz.38
        for <linux-mm@kvack.org>; Tue, 15 Sep 2009 01:30:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d760cf2d0909150121i7f6f45b9p76f8eb89ab0d5882@mail.gmail.com>
References: <200909100215.36350.ngupta@vflare.org>
	 <200909100249.26284.ngupta@vflare.org>
	 <84144f020909141310y164b2d1ak44dd6945d35e6ec@mail.gmail.com>
	 <d760cf2d0909142339i30d74a9dic7ece86e7227c2e2@mail.gmail.com>
	 <84144f020909150030h1f9d8062sc39057b55a7ba6c0@mail.gmail.com>
	 <d760cf2d0909150121i7f6f45b9p76f8eb89ab0d5882@mail.gmail.com>
Date: Tue, 15 Sep 2009 11:30:16 +0300
Message-ID: <84144f020909150130r573df1e1jfe359b88387f94ad@mail.gmail.com>
Subject: Re: [PATCH 2/4] virtual block device driver (ramzswap)
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Nitin Gupta <ngupta@vflare.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Ed Tomlinson <edt@aei.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mm-cc@laptop.org, Ingo Molnar <mingo@elte.hu>, =?ISO-8859-1?Q?Fr=E9d=E9ric_Weisbecker?= <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Greg KH <greg@kroah.com>
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 11:21 AM, Nitin Gupta <ngupta@vflare.org> wrote:
> I don't want to ponder too much about this point now. If you all are okay
> with keeping this function buried in driver, I will do so. I'm almost tir=
ed
> maintaining this compcache thing outside of mainline.

Yup, whatever makes most sense to you.

>> Then make ramzswap depend on !CONFIG_ARM. In any case, CONFIG_ARM bits
>> really don't belong into drivers/block.
>
> ARM is an extremely important user of compcache -- Its currently being
> tested (unofficially) on Android, Nokia etc.

That's not a technical argument for keeping CONFIG_ARM in the driver.

>>>>> +
>>>>> + =A0 =A0 =A0 trace_mark(ramzswap_lock_wait, "ramzswap_lock_wait");
>>>>> + =A0 =A0 =A0 mutex_lock(&rzs->lock);
>>>>> + =A0 =A0 =A0 trace_mark(ramzswap_lock_acquired, "ramzswap_lock_acqui=
red");
>>>>
>>>> Hmm? What's this? I don't think you should be doing ad hoc
>>>> trace_mark() in driver code.
>>>
>>> This is not ad hoc. It is to see contention over this lock which I beli=
eve is a
>>> major bottleneck even on dual-cores. I need to keep this to measure imp=
rovements
>>> as I gradually make this locking more fine grained (using per-cpu buffe=
r etc).
>>
>> It is ad hoc. Talk to the ftrace folks how to do it properly. I'd keep
>> those bits out-of-tree until the issue is resolved, really.
>
> /me is speechless.

That's fine, I CC'd the ftrace folks. Hopefully they'll be able to help you=
.

>
>>>>> + =A0 =A0 =A0 rzs->compress_buffer =3D kzalloc(2 * PAGE_SIZE, GFP_KER=
NEL);
>>>>
>>>> Use alloc_pages(__GFP_ZERO) here?
>>>
>>> alloc pages then map them (i.e. vmalloc). What did we gain? With
>>> vmalloc, pages might
>>> not be physically contiguous which might hurt performance as
>>> compressor runs over this buffer.
>>>
>>> So, use kzalloc().
>>
>> I don't know what you're talking about. kzalloc() calls
>> __get_free_pages() directly for your allocation. You probably should
>> use that directly.
>
> What is wrong with kzalloc? I'm wholly totally stumped.
> I respect your time reviewing the code but this really goes over my head.
> We can continue arguing about get_pages vs kzalloc but I doubt if we will
> gain anything out of it.

The slab allocator needs metadata for the allocation so you're wasting
memory. If you really want *two pages*, why don't you simply use the
page allocator for that?

Btw, Nitin, why are you targeting drivers/block and not
drivers/staging at this point? It seems obvious enough that there are
still some issues that need to be ironed out (like the CONFIG_ARM
thing) so submitting the driver for inclusion in drivers/staging and
fixing it up there incrementally would likely save you from a lot of
trouble. Greg, does ramzswap sound like something that you'd be
willing to take?

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
