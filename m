Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 2A9B26B13F0
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 15:13:25 -0500 (EST)
Received: by vbip1 with SMTP id p1so2950705vbi.14
        for <linux-mm@kvack.org>; Fri, 10 Feb 2012 12:13:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1328899148.25989.38.camel@laptop>
References: <1327572121-13673-1-git-send-email-gilad@benyossef.com>
	<1327591185.2446.102.camel@twins>
	<CAOtvUMeAkPzcZtiPggacMQGa0EywTH5SzcXgWjMtssR6a5KFqA@mail.gmail.com>
	<20120201170443.GE6731@somewhere.redhat.com>
	<CAOtvUMc8L1nh2eGJez0x44UkfPCqd+xYQASsKOP76atopZi5mw@mail.gmail.com>
	<4F2AAEB9.9070302@tilera.com>
	<CAOtvUMfE3xpwmRKnFPTsstr3SuUG7SnpWn5eomEQzkap4_nfrg@mail.gmail.com>
	<1328899148.25989.38.camel@laptop>
Date: Fri, 10 Feb 2012 22:13:23 +0200
Message-ID: <CAOtvUMfZ-sfTd-WTV=+RcerTk6ejC2mmjrMGg8KkdMR=RaV+CA@mail.gmail.com>
Subject: Re: [v7 0/8] Reduce cross CPU IPI interference
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Chris Metcalf <cmetcalf@tilera.com>, Frederic Weisbecker <fweisbec@gmail.com>, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Sasha Levin <levinsasha928@gmail.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Avi Kivity <avi@redhat.com>, Michal Nazarewicz <mina86@mina86.com>, Kosaki Motohiro <kosaki.motohiro@gmail.com>, Milton Miller <miltonm@bga.com>

On Fri, Feb 10, 2012 at 8:39 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wr=
ote:
> On Sun, 2012-02-05 at 13:46 +0200, Gilad Ben-Yossef wrote:
>> > /*
>> > =A0* Cause all memory mappings to be populated in the page table.
>> > =A0* Specifying this when entering dataplane mode ensures that no futu=
re
>> > =A0* page fault events will occur to cause interrupts into the Linux
>> > =A0* kernel, as long as no new mappings are installed by mmap(), etc.
>> > =A0* Note that since the hardware TLB is of finite size, there will
>> > =A0* still be the potential for TLB misses that the hypervisor handles=
,
>> > =A0* either via its software TLB cache (fast path) or by walking the
>> > =A0* kernel page tables (slow path), so touching large amounts of memo=
ry
>> > =A0* will still incur hypervisor interrupt overhead.
>> > =A0*/
>> > #define DP_POPULATE =A0 =A0 0x8
>>
>> hmm... I've probably missed something, but doesn't this replicate
>> mlockall (MCL_CURRENT|MCL_FUTURE) ?
>
> Never use mlockall() its a sign you're doing it wrong, also his comment
> seems to imply MCL_FUTURE isn't required.
>


My current understanding is that if I have a real time task and wish it
have a deterministic performance time, you should call mlockall() to lock
the program data and text into physical memory so that  a  less often taken
branch or access to a new data region will not result in a page fault.

You still have to worry about TLB misses on non hardware page table
walk architecture, but at least everything is in the  page tables

If there is a better way to do this? I'm always happy to learn new
ways to do things. :-)


Thanks,
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
