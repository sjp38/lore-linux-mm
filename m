Date: Mon, 3 Oct 2005 09:57:51 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH]: Clean up of __alloc_pages
In-Reply-To: <1128358558.8472.13.camel@akash.sc.intel.com>
Message-ID: <Pine.LNX.4.62.0510030952520.8266@schroedinger.engr.sgi.com>
References: <20051001120023.A10250@unix-os.sc.intel.com>
 <Pine.LNX.4.62.0510030828400.7812@schroedinger.engr.sgi.com>
 <1128358558.8472.13.camel@akash.sc.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rohit Seth <rohit.seth@intel.com>
Cc: akpm@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 3 Oct 2005, Rohit Seth wrote:

> > Seems that this removes the logic intended to prefer local 
> > allocations over remote pages present in the existing alloc_pages? There 
> > is the danger that this modification will lead to the allocation of remote 
> > pages even if local pages are available. Thus reducing performance.
> Good catch.  I will up level the cpuset check in buffered_rmqueue rather
> then doing it in get_page_from_freelist.  That should retain the current
> preferences for local pages.

This is not only the cpuset check. If there is memory available in an 
earlier zone then it needs to be taken regardless of later pcp's 
the zonelist containing pages. Otherwise we did not take the pages nearest 
to the requested node.

> > I would suggest to just check the first zone's pcp instead of all zones.
> > 
> 
> Na. This for most cases will be ZONE_DMA pcp list having nothing much
> most of the time.  And picking any other zone randomly will be exposed
> to faulty behavior.

Maybe only check the first node?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
