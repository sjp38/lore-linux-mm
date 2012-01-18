Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id EB5B46B004F
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 18:27:06 -0500 (EST)
Received: by iadj38 with SMTP id j38so6759811iad.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 15:27:06 -0800 (PST)
Date: Wed, 18 Jan 2012 15:26:51 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH 1/2] SHM_UNLOCK: fix long unpreemptible section
In-Reply-To: <20120118143718.663b8cf5.akpm@linux-foundation.org>
Message-ID: <alpine.LSU.2.00.1201181457450.1256@eggly.anvils>
References: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils> <alpine.LSU.2.00.1201141615440.1338@eggly.anvils> <20120118143718.663b8cf5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@vger.kernel.org

On Wed, 18 Jan 2012, Andrew Morton wrote:
> On Sat, 14 Jan 2012 16:18:43 -0800 (PST)
> Hugh Dickins <hughd@google.com> wrote:
> 
> > scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
> > evictable again once the shared memory is unlocked.  It does this with
> > pagevec_lookup()s across the whole object (which might occupy most of
> > memory), and takes 300ms to unlock 7GB here.  A cond_resched() every
> > PAGEVEC_SIZE pages would be good.
>... 
> Is -stable backporting really warranted?  AFAICT the only thing we're
> fixing here is a long latency glitch during a rare operation on large
> machines.  Usually it will be on only one CPU, too.

True: I'm not sure if it amounts to -stable material or not.
I see you've taken out its Cc: stable line: that's fine by me, but...

> "[PATCH 2/2] SHM_UNLOCK: fix Unevictable pages stranded after swap"
> does loko like -stable material, so omitting 1/1 will probably screw
> things up :(

Sort of, but they both(?) needed respinning for -stable anyway.
Even against 3.2, there's some little change in vmscan.c that generates
a reject.  Greg has now closed down 3.1.N (which would have been tiresome
to port to, because it was still supporting a second caller of check_move),
and by your argument above it's not worth porting 1/2 back to 2.6.32.  So
I think 2/2 can just go into 3.2.N, dragging 1/2 along in its slipstream
(if you can have a slipstream in front of you).

I ordered them that way because 1/2 fixes an old, and 2/2 a recent, bug.

> > Resend in the hope that it can get into 3.3.
> 
> That we can do ;)

Thank you!

> > +#else
> > +void scan_mapping_unevictable_pages(struct address_space *mapping)
> > +{
> > +}
> > +#endif /* CONFIG_SHMEM */
> 
> Inlining the CONFIG_SHMEM=n stub would have been mroe efficient.

True, though in 2/2 it morphs into shmem_unlock_mapping() over
in shmem.c, and we seem to have the convention that TINY's !SHMEM
stubs live as non-inline functions there - probably no good reason
for that, just reflects their historical origins in tiny-shmem.c.
A grand saving to make some other time ;)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
