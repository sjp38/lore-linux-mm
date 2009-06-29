Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id AFF5A6B0055
	for <linux-mm@kvack.org>; Mon, 29 Jun 2009 17:56:06 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <a2cac9b3-74c1-4eea-8273-afe2226cef1d@default>
Date: Mon, 29 Jun 2009 14:57:23 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [RFC] transcendent memory for Linux
In-Reply-To: <4A4930DA.5030700@goop.org>
Content-Type: text/plain; charset=Windows-1252
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Jeremy Fitzhardinge <jeremy@goop.org>
Cc: Pavel Machek <pavel@ucw.cz>, linux-kernel@vger.kernel.org, xen-devel@lists.xensource.com, npiggin@suse.de, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, Avi Kivity <avi@redhat.com>, Rik van Riel <riel@redhat.com>, alan@lxorguk.ukuu.org.uk, Rusty Russell <rusty@rustcorp.com.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, akpm@osdl.org, Marcelo Tosatti <mtosatti@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, tmem-devel@oss.oracle.com, sunil.mushran@oracle.com, linux-mm@kvack.org, Himanshu Raj <rhim@microsoft.com>
List-ID: <linux-mm.kvack.org>

> From: Jeremy Fitzhardinge [mailto:jeremy@goop.org]
>=20
> On 06/29/09 14:13, Dan Magenheimer wrote:
> > The uuid is only used for shared pools.  If two different
> > "tmem clients" (guests) agree on a 128-bit "shared secret",
> > they can share a tmem pool.  For ocfs2, the 128-bit uuid in
> > the on-disk superblock is used for this purpose to implement
> > shared precache.  (Pages evicted by one cluster node
> > can be used by another cluster node that co-resides on
> > the same physical system.)=20
>=20
> What are the implications of some third party VM guessing the=20
> "uuid" of
> a shared pool?  Presumably they could view and modify the contents of
> the pool.  Is there any security model beyond making UUIDs=20
> unguessable?

Interesting question.  But, more than the 128-bit UUID must
be guessed... a valid 64-bit object id and a valid 32-bit
page index must also be guessed (though most instances of
the page index are small numbers so easy to guess).  Once
192 bits are guessed though, yes, the pages could be viewed
and modified.  I suspect there are much more easily targeted
security holes in most data centers than guessing 192 (or
even 128) bits.

Now this only affects shared pools, and shared-precache is still
experimental and not really part of this patchset.  Does "mount"
of an accessible disk/filesystem have a better security model?
Perhaps there are opportunities to leverage that?

> > The (page)size argument is always fixed (at PAGE_SIZE) for
> > any given kernel.  The underlying implementation can
> > be capable of supporting multiple pagesizes.
>
> Pavel's other point was that merging the size field into the=20
> flags is a
> bit unusual/ugly.  But you can workaround that by just defining the
> "flag" values for each plausible page size, since there's a=20
> pretty small
> bound: TMEM_PAGESZ_4K, 8K, etc.

OK I see.  Yes the point (and the workaround) are valid.
=20
> Also, having an "API version number" is a very bad idea.  Such version
> numbers are very inflexible and basically don't work (esp if you're
> expecting to have multiple independent implementations of this API).=20
> Much better is to have feature flags; the caller asks for features on
> the new pool, and pool creation either succeeds or doesn't (a call to
> return the set of supported features is a good compliment).

Yes.  Perhaps all the non-flag bits should just be reserved for
future use.  Today, the implementation just checks for (and implements)
only zero anyway and nothing is defined anywhere except the 4K
pagesize at the lowest levels of the (currently xen-only) API.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
