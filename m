Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 0D4806B0033
	for <linux-mm@kvack.org>; Tue, 14 May 2013 13:29:04 -0400 (EDT)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Tue, 14 May 2013 11:29:00 -0600
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id EB5EE19D8052
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:28:33 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r4EHSat1043520
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:28:37 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r4EHSWqn004876
	for <linux-mm@kvack.org>; Tue, 14 May 2013 11:28:33 -0600
Date: Tue, 14 May 2013 12:28:27 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
Subject: Re: [PATCHv11 3/4] zswap: add to mm/
Message-ID: <20130514172827.GE4024@medulla>
References: <1368448803-2089-1-git-send-email-sjenning@linux.vnet.ibm.com>
 <1368448803-2089-4-git-send-email-sjenning@linux.vnet.ibm.com>
 <51920197.9070105@oracle.com>
 <20130514160040.GB4024@medulla>
 <b9131728-5cf8-4979-a6de-ac14cc409b28@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <b9131728-5cf8-4979-a6de-ac14cc409b28@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Bob Liu <bob.liu@oracle.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Konrad Wilk <konrad.wilk@oracle.com>, Robert Jennings <rcj@linux.vnet.ibm.com>, Jenifer Hopper <jhopper@us.ibm.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Dave Hansen <dave@sr71.net>, Joe Perches <joe@perches.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Cody P Schafer <cody@linux.vnet.ibm.com>, Hugh Dickens <hughd@google.com>, Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, devel@driverdev.osuosl.org

On Tue, May 14, 2013 at 09:37:08AM -0700, Dan Magenheimer wrote:
> > From: Seth Jennings [mailto:sjenning@linux.vnet.ibm.com]
> > Subject: Re: [PATCHv11 3/4] zswap: add to mm/
> > 
> > On Tue, May 14, 2013 at 05:19:19PM +0800, Bob Liu wrote:
> > > Hi Seth,
> > 
> > Hi Bob, thanks for the review!
> > 
> > >
> > > > +	/* reclaim space if needed */
> > > > +	if (zswap_is_full()) {
> > > > +		zswap_pool_limit_hit++;
> > > > +		if (zbud_reclaim_page(tree->pool, 8)) {
> > >
> > > My idea is to wake up a kernel thread here to do the reclaim.
> > > Once zswap is full(20% percent of total mem currently), the kernel
> > > thread should reclaim pages from it. Not only reclaim one page, it
> > > should depend on the current memory pressure.
> > > And then the API in zbud may like this:
> > > zbud_reclaim_page(pool, nr_pages_to_reclaim, nr_retry);
> > 
> > So kswapd for zswap.  I'm not opposed to the idea if a case can be
> > made for the complexity.  I must say, I don't see that case though.
> > 
> > The policy can evolve as deficiencies are demonstrated and solutions are
> > found.
> 
> Hmmm... it is fairly easy to demonstrate the deficiency if
> one tries.  I actually first saw it occur on a real (though
> early) EL6 system which started some graphics-related service
> that caused a very brief swapstorm that was invisible during
> normal boot but clogged up RAM with compressed pages which
> later caused reduced weird benchmarking performance.

Without any specifics, I'm not sure what I can do with this.

I'm hearing you say that the source of the benchmark degradation
are the idle pages in zswap.  In that case, the periodic writeback
patches I have in the wings should address this.

I think we are on the same page without realizing it.  Right now
zswap supports a kind of "direct reclaim" model at allocation time.
The periodic writeback patches will handle the proactive writeback
part to free up the zswap pool when it has idle pages in it.

> 
> I think Mel's unpredictability concern applies equally here...
> this may be a "long-term source of bugs and strange memory
> management behavior."
> 
> > Can I get your ack on this pending the other changes?
> 
> I'd like to hear Mel's feedback about this, but perhaps
> a compromise to allow for zswap merging would be to add
> something like the following to zswap's Kconfig comment:
> 
> "Zswap reclaim policy is still primitive.  Until it improves,
> zswap should be considered experimental and is not recommended
> for production use."

Just for the record, an "experimental" tag in the Kconfig won't
work for me.

The reclaim policy for zswap is not primitive, it's simple.  There
is a difference.  Plus zswap is already runtime disabled by default.
If distros/customers enabled it, it is because they purposely
enabled it.

Seth

> 
> If Mel agrees with the unpredictability and also agrees
> with the Kconfig compromise, I am willing to ack.
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
