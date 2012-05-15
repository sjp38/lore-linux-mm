Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 72D8E6B004D
	for <linux-mm@kvack.org>; Tue, 15 May 2012 07:06:25 -0400 (EDT)
Message-ID: <1337079974.27694.36.camel@twins>
Subject: Re: Allow migration of mlocked page?
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 15 May 2012 13:06:14 +0200
In-Reply-To: <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
	 <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de>
	 <4FB1BC3E.3070107@kernel.org>
	 <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Theodore Ts'o <tytso@mit.edu>

On Tue, 2012-05-15 at 00:33 -0400, KOSAKI Motohiro wrote:
> > 3. Thera are several places which already have migrate mlocked pages bu=
t it's okay because
> >   it's done under user's control while compaction/khugepagd doesn't.
>=20
> I disagree. CPUSETS are used from admins. realtime _application_ is writt=
en
> by application developers. ok, they are often overwrapped or the same. bu=
t it's
> not exactly true. memory hotplug has similar situation.

I'm not exactly sure I get what you're saying, but with the current
scheme of things its impossible to run an RT app properly without the
administrator knowing wrf he's doing.

So the fact that cpusets are admin only doesn't matter, he'd better know
about the rt apps and its requirements.

This very much includes crap like THP (which, as stated, is unavailable
for PREEMPT_RT) since that is under administrator control.

CMA and other allocation based compaction much less so though.

> Moreover, Think mix up rt-app and non-rt-migrate_pages-user-app situation=
. RT
> app still be faced minor page fault and it's not expected from rt-app
> developers.=20

It would be if they'd listened to what I've been telling them for ages.

Anyway.. taking faults isn't the problem for RT, taking indeterministic
time to satisfy them is, and disk IO is completely off the charts
indeterministic. Minor faults much less so.

There is a very big difference between very fast and real-time, they've
got very little to do with one another.

That said, the way page migration currently works isn't ideal from a
determinism pov, the migration PTE can be present for a basically
indeterminate amount of time.

So yes, page migration is a 'serious' problem, but only because the way
its implemented is sub-optimal.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
