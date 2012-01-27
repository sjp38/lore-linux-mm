Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 5D4C06B009B
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 00:11:24 -0500 (EST)
MIME-Version: 1.0
Message-ID: <26652b48-de95-4891-9da4-836192d5f5cb@default>
Date: Thu, 26 Jan 2012 21:11:21 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
 <4F218D36.2060308@linux.vnet.ibm.com>
 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
 <20120126163150.31a8688f.akpm@linux-foundation.org>
 <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default> <4F2219D4.9010209@redhat.com>
In-Reply-To: <4F2219D4.9010209@redhat.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>

> From: Rik van Riel [mailto:riel@redhat.com]
> Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cle=
ancache)
>=20
> On 01/26/2012 07:56 PM, Dan Magenheimer wrote:
>=20
> > The patch resolves issues reported with cleancache which occur
> > especially during streaming workloads on older processors,
> > see https://lkml.org/lkml/2011/8/17/351
> >
> > I can see that may not be sufficient, so let me expand on it.
> >
> > First, just as page replacement worked prior to the active/inactive
> > redesign at 2.6.27, cleancache works without the WasActive page flag.
> > However, just as pre-2.6.27 page replacement had problems on
> > streaming workloads, so does cleancache.  The WasActive page flag
> > is an attempt to pass the same active/inactive info gathered by
> > the post-2.6.27 kernel into cleancache, with the same objectives and
> > presumably the same result: improving the "quality" of pages preserved
> > in memory thus reducing refaults.
> >
> > Is that clearer?  If so, I'll do better on the description at v2.
>=20
> Whether or not this patch improves things would depend
> entirely on the workload, no?
>=20
> I can imagine a workload where we have a small virtual
> machine and a large cleancache buffer in the host.
>=20
> Due to the small size of the virtual machine, pages
> might not stay on the inactive list long enough to get
> accessed twice in a row.
>=20
> This is almost the opposite problem (and solution) of
> what you ran into.
>=20
> Both seem equally likely (and probable)...

Hi Rik --

Thanks for the reply!

Yes, that's right, in your example, the advantage of
cleancache would be lost.  But the cost would also be
nil because the cleancache backend (zcache) would be rejecting
the inactive pages so would never incur any compression
cost and never use any space.  So "first, do no harm"
is held true.

To get the best of both (like the post-2.6.27 kernel page
replacement algorithm), the cleancache backend could implement
some kind of active/inactive balancing... but that can be
done later with no mm change beyond the proposed patch.

> When the page gets rescued from the cleancache, we
> know it was recently evicted and we can immediately
> put it onto the active file list.

True, that would be another refinement.  The proposed
patch does, however, turn on WasActive so, even if the
page never makes it back to the active lru, it will
still go back into cleancache when evicted from the
pagecache.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
