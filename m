Date: Thu, 11 May 2006 15:52:30 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
In-Reply-To: <20060511080220.48688b40.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0605111546480.16571@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy> <445CA22B.8030807@cyberone.com.au>
 <1146922446.3561.20.camel@lappy> <445CA907.9060002@cyberone.com.au>
 <1146929357.3561.28.camel@lappy> <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
 <1147116034.16600.2.camel@lappy> <Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>
 <1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, piggin@cyberone.com.au, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 May 2006, Andrew Morton wrote:

> > It survives a simple test and shows the dirty pages in /proc/vmstat.
> 
> It'd be nice to have more that a "simple test" done.  Bugs in this area
> will be subtle and will manifest in unpleasant ways.  That goes for both
> correctness and performance bugs.

Standard tests such as AIM7 will not trigger these paths. It is rather
unusual for small unix processes to have a shared writable mapping and 
therefore I doubt that the typical benchmarks may show much of a 
difference. These  types of mappings are more typical for large or 
specialized apps. Be sure that the tests actually do dirty 
pages in shared writeable mappings.

> > +int page_wrprotect(struct page *page)
> > +{
> > +	int ret = 0;
> > +
> > +	BUG_ON(!PageLocked(page));
> 
> hm.  So clear_page_dirty() and clear_page_dirty_for_io() are only ever
> called against a locked page?  I guess that makes sense, but it's not a
> guarantee which we had in the past.  It really _has_ to be true, because
> lock_page() is the only thing which can protect the address_space from
> memory reclaim in those two functions.

If that is true then we can get rid of atomic ops in both functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
