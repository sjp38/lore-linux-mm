Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A25449000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 09:49:08 -0400 (EDT)
Received: by gwaa12 with SMTP id a12so6325418gwa.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 06:49:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOtvUMdfGsPq2aaW2SOXkVvhpOKk8nLhjKGU90YGp07w_vy9Vw@mail.gmail.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
	<1317022420.9084.57.camel@twins>
	<CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
	<1317030352.9084.76.camel@twins>
	<CAOtvUMdfGsPq2aaW2SOXkVvhpOKk8nLhjKGU90YGp07w_vy9Vw@mail.gmail.com>
Date: Mon, 26 Sep 2011 16:49:06 +0300
Message-ID: <CAOtvUMeC=XMCQaa8TyyWEcE6jjb0sQr1WTKkv=orTxZ9907hPQ@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, Sep 26, 2011 at 3:05 PM, Gilad Ben-Yossef <gilad@benyossef.com> wrote:


>> The problem with a per-cpu cpumask is that you need to disable
>> preemption over the whole for_each_online_cpu() scan and that's not
>> really sane on very large machines as that can easily take a very long
>> time indeed.
>
> hmm... I might be thick, but why disable the preemption with the
> per-cpu cpumask at all?
...
>
> Does that makes sense or have I've gone over board with this concept? :-)

Scratch that. The cpumask must be per cache or the patch doesn't make
sense at all.
So sadly the only sane place to put it is in struct kmem_cache.

I think we can still update the cpumask field without caring about
preemption for the reasons
stated above, but the per cache memory overhead is still there I'm afraid.

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
