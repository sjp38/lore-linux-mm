Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 20AF96B004F
	for <linux-mm@kvack.org>; Fri, 27 Jan 2012 16:49:16 -0500 (EST)
Message-ID: <1327700951.2977.78.camel@dabdike.int.hansenpartnership.com>
Subject: RE: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Fri, 27 Jan 2012 15:49:11 -0600
In-Reply-To: <9813c0cd-0335-4994-b734-e9fc7872c0cb@default>
References: <ea3b0850-dfe0-46db-9201-2bfef110848d@default>
	 <4F218D36.2060308@linux.vnet.ibm.com>
	 <9fcd06f5-360e-4542-9fbb-f8c7efb28cb6@default>
	 <20120126163150.31a8688f.akpm@linux-foundation.org>
	 <ccb76a4d-d453-4faa-93a9-d1ce015255c0@default>
	 <20120126171548.2c85dd44.akpm@linux-foundation.org>
	 <7198bfb3-1e32-40d3-8601-d88aed7aabd8@default>
	 <1327671787.2977.17.camel@dabdike.int.hansenpartnership.com>
	 <3ac611ee-8830-41bd-8464-6867da701948@default>
	 <1327686876.2977.37.camel@dabdike.int.hansenpartnership.com>
	 <9813c0cd-0335-4994-b734-e9fc7872c0cb@default>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, riel@redhat.com, Chris Mason <chris.mason@oracle.com>, lsf-pc@lists.linux-foundation.org

On Fri, 2012-01-27 at 10:46 -0800, Dan Magenheimer wrote:
> > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > Subject: RE: [PATCH] mm: implement WasActive page flag (for improving cleancache)
> > 
> > On Fri, 2012-01-27 at 09:32 -0800, Dan Magenheimer wrote:
> > > > From: James Bottomley [mailto:James.Bottomley@HansenPartnership.com]
> > > > What I was wondering was instead of using a flag, could we make the LRU
> > > > lists do this for us ... something like have a special LRU list for
> > > > pages added to the page cache but never referenced since added?  It
> > > > sounds like you can get your WasActive information from the same type of
> > > > LRU list tricks (assuming we can do them).
> > >
> > > Hmmm... I think this would mean more LRU queues but that may be
> > > the right long term answer.  Something like?
> > >
> > > 	read but not used yet LRU
> > > 	readahead but not used yet LRU
> > 
> > What's the difference between these two?  I think read but not used is
> > some form of readahead regardless of where it came from.
> 
> Oops, I meant "read but used only once (to resolve a page fault)" LRU.
> 
> > > 	active LRU
> > > 	previously active LRU
> > 
> > I don't quite understand why you need two queues here, either.  Surely
> > active is logically at the bottom of the LRU and previously active at
> > the top (assuming we've separated the unused pages to a different LRU
> > list).
> 
> Cleancache only sees pages when they "fall off the end of the world",
> so would like to differentiate between clean pages that were used just
> once and pages that were used more than once, but not recently.
> There may be better heuristics for cleancache too.
>  
> > > Naturally, this then complicates the eviction selection process.
> > >
> > > > I think the memory pressure eviction heuristic is: referenced but not
> > > > recently used pages first followed by unreferenced and not recently used
> > > > readahead pages.  The key being to keep recently read in readahead pages
> > > > until last because there's a time between doing readahead and getting
> > > > the page accessed and we don't want to trash a recently red in readahead
> > > > page only to have the process touch it and find it has to be read in
> > > > again.
> > >
> > > I suspect that any further progress on the page replacement heuristics
> > > is going to require more per-page data to be stored.  Which means
> > > that it probably won't work under the constraints of 32-bit systems.
> > > So it might also make sense to revisit when/whether to allow the
> > > heuristics to be better on a 64-bit system than on a 32-bit.
> > > (Even ARM now has 64-bit processors!)  I put this on my topic list
> > > for LSF/MM, though I have no history of previous discussion so
> > > this may already have previously been decided.
> > 
> > I've got to say why? on this.  The object is to find a simple solution
> > that's good enough.  I think separating the LRU list into two based on
> > once referenced/never referenced might be enough to derive all the
> > information we need.
> 
> Maybe I'm misunderstanding (in which case a complete list of the LRU
> queues you are proposing would be good), but doesn't the existing design
> already do this?  Actually, IIUC the existing file cache design has a
> 	"referenced more than once" LRU ("active")

