Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: Fwd: Re: [PATCH][RFC] appling preasure to icache and dcache
Date: Tue, 3 Apr 2001 19:50:04 -0400
References: <Pine.LNX.4.21.0104031832540.14090-100000@imladris.rielhome.conectiva>
In-Reply-To: <Pine.LNX.4.21.0104031832540.14090-100000@imladris.rielhome.conectiva>
MIME-Version: 1.0
Message-Id: <01040319500401.01230@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Ed Tomlinson <tomlins@CAM.ORG>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tuesday 03 April 2001 17:35, Rik van Riel wrote:
> On Tue, 3 Apr 2001, Ed Tomlinson wrote:
> > On Tuesday 03 April 2001 11:03, Benjamin Redelings I wrote:
> > > Hi, I'm glad somebody is working on this!  VM-time seems like a pretty
> > > useful concept.
> >
> > Think it might be useful for detecting trashing too.  If vmtime is
> > made to directly relate to the page allocation rate then you can do
> > something like this.  Let K be a number intially representing 25% of
> > ram pages. Because vmtime is directly releated to allocation rates its
> > meanful to subtract K from the current vmtime.  For each swapped out
> > page, record the current vmtime.  Now if the recorded vmtime of the
> > page you are swapping in is greater than vmtime-K increment A
> > otherwise increment B. If A>B we are thrashing.  We decay A and B via
> > kswapd.  We adjust K depending on the swapping rate.  Thoughts?
>
> Hmmm, how exactly would this algorithm work ?
>
> From your description above, I can't quite see how it would
> work (or why it would work).

First remember the vmtime increments when ever we allocate a page.  Second we
record the vmtime for each page as its swapped out.  If we are thrashing we are 
cycling through sets of pages.  The swap out vmtime of most (if not all) of these
pages will be greater than some K.  So what I see the above doing is telling us
we are swaping in stuff we reciently swapped out.  If we are swapping normally
this should not be a normal distribution.  Another way to look at this would
be to find a value of K such that |A-B| is small.  If K is small and the swap
rate is high we are thrashing.  What is trashing is another question...

I am not sure this would catch _all_ cases but bet it would get a large percentage
of them.

Ed  
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
