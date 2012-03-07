Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id ADD9D6B002C
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 15:26:22 -0500 (EST)
Date: Wed, 7 Mar 2012 15:26:16 -0500
From: Vivek Goyal <vgoyal@redhat.com>
Subject: Re: [ATTEND] [LSF/MM TOPIC] Buffered writes throttling
Message-ID: <20120307202616.GJ13430@redhat.com>
References: <4F507453.1020604@suse.com>
 <20120302153322.GB26315@redhat.com>
 <20120305192226.GA3670@localhost>
 <20120305211114.GF18546@redhat.com>
 <20120305223029.GB16807@localhost>
 <20120305231930.GC7545@thinkpad>
 <20120305235132.GB13690@localhost>
 <20120306004602.GA16061@thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120306004602.GA16061@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Righi <andrea@betterlinux.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Suresh Jayaraman <sjayaraman@suse.com>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>, Greg Thelen <gthelen@google.com>

On Tue, Mar 06, 2012 at 01:46:02AM +0100, Andrea Righi wrote:

[..]
> > > > Good point. balance_dirty_pages() has no idea about the devices at
> > > > all. So the rate limit for buffered writes can hardly be unified with
> > > > the per-device rate limit for direct writes.
> > > > 
> > > 
> > > I think balance_dirty_pages() can have an idea about devices. We can get
> > > a reference to the right block device / request queue from the
> > > address_space:
> > > 
> > >   bdev = mapping->host->i_sb->s_bdev;
> > >   q = bdev_get_queue(bdev);
> > > 
> > > (NULL pointer dereferences apart).
> > 
> > Problem is, there is no general 1:1 mapping between bdev and disks.
> > For the single disk multpile partitions (sda1, sda2...) case, the
> > above scheme is fine and makes the throttle happen at sda granularity.
> > 
> > However for md/dm etc. there is no way (or need?) to reach the exact
> > disk that current blkcg is operating on.
> > 
> > Thanks,
> > Fengguang
> 
> Oh I see, the problem is with stacked block devices. Right, if we set a
> limit for sda and a stacked block device is defined over sda, we'd get
> only the bdev at the top of the stack at balance_dirty_pages() and the
> limits configured for the underlying block devices will be ignored.
> 
> However, maybe for the 90% of the cases this is fine, I can't see a real
> world scenario where we may want to limit only part or indirectly a
> stacked block device...

I agree that throttling will make most sense on the top most device in the 
stack. If we try to do anything on the intermediate device, it might not
make much sense and we will most likely lose context also.

Thanks
Vivek

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
