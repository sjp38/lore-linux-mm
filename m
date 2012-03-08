Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 608056B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 11:51:24 -0500 (EST)
Received: by wgbds10 with SMTP id ds10so545943wgb.26
        for <linux-mm@kvack.org>; Thu, 08 Mar 2012 08:51:22 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <6a7f4e8f-6b33-4db9-8292-077194f64f3d@default>
References: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com>
	<04499111-84c1-45a2-a8e8-5c86a2447b56@default>
	<4F58C3E2.7010009@gmail.com>
	<6a7f4e8f-6b33-4db9-8292-077194f64f3d@default>
Date: Thu, 8 Mar 2012 17:51:22 +0100
Message-ID: <CACQs63KgLjEPV5vdB+SamVC3CG0h2e56c60YKx3fSQ_SEwAHmg@mail.gmail.com>
Subject: Re: (un)loadable module support for zcache
From: Andor Daam <andor.daam@googlemail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Florian Schmaus <fschmaus@gmail.com>, linux-mm@kvack.org, Stefan Hengelein <ilendir@googlemail.com>, sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, i4passt@lists.informatik.uni-erlangen.de, devel@linuxdriverproject.org, Nitin Gupta <ngupta@vflare.org>

2012/3/8 Dan Magenheimer <dan.magenheimer@oracle.com>
>
> > From: Florian Schmaus [mailto:fschmaus@gmail.com]
> > Subject: Re: (un)loadable module support for zcache
> >
> > On 03/05/12 17:57, Dan Magenheimer wrote:
> > > I think the answer here is for cleancache (and frontswap) to
> > > support "lazy pool creation". =A0If a backend has not yet
> > > registered when an init_fs/init call is made, cleancache
> > > (or frontswap) must record the attempt and generate a valid
> > > "fake poolid" to return. =A0Any calls to put/get/flush with
> > > a fake poolid is ignored as the zcache module is not
> > > yet loaded. =A0Later, when zcache is insmod'ed, it will attempt
> > > to register and cleancache must then call the init_fs/init
> > > routines (to "lazily" create the pools), obtain a "real poolid"
> > > from zcache for each pool and "map" the fake poolid to the real
> > > poolid on EVERY get/put/flush and on pool destroy (umount/swapoff).
> >
> > We were thinking about how to make cleancache and frontswap able to cop=
e
> > with the mounting of filesystems and running of swapon when there is no
> > backend registered without adding an indirection caused by a fake pool
> > id map.
> >
> > We figured a way to deal with this in cleancache would be to store the
> > struct super_block pointers in an array for every call to init_fs and
> > the uuids and struct super_blocks pointers in different arrays for ever=
y
> > call to init_shared_fs. When a filesystem unmounts before a backend is
> > registered, its entries in the respective arrays are removed.
> > While no backend is registered, the put_page() and invalidate_page() ar=
e
> > ignored and get_page() fails. As soon as a backend registers the init_f=
s
> > and init_shared_fs functions are called for the struct super_block
> > pointers (and uuids) stored in the according arrays.
> >
> > For frontswap we are aiming for a similar approach by remembering the
> > types for every call to init and failing put_page() and ignoring
> > get_page() and invalidate_page().
> > Again, when a backend registers init is called for every type stored.
> >
> > This should allow backends to register with cleancache and frontswap
> > even after the mounting of filesystems and/or swapon is run. Therefore
> > it should allow zcache to be insmodded. This would be a first step to
> > allow rmmodding of zcache aswell.
> >
> > Is this approach feasible?
>
> Hi Stefan, Florian, and Andor --
>
> I do see a potential problem with this approach. =A0You would
> be saving a superblock pointer and then using it later. =A0What
> if the filesystem was unmounted in the meantime? =A0Or, worse,
> what if it was unmounted and then the address of the superblock
> is reused to point to some completely different object?
>
> I think if you ensure that cleancache_invalidate_fs() is always
> called when a cleancache-enabled filesystem is unmounted,
> then in cleancache_invalidate_fs() you remove the matching
> superblock pointer from your arrays, then it should work.
>
> Dan

We already thought of removing the matching pointer, whenever a filesystem =
is
unmounted.
As the comment to __cleancache_invalidate_fs in cleancache.c states
that this function
is called by any cleancache-enabled filesystem at time of unmount, we
assumed that this function was actually always called upon unmount.
Is it not certain that this function is always called?

Andor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
