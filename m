Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 067C36B005A
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 19:56:36 -0500 (EST)
MIME-Version: 1.0
Message-ID: <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
Date: Thu, 26 Jan 2012 16:56:34 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
 <4F218D36.2060308@linux.vnet.ibm.com>
 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
 <20120126163150.31a8688f.akpm@linux-foundation.org>
In-Reply-To: <20120126163150.31a8688f.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cle=
ancache)

Thanks for the reply!
=20
> On Thu, 26 Jan 2012 13:28:02 -0800 (PST)
> Dan Magenheimer <dan.magenheimer@oracle.com> wrote:
>=20
> > > I do think it also needs to get cleared on the way in to the page
> > > allocator.  Otherwise:
> > >
> > > =09PageSetWasActive(page);
> > > =09free_page(page);
> > > =09...
> > > =09another_user_page =3D get_free_page()
> > > =09// now cleancache sees the active bit for the prev user
> > >
> > > Or am I missing somewhere it gets cleared non-explicitly somewhere?
> >
> > True, it is not getting cleared and it should be, good catch!
>=20
> It should be added to PAGE_FLAGS_CHECK_AT_FREE.

I was thinking of clearing it in free_pages_prepare() before the
call to free_pages_check().  Does that make sense?  If so, then
it could also be added to PAGE_FLAGS_CHECK_AT_FREE, though it might
be a bit redundant.

> > I'll find the place to add the call to ClearPageWasActive() for v2.
>=20
> AFAICT this patch consumes our second-last page flag, or close to it.
> We'll all be breaking out in hysterics when the final one is gone.

I'd be OK with only using this on 64-bit systems, though there
are ARM folks playing with zcache that might disagree.  Am I
correct in assuming that your "second-last page flag" concern
applies only to 32-bit systems?

> This does appear to be a make or break thing for cleancache - if we
> can't fix https://lkml.org/lkml/2012/1/22/61 then cleancache is pretty
> much a dead duck.

Hmmm... is that URL correct?  If so, there is some subtlety in
that thread that I am missing as I don't understand the relationship
to cleancache at all?

> But I'm going to ask for great effort to avoid
> consuming another page flag.  Either fix cleancache via other means or,
> much less desirably, find an existing page flag and overload it.

Cleancache isn't broken.  The fix is not a requirement for other
cleancache users (Xen and RAMster), though it is definitely useful.
It's not a _requirement_ for zcache either but definitely helps on
certain workloads and systems, see below.

> And I'm afraid that neither I nor other MM developers are likely to
> help you with "fix cleancache via other means" because we weren't
> provided with any description of what the problem is within cleancache,
> nor how it will be fixed.  All we are given is the assertion "cleancache
> needs this".

The patch comment says:

The patch resolves issues reported with cleancache which occur
especially during streaming workloads on older processors,
see https://lkml.org/lkml/2011/8/17/351

I can see that may not be sufficient, so let me expand on it.

First, just as page replacement worked prior to the active/inactive
redesign at 2.6.27, cleancache works without the WasActive page flag.
However, just as pre-2.6.27 page replacement had problems on
streaming workloads, so does cleancache.  The WasActive page flag
is an attempt to pass the same active/inactive info gathered by
the post-2.6.27 kernel into cleancache, with the same objectives and
presumably the same result: improving the "quality" of pages preserved
in memory thus reducing refaults.

Is that clearer?  If so, I'll do better on the description at v2.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
