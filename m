Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 4C1429000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:28:17 -0400 (EDT)
Received: by iaen33 with SMTP id n33so7071728iae.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 02:28:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
	<1317022420.9084.57.camel@twins>
	<CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
Date: Mon, 26 Sep 2011 12:28:14 +0300
Message-ID: <CAOJsxLECbRHq=amSkNZGDx+rSMkE0Hd2VvCs=vyFcxPQpfxL_g@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

On Mon, Sep 26, 2011 at 11:35 AM, Gilad Ben-Yossef <gilad@benyossef.com> wrote:
>> Right, having to do that for_each_oneline_cpu() loop only to then IPI
>> them can cause a massive cacheline bounce fest.. Ideally you'd want to
>> keep a cpumask per kmem_cache, although I bet the memory overhead of
>> that isn't attractive.
>>
>> Also, what Pekka says, having that alloc here isn't good either.
>
> Yes, the alloc in the flush_all path definitively needs to go. I
> wonder if just to resolve that allocating the mask per cpu and not in
> kmem_cache itself is not better - after all, all we need is a single
> mask per cpu when we wish to do a flush_all and no per cache. The
> memory overhead of that is slightly better. This doesn't cover the
> cahce bounce issue.

I'm fine with whatever works for you as long as you don't add a
kmalloc() call in flush_all().

                        Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
