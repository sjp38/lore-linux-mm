Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 298C66B0036
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 09:55:26 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 5 Jun 2013 09:55:24 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 39EFB38C8045
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 09:55:15 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r55DtFQh240648
	for <linux-mm@kvack.org>; Wed, 5 Jun 2013 09:55:15 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r55DtEK0032684
	for <linux-mm@kvack.org>; Wed, 5 Jun 2013 10:55:15 -0300
Date: Wed, 5 Jun 2013 08:55:08 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv13 2/4] zbud: add to mm/
Message-ID: <20130605135508.GA25375@cerebellum>
References: <1370291585-26102-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1370291585-26102-3-git-send-email-sjenning@linux.vnet.ibm.com>
 <51AEDE10.4010108@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51AEDE10.4010108@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <bob.liu@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Wed, Jun 05, 2013 at 02:43:28PM +0800, Bob Liu wrote:
> Hi Seth,
> 
> On 06/04/2013 04:33 AM, Seth Jennings wrote:
> > +	/* Couldn't find unbuddied zbud page, create new one */
> 
> How about moving zswap_is_full() to here.
> 
> if (zswap_is_full()) {
> 	/* Don't alloc any new page, try to reclaim and direct use the
> reclaimed page instead */

Yes, this is at the top of the list for improvements.

I have already started on this work and it isn't quite as simple as it seems.
The difficulty rises from the fact that, for now, zswap uses per-cpu
compression buffers which require preemption to be disabled. This prevents the
calling zbud_reclaim_page() in zbud_alloc() because the eviction handler for
the user may do something that can wait; an allocation with GFP_WAIT for
example.

So it's going to take some massaging in the zswap layer to get that to work.

It's very doable.  Just not in this patchset without causing a lot of code
thrash.

> }
> 
> > +	spin_unlock(&pool->lock);
> > +	page = alloc_page(gfp);
> > +	if (!page)
> > +		return -ENOMEM;
> > +	spin_lock(&pool->lock);
> > +	pool->pages_nr++;
> > +	zhdr = init_zbud_page(page);
> > +	bud = FIRST;
<snip>
> 
> It looks good for me except two things.
> One is about what the performance might be after the zswap pool is full.
> The other is still about the 20% limit of zswap pool size.

Yep, working on both of them.

Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
