Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 650666B0068
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 17:25:25 -0500 (EST)
Message-ID: <1327875921.21193.11.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [PATCH] mm: implement WasActive page flag (for improving
 cleancache)
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Sun, 29 Jan 2012 16:25:21 -0600
In-Reply-To: <4F2497DC.2040405@redhat.com>
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
	 <1327700951.2977.78.camel@dabdike.int.hansenpartnership.com>
	 <4F2497DC.2040405@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Nebojsa Trpkovic <trx.lists@gmail.com>, minchan@kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Mason <chris.mason@oracle.com>, lsf-pc@lists.linux-foundation.org

On Sat, 2012-01-28 at 19:50 -0500, Rik van Riel wrote:
> On 01/27/2012 04:49 PM, James Bottomley wrote:
> 
> > So here, I was just saying your desire to store more data in the page
> > table and expand the page flags looks complex.
> >
> > Perhaps we do have a fundamental misunderstanding:  For readahead, I
> > don't really care about the referenced part.  referenced just means
> > pointed to by one or more vmas and active means pointed to by two or
> > more vmas (unless executable in which case it's one).
> 
> That is not at all what "referenced" means everywhere
> else in the VM.

I'm aware there's more subtlety, but I think it's a reasonable
generality: your one sentence summary of page_referenced() seems
conspicuously absent; care to provide it ... or would you prefer the VM
internals remain inaccessible to mere mortals? 

> If you write theories on what Dan should use, it would
> help if you limited yourself to stuff the VM provides
> and/or could provide :)

I didn't give any theories at all about what he should or shouldn't do.
I'm trying to think out loud about whether what he wants and what I
think would help readahead are the same thing (I started of thinking
they were and I talked myself out of it by the end of the previous
email).

> > What I think we care about for readahead is accessed.  This means a page
> > that got touched regardless of how many references it has.  An
> > unaccessed unaged RA page is a less good candidate for reclaim because
> > it should soon be accessed (under the RA heuristics) than an accessed RA
> > page.  Obviously if the heuristics misfire, we end up with futile RA
> > pages, which we read in expecting to be accessed, but which in fact
> > never were (so an unaccessed aged RA page) and need to be evicted.
> >
> > But for me, perhaps it's enough to put unaccessed RA pages into the
> > active list on instantiation and then actually put them in the inactive
> > list when they're accessed
> 
> That is an absolutely terrible idea for many obvious reasons.
> 
> Having readahead pages displace the working set wholesale
> is the absolute last thing we want.

Um, only if you assume you place them at the most recently used head of
the active list ... for obvious reasons, that's not what I was thinking.
I'm still not sure it's more feasible than having separate lists, though
since most recently used tail is  nasty because it's reverse ordering
them and probably not providing sufficient boost and middle insertion
looks just plain wrong.

> > I'm less clear on why you think a WasActive() flag is needed.  I think
> > you mean a member of the inactive list that was at some point previously
> > active.
> 
> > Um, that's complex.  Doesn't your inactive-C list really just identify
> > pages that were shared but have sunk in the LRU lists due to lack of
> > use?
> 
> Nope. Pages that are not mapped can still end up on the active
> list, by virtue of getting accessed multiple times in a "short"
> period of time (the residence on the inactive list).
> 
> We want to cache frequently accessed pages with preference over
> streaming IO data that gets accessed infrequently.

Well, no, that's what I'm trying to argue against.  The chances are that
Streaming RA I/O gets accessed once (the classic movie scenario).  So
the idea is that if you can identify RA as streaming, it should be kept
while unaccessed but discarded after it's been accessed.  To get the LRU
lists to identify this, we want to give a boost to unaccessed unaged RA,
a suppression to accessed once RA and standard heuristics if RA gets
accessed more than once.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
