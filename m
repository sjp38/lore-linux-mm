Received: from cs.amherst.edu
 ("port 1109"@host-17.subnet-238.amherst.edu [148.85.238.17])
 by amherst.edu (PMDF V6.0-24 #39159)
 with ESMTP id <01JRVCRYHO5G8ZEXAJ@amherst.edu> for linux-mm@kvack.org; Mon,
 17 Jul 2000 10:35:13 -0400 (EDT)
Date: Mon, 17 Jul 2000 10:32:45 -0400
From: "Scott F. Kaplan" <sfkaplan@cs.amherst.edu>
Subject: Re: [PATCH] 2.2.17pre7 VM enhancement Re: I/O performance on
Message-id: <3973190D.94661489@cs.amherst.edu>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii
Content-transfer-encoding: 7bit
References: <Pine.LNX.4.21.0007111503520.10961-100000@duckman.distro.conectiva>
 <200007170709.DAA27512@ocelot.cc.gatech.edu> <20000717102811.D5127@redhat.com>
 <20000717090131.D10936@bp6.sublogic.lan>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[Stephen C. Tweedie]
> > Having said that, LRU is certainly broken, but there are other ways to
> > fix it.
>
> Right.  LFU is just one way of fixing LRU.

I, too, am new to this mailing list, but since this comment was in
reference to the one made by Yannis, and I participated in the research
to which he mentioned, I'll chime in anyhow.

The problem is that LFU *doesn't* really fix LRU.  There are some cases
for which LRU performs as badly as possible.  (Imagine a 100 page memory
and a program that loops over 101 pages.)  In those cases, doing
*anything* that deviates from LRU will be an improvement; it's not much
of an accomplishment if LFU does well in this case, as RANDOM would be
an improvement as well.  Frequency isn't the right metric -- it just
allows for noise so that LFU can possibly do something different from
LRU.

There's lots of evidence that LFU can perform horribly, particularly
when the reference behavior changes (a.k.a. phase changes.)  Frequency
information doesn't reveal this change well, and the system can page
quite badly before the statistics come into line with the new behavior.

When LFU performs well, it's usually because of the skew in how often
recently used pages are re-used; that is, recently used pages *are* used
frequently.  It's when that association stops being true for a given set
of pages that a replacement policy must update its notion of the
program's behavior quickly.  LRU does so as quickly as the program can
touch some new pages.  LFU takes much longer.

LRU does the right thing in most cases.  With a little extra data, a
system can notice when LRU is doing the *wrong* thing, and only then
should non-LRU replacement be used.  At least, that's the basis of the
paper to which Yannis provided a reference.  I'll also throw out of a
reference to my dissertation, which has a more thorough (and, I hope,
better written!) discussion of recency, its uses, and the failings of
frequency information.  So, for anyone interested,
<http://www.cs.amherst.edu/~sfkaplan/papers/sfkaplan-dissertation.ps.gz>.

Scott Kaplan
sfkaplan@cs.amherst.edu
http://www.cs.amherst.edu/~sfkaplan
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
