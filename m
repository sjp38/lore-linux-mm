Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 52CAB94006D
	for <linux-mm@kvack.org>; Tue,  4 Oct 2011 11:10:43 -0400 (EDT)
Subject: Re: lockdep recursive locking detected (rcu_kthread / __cache_free)
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue, 04 Oct 2011 17:09:50 +0200
In-Reply-To: <alpine.DEB.2.00.1110040948230.8522@router.home>
References: <20111003175322.GA26122@sucs.org>
	  <20111003203139.GH2403@linux.vnet.ibm.com>
	  <alpine.DEB.2.00.1110031540560.11713@router.home>
	  <20111003214739.GK2403@linux.vnet.ibm.com>
	  <alpine.DEB.2.00.1110040916330.8522@router.home>
	 <1317739225.32543.9.camel@twins>
	 <alpine.DEB.2.00.1110040948230.8522@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317740991.32543.19.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@gentwo.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Sitsofe Wheeler <sitsofe@yahoo.com>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Tue, 2011-10-04 at 09:50 -0500, Christoph Lameter wrote:
> On Tue, 4 Oct 2011, Peter Zijlstra wrote:
>=20
> > It could of course be I got confused and broke stuff instead, could
> > someone who knows slab (I guess that's either Pekka, Christoph or David=
)
> > stare at those patches?
>=20
> Why is the loop in init_lock_keys only running over kmalloc caches and no=
t
> over all slab caches?

A little digging brings us to: 056c62418cc639bf2fe962c6a6ee56054b838bc7
which seems to have introduced that.

>  It seems that this has to be especially applied to
> regular slab caches because those are the ones that mostly have off slab
> structures. So modify init_lock_keys to run over all slab caches?

That sounds about right, worth a try. Also over new caches, the above
reverenced commit removes a hook from kmem_cache_init() which we really
need I suppose.

I'll try and compose a patch if nobody beats me to it, but need to run
an errand first.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
