Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id DD71B6B0044
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 11:06:13 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Fri, 14 Dec 2012 11:03:56 -0500
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id D9EADC90043
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 11:03:49 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qBEG3nok31129644
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 11:03:49 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qBEG3mKu028334
	for <linux-mm@kvack.org>; Fri, 14 Dec 2012 11:03:49 -0500
Message-ID: <50CB4CF7.5040400@linux.vnet.ibm.com>
Date: Fri, 14 Dec 2012 09:59:51 -0600
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/8] zswap: compressed swap caching
References: <1355262966-15281-1-git-send-email-sjenning@linux.vnet.ibm.com> <CAA25o9SYYmbq9oJaEKxuBoXSXaeku4=L7qK-1wXABTAsKCjrtQ@mail.gmail.com>
In-Reply-To: <CAA25o9SYYmbq9oJaEKxuBoXSXaeku4=L7qK-1wXABTAsKCjrtQ@mail.gmail.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luigi Semenzato <semenzato@google.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

Hey Luigi,

To echo Dan, it'd be great if we could move this discussion to a new
thread as to leaving this one for code review/comments.  But I did
want to respond.

On 12/12/2012 04:49 PM, Luigi Semenzato wrote:
> Just a couple of questions and comments as a user.  I apologize if
> this is the wrong time to make them, feel free to ignore them.
> 
> 1. It's becoming difficult to understand how zcache, zcache2, zram,
> and now zswap, interact and/or overlap with each other.  For instance,
> I am examining the possibility of using zcache2 and zram in parallel.
> Should I also/instead consider zswap, using a plain RAM disk as the
> swap device?

I guess the short answer is:
* Zcache is no more, replaced by zcache2 (so I stop making the
distinction)
* You wouldn't use zcache and zswap together unless you first disabled
the frontswap part of zcache, however this configuration isn't
recommended since there would be no cooperation between the compressed
page cache and compressed swap cache.
* Zram could work with either zswap or zcache although the
interactions would be interesting; namely, I think zram stores would
likely fail with high frequency since the primary reason the page
would not be captured by either zswap or zcache before it reaches zram
is that zswap/zcache was unable to allocate space.  So zram would
likely fail for the same reason, causing swap slots to be marked as
bad and rapidly shrink the effective size of the zram device.

> 2. Zswap looks like a two-stage swap device, with one stage being
> compressed memory.  I don't know if and where the abstraction breaks,
> and what the implementation issues would be, but I would find it
> easier to view and configure this as a two-stage swap, where one stage
> is chosen as zcache (but could be something else).

I didn't follow this.

> 3. As far as I can tell, none of these compressors has a good way of
> balancing the amount of memory dedicated to compression against the
> pressure on the rest of the memory.  On both zram and zswap, we set a
> max size for the compressed data.  That size determines how much RAM
> is left for the working set, which should remain uncompressed.  But
> the size of the working set can vary significantly with the load.  If
> we choose the size based on a worst-case working set, we'll be
> underutilizing RAM on average.  If we choose it smaller than that, the
> worst-case working set will cause excessive CPU use and thrashing.

This kind of adaptive tuning would be hard to implement and even
harder to get right for everyone, if it could be done at all.
However, one way to achieve this would be to have something in
userspace periodically change the sysfs attribute that controls
maximum compressed pool size based on your own policy.  Both zswap and
zcache have this tunable.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
