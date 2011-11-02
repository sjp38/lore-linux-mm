Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id EA8506B0069
	for <linux-mm@kvack.org>; Wed,  2 Nov 2011 17:42:19 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <7033410c-13d4-4240-8ffc-007da03d41e3@default>
Date: Wed, 2 Nov 2011 14:42:06 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [GIT PULL] mm: frontswap (for 3.2 window)
References: <b2fa75b6-f49c-4399-ba94-7ddf08d8db6e@default>
 <20111031171321.097a166c.kamezawa.hiroyu@jp.fujitsu.com>
 <ef778e79-72d0-4c58-99e8-3b36d85fa30d@default>
 <20111101095038.30289914.kamezawa.hiroyu@jp.fujitsu.com>
 <f62e02cd-fa41-44e8-8090-efe2ef052f64@default>
 <20111101144309.a51c99b5.akpm@linux-foundation.org
 4EB1B01E.7030005@redhat.com>
In-Reply-To: <4EB1B01E.7030005@redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Jeremy Fitzhardinge <jeremy@goop.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, ngupta@vflare.org, levinsasha928@gmail.com, Chris Mason <chris.mason@oracle.com>, JBeulich@novell.com, Dave Hansen <dave@linux.vnet.ibm.com>, Jonathan Corbet <corbet@lwn.net>, Neo Jia <cyclonusj@gmail.com>

> From: Rik van Riel [mailto:riel@redhat.com]
> Subject: Re: [GIT PULL] mm: frontswap (for 3.2 window)
>=20
> On 11/01/2011 05:43 PM, Andrew Morton wrote:
>=20
> > I will confess to and apologise for dropping the ball on cleancache and
> > frontswap.  I was never really able to convince myself that it met the
> > (very vague) cost/benefit test,
>=20
> I believe that it can, but if it does, we also have to
> operate under the assumption that the major distros will
> enable it.
> This means that "no overhead when not compiled in" is
> not going to apply to the majority of the users out there,
> and we need clear numbers on what the overhead is when it
> is enabled, but not used.

Right.  That's Case B (see James Bottomley subthread)
and the overhead is one pointer comparison against
NULL per page physically swapin/swapout to a swap
device (i.e., essentially zero).  Rik, would you
be willing to examine the code to confirm that
statement?
=20
> We also need an API that can handle arbitrarily heavy
> workloads, since that is what people will throw at it
> if it is enabled everywhere.
>=20
> I believe that means addressing some of Andrea's concerns,
> specifically that the API should be able to handle vectors
> of pages and handle them asynchronously.
>=20
> Even if the current back-ends do not handle that today,
> chances are that (if tmem were to be enabled everywhere)
> people will end up throwing workloads at tmem that pretty
> much require such a thing.

Wish I'd been a little faster on typing the previous
message.  Rik, could you ensure you respond to yourself
here if you are happy with my proposed batching design
to do the batching that you and Andrea want?  (And if
you are not happy, provide code to show where you
would place a new batch-put hook?)

> An asynchronous interface would probably be a requirement
> for something as high latency as encrypted ramster :)

Pure asynchrony is a show-stopper for me.  But the
only synchrony required is to move/transform the
data locally.  Asynchronous things can still be done
but as a separate thread AFTER the data has been
"put" to tmem (which is exactly what RAMster does).

If asynchrony at frontswap_ops is demanded (and
I think Andrea has already retracted that), I would
have to ask you to present alternate code, both hooks
and driver, that work successfully, because my claim
is that it can't be done, certainly not without
massive changes to the swap subsystem (and likely
corresponding massive changes to VFS for cleancache).

> API concerns like this are things that should be solved
> before a merge IMHO, since afterwards we would end up with
> the "we cannot change the API, because that breaks users"
> scenario that we always end up finding ourselves in.

I think I've amply demonstrated that the API is
minimal and extensible, as demonstrated by the
above points.  Much of Andrea's concerns were due to
a misunderstanding of the code in staging/zcache,
thinking it was part of the API; the only "API"
being considered here is defined by frontswap_ops.

Also, the API for frontswap_ops is almost identical to the
API for cleancache_ops and uses a much simpler, much
more isolated set of hooks.   Frontswap "finishes"
tmem, cleancache is already merged. Leaving tmem
unfinished is worse than not having it all (and
I can already hear Christoph cackling and jumping
to his keyboard ;-)

Thanks,
Dan

OK, I really need to discontinue my participation in
this for a couple of days for personal/health reasons,
so I hope I've made my case.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
