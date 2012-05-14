Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 5C6526B004D
	for <linux-mm@kvack.org>; Mon, 14 May 2012 09:52:15 -0400 (EDT)
Message-ID: <1337003515.2443.35.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 14 May 2012 15:51:55 +0200
In-Reply-To: <20120514133210.GE29102@suse.de>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
	 <4FADA007.3020309@gmail.com> <20120514133210.GE29102@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Mon, 2012-05-14 at 14:32 +0100, Mel Gorman wrote:

> Embedded does not imply realtime constraints.
>=20
> > So, I don't think
> > CMA and compaction are significantly different.
> >=20
>=20
> CMA is used in cases such as a mobile phone needing to allocate a large
> contiguous range of memory for video decoding. Compaction is used by
> features such as THP with khugepaged potentially using it frequently on
> x86-64 machines. The use cases are different and compaction is used by
> THP a lot more than CMA is used by anything.
>=20
> If compaction can move mlocked pages then khugepaged can introduce unexpe=
cted
> latencies on mlocked anonymous regions of memory.

I'd like to see CMA used for memcg and things as well, where we only
allocate the shadow page frames on-demand.

This moves CMA out of the crappy hardware-only section and should result
in pretty much everybody using it (except me, since I have cgroup=3Dn).

Anyway, THP isn't an issue for -rt, its impossible to select when you
have PREEMPT_RT.

> > >Compaction on the other hand is during the normal operation of the
> > >machine. There are applications that assume that if anonymous memory
> > >is mlocked() then access to it is close to zero latency. They are
> > >not RT-critical processes (or they would disable THP) but depend on
> > >this. Allowing compaction to migrate mlocked() pages will result in bu=
gs
> > >being reported by these people.
> > >
> > >I've received one bug this year about access latency to mlocked() regi=
ons but
> > >it turned out to be a file-backed region and related to when the write=
-fault
> > >is incurred. The ultimate fix was in the application but we'll get new=
 bug
> > >reports if anonymous mlocked pages do not preserve the current guarant=
ees
> > >on access latency.
> >=20
> > Can you please tell us your opinion about autonuma?
>=20
> I think it will have the same problem as THP using compaction. If
> mlocked pages can move then there may be unexpected latencies accessing
> mlocked anonymous regions.

numa and rt don't mix anyway.. don't worry about that.

> > I doubt we can keep such
> > mlock guarantee. I think we need to suggest application fix. maybe to i=
ntroduce
> > MADV_UNMOVABLE is good start. it seems to solve autonuma issue too.
> >=20
>=20
> That'll regress existing applications. It would be preferable to me that
> it be the other way around to not move mlocked pages unless the user says
> it's allowed.

I'd say go for it, I've been telling everybody who would listen that
mlock() only means no major faults for a very long time now.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
