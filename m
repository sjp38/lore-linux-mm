Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 4F6356B005A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 06:27:39 -0400 (EDT)
Message-ID: <1340792851.10063.20.camel@twins>
Subject: Re: needed lru_add_drain_all() change
From: Peter Zijlstra <peterz@infradead.org>
Date: Wed, 27 Jun 2012 12:27:31 +0200
In-Reply-To: <20120626234119.755af455.akpm@linux-foundation.org>
References: <20120626143703.396d6d66.akpm@linux-foundation.org>
	 <4FEA59EE.8060804@kernel.org>
	 <20120626181504.23b8b73d.akpm@linux-foundation.org>
	 <4FEA6B5B.5000205@kernel.org>
	 <20120626221217.1682572a.akpm@linux-foundation.org>
	 <4FEA9D13.6070409@kernel.org>
	 <20120626225544.068df1b9.akpm@linux-foundation.org>
	 <4FEAA925.9020202@kernel.org>
	 <20120626234119.755af455.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@gmail.com>

On Tue, 2012-06-26 at 23:41 -0700, Andrew Morton wrote:
> On Wed, 27 Jun 2012 15:33:09 +0900 Minchan Kim <minchan@kernel.org> wrote=
:
>=20
> > Anyway, let's wait further answer, especially, RT folks.=20
>=20
> rt folks said "it isn't changing", and I agree with them.  It isn't
> worth breaking the rt-prio quality of service because a few odd parts
> of the kernel did something inappropriate.  Especially when those
> few sites have alternatives.

I'm not exactly sure its a 'few' sites.. but yeah there's a few obvious
sites we should look at.

Afaict all lru_add_drain_all() callers do this optimistically, esp.
since there's no hard sync. against adding new entries to the per-cpu
pagevecs.

So there's no hard requirement to wait for completion, now not waiting
has obvious problems as well, but we could cheat and timeout after a few
jiffies or so.

This would avoid the DoS scenario, it will not improve the over-all
quality of the kernel though, since an unflushed pagevec can result in
compaction etc. failing.

The problem with stuffing all this in hardirq context (using
on_each_cpu() and friends) is that these people who do spin in fifo
threads generally don't like interrupt latencies forced on them either.
And I presume its currently scheduled is because its potentially quite
expensive to flush all these pages.

The only alternative I can come up with is scheduling the work like we
do now, wait for it for a few jiffies, track which CPUs completed,
cancel the others, and remote flush their pagevecs from the calling cpu.

But I can't say I like that option either...


As it stands I've always said that doing while(1) from FIFO/RR tasks is
broken and you get to keep the pieces. If we can find good solutions for
this I'm all ears, but I don't think its something we should bend over
backwards for.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
