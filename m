Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 9C92D6B003D
	for <linux-mm@kvack.org>; Sat, 14 Mar 2009 20:57:26 -0400 (EDT)
From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [Bug 12556] pgoff_t type not wide enough (32-bit with LFS and/or LBD)
Date: Sun, 15 Mar 2009 11:57:12 +1100
References: <bug-12556-27@http.bugzilla.kernel.org/> <20090313125909.99637b18.akpm@linux-foundation.org> <alpine.WNT.1.10.0903131524490.1936@cluij.ucs.ualberta.ca>
In-Reply-To: <alpine.WNT.1.10.0903131524490.1936@cluij.ucs.ualberta.ca>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200903151157.12906.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
To: Marc Aurele La France <tsi@ualberta.ca>
Cc: Andrew Morton <akpm@linux-foundation.org>, bugme-daemon@bugzilla.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sunday 15 March 2009 04:08:37 Marc Aurele La France wrote:
> On Fri, 13 Mar 2009, Andrew Morton wrote:
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
>
> OK.  Thanks for responding.
>
> > We never had any serious intention of implementing 64-bit pagecache
> > indexes on 32-bit architectures.  I added pgoff_t mainly for code
> > clarity reasons (it was getting nutty in there), with a vague
> > expectation that we would need to use a 64-bit type one day.
> >
> > And, yes, the need to be able to manipulate block devices via the
> > pagecache does mean that this day is upon us.
>
> I'm somewhat surprised this didn't come up back in 2.6.20, when LBD and LSF
> were first introduced.

They increased the width of the type that stores sectors, so needed
for > 2TB. pagecache index was enough for several more doublings
after that.


> > A full implementation is quite problematic.  Such a change affects each
> > filesystem, many of which are old and crufty and which nobody
> > maintains.  The cost of bugs in there (and there will be bugs) is
> > corrupted data in rare cases for few people, which is bad.
> >
> > Perhaps what we should do is to add a per-filesystem flag which says
> > "this fs is OK with 64-bit page indexes", and turn that on within each
> > filesystem as we convert and test them.  Add checks to the VFS to
> > prevent people from extending files to more than 16TB on unverified
> > filesystems.  Hopefully all of this infrastructure is already in place
> > via super_block.s_maxbytes, and we can just forget about >16TB _files_.
> >
> > And fix up the core VFS if there are any problems, and get pagecache IO
> > reviewed, tested and working for the blockdev address_spaces.
> >
> > I expect it's all pretty simple, actually.  Mainly a matter of doing a
> > few hours code review to clean up those places where we accidentally
> > copy a pgoff_t to or from a long type.
> >
> > The fact that the kernel apparently already works correctly when one
> > simply makes pgoff_t a u64 is surprising and encouraging and unexpected. 
> > I bet it doesn't work 100% properly!
>
> True enough.  The kernel is rife with nooks and cranies.  So I can't
> vouch for all of them.  But, this has already undergone some stress.  For a
> period of three weeks, I had this in production on a cluster's NFS server
> that also does backups and GFS2.  Even before then, periods of load
> averages of 50 or more and heavy paging were not unusual.  It was, in part,
> to address that load that this system has since been replaced with more
> capable and, unfortunately for this bug report, 64-bit hardware.
>
> I also don't share your "doom and gloom" assessment.  First, unless a
> filesystem is stupid enough to store a pgoff_t on disc (a definite bug
> candidate), it doesn't really matter what the kernel's internal
> representation of one is, as long as it is wide enough.  Secondly, this is
> an unsigned quantity, so, barring compiler bugs, sign-extension issues
> cannot occur.
>
> Third, the vast majority of filesystems in the wild are less than 16TB in
> size.  This whether or not the filesystem type used can handle more.  Here,
> all pgoff_t values fit in 32 bits and are therefore immune to any, even
> random, zero-extensions to 64 bits and truncations back to 32 bits that
> might internally occur.  A similar argument can be made for the bulk of
> block devices out there that are also no larger than 16TB.
>
> This leaves us with the rare >16TB situations.  But, wait.  Isn't that the
> bug we're talking about?  Of these, I can tell you that a 23TB GFS2
> filesystem is much more stable with this change than it is without.  And,
> on a 32-bit system, a swap device that large can't be fully used anyway.
>
> There's also the fact that, as things stand now, a pgoff_t's size doesn't
> affect interoperability among 32-bit and 64-bit systems.

I don't know how this could possibly be working correctly considering
that the radix tree that is the basic store of pagecache pages uses
keys typed unsigned long. And that was just the first place I looked
at.


> All in all, I think you're selling yourself short WRT the correctness of
> your introduction of pgoff_t.

The assessment is more like realism than doom and gloom. pgoff_t is
the right way to fix this, but right now the 32-bit kernel is obviously
not going to work with > 32-bit index, and yes I agree with Andrew it
does need some kind of audit of each filesystem before we can tell
users it is supported. Maybe sparse could help with that...?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
