Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 64FCB6B002C
	for <linux-mm@kvack.org>; Mon,  5 Mar 2012 18:51:33 -0500 (EST)
Date: Mon, 5 Mar 2012 15:51:32 -0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120305235132.GB13690@localhost>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305192226.GA3670@localhost>
 <20120305211114.GF18546@redhat.com>
 <20120305223029.GB16807@localhost>
 <20120305231930.GC7545@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120305231930.GC7545@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Vivek Goyal <vgoyal@redhat.com>, Suresh Jayaraman <sjayaraman@suse.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>

On Tue, Mar 06, 2012 at 12:19:30AM +0100, Andrea Righi wrote:
> On Mon, Mar 05, 2012 at 02:30:29PM -0800, Fengguang Wu wrote:
> > On Mon, Mar 05, 2012 at 04:11:15PM -0500, Vivek Goyal wrote:
> ...
> > > But looks like we don't much choice. As buffered writes can be controlled
> > > at two levels, we probably need two knobs. Also controlling writes while
> > > entring cache limits will be global and not per device (unlinke currnet
> > > per device limit in blkio controller). Having separate control for "dirty
> > > rate limit" leaves the scope for implementing write control at device
> > > level in the future (As some people prefer that). In possibly two 
> > > solutions can co-exist in future.
> > 
> > Good point. balance_dirty_pages() has no idea about the devices at
> > all. So the rate limit for buffered writes can hardly be unified with
> > the per-device rate limit for direct writes.
> > 
> 
> I think balance_dirty_pages() can have an idea about devices. We can get
> a reference to the right block device / request queue from the
> address_space:
> 
>   bdev = mapping->host->i_sb->s_bdev;
>   q = bdev_get_queue(bdev);
> 
> (NULL pointer dereferences apart).

Problem is, there is no general 1:1 mapping between bdev and disks.
For the single disk multpile partitions (sda1, sda2...) case, the
above scheme is fine and makes the throttle happen at sda granularity.

However for md/dm etc. there is no way (or need?) to reach the exact
disk that current blkcg is operating on.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
