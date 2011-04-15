Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 06861900086
	for <linux-mm@kvack.org>; Fri, 15 Apr 2011 10:45:59 -0400 (EDT)
Date: Fri, 15 Apr 2011 09:45:56 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: BUILD_BUG_ON() breaks sparse gfp_t checks
In-Reply-To: <1302817191.16562.1036.camel@nimitz>
Message-ID: <alpine.DEB.2.00.1104150945230.5863@router.home>
References: <1302795695.14658.6801.camel@nimitz>  <20110414132220.970cfb2a.akpm@linux-foundation.org> <1302817191.16562.1036.camel@nimitz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>, Jan Beulich <JBeulich@novell.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 14 Apr 2011, Dave Hansen wrote:

> On Thu, 2011-04-14 at 13:22 -0700, Andrew Morton wrote:
> > The kernel calls gfp_zone() with a constant arg in very few places.
> > This?
> >
> > --- a/include/linux/gfp.h~a
> > +++ a/include/linux/gfp.h
> > @@ -249,14 +249,9 @@ static inline enum zone_type gfp_zone(gf
> >
> >         z = (GFP_ZONE_TABLE >> (bit * ZONES_SHIFT)) &
> >                                          ((1 << ZONES_SHIFT) - 1);
> > -
> > -       if (__builtin_constant_p(bit))
> > -               BUILD_BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > -       else {
> >  #ifdef CONFIG_DEBUG_VM
> > -               BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> > +       BUG_ON((GFP_ZONE_BAD >> bit) & 1);
> >  #endif
> > -       }
> >         return z;
> >  }
>
> That definitely makes sparse happier.  I hope the folks on cc will chime
> in if they wanted something special at build time.

You can also remove the #ifdef. Use VM_BUG_ON.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
