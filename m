Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id C48A56B0062
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 13:37:52 -0500 (EST)
Message-ID: <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
Subject: Re: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Wed, 25 Jan 2012 12:37:48 -0600
In-Reply-To: <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com>
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
	 <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
	 <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Loke, Chetan" <Chetan.Loke@netscout.com>
Cc: Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, Chris Mason <chris.mason@oracle.com>, "Darrick J.Wong" <djwong@us.ibm.com>

On Wed, 2012-01-25 at 13:28 -0500, Loke, Chetan wrote:
> > So there are two separate problems mentioned here.  The first is to
> > ensure that readahead (RA) pages are treated as more disposable than
> > accessed pages under memory pressure and then to derive a statistic for
> > futile RA (those pages that were read in but never accessed).
> > 
> > The first sounds really like its an LRU thing rather than adding yet
> > another page flag.  We need a position in the LRU list for never
> > accessed ... that way they're first to be evicted as memory pressure
> > rises.
> > 
> > The second is you can derive this futile readahead statistic from the
> > LRU position of unaccessed pages ... you could keep this globally.
> > 
> > Now the problem: if you trash all unaccessed RA pages first, you end up
> > with the situation of say playing a movie under moderate memory
> > pressure that we do RA, then trash the RA page then have to re-read to display
> > to the user resulting in an undesirable uptick in read I/O.
> > 
> > Based on the above, it sounds like a better heuristic would be to evict
> > accessed clean pages at the top of the LRU list before unaccessed clean
> > pages because the expectation is that the unaccessed clean pages will
> > be accessed (that's after all, why we did the readahead).  As RA pages age
> 
> Well, the movie example is one case where evicting unaccessed page may not be the right thing to do. But what about a workload that perform a random one-shot search?
> The search was done and the RA'd blocks are of no use anymore. So it seems one solution would hurt another.

Well not really: RA is always wrong for random reads.  The whole purpose
of RA is assumption of sequential access patterns.

The point I'm making is that for the case where RA works (sequential
patterns), evicting unaccessed RA pages before accessed ones is the
wrong thing to do, so the heuristic isn't what you first thought of
(evicting unaccessed RA pages first).

For the random read case, either heuristic is wrong, so it doesn't
matter.

However, when you add the futility measure, random read processes will
end up with aged unaccessed RA pages, so its RA window will get closed.

> We can try to bring-in process run-time heuristics while evicting pages. So in the one-shot search case, the application did it's thing and went to sleep.
> While the movie-app has a pretty good run-time and is still running. So be a little gentle(?) on such apps? Selective eviction?
> 
> In addition what if we do something like this:
> 
> RA block[X], RA block[X+1], ... , RA block[X+m]
> 
> Assume a block reads 'N' pages.
> 
> Evict unaccessed RA page 'a' from block[X+2] and not [X+1].
> 
> We might need tracking at the RA-block level. This way if a movie touched RA-page 'a' from block[X], it would at least have [X+1] in cache. And while [X+1] is being read, the new slow-down version of RA will not RA that many blocks.
> 
> Also, application's should use xxx_fadvise calls to give us hints...

I think that's a bit over complex.  As long as the futility measure
works, a sequential pattern read process gets a reasonable RA window.
The trick is to prove that the simple doesn't work before considering
the complex.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
