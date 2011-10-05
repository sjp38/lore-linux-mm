Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F9346B0072
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 15:43:33 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <cc1256f9-4808-4d74-a321-6a3ec129cc05@default>
Date: Wed, 5 Oct 2011 12:43:23 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [Xen-devel] Re: RFC -- new zone type
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default
 20111005165643.GE7007@labbmf-linux.qualcomm.com>
In-Reply-To: <20111005165643.GE7007@labbmf-linux.qualcomm.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: linux-mm@kvack.org, Xen-devel@lists.xensource.com

> > You may be interested in the concept of "ephemeral pages"
> > introduced by transcendent memory ("tmem") and the cleancache
> > patchset which went upstream at 3.0.  If you write a driver
> > (called a "backend" in tmem language) that accepts pages
> > from cleancache, you would be able to use your 100MB contiguous
> > chunk of memory for clean pagecache pages when it is not needed
> > for your other purposes, easily discard all the pages when
> > you do need the space, then start using it for clean pagecache
> > pages again when you don't need it for your purposes anymore
> > (and repeat this cycle as many times as necessary).
> >
> > You maybe could call your driver "cleanzone".
> >
> > Zcache (also upstream in drivers/staging) does something like
> > this already, though you might not want/need to use compression
> > in your driver.  In zcache, space reclaim is driven by the kernel
> > "shrinker" code that runs when memory is low, but another trigger
> > could easily be used.  Also there is likely a lot of code in
> > zcache (e.g. tmem.c) that you could leverage.
> >
> > For more info, see:
> > http://lwn.net/Articles/454795/
> > http://oss.oracle.com/projects/tmem
> >
> > I'd be happy to answer any questions if you are still interested
> > after you have read the above documentation.
>=20
> It appears that ephemeral tmem ("cleancache") is at least
> close to meeting our needs.

Yes, I thought so also,

> We won't need to
> have virtualization or compression.

Right.  Those just demonstrate different interesting uses
of tmem/cleancache.

> I do have some questions (I've read the references
> you included in your email to me last week and a few
> of the links from the "project transcendent memory" one, but have
> not looked at any of the source yet):
>=20
> 1. Is it currently possible to specify the size of tmem
> (as for us it must be convertable into a large contiguous physical
> block of specified size)? Is is currently possible to specify
> the start of tmem? Are there any alignment constraints on
> the start or size?

Your "cleanzone" driver would have complete control over
this so there would be no constraints unless you (or
generic kernel code) choose to enforce them.

> 2. How does one "turn on" and "turn off" tmem (the memory
> which tmem uses may also be needed for the large contiguous
> memory block, or perhaps may be powered off entirely)?
> Is it simply that one always answers "no" for both
> get and put requests when it is "off"?

That's right.  However, you must ensure that stale data
isn't get'able after you've turned if off and then on again.
I don't think you'll need to do that... I think you
will be assuming all of the cleancache data is gone
(not preserved).

> 3. How portable is the tmem code? This needs to run
> on an ARM system.

I don't think there is any reason it wouldn't be portable.
If you are running on a system with a 32-bit pointer
but >4GB memory (e.g. "highmem"), that might add some
complexity, but I think those problems have now been
solved in zcache so should be solveable for cleanzone
also.

> 4. Apparently hooks are needed in the filesystem code --
> which filesystems are currently supported to be used with
> tmem? Is it difficult to add hooks for filesystems
> that aren't yet supported?

The hooks are currently in ext3, ext4, btrfs, and ocfs2.
If the filesystem is "well behaved" the support is easy
to add.

> 5. There are no dependencies on memory compaction
> or memory hotplug (or sparsemem), correct?

No dependencies.

Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
