Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id DE41F6B0002
	for <linux-mm@kvack.org>; Mon, 20 May 2013 11:42:42 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Mon, 20 May 2013 11:42:41 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 4F1B16E8028
	for <linux-mm@kvack.org>; Mon, 20 May 2013 11:42:36 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4KFgdgJ39059490
	for <linux-mm@kvack.org>; Mon, 20 May 2013 11:42:39 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4KFgTXo027265
	for <linux-mm@kvack.org>; Mon, 20 May 2013 11:42:30 -0400
Date: Mon, 20 May 2013 10:42:25 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv11 2/4] zbud: add to mm/
Message-ID: <20130520154225.GA25536@cerebellum>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <20130517154837.GN11497@suse.de>
 <20130519205219.GA3252@cerebellum>
 <20130520135439.GR11497@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130520135439.GR11497@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Mon, May 20, 2013 at 02:54:39PM +0100, Mel Gorman wrote:
> On Sun, May 19, 2013 at 03:52:19PM -0500, Seth Jennings wrote:
> > My first guess is that the external fragmentation situation you are referring to
> > is a workload in which all pages compress to greater than half a page.  If so,
> > then it doesn't matter what NCHUCNKS_ORDER is, there won't be any pages the
> > compress enough to fit in the < PAGE_SIZE/2 free space that remains in the
> > unbuddied zbud pages.
> > 
> 
> There are numerous aspects to this, too many to write them all down.
> Modelling the external fragmentation one and how it affects swap IO
> would be a complete pain in the ass so lets consider the following
> example instead as it's a bit clearer.
> 
> Three processes. Process A compresses by 75%, Process B compresses to 15%,
> Process C pages compress to 15%. They are all adding to zswap in lockstep.
> Lets say that zswap can hold 100 physical pages.
> 
> NCHUNKS == 2
> 	All Process A pages get rejected.

Ah, I think this is our disconnect.  Process A pages will not be rejected.
They will be stored in a zbud page, and that zbud page will be added
to the 0th unbuddied list.  This list maintains a list of zbud pages
that will never be buddied because there are no free chunks.

In other words, changing NCHUNKS has no effect on the acceptable size
of allocations.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
