Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9D6E79000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 03:27:08 -0400 (EDT)
Received: by gya6 with SMTP id 6so6548567gya.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 00:27:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1109261023400.24164@router.home>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-5-git-send-email-gilad@benyossef.com>
	<1317001924.29510.160.camel@sli10-conroe>
	<CAOtvUMddUAATZcU_5jLgY10ocsHNnOO2GC2c4ecYO9KGt-U7VQ@mail.gmail.com>
	<alpine.DEB.2.00.1109261023400.24164@router.home>
Date: Tue, 27 Sep 2011 10:27:06 +0300
Message-ID: <CAOtvUMcvwWFxxxv7tsOj6FO-wrHAU8EYc+U=9u8yT=cz7XajBA@mail.gmail.com>
Subject: Re: [PATCH 4/5] mm: Only IPI CPUs to drain local pages if they exist
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: Shaohua Li <shaohua.li@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

Hi,

On Mon, Sep 26, 2011 at 6:24 PM, Christoph Lameter <cl@gentwo.org> wrote:
> On Mon, 26 Sep 2011, Gilad Ben-Yossef wrote:
>
>> I do not know if these scenarios warrant the additional overhead,
>> certainly not in all situations. Maybe the right thing is to make it a
>> config option dependent. As I stated in the patch description, that is
>> one of the thing I'm interested in feedback on.
>
> The flushing of the per cpu pages only done when kmem_cache_shrink() is
> run or when a slab cache is closed. And for diagnostics. So its rare and
> not performance critical.

Yes, I understand. The problem is it pops up in the oddest of place.
An example is in order:

The Ipath Infiniband hardware exports a char device interface to user space.
When a user opens the char device and configures a port, a kmem_cache
is created.
When the user later closes the fd, the release method of the char
device destroys
the kmem_cache.

So, if I have some high performance server with 128 processors, and
I've dedicated
127 processors to run my CPU bound computing tasks (and made sure the interrupt
are serviced by the last CPU)  and then run a shell on  the lone admin
CPU to do a backup,
I can interrupt my 127 CPUs doing computational tasks, even though
they have nothing to do
with Infiniband, or backup and have never allocated a single buffer
form that cache.

I believe there is a similar scenario with software raid if I change
RAID configs and several
other places. In fact, I'm guessing many of the lines that pop up when
doing the following
grep hide a similar scenario:

$ git grep kmem_cache_destroy . | grep '\->'

I hope this explains my interest.

My hope is to come up with a way to do more code on the CPU doing the
flush_all (which
as you said is a rare and none performance critical code path anyway)
and by that gain the ability
to do the job without interrupting CPUs that do not need to flush
their per cpu pages.

Thanks,
Gilad







>
>
>



-- 
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"I've seen things you people wouldn't believe. Goto statements used to
implement co-routines. I watched C structures being stored in
registers. All those moments will be lost in time... like tears in
rain... Time to die. "

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
