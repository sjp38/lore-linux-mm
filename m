From: dca@torrent.com
Date: Tue, 3 Aug 1999 10:02:53 -0400
Message-Id: <199908031402.KAA27172@grappelli.torrent.com>
Subject: Re: getrusage
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@muc.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> How would you count e.g. shared mappings in a single RSS number?
> I think you need some more fine grained way to report memory use.

I wrote, then cut out a paragraph from my first mail wondering if
there was an opportunity to present statistics in a more useful or
comprehensible way.

Since the current implementation seems non-functional, there's no
compatibility to break.  In fact, the trivial "reasonable" change to
me would seem to be yanking the unset entries from struct rusage.  But
we should be able to do better than that.


Here are the relevant entries from struct rusage:

  long ru_maxrss;     /* maximum resident set size */
  long ru_ixrss;      /* integral shared memory size */
  long ru_idrss;      /* integral unshared data size */
  long ru_isrss;      /* integral unshared stack size */


I'll presume this covers all interesting types of memory that gets
mapped into a process's address space.  I'm not sure what the use of
the integral values are, and they seem more properly the domain of
vtimes() as on aix and maybe bsd?.  But having access to the current
raw (unintegrated) values seems more useful to me.  Getting max values
for each makes sense too.

Then there's the question of vm statistics (rather than rss) and then
faults charged to each class.  But that feels like a slippery slope,
unless someone has a clean demarcation line.

On an implementation note, keeping around max values costs a small bit
of time whenever a new page is added.  Is this enough to be an issue?

-dca
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
