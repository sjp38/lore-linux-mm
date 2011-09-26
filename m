Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4391F9000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 05:46:27 -0400 (EDT)
Subject: Re: [PATCH 5/5] slub: Only IPI CPUs that have per cpu obj to flush
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Sep 2011 11:45:52 +0200
In-Reply-To: <CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
References: <1316940890-24138-1-git-send-email-gilad@benyossef.com>
	 <1316940890-24138-6-git-send-email-gilad@benyossef.com>
	 <1317022420.9084.57.camel@twins>
	 <CAOtvUMeMsd0Jk1k4wP9Y+7NW3FYZZAqV1-cRj5Zt4+eaugWoPg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Message-ID: <1317030352.9084.76.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gilad Ben-Yossef <gilad@benyossef.com>
Cc: linux-kernel@vger.kernel.org, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, Chris Metcalf <cmetcalf@tilera.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>

On Mon, 2011-09-26 at 11:35 +0300, Gilad Ben-Yossef wrote:
> Yes, the alloc in the flush_all path definitively needs to go. I
> wonder if just to resolve that allocating the mask per cpu and not in
> kmem_cache itself is not better - after all, all we need is a single
> mask per cpu when we wish to do a flush_all and no per cache. The
> memory overhead of that is slightly better. This doesn't cover the
> cahce bounce issue.
>=20
> My thoughts regarding that were that since the flush_all() was a
> rather rare operation it is preferable to do some more
> work/interference here, if it allows us to avoid having to do more
> work in the hotter alloc/dealloc paths, especially since it allows us
> to have less IPIs that I figured are more intrusive then cacheline
> steals (are they?)
>=20
> After all, for each CPU that actually needs to do a flush, we are
> making the flush a bit more expensive because of the cache bounce just
> before we send the IPI, but that IPI and further operations are an
> expensive operations anyway. For CPUs that don't need to do a flush, I
> replaced an IPI for a cacheline(s) steal. I figured it was still a
> good bargain

Hard to tell really, I've never really worked with these massive
machines, biggest I've got is 2 nodes and for that I think your
for_each_online_cpu() loop might indeed still be a win when compared to
extra accounting on the alloc/free paths.

The problem with a per-cpu cpumask is that you need to disable
preemption over the whole for_each_online_cpu() scan and that's not
really sane on very large machines as that can easily take a very long
time indeed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
