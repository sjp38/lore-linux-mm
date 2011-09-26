Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 2C13A9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 08:05:15 -0400 (EDT)
Received: by gxk28 with SMTP id 28so1499470gxk.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:05:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317030352.9084.76.camel@twins>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
	<1317022420.9084.57.camel@twins>
	<CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
	<1317030352.9084.76.camel@twins>
Date: Mon, 26 Sep 2011 15:05:12 +0300
Message-ID: <CAOtvUMdfGsPq2aaW2SOXkVvhpOKk8nLhjKGU90YGp07w_vy9Vw@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, Sep 26, 2011 at 12:45 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Mon, 2011-09-26 at 11:35 +0300, Gilad Ben-Yossef wrote:
>> Yes, the alloc in the flush_all path definitively needs to go. I
>> wonder if just to resolve that allocating the mask per cpu and not in
>> kmem_cache itself is not better - after all, all we need is a single
>> mask per cpu when we wish to do a flush_all and no per cache. The
>> memory overhead of that is slightly better. This doesn't cover the
>> cahce bounce issue.
>>
>> My thoughts regarding that were that since the flush_all() was a
>> rather rare operation it is preferable to do some more
>> work/interference here, if it allows us to avoid having to do more
>> work in the hotter alloc/dealloc paths, especially since it allows us
>> to have less IPIs that I figured are more intrusive then cacheline
>> steals (are they?)
>>
>> After all, for each CPU that actually needs to do a flush, we are
>> making the flush a bit more expensive because of the cache bounce just
>> before we send the IPI, but that IPI and further operations are an
>> expensive operations anyway. For CPUs that don't need to do a flush, I
>> replaced an IPI for a cacheline(s) steal. I figured it was still a
>> good bargain
>
> Hard to tell really, I've never really worked with these massive
> machines, biggest I've got is 2 nodes and for that I think your
> for_each_online_cpu() loop might indeed still be a win when compared to
> extra accounting on the alloc/free paths.

 I've worked on the SGI Altix which supports up to 1,024 cores in a
single Linux instance, although my dev. machine
at the time only had 32 cores, if I remember correctly,  but I still
don't know the answer either... :-)

> The problem with a per-cpu cpumask is that you need to disable
> preemption over the whole for_each_online_cpu() scan and that's not
> really sane on very large machines as that can easily take a very long
> time indeed.

hmm... I might be thick, but why disable the preemption with the
per-cpu cpumask at all?
Are you worried about re-entering flush_all()? because I don't think
that is a problem -

Let's say we're in the middle of flush_all doing for_each_online_cpu
and updating our cpumask
and then we get preempted and go again into flush_all again. We'll run
over whatever values we
started to put into the cpumask and do the IPIs. When we get back to
our original context
we'll continue updating the tail of the cpumask and send IPIs based on
the updated mask again.

True, we'll end up sending the IPI twice to the head of the cpumask
(the part we managed to update
in the first part of flush_all before the preemption), but that's
doesn't really do any harm and it is still
better then what we have now - in a flush_all preempting flush_all,
we're 100% sure to double IPI all the
processors in the system currently.

Actually, continuing the same line of though - why not have only  one
single global cpumask  that we update
in flush_all before sending the IPI? Using the same reasoning, it
might get updated in parallel from one
processor when  we IPI from another or being doubly updated in
parallel in a few - but we don't really care as
long as cpumask_set_cpu() does its work atomically and
on_each_cpu_mask() is OK with the cpumask
changing under its feet (which I believe both are). We might end up
doing the IPIs based on more updated
values then the one that "our" for_each_online_cpu() walk calculated,
but that isn't a problem.

Sure, it will generate some cacheline bouncing for the global cpumask
variable if several processor do flush_all()
in parallel, but that's supposed to be rare and frankly, if more then
one CPU is about send a bunch of cross system
IPIs you're bound for hell more then some cacheline bouncing anyway.

Does that makes sense or have I've gone over board with this concept? :-)

Thanks,
Gilad

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
