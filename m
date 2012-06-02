Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 305CA6B004D
	for <linux-mm@kvack.org>; Sat,  2 Jun 2012 00:41:02 -0400 (EDT)
Received: by dakp5 with SMTP id p5so4626159dak.14
        for <linux-mm@kvack.org>; Fri, 01 Jun 2012 21:41:01 -0700 (PDT)
Date: Fri, 1 Jun 2012 21:40:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-Reply-To: <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
Message-ID: <alpine.LSU.2.00.1206012108430.11308@eggly.anvils>
References: <20120530163317.GA13189@redhat.com> <20120531005739.GA4532@redhat.com> <20120601023107.GA19445@redhat.com> <alpine.LSU.2.00.1206010030050.8462@eggly.anvils> <20120601161205.GA1918@redhat.com> <20120601171606.GA3794@redhat.com>
 <alpine.LSU.2.00.1206011511560.12839@eggly.anvils> <CA+55aFy2-X92EqpiuyvkBp_2-UaYDUpaC2c3XT3gXMN1O+T7sw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323584-1474580492-1338612042=:11308"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323584-1474580492-1338612042=:11308
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Fri, 1 Jun 2012, Linus Torvalds wrote:
> On Fri, Jun 1, 2012 at 3:17 PM, Hugh Dickins <hughd@google.com> wrote:
> >
> > + =A0 =A0 =A0 spin_lock_irqsave(&zone->lock, flags);
> > =A0 =A0 =A0 =A0for (page =3D start_page, pfn =3D start_pfn; page < end_=
page; pfn++,
> > =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page++) {
>=20
> So holding the spinlock (and disabling irqs!) over the whole loop
> sounds horrible.

There looks to be a pretty similar loop inside move_freepages_block(),
which is the part which I believe really needs the lock - it's moving
free pages from one lru to another.

>=20
> At the same time, the iterators don't seem to require the spinlock, so
> it should be possible to just move the lock into the loop, no?

Move the lock after the loop, I think you meant.

I put the lock before the loop because it's deciding whether it can
usefully proceed, and then proceeding: I was thinking that the lock
would stabilize the conditions that it bases that decision on.

But it certainly does not stabilize all of them (most obviously not
PageLRU), so I'm guesssing that this is a best-effort decision which
can safely go wrong some of the time.

In which case, yes, much better to follow your suggestion, and hold
the lock (with irqs disabled) for only half the time.

Similarly untested patch below.

But I'm entirely unfamiliar with this code: best Cc people more familiar
with it.  Does this addition of locking to rescue_unmovable_pageblock()
look correct to you, and do you think it has a good chance of fixing the
move_freepages_block() list debug warnings which Dave has been reporting
(in this and in another thread)?

(Although there's still something of a mystery in where Dave's bisection
appeared to converge, our best assumption at present is that one of my
tmpfs changes is to blame for the __set_page_dirty_nobuffers warnings,
and I need to send a finalized patch to fix that later.

I'm guessing that the few people who see the warning are those running
new systemd distros, and that systemd is indeed now making use of the
fallocate support we added into tmpfs for it.)

Hugh

--- 3.4.0+/mm/compaction.c=092012-05-30 08:17:19.396008280 -0700
+++ linux/mm/compaction.c=092012-06-01 20:59:56.840204915 -0700
@@ -369,6 +369,8 @@ static bool rescue_unmovable_pageblock(s
 {
 =09unsigned long pfn, start_pfn, end_pfn;
 =09struct page *start_page, *end_page;
+=09struct zone *zone;
+=09unsigned long flags;
=20
 =09pfn =3D page_to_pfn(page);
 =09start_pfn =3D pfn & ~(pageblock_nr_pages - 1);
@@ -378,7 +380,8 @@ static bool rescue_unmovable_pageblock(s
 =09end_page =3D pfn_to_page(end_pfn);
=20
 =09/* Do not deal with pageblocks that overlap zones */
-=09if (page_zone(start_page) !=3D page_zone(end_page))
+=09zone =3D page_zone(start_page);
+=09if (zone !=3D page_zone(end_page))
 =09=09return false;
=20
 =09for (page =3D start_page, pfn =3D start_pfn; page < end_page; pfn++,
@@ -399,8 +402,10 @@ static bool rescue_unmovable_pageblock(s
 =09=09return false;
 =09}
=20
+=09spin_lock_irqsave(&zone->lock, flags);
 =09set_pageblock_migratetype(page, MIGRATE_MOVABLE);
-=09move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+=09move_freepages_block(zone, page, MIGRATE_MOVABLE);
+=09spin_unlock_irqrestore(&zone->lock, flags);
 =09return true;
 }
=20
--8323584-1474580492-1338612042=:11308--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
