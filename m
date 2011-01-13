Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9BBD86B0092
	for <linux-mm@kvack.org>; Thu, 13 Jan 2011 05:41:59 -0500 (EST)
Date: Thu, 13 Jan 2011 18:41:54 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 02/35] writeback: safety margin for bdi stat error
Message-ID: <20110113104154.GA5309@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150326.604451840@intel.com>
 <20110112215949.GD14260@quack.suse.cz>
 <20110113041440.GC7840@localhost>
 <20110113103834.GA5008@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110113103834.GA5008@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 13, 2011 at 06:38:34PM +0800, Jan Kara wrote:
> On Thu 13-01-11 12:14:40, Wu Fengguang wrote:
> > On Thu, Jan 13, 2011 at 05:59:49AM +0800, Jan Kara wrote:
> > > > So the root cause is, the bdi_dirty is well under the global nr_dirty
> > > > due to accounting errors. This can be fixed by using bdi_stat_sum(),
> > >   So which statistic had the big error? I'd just like to understand
> > > this (and how come your patch improves the situation)...
> > 
> > bdi_stat_error() = nr_cpu_ids * BDI_STAT_BATCH
> >                  = 8 * (8*(1+ilog2(8)))
> >                  = 8 * 8 * 4
> >                  = 256 pages
> >                  = 1MB
>   Yes, my question was more aiming at on which statistics the error happens
> so that it causes problems for you. Thinking about it now I suppose you
> observe that bdi_nr_writeback + bdi_nr_reclaimable < bdi_thresh but in fact
> the number of pages is higher than bdi_thresh because of accounting errors.
> And thus we are able to reach global dirty limit and the tasks get
> throttled heavily. Am I right?

Yes, exactly.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
