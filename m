Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id C56A26B004F
	for <linux-mm@kvack.org>; Thu, 26 Jan 2012 16:28:04 -0500 (EST)
MIME-Version: 1.0
Message-ID: <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
Date: Thu, 26 Jan 2012 13:28:02 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
 <4F218D36.2060308@linux.vnet.ibm.com>
In-Reply-To: <4F218D36.2060308@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>

> From: Dave Hansen [mailto:dave@linux.vnet.ibm.com]
> Subject: Re: [PATCH] mm: implement WasActive page flag (for improving cle=
ancache)

Thanks for the review Dave!
=20
> On 01/25/2012 01:58 PM, Dan Magenheimer wrote:
> > (Feedback welcome if there is a different/better way to do this
> > without using a page flag!)
> >
> > Since about 2.6.27, the page replacement algorithm maintains
> > an "active" bit to help decide which pages are most eligible
> > to reclaim, see http://linux-mm.org/PageReplacementDesign
> >
> > This "active' information is also useful to cleancache but is lost
> > by the time that cleancache has the opportunity to preserve the
> > pageful of data.  This patch adds a new page flag "WasActive" to
> > retain the state.  The flag may possibly be useful elsewhere.
>=20
> I guess cleancache itself is clearing the bit, right?  I didn't see any
> clearing going on in the patch.

No, there are no changes in cleancache.c so it isn't clearing
the bit.

> I do think it also needs to get cleared on the way in to the page
> allocator.  Otherwise:
>=20
> =09PageSetWasActive(page);
> =09free_page(page);
> =09...
> =09another_user_page =3D get_free_page()
> =09// now cleancache sees the active bit for the prev user
>=20
> Or am I missing somewhere it gets cleared non-explicitly somewhere?

True, it is not getting cleared and it should be, good catch!

I'll find the place to add the call to ClearPageWasActive() for v2.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
