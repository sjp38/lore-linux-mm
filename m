Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id D77D16B13F0
	for <linux-mm@kvack.org>; Fri, 10 Feb 2012 04:30:32 -0500 (EST)
Date: Fri, 10 Feb 2012 17:20:26 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: memcg writeback (was Re: [Lsf-pc] [LSF/MM TOPIC] memcg topics.)
Message-ID: <20120210092026.GA16129@localhost>
References: <CAHH2K0b-+T4dspJPKq5TH25aH58TEr+7yvq0-HMkbFi0ghqAfA@mail.gmail.com>
 <20120208093120.GA18993@localhost>
 <CAHH2K0bmURXpk6-4D9q7ErppVyMJjKMsn37MenwqcP_nnT66Mw@mail.gmail.com>
 <CAHH2K0bmZn-hthrMasw8FdmgERct2m-8gwsumXpV1q=WQzUW1A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAHH2K0bmZn-hthrMasw8FdmgERct2m-8gwsumXpV1q=WQzUW1A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Thelen <gthelen@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, "bsingharora@gmail.com" <bsingharora@gmail.com>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>

On Thu, Feb 09, 2012 at 09:52:03PM -0800, Greg Thelen wrote:
> (removed lsf-pc@lists.linux-foundation.org because this really isn't
> program committee matter)
> 
> On Wed, Feb 1, 2012 at 11:52 PM, Wu Fengguang <fengguang.wu@intel.com> wrote:
> > Unfortunately the memcg partitioning could fundamentally make the
> > dirty throttling more bumpy.
> >
> > Imagine 10 memcgs each with
> >
> > - memcg_dirty_limit=50MB
> > - 1 dd dirty task
> >
> > The flusher thread will be working on 10 inodes in turn, each time
> > grabbing the next inode and taking ~0.5s to write ~50MB of its dirty
> > pages to the disk. So each inode will be flushed on every ~5s.
> 
> Does the flusher thread need to write 50MB/inode in this case?
> Would there be problems interleaving writes by declaring some max
> write limit (e.g. 8 MiB/write).  

ext4 actually forces write chunk size to be >=128MB for better write
throughput and less fragmentation, which also helps read performance.

Other filesystems use the VFS computed chunk size, which is defined
in writeback_chunk_size() as write_bandwith/2.

> Such interleaving would be beneficial if there are multiple memcg
> expecting service from the single bdi flusher thread.

Right, reducing the writeback chunk size will improve the memcg's
dirty pages smoothness right away.

> I suspect certain filesystems might have increased fragmentation
> with this, but I am not sure if appending writes can easily expand
> an extent.

To be exact, it's ext4 that will suffer from fragmentation with smaller
chunk sizes. Because it uses the size passed by ->writepages() as hint
to allocate extents. Perhaps this heuristic is somehow improvable.

XFS does not have the fragmentation issue (at least not affected by
the chunk size). However my old tests show that it costs much less
seeks and performs noticeably better with raised write chunk size.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
