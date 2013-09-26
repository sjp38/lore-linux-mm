Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id AF81C6B0039
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:14:08 -0400 (EDT)
Received: by mail-pa0-f48.google.com with SMTP id bj1so1516031pad.21
        for <linux-mm@kvack.org>; Thu, 26 Sep 2013 09:14:08 -0700 (PDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjennings@medulla.variantweb.net>;
	Thu, 26 Sep 2013 12:14:05 -0400
Received: from b01cxnp22034.gho.pok.ibm.com (b01cxnp22034.gho.pok.ibm.com [9.57.198.24])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 400766E8054
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:14:02 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by b01cxnp22034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8QGE24G60424414
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 16:14:02 GMT
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8QGE23j020705
	for <linux-mm@kvack.org>; Thu, 26 Sep 2013 12:14:02 -0400
Date: Thu, 26 Sep 2013 11:14:01 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [RFC 0/4] cleancache: SSD backed cleancache backend
Message-ID: <20130926161401.GA3288@medulla.variantweb.net>
References: <20130926141428.392345308@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130926141428.392345308@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: linux-mm@kvack.org, bob.liu@oracle.com, dan.magenheimer@oracle.com

On Thu, Sep 26, 2013 at 10:14:28PM +0800, Shaohua Li wrote:
> Hi,
> 
> This is a cleancache backend which caches page to disk, usually a SSD. The
> usage model is similar like Windows readyboost. Eg, user plugs a USB drive,
> and we use the USB drive to cache clean pages to reduce IO to hard disks.

Very interesting! A few thoughts:

It seems that this is doing at the page level what bcache/dm-cache do at
the block layer.  What is the advantage of doing it this way?

I've always had an issue with cleancache.  It hooks into the page cache
eviction code which is an otherwise fast path.  Clean page cache
eviction is the cheapest kind of memory reclaim. However, cleancache
introduces overhead into this path for an uncertain benefit; namely that
a future page access, if done before it is dropped from the secondary
cache, will be faster.

Another side effect of introducing overhead here is in the case of a
large memory allocation, the reclaim system can evict a LOT of page
cache pages.  It seems that with this model, the eviction/reclaim speed
is throttled by the SSD write speed.

It looks like this set makes quite a few changes outside of the backend
itself.  I'm sure we would have to come up with some convincing use case
in order to justify introducing changes into these highly used paths.

I can see this burning out your SSD as well.  If someone enabled this on
a machine that did large (relative to the size of the SDD) streaming
reads, you'd be writing to the SSD continuously and never have a cache
hit.

Thanks,
Seth

> 
> So far I only did some micro benchmark, for example, access files with size
> excess memory size. The result is positive. Of course we need solid data for
> more real workloads. I'd like some comments/suggestions before I put more time
> on it.
> 
> Thanks,
> Shaohua
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
