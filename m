Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5B79C6B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 19:06:53 -0400 (EDT)
Received: by pdjn11 with SMTP id n11so51335731pdj.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 16:06:53 -0700 (PDT)
Received: from ipmail05.adl6.internode.on.net (ipmail05.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id f12si8429185pat.66.2015.06.17.16.06.51
        for <linux-mm@kvack.org>;
        Wed, 17 Jun 2015 16:06:52 -0700 (PDT)
Date: Thu, 18 Jun 2015 09:06:05 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC v3 1/4] fs: Add generic file system event notifications
Message-ID: <20150617230605.GK10224@dastard>
References: <1434460173-18427-1-git-send-email-b.michalska@samsung.com>
 <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1434460173-18427-2-git-send-email-b.michalska@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Beata Michalska <b.michalska@samsung.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-api@vger.kernel.org, greg@kroah.com, jack@suse.cz, tytso@mit.edu, adilger.kernel@dilger.ca, hughd@google.com, lczerner@redhat.com, hch@infradead.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com, kmpark@infradead.org

On Tue, Jun 16, 2015 at 03:09:30PM +0200, Beata Michalska wrote:
> Introduce configurable generic interface for file
> system-wide event notifications, to provide file
> systems with a common way of reporting any potential
> issues as they emerge.
> 
> The notifications are to be issued through generic
> netlink interface by newly introduced multicast group.
> 
> Threshold notifications have been included, allowing
> triggering an event whenever the amount of free space drops
> below a certain level - or levels to be more precise as two
> of them are being supported: the lower and the upper range.
> The notifications work both ways: once the threshold level
> has been reached, an event shall be generated whenever
> the number of available blocks goes up again re-activating
> the threshold.
> 
> The interface has been exposed through a vfs. Once mounted,
> it serves as an entry point for the set-up where one can
> register for particular file system events.
> 
> Signed-off-by: Beata Michalska <b.michalska@samsung.com>

This has massive scalability problems:

> + 4.3 Threshold notifications:
> +
> + #include <linux/fs_event.h>
> + void fs_event_alloc_space(struct super_block *sb, u64 ncount);
> + void fs_event_free_space(struct super_block *sb, u64 ncount);
> +
> + Each filesystme supporting the threshold notifications should call
> + fs_event_alloc_space/fs_event_free_space respectively whenever the
> + amount of available blocks changes.
> + - sb:     the filesystem's super block
> + - ncount: number of blocks being acquired/released

... here.

> + Note that to properly handle the threshold notifications the fs events
> + interface needs to be kept up to date by the filesystems. Each should
> + register fs_trace_operations to enable querying the current number of
> + available blocks.

Have you noticed that the filesystems have percpu counters for
tracking global space usage? There's good reason for that - taking a
spinlock in such a hot accounting path causes severe contention.

> +static void fs_event_send(struct fs_trace_entry *en, unsigned int event_id)
> +{
> +	size_t size = nla_total_size(sizeof(u32)) * 2 +
> +		      nla_total_size(sizeof(u64));
> +
> +	fs_netlink_send_event(size, event_id, create_common_msg, en);
> +}
> +
> +static void fs_event_send_thresh(struct fs_trace_entry *en,
> +				  unsigned int event_id)
> +{
> +	size_t size = nla_total_size(sizeof(u32)) * 2 +
> +		      nla_total_size(sizeof(u64)) * 2;
> +
> +	fs_netlink_send_event(size, event_id, create_thresh_msg, en);
> +}
> +
> +void fs_event_notify(struct super_block *sb, unsigned int event_id)
> +{
> +	struct fs_trace_entry *en;
> +
> +	en = fs_trace_entry_get_rcu(sb);
> +	if (!en)
> +		return;
> +
> +	spin_lock(&en->lock);
> +	if (atomic_read(&en->active) && (en->notify & FS_EVENT_GENERIC))
> +		fs_event_send(en, event_id);
> +	spin_unlock(&en->lock);
> +	fs_trace_entry_put(en);
> +}
> +EXPORT_SYMBOL(fs_event_notify);
> +
> +void fs_event_alloc_space(struct super_block *sb, u64 ncount)
> +{
> +	struct fs_trace_entry *en;
> +	s64 count;
> +
> +	en = fs_trace_entry_get_rcu(sb);
> +	if (!en)
> +		return;

Adds an atomic write to get the trace entry,

> +	spin_lock(&en->lock);

a spin lock to lock the entry,


> +	if (!atomic_read(&en->active) || !(en->notify & FS_EVENT_THRESH))
> +		goto leave;
> +	/*
> +	 * we shouldn't drop below 0 here,
> +	 * unless there is a sync issue somewhere (?)
> +	 */
> +	count = en->th.avail_space - ncount;
> +	en->th.avail_space = count < 0 ? 0 : count;
> +
> +	if (en->th.avail_space > en->th.lrange)
> +		/* Not 'even' close - leave */
> +		goto leave;
> +
> +	if (en->th.avail_space > en->th.urange) {
> +		/* Close enough - the lower range has been reached */
> +		if (!(en->th.state & THRESH_LR_BEYOND)) {
> +			/* Send notification */
> +			fs_event_send_thresh(en, FS_THR_LRBELOW);
> +			en->th.state &= ~THRESH_LR_BELOW;
> +			en->th.state |= THRESH_LR_BEYOND;
> +		}
> +		goto leave;

Then puts the entire netlink send path inside this spinlock, which
includes memory allocation and all sorts of non-filesystem code
paths. And it may be inside critical filesystem locks as well....

Apart from the serialisation problem of the locking, adding
memory allocation and the network send path to filesystem code
that is effectively considered "innermost" filesystem code is going
to have all sorts of problems for various filesystems. In the XFS
case, we simply cannot execute this sort of function in the places
where we update global space accounting.

As it is, I think the basic concept of separate tracking of free
space if fundamentally flawed. What I think needs to be done is that
filesystems need access to the thresholds for events, and then the
filesystems call fs_event_send_thresh() themselves from appropriate
contexts (ie. without compromising locking, scalability, memory
allocation recursion constraints, etc).

e.g. instead of tracking every change in free space, a filesystem
might execute this once every few seconds from a workqueue:

	event = fs_event_need_space_warning(sb, <fs_free_space>)
	if (event)
		fs_event_send_thresh(sb, event);

User still gets warnings about space usage, but there's no runtime
overhead or problems with lock/memory allocation contexts, etc.

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
