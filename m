From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: [PATCH] mm: avoid dirtying shared mappings on mlock
Date: Fri, 12 Oct 2007 04:14:10 +1000
References: <11854939641916-git-send-email-ssouhlal@FreeBSD.org> <200710120257.05960.nickpiggin@yahoo.com.au> <1192185439.27435.19.camel@twins>
In-Reply-To: <1192185439.27435.19.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200710120414.11026.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Suleiman Souhlal <ssouhlal@freebsd.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Suleiman Souhlal <suleiman@google.com>, linux-mm <linux-mm@kvack.org>, hugh <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Friday 12 October 2007 20:37, Peter Zijlstra wrote:
> On Fri, 2007-10-12 at 02:57 +1000, Nick Piggin wrote:
> > On Friday 12 October 2007 19:03, Peter Zijlstra wrote:
> > > Subject: mm: avoid dirtying shared mappings on mlock
> > >
> > > Suleiman noticed that shared mappings get dirtied when mlocked.
> > > Avoid this by teaching make_pages_present about this case.
> > >
> > > Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> > > Acked-by: Suleiman Souhlal <suleiman@google.com>
> >
> > Umm, I don't see the other piece of this thread, so I don't
> > know what the actual problem was.
> >
> > But I would really rather not do this. If you do this, then you
> > now can get random SIGBUSes when you write into the memory if it
> > can't allocate blocks or ... (some other filesystem specific
> > condition).
>
> I'm not getting this, make_pages_present() only has to ensure all the
> pages are read from disk and in memory. How is this different from a
> read-scan?

I guess because we've mlocked a region that has PROT_WRITE access...
but actually, I suppose mlock doesn't technically require that we
can write to the memory, only that the page isn't swapped out.

Still, it is nice to be able to have a reasonable guarantee of
writability.


> The pages will still be read-only due to dirty tracking, so the first
> write will still do page_mkwrite().

Which can SIGBUS, no?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
