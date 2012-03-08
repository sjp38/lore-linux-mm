Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id CEC416B007E
	for <linux-mm@kvack.org>; Thu,  8 Mar 2012 12:07:31 -0500 (EST)
MIME-Version: 1.0
Message-ID: <0e5e6a0b-2fa2-4796-bf9c-5bf693ae2477@default>
Date: Thu, 8 Mar 2012 09:07:22 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: (un)loadable module support for zcache
References: <CABv5NL-SquBQH8W+K1CXNBQQWqHyYO+p3Y9sPqsbfZKp5EafTg@mail.gmail.com>
 <04499111-84c1-45a2-a8e8-5c86a2447b56@default> <4F58C3E2.7010009@gmail.com>
 <6a7f4e8f-6b33-4db9-8292-077194f64f3d@default>
 <CACQs63KgLjEPV5vdB+SamVC3CG0h2e56c60YKx3fSQ_SEwAHmg@mail.gmail.com>
In-Reply-To: <CACQs63KgLjEPV5vdB+SamVC3CG0h2e56c60YKx3fSQ_SEwAHmg@mail.gmail.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andor Daam <andor.daam@googlemail.com>
Cc: Florian Schmaus <fschmaus@gmail.com>, linux-mm@kvack.org, Stefan Hengelein <ilendir@googlemail.com>, sjenning@linux.vnet.ibm.com, Konrad Wilk <konrad.wilk@oracle.com>, i4passt@lists.informatik.uni-erlangen.de, devel@linuxdriverproject.org, Nitin Gupta <ngupta@vflare.org>

> From: Andor Daam [mailto:andor.daam@googlemail.com]
> Subject: Re: (un)loadable module support for zcache
>=20
> 2012/3/8 Dan Magenheimer <dan.magenheimer@oracle.com>
> >
> > > From: Florian Schmaus [mailto:fschmaus@gmail.com]
> > > Subject: Re: (un)loadable module support for zcache
> > >
> > > This should allow backends to register with cleancache and frontswap
> > > even after the mounting of filesystems and/or swapon is run. Therefor=
e
> > > it should allow zcache to be insmodded. This would be a first step to
> > > allow rmmodding of zcache aswell.
> > >
> > > Is this approach feasible?
> >
> > Hi Stefan, Florian, and Andor --
> >
> > I do see a potential problem with this approach. =A0You would
> > be saving a superblock pointer and then using it later. =A0What
> > if the filesystem was unmounted in the meantime? =A0Or, worse,
> > what if it was unmounted and then the address of the superblock
> > is reused to point to some completely different object?
> >
> > I think if you ensure that cleancache_invalidate_fs() is always
> > called when a cleancache-enabled filesystem is unmounted,
> > then in cleancache_invalidate_fs() you remove the matching
> > superblock pointer from your arrays, then it should work.
>=20
> We already thought of removing the matching pointer, whenever a filesyste=
m is
> unmounted.

Great!

> As the comment to __cleancache_invalidate_fs in cleancache.c states
> that this function
> is called by any cleancache-enabled filesystem at time of unmount, we
> assumed that this function was actually always called upon unmount.

Hi Andor --

Until now, cleancache_invalidate_fs was only called for garbage
collection so it didn't really matter.  Since, after you work is
done, a missed call to cleancache_invalidate_fs has the potential
to cause data corruption, it's probably best to be paranoid
and verify.

> Is it not certain that this function is always called?

I *think* it should always be called, but I am not a filesystem expert.
It might be worth asking the question on a filesytem mailing list
(or on the individual lists for ext3/4, ocfs2, btrfs):  "Is it
ever possible for a superblock for a mounted filesystem to be free'd
without a previous call to unmount the filesystem?"  And you might
want to check the call points for cleancache_invalidate_fs (in each
of the filesystems) to see if there are error conditions which
would skip the call to cleancache_invalidate_fs.

Alternately, if you generate and keep track of a "fake pool id"
and map it (after the backend registers) to a real pool id,
I think there's no risk.  However, I agree your solution is
more elegant so as long as you verify that there is no chance
of data corruption, I am OK with your solution.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
