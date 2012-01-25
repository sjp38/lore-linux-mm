Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 461836B004F
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 17:58:50 -0500 (EST)
Date: Wed, 25 Jan 2012 23:58:46 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [Lsf-pc] [dm-devel]  [LSF/MM TOPIC] a few storage topics
Message-ID: <20120125225846.GC5415@quack.suse.cz>
References: <20120125032932.GA7150@localhost>
 <F6F2DEB8-F096-4A3B-89E3-3A132033BC76@dilger.ca>
 <1327502034.2720.23.camel@menhir>
 <D3F292ADF945FB49B35E96C94C2061B915A638A6@nsmail.netscout.com>
 <1327509623.2720.52.camel@menhir>
 <1327512727.2776.52.camel@dabdike.int.hansenpartnership.com>
 <D3F292ADF945FB49B35E96C94C2061B915A63A30@nsmail.netscout.com>
 <1327516668.7168.7.camel@dabdike.int.hansenpartnership.com>
 <20120125200613.GH15866@shiny>
 <20120125224614.GM30782@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120125224614.GM30782@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Chris Mason <chris.mason@oracle.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, "Loke, Chetan" <Chetan.Loke@netscout.com>, Steven Whitehouse <swhiteho@redhat.com>, Andreas Dilger <adilger@dilger.ca>, Jan Kara <jack@suse.cz>, Mike Snitzer <snitzer@redhat.com>, linux-scsi@vger.kernel.org, neilb@suse.de, dm-devel@redhat.com, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Jeff Moyer <jmoyer@redhat.com>, Wu Fengguang <fengguang.wu@gmail.com>, Boaz Harrosh <bharrosh@panasas.com>, linux-fsdevel@vger.kernel.org, lsf-pc@lists.linux-foundation.org, "Darrick J.Wong" <djwong@us.ibm.com>

On Wed 25-01-12 23:46:14, Andrea Arcangeli wrote:
> On Wed, Jan 25, 2012 at 03:06:13PM -0500, Chris Mason wrote:
> > We can talk about scaling up how big the RA windows get on their own,
> > but if userland asks for 1MB, we don't have to worry about futile RA, we
> > just have to make sure we don't oom the box trying to honor 1MB reads
> > from 5000 different procs.
> 
> :) that's for sure if read has a 1M buffer as destination. However
> even cp /dev/sda reads/writes through a 32kb buffer, so it's not so
> common to read in 1m buffers.
> 
> But I also would prefer to stay on the simple side (on a side note we
> run out of page flags already on 32bit I think as I had to nuke
> PG_buddy already).
> 
> Overall I think the risk of the pages being evicted before they can be
> copied to userland is quite a minor risk. A 16G system with 100
> readers all hitting on disk at the same time using 100M readahead
> would still only create a 100m memory pressure... So it'd sure be ok,
> 100m is less than what kswapd keeps always free for example. Think a
> 4TB system. Especially if 128k fixed has been ok so far on a 1G system.
> 
> If we really want to be more dynamic than a setting at boot depending
> on ram size, we could limit it to a fraction of freeable memory (using
> similar math to determine_dirtyable_memory, maybe calling it over time
> but not too frequently to reduce the overhead). Like if there's 0
> memory freeable keep it low. If there's 1G freeable out of that math
> (and we assume the readahead hit rate is near 100%), raise the maximum
> readahead to 1M even if the total ram is only 1G. So we allow up to
> 1000 readers before we even recycle the readahead.
> 
> I doubt the complexity of tracking exactly how many pages are getting
> recycled before they're copied to userland would be worth it, besides
> it'd be 0% for 99% of systems and workloads.
> 
> Way more important is to have feedback on the readahead hits and be
> sure when readahead is raised to the maximum the hit rate is near 100%
> and fallback to lower readaheads if we don't get that hit rate. But
> that's not a VM problem and it's a readahead issue only.
> 
> The actual VM pressure side of it, sounds minor issue if the hit rate
> of the readahead cache is close to 100%.
> 
> The config option is also ok with me, but I think it'd be nicer to set
> it at boot depending on ram size (one less option to configure
> manually and zero overhead).
  Yeah. I'd also keep it simple. Tuning max readahead size based on
available memory (and device size) once in a while is about the maximum
complexity I'd consider meaningful. If you have real data that shows
problems which are not solved by that simple strategy, then sure, we can
speak about more complex algorithms. But currently I don't think they are
needed.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
