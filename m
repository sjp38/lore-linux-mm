Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 6F2BA6B004F
	for <linux-mm@kvack.org>; Thu, 12 Jan 2012 14:52:00 -0500 (EST)
Received: by iafj26 with SMTP id j26so4210482iaf.14
        for <linux-mm@kvack.org>; Thu, 12 Jan 2012 11:51:59 -0800 (PST)
Date: Thu, 12 Jan 2012 11:51:39 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: vmscan: deactivate isolated pages with lru lock
 released
In-Reply-To: <CAJd=RBC6zXtN1uQMxJJxGGHrXH5xUAeDWGzoEazbVAdRXo9F0Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1201121127440.2945@eggly.anvils>
References: <CAJd=RBAiAfyXBcn+9WO6AERthyx+C=cNP-romp9YJO3Hn7-U-g@mail.gmail.com> <alpine.LSU.2.00.1201111351080.1846@eggly.anvils> <CAJd=RBC6zXtN1uQMxJJxGGHrXH5xUAeDWGzoEazbVAdRXo9F0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1299436237-1326397913=:2945"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1299436237-1326397913=:2945
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Thu, 12 Jan 2012, Hillf Danton wrote:
> On Thu, Jan 12, 2012 at 6:33 AM, Hugh Dickins <hughd@google.com> wrote:
> > On Wed, 11 Jan 2012, Hillf Danton wrote:
>=20
> > I suspect that your patch can be improved, to take away that worry.
> > Why do we need to take the lock again? =C2=A0Only to update reclaim_sta=
t:
> > for the other stats, interrupts disabled is certainly good enough,
> > and more research might show that preemption disabled would be enough.
> >
> > get_scan_count() is called at the (re)start of shrink_mem_cgroup_zone()=
,
> > before it goes down to do shrink_list()s: I think it would not be harme=
d
> > at all if we delayed updating reclaim_stat->recent_scanned until the
> > next time we take the lock, lower down.
> >
>=20
> Dunno how to handle the tons of __mod_zone_page_state() or similar withou=
t lock
> protection 8-/ try to deffer updating reclaim_stat soon.

Aren't the __mod_zone_page_state() counts per-cpu?  Although we very
often update them while holding the zone spinlock, that's because we
happen to be holding it already, and it prevents preemption to another
cpu, without needing to invoke the more expensive mod_zone_page_state().
Similarly __count_vm_events() is per-cpu (and no zone lock would help it).

>=20
> > Other things that strike me, looking here again: isn't it the case that
> > update_isolated_counts() is actually called either for file or for anon=
,
> > but never for both?
>=20
> No, see the above diff please 8-)

I think you are obliquely reminding me that lumpy reclaim will take pages
from wherever, so that way some anon pages will sneak into the file lru
reclaim and some file pages into the anon lru reclaim.  Right?  Whereas
move_active_pages_to_lru() doesn't have that problem, because
shrink_active_list() uses a stricter setting of reclaim_mode.  Hmm,
more simplification that can be done once lumpy reclaim is removed.

(It's the 3.2 tree with its naming that I'm examining at this moment.)

Hugh
--8323584-1299436237-1326397913=:2945--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
