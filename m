Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 856478D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 10:41:09 -0500 (EST)
Subject: Re: [PATCH 3/5] mm: Implement IO-less balance_dirty_pages()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20110211154616.GK5187@quack.suse.cz>
References: <1296783534-11585-1-git-send-email-jack@suse.cz>
	 <1296783534-11585-4-git-send-email-jack@suse.cz>
	 <1296824956.26581.649.camel@laptop>  <20110211154616.GK5187@quack.suse.cz>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Tue, 22 Feb 2011 16:40:56 +0100
Message-ID: <1298389256.2217.238.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>

On Fri, 2011-02-11 at 16:46 +0100, Jan Kara wrote:
> On Fri 04-02-11 14:09:16, Peter Zijlstra wrote:
> > On Fri, 2011-02-04 at 02:38 +0100, Jan Kara wrote:
> > > +       dirty_exceeded =3D check_dirty_limits(bdi, &st);
> > > +       if (dirty_exceeded < DIRTY_MAY_EXCEED_LIMIT) {
> > > +               /* Wakeup everybody */
> > > +               trace_writeback_distribute_page_completions_wakeall(b=
di);
> > > +               spin_lock(&bdi->balance_lock);
> > > +               list_for_each_entry_safe(
> > > +                               waiter, tmpw, &bdi->balance_list, bw_=
list)
> > > +                       balance_waiter_done(bdi, waiter);
> > > +               spin_unlock(&bdi->balance_lock);
> > > +               return;
> > > +       }
> > > +
> > > +       spin_lock(&bdi->balance_lock);
> > is there any reason this is a spinlock and not a mutex?
>   No. Is mutex preferable?

I'd say so, the loops you do under it can be quite large and you're
going to make the task sleep anyway, doesn't really matter if it blocks
on a mutex too while its at it.

> > > +       /*
> > > +        * Note: This loop can have quadratic complexity in the numbe=
r of
> > > +        * waiters. It can be changed to a linear one if we also main=
tained a
> > > +        * list sorted by number of pages. But for now that does not =
seem to be
> > > +        * worth the effort.
> > > +        */
> >=20
> > That doesn't seem to explain much :/
> >=20
> > > +       remainder_pages =3D written - bdi->written_start;
> > > +       bdi->written_start =3D written;
> > > +       while (!list_empty(&bdi->balance_list)) {
> > > +               pages_per_waiter =3D remainder_pages / bdi->balance_w=
aiters;
> > > +               if (!pages_per_waiter)
> > > +                       break;
> >=20
> > if remainder_pages < balance_waiters you just lost you delta, its best
> > to not set bdi->written_start until the end and leave everything not
> > processed for the next round.
>   I haven't lost it, it will be distributed in the second loop.

Ah, indeed. weird construct though.

> > > +               remainder_pages %=3D bdi->balance_waiters;
> > > +               list_for_each_entry_safe(
> > > +                               waiter, tmpw, &bdi->balance_list, bw_=
list) {
> > > +                       if (waiter->bw_to_write <=3D pages_per_waiter=
) {
> > > +                               remainder_pages +=3D pages_per_waiter=
 -
> > > +                                                  waiter->bw_to_writ=
e;
> > > +                               balance_waiter_done(bdi, waiter);
> > > +                               continue;
> > > +                       }
> > > +                       waiter->bw_to_write -=3D pages_per_waiter;
> > >                 }
> > > +       }
> > > +       /* Distribute remaining pages */
> > > +       list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw=
_list) {
> > > +               if (remainder_pages > 0) {
> > > +                       waiter->bw_to_write--;
> > > +                       remainder_pages--;
> > > +               }
> > > +               if (waiter->bw_to_write =3D=3D 0 ||
> > > +                   (dirty_exceeded =3D=3D DIRTY_MAY_EXCEED_LIMIT &&
> > > +                    !bdi_task_limit_exceeded(&st, waiter->bw_task)))
> > > +                       balance_waiter_done(bdi, waiter);
> > > +       }
> >=20
> > OK, I see what you're doing, but I'm not quite sure it makes complete
> > sense yet.
> >=20
> >   mutex_lock(&bdi->balance_mutex);
> >   for (;;) {
> >     unsigned long pages =3D written - bdi->written_start;
> >     unsigned long pages_per_waiter =3D pages / bdi->balance_waiters;
> >     if (!pages_per_waiter)
> >       break;
> >     list_for_each_entry_safe(waiter, tmpw, &bdi->balance_list, bw_list)=
{
> >       unsigned long delta =3D min(pages_per_waiter, waiter->bw_to_write=
);
> >=20
> >       bdi->written_start +=3D delta;
> >       waiter->bw_to_write -=3D delta;
> >       if (!waiter->bw_to_write)
> >         balance_waiter_done(bdi, waiter);
> >     }
> >   }
> >   mutex_unlock(&bdi->balance_mutex);
> >=20
> > Comes close to what you wrote I think.
>   Yes, quite close. Only if we wake up and there are not enough pages for
> all waiters. We at least "help" waiters in the beginning of the queue. Th=
at
> could have some impact when the queue grows quickly on a slow device
> (something like write fork bomb) but given we need only one page written =
per
> waiter it would be really horrible situation when this triggers anyway...

Right, but its also unfair, suppose your timer/bandwidth ratio is such
that each timer hit is after 1 writeout, in that case you would
distribute pages to the first waiter in a 1 ratio instead of
1/nr_waiters, essentially robbing the other waiters of progress.

> > One of the problems I have with it is that min(), it means that that
> > waiter waited too long, but will not be compensated for this by reducin=
g
> > its next wait. Instead you give it away to other waiters which preserve=
s
> > fairness on the bdi level, but not for tasks.
> >=20
> > You can do that by keeping ->bw_to_write in task_struct and normalize i=
t
> > by the estimated bdi bandwidth (patch 5), that way, when you next
> > increment it it will turn out to be lower and the wait will be shorter.
> >=20
> > That also removes the need to loop over the waiters.
>   Umm, interesting idea! Just the implication "pages_per_waiter >
> ->bw_to_write =3D> we waited for too long" isn't completely right. In fac=
t,
> each waiter entered the queue sometime between the first waiter entered i=
t
> and the time timer triggered. It might have been just shortly before the
> timer triggered and thus it will be in fact delayed for too short time. S=
o
> this problem is somehow the other side of the problem you describe and so
> far I just ignored this problem in a hope that it just levels out in the
> long term.

Yeah,.. it will balance out over the bdi, just not over tasks afaict.
But as you note below its not without problems of its own. Part of the
issues can be fixed by more accurate accounting, but not at all sure
that's actually worth the effort.

> The trouble I see with storing remaining written pages with each task is
> that we can accumulate significant amount of pages in that - from what I
> see e.g. with my SATA drive the writeback completion seems to be rather
> bumpy (and it's even worse over NFS). If we then get below dirty limit,
> process can carry over a lot of written pages to the time when dirty limi=
t
> gets exceeded again which reduces the effect of throttling at that time
> and we can exceed dirty limits by more than we'd wish. We could solve thi=
s
> by somehow invalidating the written pages when we stop throttling on that
> bdi but that would mean to track something like pairs <bonus pages, bdi>
> with each task - not sure we want to do that...

Right, but even for those bursty devices the estimated bandwidth should
average out.. but yeah, its all a bit messy and I can quite see why you
wouldn't want to go there ;-)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
