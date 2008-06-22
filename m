Date: Sun, 22 Jun 2008 18:07:05 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: 2.6.26-rc: nfsd hangs for a few sec
Message-ID: <20080622170704.GB625@csn.ul.ie>
References: <a4423d670806210557k1e8fcee1le3526f62962799e@mail.gmail.com> <20080621224135.GD4692@csn.ul.ie> <Pine.LNX.4.64.0806211711470.18719@schroedinger.engr.sgi.com> <20080622013801.GE4692@csn.ul.ie> <Pine.LNX.4.64.0806212107510.18908@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0806212107510.18908@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Alexander Beregalov <a.beregalov@gmail.com>, kernel-testers@vger.kernel.org, kernel list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, bfields@fieldses.org, neilb@suse.de, linux-nfs@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On (21/06/08 21:13), Christoph Lameter didst pronounce:
> On Sun, 22 Jun 2008, Mel Gorman wrote:
> 
> > > Before the change we walk all zones of the zonelist.
> > > 
> > 
> > Yeah, but the zonelist is for GFP_KERNEL so it should not include the HIGHMEM
> > zones, right? The key change is that after the patch there are fewer zonelists
> > than get filtered.
> 
> But the HIGHMEM zones etc were included before. There was no check for 
> HIGHMEM etc there. The gfpmask was ignored.
>  

Well, the mask is not totally ignored, it's part of the scan_control and
used later when deciding what can and can't be done as part of reclaim.
However, you are right in that it is apparently ignored for zone
selection.

However, try_to_free_pages() received a struct zone **zones which was
a zonelist which is a zonelist->zones selected based on the gfp_mask in
__alloc_pages. By the time shrink_zones() is called, it can ignore the
mask because only relevant zones are in there. For GFP_KERNEL, that would
exclude HIGHMEM.

> > I think the effect of that patch is that zones get shrunk that have
> > nothing to do with the requestors requirements. Right?
> 
> Right. AFAICT That was the behavior before the change.
> 


-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
