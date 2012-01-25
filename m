Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx146.postini.com [74.125.245.146])
	by kanga.kvack.org (Postfix) with SMTP id 23AF86B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 15:06:32 -0500 (EST)
Date: Wed, 25 Jan 2012 15:06:13 -0500
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Message-ID: <20120125200613.GH15866@shiny>
References: <x49pqe8kgej.fsf@segfault.boston.devel.redhat.com>
 <20120124203936.GC20650@quack.suse.cz>
 <20120125032932.GA7150@localhost>
 <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca>
 <1327502034.2720.23.camel@menhir>
 <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com>
 <1327509623.2720.52.camel@menhir>
 <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
 <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com>
 <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: "Loke, Chetan" <Chetan.Loke@netscout.com>, Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Andrea Arcangeli <aarcange@redhat.com>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, "Darrick J.Wong" <djwong@us.ibm.com>

On Wed, Jan 25, 2012 at 12:37:48PM -0600, James Bottomley wrote:
> On Wed, 2012-01-25 at 13:28 -0500, Loke, Chetan wrote:
> > > So there are two separate problems mentioned here.  The first is to
> > > ensure that readahead (RA) pages are treated as more disposable than
> > > accessed pages under memory pressure and then to derive a statistic for
> > > futile RA (those pages that were read in but never accessed).
> > > 
> > > The first sounds really like its an LRU thing rather than adding yet
> > > another page flag.  We need a position in the LRU list for never
> > > accessed ... that way they're first to be evicted as memory pressure
> > > rises.
> > > 
> > > The second is you can derive this futile readahead statistic from the
> > > LRU position of unaccessed pages ... you could keep this globally.
> > > 
> > > Now the problem: if you trash all unaccessed RA pages first, you end up
> > > with the situation of say playing a movie under moderate memory
> > > pressure that we do RA, then trash the RA page then have to re-read to display
> > > to the user resulting in an undesirable uptick in read I/O.
> > > 
> > > Based on the above, it sounds like a better heuristic would be to evict
> > > accessed clean pages at the top of the LRU list before unaccessed clean
> > > pages because the expectation is that the unaccessed clean pages will
> > > be accessed (that's after all, why we did the readahead).  As RA pages age
> > 
> > Well, the movie example is one case where evicting unaccessed page may not be the right thing to do. But what about a workload that perform a random one-shot search?
> > The search was done and the RA'd blocks are of no use anymore. So it seems one solution would hurt another.
> 
> Well not really: RA is always wrong for random reads.  The whole purpose
> of RA is assumption of sequential access patterns.

Just to jump back, Jeff's benchmark that started this (on xfs and ext4):

	- buffered 1MB reads get down to the scheduler in 128KB chunks

The really hard part about readahead is that you don't know what
userland wants.  In Jeff's test, he's telling the kernel he wants 1MB
ios and our RA engine is doing 128KB ios.

We can talk about scaling up how big the RA windows get on their own,
but if userland asks for 1MB, we don't have to worry about futile RA, we
just have to make sure we don't oom the box trying to honor 1MB reads
from 5000 different procs.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
