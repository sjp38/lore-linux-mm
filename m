Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 59351900138
	for <linux-mm@kvack.org>; Wed, 10 Aug 2011 14:41:05 -0400 (EDT)
Date: Wed, 10 Aug 2011 14:40:52 -0400
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [PATCH 0/5] IO-less dirty throttling v8
Message-ID: <20110810184052.GE3396@redhat.com>
References: <20110806084447.388624428@intel.com>
 <20110809020127.GA3700@redhat.com>
 <20110809055551.GP3162@dastard>
 <20110809140421.GB6482@redhat.com>
 <CAHH2K0bV3WPSOBn=Kob-kvw0FgchUhm_bA9HGVJGmsZgWf0dSg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHH2K0bV3WPSOBn=Kob-kvw0FgchUhm_bA9HGVJGmsZgWf0dSg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@lst.de>, LKML <linux-kernel@vger.kernel.org>, Andrea Righi <arighi@develer.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Wed, Aug 10, 2011 at 12:41:00AM -0700, Greg Thelen wrote:

[..]
> > > However, before we have a "finished product", there is still another
> > > piece of the puzzle to be put in place - memcg-aware buffered
> > > writeback. That is, having a flusher thread do work on behalf of
> > > memcg in the IO context of the memcg. Then the IO controller just
> > > sees a stream of async writes in the context of the memcg the
> > > buffered writes came from in the first place. The block layer
> > > throttles them just like any other IO in the IO context of the
> > > memcg...
> >
> > Yes that is still a piece remaining. I was hoping that Greg Thelen will
> > be able to extend his patches to submit writes in the context of
> > per cgroup flusher/worker threads and solve this problem.
> >
> > Thanks
> > Vivek
> 
> Are you suggesting multiple flushers per bdi (one per cgroup)?  I
> thought the point of IO less was to one issue buffered writes from a
> single thread.

I think in one of the mail threads Dave Chinner mentioned this idea
of using per cgroup worker/worqueue.

Agreed that it leads back to the issue of multiple writers (but only
if multiple cgroups are there). But at the same time it simplifies
atleast two problems.

- Worker could be migrated to the cgroup we are writting for and we
  don't need the IO tracking logic. blkio controller should will
  automatically account the IO to right group.

- We don't have to worry about a single flusher thread sleeping
  on request queue because either queue or group is congested and
  this can lead other group's IO is not being submitted.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
