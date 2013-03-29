Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id E03D56B0002
	for <linux-mm@kvack.org>; Thu, 28 Mar 2013 22:50:34 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id uo1so77208pbc.19
        for <linux-mm@kvack.org>; Thu, 28 Mar 2013 19:50:34 -0700 (PDT)
Date: Fri, 29 Mar 2013 10:50:27 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [patch 1/4 v4]swap: change block allocation algorithm for SSD
Message-ID: <20130329025027.GB19943@kernel.org>
References: <20130326053706.GA19646@kernel.org>
 <20130329020051.GB17301@optiplex.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130329020051.GB17301@optiplex.redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rafael Aquini <aquini@redhat.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, riel@redhat.com, minchan@kernel.org, kmpark@infradead.org, hughd@google.com

On Thu, Mar 28, 2013 at 11:00:53PM -0300, Rafael Aquini wrote:
> On Tue, Mar 26, 2013 at 01:37:06PM +0800, Shaohua Li wrote:
> > I'm using a fast SSD to do swap. scan_swap_map() sometimes uses up to 20~30%
> > CPU time (when cluster is hard to find, the CPU time can be up to 80%), which
> > becomes a bottleneck.  scan_swap_map() scans a byte array to search a 256 page
> > cluster, which is very slow.
> > 
> > Here I introduced a simple algorithm to search cluster. Since we only care
> > about 256 pages cluster, we can just use a counter to track if a cluster is
> > free. Every 256 pages use one int to store the counter. If the counter of a
> > cluster is 0, the cluster is free. All free clusters will be added to a list,
> > so searching cluster is very efficient. With this, scap_swap_map() overhead
> > disappears.
> > 
> > Since searching cluster with a list is easy, we can easily implement a per-cpu
> > cluster algorithm to do block allocation, which can make swapout more
> > efficient. This is in my TODO list.
> > 
> > This might help low end SD card swap too. Because if the cluster is aligned, SD
> > firmware can do flash erase more efficiently.
> > 
> > We only enable the algorithm for SSD. Hard disk swap isn't fast enough and has
> > downside with the algorithm which might introduce regression (see below).
> > 
> > The patch slightly changes which cluster is choosen. It always adds free
> > cluster to list tail. This can help wear leveling for low end SSD too. And if
> > no cluster found, the scan_swap_map() will do search from the end of last
> > cluster. So if no cluster found, the scan_swap_map() will do search from the
> > end of last free cluster, which is random. For SSD, this isn't a problem at
> > all.
> > 
> > Another downside is the cluster must be aligned to 256 pages, which will reduce
> > the chance to find a cluster. I would expect this isn't a big problem for SSD
> > because of the non-seek penality. (And this is the reason I only enable the
> > algorithm for SSD).
> > 
> > V3 -> V4:
> > clean up
> > 
> > V2 -> V3:
> > rebase to latest linux-next
> > 
> > V1 -> V2:
> > 1. free cluster is added to a list, which makes searching cluster more efficient
> > 2. only enable the algorithm for SSD.
> > 
> > Signed-off-by: Shaohua Li <shli@fusionio.com>
> > ---
> 
> Hello Shaohua,
> 
> I'm still OK with your series and tests I've been making with it are going fine
> and dandy. I guess there were a couple of questions Andrew has raised you left
> yet opened, but I'm assuming you both might have sorted them out in private.
> 
> If you're going to resubmit this work to make any extra adjustment, please
> consider the suggestions that follow below. (mostly cosmetics changes/nitpicks) 

Nice, makes the description quite clear, Thanks! I'd like to add these for an
add-on cleanup patch if Andrew accepts the patches. Lazy to repost again :)

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
