Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: Fwd: Re: [PATCH][RFC] appling preasure to icache and dcache
Date: Thu, 5 Apr 2001 07:35:08 -0400
References: <Pine.LNX.4.21.0104040825100.803-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.21.0104040825100.803-100000@localhost.localdomain>
MIME-Version: 1.0
Message-Id: <01040507350800.00699@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: sfkaplan@cs.amherst.edu, Ed Tomlinson <tomlins@CAM.ORG>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 04 April 2001 08:40, sfkaplan@cs.amherst.edu wrote:
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>
> Hi.  Just a few thoughts that I hope will be useful.
>
> On Tue, 3 Apr 2001, Ed Tomlinson wrote:
> > On Tuesday 03 April 2001 17:35, Rik van Riel wrote:
> > > On Tue, 3 Apr 2001, Ed Tomlinson wrote:
> > > > On Tuesday 03 April 2001 11:03, Benjamin Redelings I wrote:
> > > > > Hi, I'm glad somebody is working on this!  VM-time seems like a
> > > > > pretty useful concept.
>
> The notion of VM time has been kicking around for about 10 years.  I
> picked it up from my graduate advisor, and so it has worked its way
> into a number of research ideas.  This approach to measuring VM time
> is an interesting one, and slightly different from the way in which
> I've approached it.

I am aware that vmtime has been around for a while - just not implemented
in linux.

> > > > Think it might be useful for detecting trashing too.  If vmtime is
> > > > made to directly relate to the page allocation rate then you can do
> > > > something like this.  Let K be a number intially representing 25% of
> > > > ram pages. Because vmtime is directly releated to allocation rates
> > > > its meanful to subtract K from the current vmtime.  For each swapped
> > > > out page, record the current vmtime.  Now if the recorded vmtime of
> > > > the page you are swapping in is greater than vmtime-K increment A
> > > > otherwise increment B. If A>B we are thrashing.  We decay A and B via
> > > > kswapd.  We adjust K depending on the swapping rate.  Thoughts?
>
> A couple of thoughts:
>
> 1) Nit-pick:  You mean "thrashing", not "trashing", right?  Or is
>    there a definition of "trashing" with which I'm not familiar?

Right - spelling is _not_ my forte.

> 2) There's a difference between detecting that the VM system is
>    evicting pages and then using them shortly thereafter, and
>    detecting thrashing.  Your description above may detect the former
>    case -- It's something that AIX did many years ago (or so I'm told
>    by some IBM researchers), and it's a simplified case of what EELRU,
>    an algorithm I was part of developing, detects.  It's a useful
>    case, because it likely indicates a loop-like reference pattern
>    over slightly more memory than is available, forcing LRU to
>    degenerate into FIFO.
>
>    However, it is not necessarily detecting thrashing.  "Heavy paging"
>    and "thrashing" aren't necessarily the same thing.  Thrashing
>    occurs when so much time is spent servicing page faults that the
>    CPU rarely has any work to do (i.e. no ready processes to run.)  It
>    is easily possible to thrash without tripping the detection
>    mechanism that you're describing.

I am very aware that heavy paging, which is ok _if_ you have the bandwidth, 
and thrashing are different.

> 3) Your detection mechanism seems as though it would detect something
>    interesting.  However, I don't understand the response that you
>    describe.  Decaying A and B seems fine, and an important part of
>    accurate detection based on recent behavior.  However, why adjust
>    K?  That doesn't seem to solve the problem.  The process may still
>    continue to reference pages evicted not long ago.  Addressing
>    this case reqires either a larger memory allocation (somehow or
>    other) or a modification of the replacement policy (some non-LRU
>    evictions).  If you adjust K to be smaller, than you're just less
>    likely to trip the detection mechanism.  If you make K larger, it
>    becomes more likely.  You'll still have the same problem.

Wonder what gets detected if you adjust K such that abs(A-B) is small?
if K is near the current vmtime you have a case where EELRU might help.
as K approaches vmtime+physical pages you have thrashing?  Think that,
with some work, these sorts of metrics could be effective in detecting
many cases of thrashing.

> I hope these comments help.  More likely than not, I've misunderstood
> what you're proposing.  If so, please let me know what I've botched.

Comments like these always help (even the spelling <grin>).  

Thanks

Ed Tomlinson <tomlins@cam.org>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
