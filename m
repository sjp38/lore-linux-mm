Subject: Re: [PATCH]: Clean up of __alloc_pages
From: Rohit Seth <rohit.seth@intel.com>
In-Reply-To: <Pine.LNX.4.62.0510030828400.7812@schroedinger.engr.sgi.com>
References: <20051001120023.A10250@unix-os.sc.intel.com>
	 <Pine.LNX.4.62.0510030828400.7812@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 03 Oct 2005 09:55:58 -0700
Message-Id: <1128358558.8472.13.camel@akash.sc.intel.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2005-10-03 at 08:34 -0700, Christoph Lameter wrote:
> On Sat, 1 Oct 2005, Seth, Rohit wrote:
> 
> > -				goto zone_reclaim_retry;
> > -			}
> > +	if (order == 0) {
> > +		for (i = 0; (z = zones[i]) != NULL; i++) {
> > +			page = buffered_rmqueue(z, 0, gfp_mask, 0);
> > +			if (page) 
> > +				goto got_pg;
> >  		}
> > -
> 
> This is checking all zones for pages on the pcp before going the more 
> expensive route?
> 

That is right.

> Seems that this removes the logic intended to prefer local 
> allocations over remote pages present in the existing alloc_pages? There 
> is the danger that this modification will lead to the allocation of remote 
> pages even if local pages are available. Thus reducing performance.
> 

Good catch.  I will up level the cpuset check in buffered_rmqueue rather
then doing it in get_page_from_freelist.  That should retain the current
preferences for local pages.

> I would suggest to just check the first zone's pcp instead of all zones.
> 

Na. This for most cases will be ZONE_DMA pcp list having nothing much
most of the time.  And picking any other zone randomly will be exposed
to faulty behavior.

Thanks,
-rohit

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
