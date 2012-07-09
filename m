Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2B1A56B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:07:05 -0400 (EDT)
Message-ID: <1341835552.3462.50.camel@twins>
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 09 Jul 2012 14:05:52 +0200
In-Reply-To: <4FF87F5F.30106@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <20120316144241.012558280@chello.nl> <4FF87F5F.30106@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2012-07-07 at 14:26 -0400, Rik van Riel wrote:
> > +/*
> > + * Assumes symmetric NUMA -- that is, each node is of equal size.
> > + */
> > +static void set_max_mem_load(unsigned long load)
> > +{
> > +     unsigned long old_load;
> > +
> > +     spin_lock(&max_mem_load.lock);
> > +     old_load =3D max_mem_load.load;
> > +     if (!old_load)
> > +             old_load =3D load;
> > +     max_mem_load.load =3D (old_load + load) >> 1;
> > +     spin_unlock(&max_mem_load.lock);
> > +}
>=20
> The above in your patch kind of conflicts with this bit
> from patch 6/26:

Yeah,.. its pretty broken. Its also effectively disabled, but yeah.


> Looking at how the memory load code is used, I wonder
> if it would make sense to count "zone size - free - inactive
> file" pages instead?=20

Something like that, although I guess we'd want a sum over all zones in
a node for that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
