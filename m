Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 436BE6B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 15:59:47 -0500 (EST)
Received: by fg-out-1718.google.com with SMTP id d23so2591011fga.8
        for <linux-mm@kvack.org>; Tue, 24 Nov 2009 12:59:45 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091124162311.GA8679@linux.vnet.ibm.com>
References: <20091118181202.GA12180@linux.vnet.ibm.com>
	 <84144f020911192249l6c7fa495t1a05294c8f5b6ac8@mail.gmail.com>
	 <1258709153.11284.429.camel@laptop>
	 <84144f020911200238w3d3ecb38k92ca595beee31de5@mail.gmail.com>
	 <1258714328.11284.522.camel@laptop> <4B067816.6070304@cs.helsinki.fi>
	 <1258729748.4104.223.camel@laptop>
	 <1259002800.5630.1.camel@penberg-laptop>
	 <20091124162311.GA8679@linux.vnet.ibm.com>
Date: Tue, 24 Nov 2009 22:59:44 +0200
Message-ID: <84144f020911241259r3a604b29yb59902655ec03a20@mail.gmail.com>
Subject: Re: lockdep complaints in slab allocator
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: paulmck@linux.vnet.ibm.com
Cc: Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com, LKML <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 24, 2009 at 6:23 PM, Paul E. McKenney
<paulmck@linux.vnet.ibm.com> wrote:
> On Mon, Nov 23, 2009 at 09:00:00PM +0200, Pekka Enberg wrote:
>> Hi Peter,
>>
>> On Fri, 2009-11-20 at 16:09 +0100, Peter Zijlstra wrote:
>> > > Uh, ok, so apparently I was right after all. There's a comment in
>> > > free_block() above the slab_destroy() call that refers to the commen=
t
>> > > above alloc_slabmgmt() function definition which explains it all.
>> > >
>> > > Long story short: ->slab_cachep never points to the same kmalloc cac=
he
>> > > we're allocating or freeing from. Where do we need to put the
>> > > spin_lock_nested() annotation? Would it be enough to just use it in
>> > > cache_free_alien() for alien->lock or do we need it in
>> > > cache_flusharray() as well?
>> >
>> > You'd have to somehow push the nested state down from the
>> > kmem_cache_free() call in slab_destroy() to all nc->lock sites below.
>>
>> That turns out to be _very_ hard. How about something like the following
>> untested patch which delays slab_destroy() while we're under nc->lock.
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Pekka
>
> Preliminary tests look good! =A0The test was a ten-hour rcutorture run on
> an 8-CPU Power system with a half-second delay between randomly chosen
> CPU-hotplug operations. =A0No lockdep warnings. =A0;-)
>
> Will keep hammering on it.

Thanks! Please let me know when you're hammered it enough :-). Peter,
may I have your ACK or NAK on the patch, please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
