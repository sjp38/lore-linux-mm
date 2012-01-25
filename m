Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 4C8AD6B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 12:32:11 -0500 (EST)
Message-ID: <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
Subject: RE: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 25 Jan 2012 11:32:07 -0600
In-Reply-To: <1327509623.2720.52.camel@menhir>
References: <20120124151504.GQ4387@shiny>
	 <20120124165631.GA8941@infradead.org>
	 <186EA560-1720-4975-AC2F-8C72C4A777A9@dilger.ca>
	 <x49fwf5kmbl.fsf@segfault.boston.devel.redhat.com>
	 <20120124184054.GA23227@infradead.org> <20120124190732.GH4387@shiny>
	 <x49vco0kj5l.fsf@segfault.boston.devel.redhat.com>
	 <20120124200932.GB20650@quack.suse.cz>
	 <x49pqe8kgej.fsf@segfault.boston.devel.redhat.com>
	 <20120124203936.GC20650@quack.suse.cz> <20120125032932.GA7150@localhost>
	 <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca>
	 <1327502034.2720.23.camel@menhir>
	 <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com>
	 <1327509623.2720.52.camel@menhir>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Whitehouse <swhiteho@redhat.com>
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>, Andreas Dilger <adilger@dilger.ca>, Wu Fengguang <fengguang.wu@gmail.com>, Jan Kara <jack@suse.cz>, Jeff Moyer <jmoyer@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-scsi@vger.kernel.org, Mike Snitzer <snitzer@redhat.com>, neilb@suse.de, Christoph Hellwig <hch@infradead.org>, dm-devel@redhat.com, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Chris Mason <chris.mason@oracle.com>, "Darrick J.Wong" <djwong@us.ibm.com>, linux-mm@kvack.org

On Wed, 2012-01-25 at 16:40 +0000, Steven Whitehouse wrote:
> Hi,
> 
> On Wed, 2012-01-25 at 11:22 -0500, Loke, Chetan wrote:
> > > If the reason for not setting a larger readahead value is just that it
> > > might increase memory pressure and thus decrease performance, is it
> > > possible to use a suitable metric from the VM in order to set the value
> > > automatically according to circumstances?
> > > 
> > 
> > How about tracking heuristics for 'read-hits from previous read-aheads'? If the hits are in acceptable range(user-configurable knob?) then keep seeking else back-off a little on the read-ahead?
> > 
> > > Steve.
> > 
> > Chetan Loke
> 
> I'd been wondering about something similar to that. The basic scheme
> would be:
> 
>  - Set a page flag when readahead is performed
>  - Clear the flag when the page is read (or on page fault for mmap)
> (i.e. when it is first used after readahead)
> 
> Then when the VM scans for pages to eject from cache, check the flag and
> keep an exponential average (probably on a per-cpu basis) of the rate at
> which such flagged pages are ejected. That number can then be used to
> reduce the max readahead value.
> 
> The questions are whether this would provide a fast enough reduction in
> readahead size to avoid problems? and whether the extra complication is
> worth it compared with using an overall metric for memory pressure?
> 
> There may well be better solutions though,

So there are two separate problems mentioned here.  The first is to
ensure that readahead (RA) pages are treated as more disposable than
accessed pages under memory pressure and then to derive a statistic for
futile RA (those pages that were read in but never accessed).

The first sounds really like its an LRU thing rather than adding yet
another page flag.  We need a position in the LRU list for never
accessed ... that way they're first to be evicted as memory pressure
rises.

The second is you can derive this futile readahead statistic from the
LRU position of unaccessed pages ... you could keep this globally.

Now the problem: if you trash all unaccessed RA pages first, you end up
with the situation of say playing a movie under moderate memory pressure
that we do RA, then trash the RA page then have to re-read to display to
the user resulting in an undesirable uptick in read I/O.

Based on the above, it sounds like a better heuristic would be to evict
accessed clean pages at the top of the LRU list before unaccessed clean
pages because the expectation is that the unaccessed clean pages will be
accessed (that's after all, why we did the readahead).  As RA pages age
in the LRU list, they become candidates for being futile, since they've
been in memory for a while and no-one has accessed them, leading to the
conclusion that they aren't ever going to be read.

So I think futility is a measure of unaccessed aging, not necessarily of
ejection (which is a memory pressure response).

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
