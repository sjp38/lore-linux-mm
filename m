Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id B982B6B004D
	for <linux-mm@kvack.org>; Wed, 18 Jan 2012 07:09:15 -0500 (EST)
Received: by vbbfa15 with SMTP id fa15so3154738vbb.14
        for <linux-mm@kvack.org>; Wed, 18 Jan 2012 04:09:14 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1326265453_1662@mail4.comsite.net>
References: <1326040026-7285-6-git-send-email-gilad@benyossef.com>
	<1326265453_1662@mail4.comsite.net>
Date: Wed, 18 Jan 2012 14:09:14 +0200
Message-ID: <CAOtvUMceUE9t1EsTPGTZ9gERHvshnZOZ1_4YVumyNiBvrixMTQ@mail.gmail.com>
Subject: Re: [PATCH v6 5/8] slub: only IPI CPUs that have per cpu obj to flush
From: Gilad Ben-Yossef <gilad@benyossef.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Milton Miller <miltonm@bga.com>
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux.com>, Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Frederic Weisbecker <fweisbec@gmail.com>, Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Avi Kivity <avi@redhat.com>

On Wed, Jan 11, 2012 at 9:04 AM, Milton Miller <miltonm@bga.com> wrote:

>
> > mm/slub.c | 10 +++++++++-
> > 1 files changed, 9 insertions(+), 1 deletions(-)
> >
> > diff --git a/mm/slub.c b/mm/slub.c
> > index 09ccee8..31833d6 100644
> > --- a/mm/slub.c
> > +++ b/mm/slub.c
> > @@ -2013,9 +2013,17 @@ static void flush_cpu_slab(void *d)
> > __flush_cpu_slab(s, smp_processor_id());
> > }
> >
> > +static int has_cpu_slab(int cpu, void *info)
> > +{
> > + struct kmem_cache *s =3D info;
> > + struct kmem_cache_cpu *c =3D per_cpu_ptr(s->cpu_slab, cpu);
> > +
> > + return !!(c->page);
>
> __flush_cpu_slab is careful to test that the the per_cpu_ptr is not
> NULL before referencing the page field. =A0free_percpu likewise ignores
> NULL pointers. =A0We need to check !!(c && c->page) here.
>
This is indeed what I did in the first iterations but Christoph indicated t=
hat
c could never be NULL in his review of the patch. See :
https://lkml.org/lkml/2011/11/15/207

I integrated all the other review comment of this patch though. Thanks!
Gilad

--
Gilad Ben-Yossef
Chief Coffee Drinker
gilad@benyossef.com
Israel Cell: +972-52-8260388
US Cell: +1-973-8260388
http://benyossef.com

"Unfortunately, cache misses are an equal opportunity pain provider."
-- Mike Galbraith, LKML

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
