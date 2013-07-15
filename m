Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id B66D76B0031
	for <linux-mm@kvack.org>; Mon, 15 Jul 2013 10:57:07 -0400 (EDT)
Date: Mon, 15 Jul 2013 09:56:53 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: Testing results of zswap
Message-ID: <20130715145653.GA7275@medulla.variantweb.net>
References: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAA_GA1fiEJYxqAZ1c0BneuftB5g8d+2_mYBj=4iE=1EcYaTx7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Nitin Gupta <ngupta@vflare.org>, bob.liu@oracle.com, Mel Gorman <mgorman@suse.de>

On Mon, Jul 15, 2013 at 10:56:17AM +0800, Bob Liu wrote:
> As my test results showed in this thread.
> 1. Zswap only useful when total ram size is large else the performance
> was worse than disabled it!

I have not observed this.  In my kernbench runs, I was using VMs with ~512MB
of RAM and saw significant improvement from zswap.

> 
> 2. Zswap occupies some memory but that's unfair to file pages, more
> file pages maybe reclaimed during memory pressure.

This is true.  It remains to be explored how the policies that balance anon
reclaim and page cache reclaim can be respected by zswap.  Until then though,
the growth of the zswap pool does add memory pressure which causes more
reclaim in general, both anon and page cache.

> I think that's why the performance of the background io-duration was
> worse than disable zswap.

The I/O load during the parallelio-memcached test shouldn't be effected by 
page cache reclaim since it is not re-reading anything.  Again, I say that
that test is not a good and repeatable (across different systems and kernel
versions) to test zswap.  parallelio-memcached is designed to test
suboptimal page reclaim decisions, not swap performance.

Have you tried running kernbench in a memory environment restricted enough
to cause swapping with zswap enabled?  I think that would be a better test.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
