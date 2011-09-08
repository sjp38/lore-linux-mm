Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AD44E6B018D
	for <linux-mm@kvack.org>; Thu,  8 Sep 2011 11:01:12 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <896345e2-ded0-404a-8e64-490584ec2b4e@default>
Date: Thu, 8 Sep 2011 08:00:36 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V8 2/4] mm: frontswap: core code
References: <20110829164908.GA27200@ca-server1.us.oracle.com
 20110907162510.3547d67a.akpm@linux-foundation.org>
In-Reply-To: <20110907162510.3547d67a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hughd@google.com, ngupta@vflare.org, Konrad Wilk <konrad.wilk@oracle.com>, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@kernel.dk, riel@redhat.com, hannes@cmpxchg.org, matthew@wil.cx, Chris Mason <chris.mason@oracle.com>, sjenning@linux.vnet.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, jackdachef@gmail.com, cyclonusj@gmail.com, levinsasha928@gmail.com

> From: Andrew Morton [mailto:akpm@linux-foundation.org]
> Subject: Re: [PATCH V8 2/4] mm: frontswap: core code

Thanks very much for taking the time for this feedback!

Please correct me if I am presumptuous or misreading
SubmittingPatches, but after making the changes below,
I am thinking this constitutes a "Reviewed-by"?

> > From: Dan Magenheimer <dan.magenheimer@oracle.com>
> > Subject: [PATCH V8 2/4] mm: frontswap: core code
> >
> > This second patch of four in this frontswap series provides the core co=
de
> > for frontswap that interfaces between the hooks in the swap subsystem a=
nd
> > +
> > +struct frontswap_ops {
> > +=09void (*init)(unsigned);
> > +=09int (*put_page)(unsigned, pgoff_t, struct page *);
> > +=09int (*get_page)(unsigned, pgoff_t, struct page *);
> > +=09void (*flush_page)(unsigned, pgoff_t);
> > +=09void (*flush_area)(unsigned);
> > +};
>=20
> Please don't use the term "flush".  In both the pagecache code and the
> pte code it is interchangably used to refer to both writeback and
> invalidation.  The way to avoid this ambiguity and confusion is to use
> the terms "writeback" and "invalidate" instead.
>=20
> Here, you're referring to invalidation.

While the different name is OK, changing this consistently would now
require simultaneous patches in cleancache, zcache, and xen (not
to mention lots of docs inside and outside the kernel).  I suspect
it would be cleaner to do this later across all affected code
with a single commit.  Hope that's OK.

(Personally, I find "invalidate" to be inaccurate because common
usage of the term doesn't imply that the space used in the cache
is recovered, i.e. garbage collection, which is the case here.
To me, "flush" implies invalidate PLUS recover space.)

> > +static struct frontswap_ops frontswap_ops;
>=20
> __read_mostly?

Yep.  Will fix.
=20
> > +/*
> > + * This global enablement flag reduces overhead on systems where front=
swap_ops
> > + * has not been registered, so is preferred to the slower alternative:=
 a
> > + * function call that checks a non-global.
> > + */
> > +int frontswap_enabled;
>=20
> __read_mostly?

Yep.  Will fix.

> > +/*
> > + * Useful stats available in /sys/kernel/mm/frontswap.  These are for
> > + * information only so are not protected against increment/decrement r=
aces.
> > + */
> > +static unsigned long frontswap_gets;
> > +static unsigned long frontswap_succ_puts;
> > +static unsigned long frontswap_failed_puts;
> > +static unsigned long frontswap_flushes;
>=20
> If they're in /sys/kernel/mm then they rather become permanent parts of
> the exported kernel interface.  We're stuck with them.  Plus they're
> inaccurate and updating them might be inefficient, so we don't want to
> be stuck with them.
>=20
> I suggest moving these to debugfs from where we can remove them if we
> feel like doing so.

The style (and code) for this was mimicked from ksm and hugepages, which
expose the stats the same way... as does cleancache now.  slub is also
similar.  I'm OK with using a different approach (e.g. debugfs), but
think it would be inconsistent and confusing to expose these stats
differently than cleancache (or ksm and hugepages).  I'd support
and help with a massive cleanup commit across all of mm later though.
Hope that's OK for now.

> > +/*
> > + * Frontswap, like a true swap device, may unnecessarily retain pages
> > + * under certain circumstances; "shrink" frontswap is essentially a
> > + * "partial swapoff" and works by calling try_to_unuse to attempt to
> > + * unuse enough frontswap pages to attempt to -- subject to memory
> > + * constraints -- reduce the number of pages in frontswap
> > + */
> > +void frontswap_shrink(unsigned long target_pages)
>=20
> It's unclear whether `target_pages' refers to the number of pages to
> remove or to the number of pages to retain.  A comment is needed.

OK.  Will fix.

> > +{
> > +=09int wrapped =3D 0;
> > +=09bool locked =3D false;
> > +
> > +=09/* try a few times to maximize chance of try_to_unuse success */
>=20
> Why?  Is this necessary?  How often does try_to_unuse fail?
>=20
> > +=09for (wrapped =3D 0; wrapped < 3; wrapped++) {
>=20
> `wrapped' seems an inappropriate identifier.

Hmmm... this loop was mimicking some swap code that now
seems to be long gone.  I agree it's not really necessary
and will remove the loop (which also removes the identifier).

> > +
>=20
> unneeded newline

Doh!  Will fix.

> > +=09=09=09if (security_vm_enough_memory_kern(pages))
>=20
> What's this doing here? Needs a comment please.
>=20
> > +=09=09=09=09continue;
> > +=09=09=09vm_unacct_memory(pages);
>=20
> hm, is that accurate?  Or should we account for the pages which
> try_to_unuse() actually unused?

These are mimicking code in swapoff.  I think the code is
correct but agree a clarifying comment or two is in order.

> > +/*
> > + * Count and return the number of pages frontswap pages across all
>=20
> s/pages//

Doh!  Will fix.

> > + * swap devices.  This is exported so that a kernel module can
> > + * determine current usage without reading sysfs.
>=20
> Which kernel module might want to do this?

The tmem backends (currently zcache and xen tmem).  I'll change
the wording in the comment to clarify.

> > +#ifdef CONFIG_SYSFS
>=20
> Has the code been tested with CONFIG_SYSFS=3Dn?

Yes, in a previous version.  I'll doublecheck though.

Thanks again for the feedback!  I'll publish a V9 with
the corrections no later than early next week.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
