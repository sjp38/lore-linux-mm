Date: Tue, 3 Aug 1999 16:21:32 +0200
From: Andi Kleen <ak@muc.de>
Subject: Re: getrusage
Message-ID: <19990803162132.A3657@fred.muc.de>
References: <199908031402.KAA27172@grappelli.torrent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <199908031402.KAA27172@grappelli.torrent.com>; from dca@torrent.com on Tue, Aug 03, 1999 at 04:02:53PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: dca@torrent.com
Cc: ak@muc.de, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 03, 1999 at 04:02:53PM +0200, dca@torrent.com wrote:
> > How would you count e.g. shared mappings in a single RSS number?
> > I think you need some more fine grained way to report memory use.
> 
> I wrote, then cut out a paragraph from my first mail wondering if
> there was an opportunity to present statistics in a more useful or
> comprehensible way.
> 
> Since the current implementation seems non-functional, there's no
> compatibility to break.  In fact, the trivial "reasonable" change to
> me would seem to be yanking the unset entries from struct rusage.  But
> we should be able to do better than that.
> 
> 
> Here are the relevant entries from struct rusage:
> 
>   long ru_maxrss;     /* maximum resident set size */
>   long ru_ixrss;      /* integral shared memory size */
>   long ru_idrss;      /* integral unshared data size */
>   long ru_isrss;      /* integral unshared stack size */
> 
> 
> I'll presume this covers all interesting types of memory that gets
> mapped into a process's address space.  I'm not sure what the use of
> the integral values are, and they seem more properly the domain of
> vtimes() as on aix and maybe bsd?.  But having access to the current
> raw (unintegrated) values seems more useful to me.  Getting max values
> for each makes sense too.

You need another one: a vm id. Multiple "processes" can share VM 
in linux via clone, and you don't want to account that twice (otherwise
there are funny results like 50MB StarOffice with 10 threads reported as
500MB of memory in gtop). I think it is important to have an unique
identifier to avoid such mistakes.

There is already a patch floating around on l-k that does that,
although it reports via a /proc entry per process. Integrating it in
rusage would be a nice addition. The possible unique ids are memory address
of the kernel mm_struct  (ugly, but zero cost), or the pid of the process
who created the VM first.

> On an implementation note, keeping around max values costs a small bit
> of time whenever a new page is added.  Is this enough to be an issue?

Max limits are useful, and it is usually left in the noise from the
page zeroing anyways.

-Andi

-- 
This is like TV. I don't like TV.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
