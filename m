Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id D47738D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 16:36:35 -0500 (EST)
Date: Mon, 7 Mar 2011 13:34:41 -0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 19/27] writeback: dirty throttle bandwidth control
Message-ID: <20110307213441.GA22237@localhost>
References: <20110303064505.718671603@intel.com>
 <20110303074951.143474038@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110303074951.143474038@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Trond Myklebust <Trond.Myklebust@netapp.com>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, Vivek Goyal <vgoyal@redhat.com>, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Mar 03, 2011 at 02:45:24PM +0800, Wu, Fengguang wrote:
> balance_dirty_pages() has been using a very simple and robust threshold
> based throttle scheme. It automatically limits the dirty rate down,
> however in a very bumpy way that constantly block the dirtier tasks for
> hundreds of milliseconds on a local ext4.

To get an idea of what exactly is going on in the current kernel, I
back ported the balance_dirty_pages and global_page_state trace events
to 2.6.38-rc7 and run the same test cases. The resulted graphs are
pretty striking.

In the worst NFS cases, the pause time frequently go up to 20-30 seconds,
and the dirty progress is rather bumpy.

1-dd case
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-07-23-14/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-07-23-14/global_dirtied_written.png

8-dd case
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/NFS/nfs-8dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-07-23-26/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/NFS/nfs-8dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-07-23-26/balance_dirty_pages-task-bw.png

The writes to USB key starts with a long 30 seconds pause, followed by
many ~2 seconds long pauses for ext4. XFS is better; btrfs performs the
best, however can still have 7s and 2s long delays.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/1UKEY+1HDD-3G/ext4-1dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-07-23-34/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/1UKEY+1HDD-3G/xfs-1dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-07-23-56/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/1UKEY+1HDD-3G/btrfs-1dd-1M-8p-2945M-20%25-2.6.38-rc7+-2011-03-08-00-14/balance_dirty_pages-pause.png

For the normal writes to HDD, ext4 has some >300ms pause times in 1-dd
case, >600ms for 2-dd case, and >2s for 8-dd case. The pause time
roughly deteriorates proportionally with the number of concurrent dd tasks.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/ext4-1dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-22-15/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/ext4-2dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-22-22/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/ext4-8dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-22-30/balance_dirty_pages-pause.png

XFS performs similarly
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/xfs-8dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-22-08/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/xfs-8dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-22-08/balance_dirty_pages-task-bw.png

btrfs is better, typically has 1-2s max pause time in 8-dd case
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/btrfs-8dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-21-48/balance_dirty_pages-pause.png

The long pause times will obviously ruin user experiences. It may also
hurt performance. For example, if the dirtier is a simple "cp" or
"scp", the long pause time will break the readahead pipeline or the
network pipeline, leading to moments of underutilized disk/network
bandwidth.

Comparing to the above graphs, this patchset is able to keep latency
under control (less than the configured 200ms max pause time) in all
known cases, whether it be 1-dd or 1000-dd, on local file systems,
over NFS or on USB key.

8-dd case
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/vanilla/4G/ext4-8dd-1M-8p-3911M-20%25-2.6.38-rc7+-2011-03-07-22-30/balance_dirty_pages-task-bw.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-8dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-18/balance_dirty_pages-task-bw.png

128-dd case
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-128dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-25/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-128dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-23-25/balance_dirty_pages-task-bw.png

1000-dd case
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/10SSD-RAID0-64G/xfs-1000dd-1M-64p-64288M-20%25-2.6.38-rc6-dt6+-2011-02-28-10-40/balance_dirty_pages-pause.png

UKEY
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/ext4-1dd-1M-8p-2975M-20%25-2.6.38-rc6-dt6+-2011-02-28-20-21/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/xfs-4dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-27/balance_dirty_pages-pause.png

NFS
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-1dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-09/balance_dirty_pages-pause.png
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/NFS/nfs-8dd-1M-8p-2945M-20%25-2.6.38-rc6-dt6+-2011-02-22-21-22/balance_dirty_pages-pause.png

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
