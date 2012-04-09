Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C71276B007E
	for <linux-mm@kvack.org>; Mon,  9 Apr 2012 18:04:08 -0400 (EDT)
Received: by iajr24 with SMTP id r24so8699188iaj.14
        for <linux-mm@kvack.org>; Mon, 09 Apr 2012 15:04:08 -0700 (PDT)
Date: Mon, 9 Apr 2012 15:03:45 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: sync rss-counters at the end of exit_mm()
In-Reply-To: <CAHGf_=oWj-hz-E5ht8-hUbQKdsZ1bzP80n987kGYnFm8BpXBVQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1204091433380.1859@eggly.anvils>
References: <20120409200336.8368.63793.stgit@zurg> <CAHGf_=oWj-hz-E5ht8-hUbQKdsZ1bzP80n987kGYnFm8BpXBVQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-495961883-1334009032=:1859"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, Markus Trippelsdorf <markus@trippelsdorf.de>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-495961883-1334009032=:1859
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Mon, 9 Apr 2012, KOSAKI Motohiro wrote:
> On Mon, Apr 9, 2012 at 4:03 PM, Konstantin Khlebnikov
> <khlebnikov@openvz.org> wrote:
> > On task's exit do_exit() calls sync_mm_rss() but this is not enough,
> > there can be page-faults after this point, for example exit_mm() ->
> > mm_release() -> put_user() (for processing tsk->clear_child_tid).
> > Thus there may be some rss-counters delta in current->rss_stat.
>=20
> Seems reasonable.

Yes, I think Konstantin has probably caught it;
but I'd like to hear confirmation from Markus.

> but I have another question. Do we have any reason to
> keep sync_mm_rss() in do_exit()? I havn't seen any reason that thread exi=
ting
> makes rss consistency.

IIRC it's all about the hiwater_rss/maxrss stuff: we want to sync the
maximum rss into mm->hiwater_rss before it's transferred to signal->maxrss,
and later made visible to the user though getrusage(RUSAGE_CHILDREN,) -
does your reading confirm that?

Konstantin now finds the child_tid and futex stuff can trigger faults
raising rss beyond that point, but usually it won't go higher than when
it was captured for maxrss there.

The sync_mm_rss() added by this patch (after "tsk->mm =3D NULL" so
*_mm_counter_fast() cannot store any more into the tsk even if there
were more faults) is solely to satisfy Konstantin's check_mm(), and
it is irritating to have that duplicated on the exit path.

I'd be happy to see the new one put under CONFIG_DEBUG_VM along with
check_mm(), once it's had a few -rcs of exposure without.

Hugh

>=20
>=20
> >
> > Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> > Reported-by: Markus Trippelsdorf <markus@trippelsdorf.de>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > =A0kernel/exit.c | =A0 =A01 +
> > =A01 file changed, 1 insertion(+)
> >
> > diff --git a/kernel/exit.c b/kernel/exit.c
> > index d8bd3b42..8e09dbe 100644
> > --- a/kernel/exit.c
> > +++ b/kernel/exit.c
> > @@ -683,6 +683,7 @@ static void exit_mm(struct task_struct * tsk)
> > =A0 =A0 =A0 =A0enter_lazy_tlb(mm, current);
> > =A0 =A0 =A0 =A0task_unlock(tsk);
> > =A0 =A0 =A0 =A0mm_update_next_owner(mm);
> > + =A0 =A0 =A0 sync_mm_rss(mm);
> > =A0 =A0 =A0 =A0mmput(mm);
> > =A0}
> >
--8323584-495961883-1334009032=:1859--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
