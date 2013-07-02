Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 8EEE46B0032
	for <linux-mm@kvack.org>; Tue,  2 Jul 2013 08:19:54 -0400 (EDT)
Date: Tue, 2 Jul 2013 22:19:47 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130702121947.GE14996@dastard>
References: <20130625022754.GP29376@dastard>
 <20130626081509.GF28748@dhcp22.suse.cz>
 <20130626232426.GA29034@dastard>
 <20130627145411.GA24206@dhcp22.suse.cz>
 <20130629025509.GG9047@dastard>
 <20130630183349.GA23731@dhcp22.suse.cz>
 <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130702092200.GB16815@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 02, 2013 at 11:22:00AM +0200, Michal Hocko wrote:
> On Mon 01-07-13 18:10:56, Dave Chinner wrote:
> > On Mon, Jul 01, 2013 at 09:50:05AM +0200, Michal Hocko wrote:
> > > On Mon 01-07-13 11:25:58, Dave Chinner wrote:
> > That is the recycle stat, which indicates we've found an inode being
> > reclaimed. When it's found an inode that have been evicted, but not
> > yet reclaimed at the XFS level, that stat will increase. If the
> > inode is still valid at the VFS level, and igrab() fails, then we'll
> > get EAGAIN without that stat being increased. So, igrab() is
> > failing, and that means I_FREEING|I_WILL_FREE are set.
> > 
> > So, it looks to be the same case as the ext4 hang, and it's likely
> > that we have some dangling inode dispose list somewhere. So, here's
> > the fun part. Use tracing to grab the inode number that is stuck
> > (tracepoint xfs::xfs_iget_skip), 
> 
> $ cat /sys/kernel/debug/tracing/trace_pipe > demon.trace.log &
> $ pid=$!
> $ sleep 10s ; kill $pid
> $ awk '{print $1, $9}' demon.trace.log | sort -u
> cc1-7561 0xf78d4f
> cc1-9100 0x80b2a35
.....
> 
> > and the dispose list that it is on should be the on the
> > inode->i_lru_list. 
> 
> crash> struct inode.i_lru ffff88000c09e2f8
>   i_lru = {
>     next = 0xffff88000c09e3e8, 
>     prev = 0xffff88000c09e3e8
>   }

Hmmm, that's empty.

> crash> struct inode.i_flags ffff88000c09e2f8
>   i_flags = 4096

I asked for the wrong field, I wanted i_state, but seeing as you:

> The full xfs_inode dump is attached.

Dumped the whole inode, I got it from below :)

>     i_state = 32, 

so, i_state = I_FREEING.

IOWs, we've got an inode marked I_FREEING that isn't on a dispose
list but hasn't passed through evict() correctly.

> crash> struct xfs_inode ffff88000c09e1c0
> struct xfs_inode {
.....
>   i_flags = 0, 

XFS doesn't see the inode as reclaimable yet, either.

Ok, so it's been leaked from a dispose list somehow. Thanks for the
info, Michal, it's time to go look at the code....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
