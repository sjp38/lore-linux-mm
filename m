Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4D6896B0071
	for <linux-mm@kvack.org>; Tue, 22 Jun 2010 12:21:23 -0400 (EDT)
MIME-Version: 1.0
Message-ID: <6fae6075-c6ed-4df4-af7b-44fb3ed1bae1@default>
Date: Tue, 22 Jun 2010 09:20:07 -0700 (PDT)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: RE: [PATCH V3 3/8] Cleancache: core ops functions and configuration
References: <20100621231939.GA19505@ca-server1.us.oracle.com
 20100622144320.GA13324@infradead.org>
In-Reply-To: <20100622144320.GA13324@infradead.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Chris Mason <chris.mason@oracle.com>, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, adilger@sun.com, tytso@mit.edu, mfasheh@suse.com, Joel Becker <joel.becker@oracle.com>, matthew@wil.cx, linux-btrfs@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org, ocfs2-devel@oss.oracle.com, linux-mm@kvack.org, ngupta@vflare.org, jeremy@goop.org, JBeulich@novell.com, Kurt Hackel <kurt.hackel@oracle.com>, npiggin@suse.de, Dave Mccracken <dave.mccracken@oracle.com>, riel@redhat.com, avi@redhat.com, Konrad Wilk <konrad.wilk@oracle.com>
List-ID: <linux-mm.kvack.org>

Hi Christoph --

Thanks for the comments... replying to both in one reply.

> Subject: Re: [PATCH V3 0/8] Cleancache: overview
>=20
> What all this fails to explain is that this actually is useful for?

See FAQ #1 in patch 1/8 (and repeated in patch 0/8).

But, in a few words, it's useful for maintaining a cache
of clean pages (for which the kernel has insufficient RAM)
in "other" RAM that's not directly accessible or addressable
by the kernel (such as hypervisor-owned RAM or kernel-owned
RAM that is secretly compressed).  Like the kernel's page
cache, use of cleancache avoids lots of disk reads ("refaults").
And when kernel RAM is scarce but "other" RAM is plentiful,
it avoids LOTS and LOTS of disk reads/refaults.

> Subject: Re: [PATCH V3 3/8] Cleancache: core ops functions and
> configuration
>=20
> On Mon, Jun 21, 2010 at 04:19:39PM -0700, Dan Magenheimer wrote:
> > [PATCH V3 3/8] Cleancache: core ops functions and configuration
> >
> > Cleancache core ops functions and configuration
>
> NACK for code that just adds random hooks all over VFS and even
> individual FS code, does an EXPORT_SYMBOL but doesn't actually
> introduce any users.

There's a bit of a chicken and egg here.  Since cleancache
touches code owned by a number of maintainers, it made sense to
get that code reviewed first and respond to the feedback of those
maintainers.  So if this is the only remaining objection, we
will proceed next with introducing users.  See below for
a brief description.

> And even if it had users these would have to be damn good ones given
> how invasive it is.

I need to quibble with your definition of "invasive".  The patch
adds 43 lines of code (not counting comments and blank lines)
in VFS/filesystem code.  These lines have basically stayed the
same since 2.6.18 so the hooks are clearly not in code that
is rapidly changing... so maintenance should not be an issue.
The patch covers four filesystems and implements an interface
that provides both reading/writing to an "external" cache AND
coherency with that cache.

And all of these lines of code either compile into nothingness
when CONFIG_CLEANCACHE is off, or become compare function-pointer-
to-NULL if no user ("backend") claims the ops function.

I consider that very very NON-invasive.  (And should credit
Chris Mason for the hook placement and Jeremy Fitzhardinge
for the clean layering.)

> So what exactly is this going to help us?  Given your
> affiliation probably something Xen related, so some real use case would
> be interesting as well instead of just making Xen suck slightly less.

As I was typing this reply, I saw Nitin's reply talking
about zcache.  That's the non-Xen-related "real" use case...
it may even help KVM suck slightly less ;-)

Making-Xen-suck-slightly-less is another user... Transcendent
Memory ("tmem") has been in Xen for over a year now and distros
are already shipping an earlier version of cleancache that works
with Xen tmem.  Some shim code is required between cleancache and
Xen tmem, and this shim will live in the drivers/xen directory.
Excellent performance results for this "user" have been presented
at OLS'09 and LCA'10.

And the patch provides a very generic clean interface that
will likely be useful for future TBD forms of "other RAM".
While I honestly believe these additional users will eventually
appear, the first two users (zcache and Xen tmem) should be
sufficient to resolve your NACK.

Thanks,
Dan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
