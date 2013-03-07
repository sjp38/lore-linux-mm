Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0061F6B0006
	for <linux-mm@kvack.org>; Thu,  7 Mar 2013 18:11:31 -0500 (EST)
MIME-Version: 1.0
Message-ID: <cd5fb4ff-094c-430c-94fb-a7416de0d332@default>
Date: Thu, 7 Mar 2013 15:11:06 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCHv7 4/8] zswap: add to mm/
References: <1362585143-6482-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1362585143-6482-5-git-send-email-sjenning@linux.vnet.ibm.com>
 <5138E3C7.9080205@sr71.net> <513904F2.50607@linux.vnet.ibm.com>
In-Reply-To: <513904F2.50607@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>, Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

> From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> To: Dave Hansen
> Subject: Re: [PATCHv7 4/8] zswap: add to mm/
>=20
> On 03/07/2013 01:00 PM, Dave Hansen wrote:
> > On 03/06/2013 07:52 AM, Seth Jennings wrote:
> > ...
> >> +**********************************/
> >> +/* attempts to compress and store an single page */
> >> +static int zswap_frontswap_store(unsigned type, pgoff_t offset,
> >> +=09=09=09=09struct page *page)
> >> +{
> > ...
> >> +=09/* store */
> >> +=09handle =3D zs_malloc(tree->pool, dlen,
> >> +=09=09__GFP_NORETRY | __GFP_HIGHMEM | __GFP_NOMEMALLOC |
> >> +=09=09=09__GFP_NOWARN);
> >> +=09if (!handle) {
> >> +=09=09zswap_reject_zsmalloc_fail++;
> >> +=09=09ret =3D -ENOMEM;
> >> +=09=09goto putcpu;
> >> +=09}
> >> +
> >
> > I think there needs to at least be some strong comments in here about
> > why you're doing this kind of allocation.  From some IRC discussion, it
> > seems like you found some pathological case where zswap wasn't helping
> > make reclaim progress and ended up draining the reserve pools and you
> > did this to avoid draining the reserve pools.
>=20
> I'm currently doing some tests with fewer zsmalloc class sizes and
> removing __GFP_NOMEMALLOC to see the effect.

Zswap/zcache/frontswap are greedy, at times almost violently so.
Using emergency reserves seems like a sure way to OOM depending
on the workload (and luck).

I did some class size experiments too without seeing much advantage.
But without a range of "representative" data streams, it's very
hard to claim any experiment is successful.

I've got some ideas on combining the best of zsmalloc and zbud
but they are still a little raw.

> > I think the lack of progress doing reclaim is really the root cause you
> > should be going after here instead of just working around the symptom.

Dave, agreed.  See http://marc.info/?l=3Dlinux-mm&m=3D136147977602561&w=3D2=
=20
and the PAGEFRAME EVACUATION subsection of
http://marc.info/?l=3Dlinux-mm&m=3D136200745931284&w=3D2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
