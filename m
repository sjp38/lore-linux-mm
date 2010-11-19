Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 21D376B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 11:07:00 -0500 (EST)
Date: Fri, 19 Nov 2010 17:06:53 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] writeback: prevent bandwidth calculation overflow
Message-ID: <20101119160653.GB3871@tiehlicka.suse.cz>
References: <20101118065725.GB8458@localhost>
 <4CE537BE.6090103@redhat.com>
 <20101118154408.GA18582@localhost>
 <1290096121.2109.1525.camel@laptop>
 <20101118161356.GA20569@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118161356.GA20569@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Li, Shaohua" <shaohua.li@intel.com>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri 19-11-10 00:13:56, Wu Fengguang wrote:
> On Fri, Nov 19, 2010 at 12:02:01AM +0800, Peter Zijlstra wrote:
> > On Thu, 2010-11-18 at 23:44 +0800, Wu Fengguang wrote:
> > > +               pause = HZ * pages_dirtied / (bw + 1);
> > 
> > Shouldn't that be using something like div64_u64 ?
> 
> Thanks for review. Here is the updated patch using div64_u64().
> 
> ---
> Subject: writeback: prevent bandwidth calculation overflow
> Date: Thu Nov 18 12:55:42 CST 2010
> 
> On 32bit kernel, bdi->write_bandwidth can express at most 4GB/s.
> 
> However the current calculation code can overflow when disk bandwidth
> reaches 800MB/s.  Fix it by using "long long" and div64_u64() in the
> calculations.
> 
> And further change its unit from bytes/second to pages/second.
> That allows up to 16TB/s bandwidth in 32bit kernel.
> 
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Acked-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  mm/backing-dev.c    |    4 ++--
>  mm/page-writeback.c |   11 +++++------
>  2 files changed, 7 insertions(+), 8 deletions(-)
> 
> --- linux-next.orig/mm/page-writeback.c	2010-11-18 12:42:58.000000000 +0800
> +++ linux-next/mm/page-writeback.c	2010-11-19 00:08:23.000000000 +0800
> @@ -494,7 +494,7 @@ void bdi_update_write_bandwidth(struct b
>  	unsigned long written;
>  	unsigned long elapsed;
>  	unsigned long bw;
> -	unsigned long w;
> +	unsigned long long w;
>  
>  	if (*bw_written == 0)
>  		goto snapshot;
> @@ -513,7 +513,7 @@ void bdi_update_write_bandwidth(struct b
>  		goto snapshot;
>  
>  	written = percpu_counter_read(&bdi->bdi_stat[BDI_WRITTEN]) - *bw_written;
> -	bw = (HZ * PAGE_CACHE_SIZE * written + elapsed/2) / elapsed;
> +	bw = (HZ * written + elapsed/2) / elapsed;

Sorry for a dumb question, but where did PAGE_CACHE_SIZE part go?

>  	w = min(elapsed / unit_time, 128UL);
>  	bdi->write_bandwidth = (bdi->write_bandwidth * (1024-w) + bw * w) >> 10;
>  	bdi->write_bandwidth_update_time = jiffies;

-- 
Michal Hocko
L3 team 
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
