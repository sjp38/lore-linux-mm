Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6ACBC9000BD
	for <linux-mm@kvack.org>; Fri, 30 Sep 2011 04:56:33 -0400 (EDT)
Date: Fri, 30 Sep 2011 10:55:39 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 3/5] mm: try to distribute dirty pages fairly across zones
Message-ID: <20110930085539.GD30857@redhat.com>
References: <1317367044-475-1-git-send-email-jweiner@redhat.com>
 <1317367044-475-4-git-send-email-jweiner@redhat.com>
 <CAOJsxLFWfH5zDG8ui=yQyOcZY_nXhK6r+ziapLg9Zhmb3ibuWQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOJsxLFWfH5zDG8ui=yQyOcZY_nXhK6r+ziapLg9Zhmb3ibuWQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Christoph Hellwig <hch@infradead.org>, Dave Chinner <david@fromorbit.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Chris Mason <chris.mason@oracle.com>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Shaohua Li <shaohua.li@intel.com>, xfs@oss.sgi.com, linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Fri, Sep 30, 2011 at 10:35:25AM +0300, Pekka Enberg wrote:
> Hi Johannes!
> 
> On Fri, Sep 30, 2011 at 10:17 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> > But there is a flaw in that we have a zoned page allocator which does
> > not care about the global state but rather the state of individual
> > memory zones.  And right now there is nothing that prevents one zone
> > from filling up with dirty pages while other zones are spared, which
> > frequently leads to situations where kswapd, in order to restore the
> > watermark of free pages, does indeed have to write pages from that
> > zone's LRU list.  This can interfere so badly with IO from the flusher
> > threads that major filesystems (btrfs, xfs, ext4) mostly ignore write
> > requests from reclaim already, taking away the VM's only possibility
> > to keep such a zone balanced, aside from hoping the flushers will soon
> > clean pages from that zone.
> 
> The obvious question is: how did you test this? Can you share the results?

Meh, sorry about that, they were in the series introduction the last
time and I forgot to copy them over.

I did single-threaded, linear writing to an USB stick as the effect is
most pronounced with slow backing devices.

[ The write deferring on ext4 because of delalloc is so extreme that I
  could trigger it even with simple linear writers on a mediocre
  rotating disk, though.  I can not access the logfiles right now, but
  the nr_vmscan_writes went practically away here as well and runtime
  was unaffected with the patched kernel. ]

			Test results

15M DMA + 3246M DMA32 + 504M Normal = 3765M memory
40% dirty ratio, 10% background ratio
16G USB thumb drive
10 runs of dd if=/dev/zero of=disk/zeroes bs=32k count=$((10 << 15))

		seconds			nr_vmscan_write
		        (stddev)	       min|     median|        max
xfs
vanilla:	 549.747( 3.492)	     0.000|      0.000|      0.000
patched:	 550.996( 3.802)	     0.000|      0.000|      0.000

fuse-ntfs
vanilla:	1183.094(53.178)	 54349.000|  59341.000|  65163.000
patched:	 558.049(17.914)	     0.000|      0.000|     43.000

btrfs
vanilla:	 573.679(14.015)	156657.000| 460178.000| 606926.000
patched:	 563.365(11.368)	     0.000|      0.000|   1362.000

ext4
vanilla:	 561.197(15.782)	     0.000|2725438.000|4143837.000
patched:	 568.806(17.496)	     0.000|      0.000|      0.000

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
