Date: Sun, 22 Sep 2002 01:49:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: overcommit stuff
In-Reply-To: <3D8D066F.1B45E3EA@digeo.com>
Message-ID: <Pine.LNX.4.44.0209220129310.2339-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 21 Sep 2002, Andrew Morton wrote:
> Hugh Dickins wrote:
> > On Sat, 21 Sep 2002, Andrew Morton wrote:
> > >
> > > running 10,000 tiobench threads I'm showing 23 gigs of
> > > `Commited_AS'.  Is this right?  Those pages are shared,
> > > and if they're not PROT_WRITEable then there's no way in
> > > which they can become unshared?   Seems to be excessively
> > > pessimistic?
>  
> > Committed_AS certainly errs on the pessimistic side, that's
> > what it's about.  How much swap do you have i.e. is 23GB
> > committed impossible, or just surprising to you?  Does the
> > number go back to what it started off from when you kill
> > off the tests?  How are "those pages" allocated e.g. what
> > mmap args?
> 
> I have 7G physical, 4G swap.

When I wondered if impossible, of course I was overlooking
that you wouldn't be running with strict commit limitation,
so "impossible" is quite difficult to reach.

> "those pages" were just used by some scruffy perl script 
> running `./tiotest &' ten thousand times.  I assume it's
> shared executable text.

When I run tiotest here, /proc/<pid>/maps shows a little over
2MB of rwxp or rw-p areas, all to be counted in Committed_AS.
So 23GB for 10,000 of them sounds reasonable.  You think you
have less PROT_WRITE or less MAP_PRIVATE than I'm seeing?

> It seems very unlikely (impossible?) that those pages will
> ever become unshared.

I expect it's very unlikely (short of application bugs) that
those pages would become unshared; but they have been mapped
in such a way that the process is entitled to unshare them,
therefore they have been counted.  A good example of why
Linux does not impose strict commit accounting, and why
you may choose not to use Alan's strict accounting policy.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
