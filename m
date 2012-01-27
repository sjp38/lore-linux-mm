Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id ACF756B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 08:43:10 -0500 (EST)
Message-ID: <1327671787.2977.17.camel@dabdike.int.hansenpartnership.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 27 Jan 2012 07:43:07 -0600
In-Reply-To: <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
	 <4F218D36.2060308@linux.vnet.ibm.com>
	 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
	 <20120126163150.31a8688f.akpm@linux-foundation.org>
	 <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
	 <20120126171548.2c85dd44.akpm@linux-foundation.org>
	 <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>, lsf-pc@lists.linux-foundation.org

On Thu, 2012-01-26 at 18:43 -0800, Dan Magenheimer wrote:
> > From: Andrew Morton [mailto:akpm@linux-foundation.org]
> > It really didn't tell us anything, apart from referring to vague
> > "problems on streaming workloads", which forces everyone to go off and
> > do an hour or two's kernel archeology, probably in the area of
> > readahead.
> > 
> > Just describe the problem!  Why is it slow?  Where's the time being
> > spent?  How does the proposed fix (which we haven't actually seen)
> > address the problem?  If you inform us of these things then perhaps
> > someone will have a useful suggestion.  And as a side-effect, we'll
> > understand cleancache better.
> 
> Sorry, I'm often told that my explanations are long-winded so
> as a result I sometimes err on the side of brevity...
> 
> The problem is that if a pageframe is used for a page that is
> very unlikely (or never going) to be used again instead of for
> a page that IS likely to be used again, it results in more
> refaults (which means more I/O which means poorer performance).
> So we want to keep pages that are most likely to be used again.
> And pages that were active are more likely to be used again than
> pages that were never active... at least the post-2.6.27 kernel
> makes that assumption.  A cleancache backend can keep or discard
> any page it pleases... it makes sense for it to keep pages
> that were previously active rather than pages that were never
> active.
> 
> For zcache, we can store twice as many pages per pageframe.
> But if we are storing two pages that are very unlikely
> (or never going) to be used again instead of one page
> that IS likely to be used again, that's probably still a bad choice.
> Further, for every page that never gets used again (or gets reclaimed
> before it can be used again because there's so much data streaming
> through cleancache), zcache wastes the cpu cost of a page compression.
> On newer machines, compression is suitably fast that this additional
> cpu cost is small-ish.  On older machines, it adds up fast and that's
> what Nebojsa was seeing in https://lkml.org/lkml/2011/8/17/351 
> 
> Page replacement algorithms are all about heuristics and
> heuristics require information.  The WasActive flag provides
> information that has proven useful to the kernel (as proven
> by the 2.6.27 page replacement design rewrite) to cleancache
> backends (such as zcache).

So this sounds very similar to the recent discussion which I cc'd to
this list about readahead:

http://marc.info/?l=linux-scsi&m=132750980203130

It sounds like we want to measure something similar (whether a page has
been touched since it was brought in).  It isn't exactly your WasActive
flag because we want to know after we bring a page in for readahead was
it ever actually used, but it's very similar.

What I was wondering was instead of using a flag, could we make the LRU
lists do this for us ... something like have a special LRU list for
pages added to the page cache but never referenced since added?  It
sounds like you can get your WasActive information from the same type of
LRU list tricks (assuming we can do them).

I think the memory pressure eviction heuristic is: referenced but not
recently used pages first followed by unreferenced and not recently used
readahead pages.  The key being to keep recently read in readahead pages
until last because there's a time between doing readahead and getting
the page accessed and we don't want to trash a recently red in readahead
page only to have the process touch it and find it has to be read in
again.

James



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
