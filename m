Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 557C16B0092
	for <linux-mm@kvack.org>; Tue, 15 May 2012 00:33:48 -0400 (EDT)
Received: by ggm4 with SMTP id 4so3909099ggm.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 21:33:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FB1BC3E.3070107@kernel.org>
References: <4FAC9786.9060200@kernel.org> <20120511131404.GQ11435@suse.de>
 <4FB08920.4010001@kernel.org> <20120514133944.GF29102@suse.de> <4FB1BC3E.3070107@kernel.org>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Tue, 15 May 2012 00:33:27 -0400
Message-ID: <CAHGf_=qW6759UUxPvzoLfTdPCOHAahxN9DsPkkXHgoij9e5urg@mail.gmail.com>
Subject: Re: Allow migration of mlocked page?
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, tglx@linutronix.de, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Theodore Ts'o <tytso@mit.edu>

> Okay. Let's summary opinions in this thread until now.
>
> 1. mlock doesn't have pinning's semantic by definition of opengroup.
> 2. man page says "No page fault". It's bad. Maybe need fix up of man page=
.

Yes, it should be.

> 3. Thera are several places which already have migrate mlocked pages but =
it's okay because
> =A0 it's done under user's control while compaction/khugepagd doesn't.

I disagree. CPUSETS are used from admins. realtime _application_ is written
by application developers. ok, they are often overwrapped or the same. but =
it's
not exactly true. memory hotplug has similar situation.

Moreover, Think mix up rt-app and non-rt-migrate_pages-user-app situation. =
RT
app still be faced minor page fault and it's not expected from rt-app
developers.


> 3. Many application already used mlock by semantic of 2. So let's break l=
egacy application if possible.

Many? really? I guess it's a very few.

> 4. CMA consider getting of free contiguos memory as top priority so laten=
cy may be okay in CMA
> =A0 while THP consider latency as top priority.
> 5. Let's define new API which would be
> =A0 5.1 mlock(SOFT) - it can gaurantee memory-resident.
> =A0 5.2 mlock(HARD) - it can gaurantee 1 and pinning.
> =A0 Current mlock could be 5.1, then we should implement 5.2. Or
> =A0 Current mlock could be 5.2, then we should implement 5.1
> =A0 We can implement it by PG_pinned or vma flags.

I definitely agree we need both pinned and not-pinned mlock.


> One of clear point is that it's okay to migrate mlocked page in CMA.
> And we can migrate mlocked anonymous pages and mlocked file pages by MIGR=
ATE_ASYNC mode in compaction
> if we all agree Peter who says "mlocked mean NO MAJOR FAULT".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
