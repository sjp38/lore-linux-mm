Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id E154B6B005C
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 12:54:39 -0500 (EST)
Message-ID: <1327686876.2977.37.camel@dabdike.int.hansenpartnership.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 27 Jan 2012 11:54:36 -0600
In-Reply-To: <3ac611ee-8830-41bd-8464-6867da701948@default>
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
	 <4F218D36.2060308@linux.vnet.ibm.com>
	 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
	 <20120126163150.31a8688f.akpm@linux-foundation.org>
	 <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
	 <20120126171548.2c85dd44.akpm@linux-foundation.org>
	 <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
	 <1327671787.2977.17.camel@dabdike.int.hansenpartnership.com>
	 <3ac611ee-8830-41bd-8464-6867da701948@default>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>, lsf-pc@lists.linux-foundation.org

On Fri, 2012-01-27 at 09:32 -0800, Dan Magenheimer wrote:
> > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > What I was wondering was instead of using a flag, could we make the LRU
> > lists do this for us ... something like have a special LRU list for
> > pages added to the page cache but never referenced since added?  It
> > sounds like you can get your WasActive information from the same type of
> > LRU list tricks (assuming we can do them).
> 
> Hmmm... I think this would mean more LRU queues but that may be
> the right long term answer.  Something like?
> 
> 	read but not used yet LRU
> 	readahead but not used yet LRU

What's the difference between these two?  I think read but not used is
some form of readahead regardless of where it came from.

> 	active LRU
> 	previously active LRU

I don't quite understand why you need two queues here, either.  Surely
active is logically at the bottom of the LRU and previously active at
the top (assuming we've separated the unused pages to a different LRU
list).

> Naturally, this then complicates the eviction selection process.
> 
> > I think the memory pressure eviction heuristic is: referenced but not
> > recently used pages first followed by unreferenced and not recently used
> > readahead pages.  The key being to keep recently read in readahead pages
> > until last because there's a time between doing readahead and getting
> > the page accessed and we don't want to trash a recently red in readahead
> > page only to have the process touch it and find it has to be read in
> > again.
> 
> I suspect that any further progress on the page replacement heuristics
> is going to require more per-page data to be stored.  Which means
> that it probably won't work under the constraints of 32-bit systems.
> So it might also make sense to revisit when/whether to allow the
> heuristics to be better on a 64-bit system than on a 32-bit.
> (Even ARM now has 64-bit processors!)  I put this on my topic list
> for LSF/MM, though I have no history of previous discussion so
> this may already have previously been decided.

I've got to say why? on this.  The object is to find a simple solution
that's good enough.  I think separating the LRU list into two based on
once referenced/never referenced might be enough to derive all the
information we need.  Until that theory is disproved, there's not much
benefit to developing ever more complex heuristics.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
