Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 737606B0089
	for <linux-mm@kvack.org>; Sun, 10 May 2009 06:04:06 -0400 (EDT)
Date: Sun, 10 May 2009 18:03:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
	class  citizen
Message-ID: <20090510100335.GC7651@localhost>
References: <1241432635.7620.4732.camel@twins> <20090507121101.GB20934@localhost> <20090507151039.GA2413@cmpxchg.org> <20090507134410.0618b308.akpm@linux-foundation.org> <20090508081608.GA25117@localhost> <20090508125859.210a2a25.akpm@linux-foundation.org> <20090508230045.5346bd32@lxorguk.ukuu.org.uk> <2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com> <20090510092053.GA7651@localhost> <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2f11576a0905100229m2c5e6a67md555191dc8c374ae@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Sun, May 10, 2009 at 05:29:43PM +0800, KOSAKI Motohiro wrote:
> >> >> The patch seems reasonable but the changelog and the (non-existent)
> >> >> design documentation could do with a touch-up.
> >> >
> >> > Is it right that I as a user can do things like mmap my database
> >> > PROT_EXEC to get better database numbers by making other
> >> > stuff swap first ?
> >> >
> >> > You seem to be giving everyone a "nice my process up" hack.
> >>
> >> How about this?
> >
> > Why it deserves more tricks? PROT_EXEC pages are rare.
> > If user space is to abuse PROT_EXEC, let them be for it ;-)
> 
> yes, typicall rare.
> tha problem is, user program _can_ use PROT_EXEC for get higher priority
> ahthough non-executable memory.

- abuses should be rare
- large scale abuses will be even more rare,
- the resulted vmscan overheads are the *expected* side effect
- the side effects are still safe

So if that's what they want, let them have it to their heart's content.

You know it's normal for many users/apps to care only about the result.
When they want something but cannot get it from the smarter version of
PROT_EXEC heuristics, they will go on to devise more complicated tricks.

In the end both sides loose.

If the abused case is important enough, then let's introduce a feature
to explicitly prioritize the pages. But let's leave the PROT_EXEC case
simple.

> In general, static priority mechanism have one weakness. if all object
> have higher priority, it break priority mechanism.

Yup.

> >> then, this patch don't change kernel reclaim policy.
> >>
> >> anyway, user process non-changable preventing "nice my process up
> >> hack" seems makes sense to me.
> >>
> >> test result:
> >>
> >> echo 100 > /proc/sys/vm/dirty_ratio
> >> echo 100 > /proc/sys/vm/dirty_background_ratio
> >> run modified qsbench (use mmap(PROT_EXEC) instead malloc)
> >>
> >> A  A  A  A  A  A active2active vs active2inactive ratio
> >> before A  A 5:5
> >> after A  A  A  1:9
> >
> > Do you have scripts for producing such numbers? I'm dreaming to have
> > such tools :-)
> 
> I made stastics showing patch for testing, hehe :)

I see :)

Thanks,
Fengguang

> ---
>  include/linux/vmstat.h |    1 +
>  mm/vmstat.c            |    1 +
>  2 files changed, 2 insertions(+)
> 
> Index: b/include/linux/vmstat.h
> ===================================================================
> --- a/include/linux/vmstat.h    2009-02-17 07:34:38.000000000 +0900
> +++ b/include/linux/vmstat.h    2009-05-10 02:36:37.000000000 +0900
> @@ -51,6 +51,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PS
>                 UNEVICTABLE_PGSTRANDED, /* unable to isolate on unlock */
>                 UNEVICTABLE_MLOCKFREED,
>  #endif
> +               FOR_ALL_ZONES(PGA2A),
>                 NR_VM_EVENT_ITEMS
>  };
> 
> Index: b/mm/vmstat.c
> ===================================================================
> --- a/mm/vmstat.c       2009-05-10 01:08:36.000000000 +0900
> +++ b/mm/vmstat.c       2009-05-10 02:37:18.000000000 +0900
> @@ -708,6 +708,7 @@ static const char * const vmstat_text[]
>         "unevictable_pgs_stranded",
>         "unevictable_pgs_mlockfreed",
>  #endif
> +       TEXTS_FOR_ZONES("pga2a")
>  #endif
>  };
> 
> 
> 
> >> please don't ask performance number. I haven't reproduce Wu's patch
> >> improvemnt ;)
> >
> > That's why I decided to "explain" instead of "benchmark" the benefits
> > of my patch, hehe.
> 
> okey, I see.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
