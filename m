Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id A1F246B13F2
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 15:39:04 -0500 (EST)
Received: by vcbf13 with SMTP id f13so1837880vcb.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:39:03 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328905759.25989.57.camel@laptop>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<20120201170443.GE6731@somewhere.redhat.com>
	<CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	<4F2AAEB9.9070302@tilera.com>
	<CAOtvUMfE3xpwmRKnFPTsstr3SuUG7SnpWn5eomEQzkap4_nfrg@mail.gmail.com>
	<1328899148.25989.38.camel@laptop>
	<CAOtvUMfZ-sfTd-WTV=+RcerTk6ejC2mmjrMGg8KkdMR=RaV+CA@mail.gmail.com>
	<1328905759.25989.57.camel@laptop>
Date: Fri, 10 Feb 2012 22:39:02 +0200
Message-ID: <CAOtvUMeaL8-9wYYrC-05P95ZcYHnV5as0bjjv9gJSHKN+EFz0w@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Fri, Feb 10, 2012 at 10:29 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> w=
rote:
> On Fri, 2012-02-10 at 22:13 +0200, Gilad Ben-Yossef wrote:
>> My current understanding is that if I have a real time task and wish it
>> have a deterministic performance time, you should call mlockall() to loc=
k
>> the program data and text into physical memory so that =A0a =A0less ofte=
n taken
>> branch or access to a new data region will not result in a page fault.
>>
>> You still have to worry about TLB misses on non hardware page table
>> walk architecture, but at least everything is in the =A0page tables
>>
>> If there is a better way to do this? I'm always happy to learn new
>> ways to do things. :-)
>
> A rt application usually consists of a lot of non-rt parts and a usually
> relatively small rt part. Using mlockall() pins the entire application
> into memory, which while on the safe side is very often entirely too
> much.
>
> The alternative method is to only mlock the text and data used by the rt
> part. You need to be aware of what text runs in your rt part anyway,
> since you need to make sure it is in fact deterministic code.
>
> One of the ways of achieving this is using a special linker section for
> your vetted rt code and mlock()'ing only that text section.
>
> On thread creation, provide a custom allocated (and mlock()'ed) stack
> etc..
>
> Basically, if you can't tell a-priory what code is part of your rt part,
> you don't have an rt part ;-)
>

That I can totally agree with.

I guess mlockall() is still useful as a kind of hack for lazy people,
although if you say that this kind of laziness does not really mix
well with real
time programming I will tend to agree... :-)

Gilad



--=20
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"If you take a class in large-scale robotics, can you end up in a
situation where the homework eats your dog?"
=A0-- Jean-Baptiste Queru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
