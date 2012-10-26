Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 076646B0072
	for <linux-mm@kvack.org>; Thu, 25 Oct 2012 22:29:21 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id fa10so1762198pad.14
        for <linux-mm@kvack.org>; Thu, 25 Oct 2012 19:29:21 -0700 (PDT)
Date: Fri, 26 Oct 2012 10:29:05 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC 1/2]swap: add a simple buddy allocator
Message-ID: <20121026022905.GA1546@kernel.org>
References: <20121022023051.GA20255@kernel.org>
 <20121025002037.GA3838@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121025002037.GA3838@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com, riel@redhat.com

On Thu, Oct 25, 2012 at 09:20:37AM +0900, Minchan Kim wrote:
> Hi Shaohua,
> 
> Your idea does make sense to me.
> Below just a few nitpick.

Thanks for your time.
 
> On Mon, Oct 22, 2012 at 10:30:51AM +0800, Shaohua Li wrote:
> > I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> > CPU time (when cluster is hard to find), which becomes a bottleneck.
> > scan_swap_map() scans a byte array to search a 256 page cluster, which is very
> > slow.
> > 
> > Here I introduced a simple buddy allocator. Since we only care about 256 pages
> > cluster, we can just use a counter to implement the buddy allocator. Every 256
> > pages use one int to store the counter, so searching cluster is very efficient.
> > With this, scap_swap_map() overhead disappears.
> > 
> > This might help low end SD card swap too. Because if the cluster is aligned, SD
> > firmware can do flash erase more efficiently.
> 
> Indeed.
> 
> > 
> > The downside is the cluster must be aligned to 256 pages, which will reduce the
> > chance to find a cluster.
> 
> It would be not good for roration device. Can't we make it for only discardable
> device?

This is the biggest concern. Andrew raised it too. If most swap space isn't
full, this isn't a problem. Otherwise, might be. But I didn't find a way to
evaluate how big the chance is reduced. I can try if anybody has ideal
workload. If can't evaluate the chance, I'll choose to only enable it for
discardable device.

Other comments make sense, I'll update in next post.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
