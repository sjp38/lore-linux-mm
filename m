Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 13D5C9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 04:07:47 -0400 (EDT)
Received: by ywe9 with SMTP id 9so5503134ywe.14
        for <linux-mm@kvack.org>; Mon, 26 Sep 2011 01:07:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1317022565.9084.60.camel@twins>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	<1316940890-24138-6-git-send-email-gilad@benyossef.com>
	<CAOJsxLEHHJyPnCngQceRW04PLKFa3RUQEbc3rLwiOPXa7XZNeQ@mail.gmail.com>
	<1317022565.9084.60.camel@twins>
Date: Mon, 26 Sep 2011 11:07:45 +0300
Message-ID: <CAOtvUMfnrtonwbCn4j=weA-kjf4K0SG2YRwZ-Cy5XONNWyN_pQ@mail.gmail.com>
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Matt Mackall <mpm@selenic.com>

Hi,

On Mon, Sep 26, 2011 at 10:36 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> On Mon, 2011-09-26 at 09:54 +0300, Pekka Enberg wrote:
>>
>> AFAICT, flush_all() isn't all that performance sensitive. Why do we
>> want to reduce IPIs here?
>
> Because it can wake up otherwise idle CPUs, wasting power. Or for the
> case I care more about, unnecessarily perturb a CPU that didn't actually
> have anything to flush but was running something, introducing jitter.
>
> on_each_cpu() things are bad when you have a ton of CPUs (which is
> pretty normal these days).
>


Peter basically already answered better then I could :-)

All I have to add is an example -

flush_all() is called for each kmem_cahce_destroy(). So every cache
being destroyed dynamically ends up sending an IPI to each CPU in the
system, regardless if the cache has ever been used there.

For example, if you close the Infinband ipath driver char device file,
the close file ops calls kmem_cache_destroy().So, if I understand
correctly, running some infiniband config tool on one a single CPU
dedicated to system tasks might interrupt the rest of the 127 CPUs I
dedicated to some CPU intensive task. This is the scenario I'm
tryingto avoid.

I suspect there is a good chance that every line in the output of "git
grep kmem_cache_destroy linux/ | grep '\->'" has a similar scenario
(there are 42 of them).

I hope this sheds some light on the motive of the work.

Thanks!
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
