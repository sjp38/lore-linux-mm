Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 9B6B46B0026
	for <linux-mm@kvack.org>; Thu, 12 May 2011 12:10:51 -0400 (EDT)
Received: by wyf19 with SMTP id 19so1734557wyf.14
        for <linux-mm@kvack.org>; Thu, 12 May 2011 09:10:43 -0700 (PDT)
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1105121050220.26013@router.home>
References: <1305127773-10570-1-git-send-email-mgorman@suse.de>
	 <1305127773-10570-4-git-send-email-mgorman@suse.de>
	 <alpine.DEB.2.00.1105120942050.24560@router.home>
	 <1305213359.2575.46.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121024350.26013@router.home>
	 <1305214993.2575.50.camel@mulgrave.site>
	 <alpine.DEB.2.00.1105121050220.26013@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 12 May 2011 18:10:38 +0200
Message-ID: <1305216638.3795.36.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: James Bottomley <James.Bottomley@HansenPartnership.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Pekka Enberg <penberg@kernel.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

Le jeudi 12 mai 2011 A  11:01 -0500, Christoph Lameter a A(C)crit :
> On Thu, 12 May 2011, James Bottomley wrote:
> 
> > > Debian and Ubuntu have been using SLUB for a long time
> >
> > Only from Squeeze, which has been released for ~3 months.  That doesn't
> > qualify as a "long time" in my book.
> 
> I am sorry but I have never used a Debian/Ubuntu system in the last 3
> years that did not use SLUB. And it was that by default. But then we
> usually do not run the "released" Debian version. Typically one runs
> testing. Ubuntu is different there we usually run releases. But those
> have been SLUB for as long as I remember.
> 
> And so far it is rock solid and is widely rolled out throughout our
> infrastructure (mostly 2.6.32 kernels).
> 
> > but a sample of one doeth not great testing make.
> >
> > However, since you admit even you see problems, let's concentrate on
> > fixing them rather than recriminations?
> 
> I do not see problems here with earlier kernels. I only see these on one
> testing system with the latest kernels on Ubuntu 11.04.

More fuel to this discussion with commit 6d4831c2

Something is wrong with high order allocations, on some machines.

Maybe we can find real cause instead of limiting us to use order-0 pages
in the end... ;)

commit 6d4831c283530a5f2c6bd8172c13efa236eb149d
Author: Andrew Morton <akpm@linux-foundation.org>
Date:   Wed Apr 27 15:26:41 2011 -0700

    vfs: avoid large kmalloc()s for the fdtable
    
    Azurit reports large increases in system time after 2.6.36 when running
    Apache.  It was bisected down to a892e2d7dcdfa6c76e6 ("vfs: use kmalloc()
    to allocate fdmem if possible").
    
    That patch caused the vfs to use kmalloc() for very large allocations and
    this is causing excessive work (and presumably excessive reclaim) within
    the page allocator.
    
    Fix it by falling back to vmalloc() earlier - when the allocation attempt
    would have been considered "costly" by reclaim.
    
  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