So here, I was just saying your desire to store more data in the page
table and expand the page flags looks complex.

Perhaps we do have a fundamental misunderstanding:  For readahead, I
don't really care about the referenced part.  referenced just means
pointed to by one or more vmas and active means pointed to by two or
more vmas (unless executable in which case it's one).

What I think we care about for readahead is accessed.  This means a page
that got touched regardless of how many references it has.  An
unaccessed unaged RA page is a less good candidate for reclaim because
it should soon be accessed (under the RA heuristics) than an accessed RA
page.  Obviously if the heuristics misfire, we end up with futile RA
pages, which we read in expecting to be accessed, but which in fact
never were (so an unaccessed aged RA page) and need to be evicted.

But for me, perhaps it's enough to put unaccessed RA pages into the
active list on instantiation and then actually put them in the inactive
list when they're accessed (following the usual active rules, so they
become inactive if they only have a single reference, but remain active
if they have two or more).

I'm less clear on why you think a WasActive() flag is needed.  I think
you mean a member of the inactive list that was at some point previously
active.

Perhaps now I've said all this, it's less clear what readahead wants and
what you want with your flag are similar.

> and a second ("inactive") LRU queue which combines
> 	"referenced only once" OR
> 	"readahead and never referenced" OR
> 	"referenced more than once but not referenced recently"
> Are you proposing to add more queues or define the existing two queues
> differently?

Actually, I think I'm just proposing different insertion criteria.

Incidentally, we don't have two LRU lists, we have five:  we have a four
way split between active/inactive and anon/file backed and then we have
the unreclaimable lru list.

Obviously, for readahead I'm ignoring all the anon and unreclaimable
lists.

> So my strawman list of LRU queues separates the three ORs in the inactive
> LRU queue to three separate LRU queues, for a total of four.
> 
>  INACTIVE-typeA) read but used only once to resolve a page fault LRU
>  INACTIVE-typeB) readahead but not used yet LRU
>  INACTIVE-typeC) previously active LRU
>  ACTIVE) active LRU

Um, that's complex.  Doesn't your inactive-C list really just identify
pages that were shared but have sunk in the LRU lists due to lack of
use?  Inactive-A would appear to identify either streaming pages, or
single application data pages.  Like I said, I think Inactive-B is easy
to work around just by putting RA pages into the active list and letting
the current algorithms run their course.

If that's what you really want, isn't the simplest thing to do to add a
PAGECACHE_TAG_ACTIVE in the page cache radix tree?  We're only using
three of the radix tag bits, so we're not as pressed for them as we are
for actual page bits.  You set it at the same time you activate the page
(mostly, you probably don't want to set it for RA pages).  Then it
remains in the radix tree even if the page sinks to the inactive list.

> > Until that theory is disproved, there's not much
> > benefit to developing ever more complex heuristics.
> 
> I think we are both "disproving" the theory that the existing
> two LRU queues are sufficient.

What I meant was begin with a theory that something simple works first
and then disprove it before moving on to something more complex ...
rather than start out with complex first.

James

>   You need to differentiate between
> typeA and typeB (to ensure typeB doesn't get evicted too quickly)
> and I would like to differentiate typeC from typeA/typeB to have
> heuristic data for cleancache at the time the kernel evicts the page.
> 
> Does that make sense?
> 
> P.S. I'm interpreting from http://linux-mm.org/PageReplacementDesign 
> rather from full understanding of the current code, so please correct
> me if I got it wrong.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
