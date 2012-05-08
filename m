Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id A305C6B004D
	for <linux-mm@kvack.org>; Mon,  7 May 2012 20:33:17 -0400 (EDT)
Received: by dakp5 with SMTP id p5so9409013dak.14
        for <linux-mm@kvack.org>; Mon, 07 May 2012 17:33:16 -0700 (PDT)
Date: Mon, 7 May 2012 17:31:51 -0700
From: Anton Vorontsov <anton.vorontsov@linaro.org>
Subject: Re: [PATCH 3/3] vmevent: Implement special low-memory attribute
Message-ID: <20120508003150.GA15921@lizard>
References: <20120501132409.GA22894@lizard>
 <20120501132620.GC24226@lizard>
 <4FA35A85.4070804@kernel.org>
 <20120504073810.GA25175@lizard>
 <CAOJsxLH_7mMMe+2DvUxBW1i5nbUfkbfRE3iEhLQV9F_MM7=eiw@mail.gmail.com>
 <CAHGf_=qcGfuG1g15SdE0SDxiuhCyVN025pQB+sQNuNba4Q4jcA@mail.gmail.com>
 <20120507121527.GA19526@lizard>
 <4FA82056.2070706@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <4FA82056.2070706@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Minchan Kim <minchan@kernel.org>, Leonid Moiseichuk <leonid.moiseichuk@nokia.com>, John Stultz <john.stultz@linaro.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

On Mon, May 07, 2012 at 03:19:50PM -0400, KOSAKI Motohiro wrote:
[...]
> You don't understand the issue.

Apparently.

> The point is NOT a formula. The problem
> is, dirty and non-dirty pages aren't isolated in our kernel. Then, kernel
> start to get stuck  far before non-dirty pages become empty. Lie notification
> always useless.

Ugh. I don't get it (yeah, see above :-), in what sense they're not
isolated? In sense of isolate_lru_page and friends? Yes, they're not
isolated, but how that makes the notifications untrustworthy?

I'm confused. Can you elaborate a bit?

> >Even more, we may introduce two attributes:
> >
> >RECLAIMABLE_CACHE_PAGES and
> >RECLAIMABLE_CACHE_PAGES_NOIO (which excludes dirty pages).
> >
> >This makes ABI detached from the mm internals and still keeps a
> >defined meaning of the attributes.
> 
> Collection of craps are also crap. If you want to improve userland
> notification, you should join VM improvement activity.

I'm all for improving VM, but please, be specific. I'm assuming
there is currently some efforts on VM improvements, which I'm
not aware of. Or there are some plans or thoughts on improvements --
please tell what are they.

> You shouldn't
> think nobody except you haven't think userland notification feature.

That was never my assumption; surely many people have worked on userland
notifications, and still, today we have none that would fully suite
Android's or Nokia's (or "embedded people's") needs, right? ;-)

So, let's try solve things.

Memcg is currently not usable for us, and I explained why (the slab
accounting for root cgroup thing: http://lkml.org/lkml/2012/4/30/115 ),
any comments?

> The problem is, Any current kernel vm statistics were not created for
> such purpose and don't fit.

OK, presuming current statistics don't fit, which ones should we
implement? How do you see it?

> Even though, some inaccurate and incorrect statistics fit _your_ usecase,
> they definitely don't fit other. And their people think it is bug.

I'm all for making a single solution for your and ours use cases, but
you don't say anything specific.

(Btw, what are your use cases?)

> >>2) libc and some important library's pages are critical important
> >>for running a system even though it is clean and reclaimable. In other
> >>word, kernel don't have an info then can't expose it.
> >
> >First off, I guess LRU would try to keep important/most used pages in
> >the cache, as we try to never fully drain page cache to the zero mark.

*1

> Yes, what do you want say?

> >Secondly, if we're really low on memory (which low memory notifications
> >help to prevent) and kernel decided to throw libc's pages out of the
> >cache, you'll get cache miss and kernel will have to read it back. Well,
> >sometimes cache misses do happen, that's life. And if somebody really
> >don't want this for the essential parts of the system, one have to
> >mlock it (which eliminates your "kernel don't have an info" argument).
> 
> First off, "low memory" is very poor definition and we must not use it.

OK.

> It is multiple meanings.
> 1) System free memory is low. Some embedded have userland

The 'free' has multiple meanings as well. For us, it is
'not-used-at-all-pages + the-pages-that-we-can-get-in-a-
jiffy-and-not-disturb-things-much'.

The 'not-disturb-things-much' has a moot meaning as well, so all this
should probably be tunable. Cool, so let's give the userspace all the
needed statistics to decide on these meanings.

> oom killer and they want to know _system_ status. 2) available memory is low.
> This is different from (1) when using NUMA, memcg or cpusets. And in nowadays,
> almost all x86 box have numa. This is userful for swap avoidance activity if
> we can implement correctly.

I don't get it: you don't see '1)' as a use case? You're saying
that the meanings are different when using NUMA/memcg. If we don't
use memcg, what statistics should we use?

OK, if you are hinting that memcg should be mandatory for proper
statistics accounting, then please comment on the current memcg
issues, which don't let us do '1)' via '2)'.

> Secondly, we can't assume someone mlock to libc. Because of, Linux is generic
> purpose kernel.

You said that libc pages are important, implying that ideally they should
never leave the page cache (i.e. we should not count the pages as 'easily
reclaimable').

I answered that if are OK with "not guaranteed, but we'll do our best"
strategy, then just don't let fully drain the caches, and then LRU will
try keep "most important" pages (apparently libc) in the cache. *1  It
is surely userland's task to maintain the needed amount of memory, and
to do this efficiently we need..... notifications, that's right.

But if you want a guarantee, I guess mlock() is the only option -- it is
the only way to tell the kernel that the pages are really not to be
reclaimed.

So, in the light of 'easily reclaimable pages' statistics, what for was
your libc point again? How would you solve "the libc problem"?

Thanks!

-- 
Anton Vorontsov
Email: cbouatmailru@gmail.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
