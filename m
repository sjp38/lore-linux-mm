Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7CF9F6B0169
	for <linux-mm@kvack.org>; Tue,  9 Aug 2011 13:43:44 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <747e657f-24be-41ed-a251-36116c8a6a13@default>
Date: Tue, 9 Aug 2011 10:43:16 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure
 changes
References: <20110808204555.GA15850@ca-server1.us.oracle.com>
 <4E414320020000780005057E@nat28.tlf.novell.com><4E414320020000780005057E@nat28.tlf.novell.com>
 <ce8cba73-ec3c-42ae-849a-11db1df8ffa3@default
 4E4179D90200007800050676@nat28.tlf.novell.com>
In-Reply-To: <4E4179D90200007800050676@nat28.tlf.novell.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Beulich <JBeulich@novell.com>
Cc: hannes@cmpxchg.org, jackdachef@gmail.com, hughd@google.com, jeremy@goop.org, npiggin@kernel.dk, linux-mm@kvack.org, akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, Chris Mason <chris.mason@oracle.com>, Konrad Wilk <konrad.wilk@oracle.com>, Kurt Hackel <kurt.hackel@oracle.com>, riel@redhat.com, ngupta@vflare.org, linux-kernel@vger.kernel.org, matthew@wil.cx

> From: Jan Beulich [mailto:JBeulich@novell.com]
> Subject: RE: Subject: [PATCH V6 1/4] mm: frontswap: swap data structure c=
hanges
>=20
> >>> On 09.08.11 at 17:03, Dan Magenheimer <dan.magenheimer@oracle.com> wr=
ote:
> >> > --- linux/include/linux/swap.h=092011-08-08 08:19:25.880690134 -0600
> >> > +++ frontswap/include/linux/swap.h=092011-08-08 08:59:03.952691415 -=
0600
> >> > @@ -194,6 +194,8 @@ struct swap_info_struct {
> >> >  =09struct block_device *bdev;=09/* swap device or bdev of swap file=
 */
> >> >  =09struct file *swap_file;=09=09/* seldom referenced */
> >> >  =09unsigned int old_block_size;=09/* seldom referenced */
> >>
> >> #ifdef CONFIG_FRONTSWAP
> >>
> >> > +=09unsigned long *frontswap_map;=09/* frontswap in-use, one bit per=
 page */
> >> > +=09unsigned int frontswap_pages;=09/* frontswap pages in-use counte=
r */
> >>
> >> #endif
> >>
> >> (to eliminate any overhead with that config option unset)
> >>
> >> Jan
> >
> > Hi Jan --
> >
> > Thanks for the review!
> >
> > As noted in the commit comment, if these structure elements are
> > not put inside an #ifdef CONFIG_FRONTSWAP, it becomes
> > unnecessary to clutter the core swap code with several ifdefs.
> > The cost is one pointer and one unsigned int per allocated
> > swap device (often no more than one swap device per system),
> > so the code clarity seemed more important than the tiny
> > additional runtime space cost.
> >
> > Do you disagree?
>=20
> Not necessarily - I just know that in other similar occasions (partly
> internally to our company) I was asked to make sure turned off
> features would not leave *any* run time foot print whatsoever.
>=20
> Jan

Well I tried adding the ifdef to the structure as you suggested
and it requires three instances of "#ifdef CONFIG_FRONTSWAP"
in mm/swapfile.c.  BUT unless I get into massive code duplication
it still leaves a runtime footprint as extra parameters are passed
to enable_swap_info(), try_to_unuse(), and find_next_to_unuse();
so the intent to achieve zero runtime footprint is illusory.
I expect "absolutely zero runtime footprint" is a goal that very
very few significant new features achieve.

That said, frontswap and cleancache are designed so that they
SHOULD be config=3Dy by default for most distros.  Unless a
module (e.g. zcache or tmem) registers the callbacks, the
overhead is very nearly zero... but if they are config=3Dn,
then a module cannot use them at all.  This would be unfortunate
because the potential performance gain is not insignificant.
I would have preferred them to be merged with default of config=3Dy,
but Linus disabused me of that notion :-}

Anyway, unless you feel very strongly about this, I'm
inclined to not add the ifdef to the struct for the
reasons previously stated.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
