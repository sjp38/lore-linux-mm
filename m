Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id C174B8D0039
	for <linux-mm@kvack.org>; Fri,  4 Mar 2011 15:56:16 -0500 (EST)
Received: by yib2 with SMTP id 2so1173338yib.14
        for <linux-mm@kvack.org>; Fri, 04 Mar 2011 12:56:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1299271377.2071.1406.camel@dan>
References: <1299174652.2071.12.camel@dan>
	<1299185882.3062.233.camel@calx>
	<1299186986.2071.90.camel@dan>
	<1299188667.3062.259.camel@calx>
	<1299191400.2071.203.camel@dan>
	<2DD7330B-2FED-4E58-A76D-93794A877A00@mit.edu>
	<AANLkTimpfk8EHjVKYsJv0p_G7tS2yB-n=PPbD2v7xefV@mail.gmail.com>
	<1299260164.8493.4071.camel@nimitz>
	<AANLkTim+XcYiiM9u8nT659FHaZO1RPDEtyAgFtiA8VOk@mail.gmail.com>
	<1299262495.3062.298.camel@calx>
	<AANLkTimRN_=APe_PWMFe_6CHHC7psUbCYE-O0qc=mmYY@mail.gmail.com>
	<1299270709.3062.313.camel@calx>
	<1299271377.2071.1406.camel@dan>
Date: Fri, 4 Mar 2011 22:56:15 +0200
Message-ID: <AANLkTik6tAfaSr3wxdQ1u_Hd326TmNZe0-FQc3NuYMKN@mail.gmail.com>
Subject: Re: [PATCH] Make /proc/slabinfo 0400
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: Matt Mackall <mpm@selenic.com>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Theodore Tso <tytso@mit.edu>, cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-03-04 at 14:31 -0600, Matt Mackall wrote:
>> On Fri, 2011-03-04 at 22:02 +0200, Pekka Enberg wrote:
>> > On Fri, Mar 4, 2011 at 8:14 PM, Matt Mackall <mpm@selenic.com> wrote:
>> > >> Of course, as you say, '/proc/meminfo' still does give you the trig=
ger
>> > >> for "oh, now somebody actually allocated a new page". That's totall=
y
>> > >> independent of slabinfo, though (and knowing the number of active
>> > >> slabs would neither help nor hurt somebody who uses meminfo - you
>> > >> might as well allocate new sockets in a loop, and use _only_ meminf=
o
>> > >> to see when that allocated a new page).
>> > >
>> > > I think lying to the user is much worse than changing the permission=
s.
>> > > The cost of the resulting confusion is WAY higher.
>> >
>> > Yeah, maybe. I've attached a proof of concept patch that attempts to
>> > randomize object layout in individual slabs. I'm don't completely
>> > understand the attack vector so I don't make any claims if the patch
>> > helps or not.
>>
>> In general, the attack relies on getting an object A (vulnerable to
>> overrun) immediately beneath an object B (that can be exploited when
>> overrun).
>>
>> I'm not sure how much randomization helps, though. Allocate 1000 objects
>> of type B, deallocate the 800th, then allocate an object of type A. It's
>> almost certainly next to a B.

On Fri, Mar 4, 2011 at 10:42 PM, Dan Rosenberg <drosenberg@vsecurity.com> w=
rote:
> On second thought, this does pose a problem. =A0Even if you don't know ho=
w
> full the most recent slab is or where free vs. used chunks are within
> it, if you can guarantee that you filled an entire previous slab with
> your objects and then free and reallocate one of them, then you can
> still win.

Guys, I still don't get it, sorry.

Why can you still win? With my patch, reallocation shouldn't matter;
the freelist randomization ought to make it less likely for *any* two
allocated objects to be adjacent.

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
