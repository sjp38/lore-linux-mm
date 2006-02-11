Date: Sat, 11 Feb 2006 13:13:24 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: Get rid of scan_control
Message-Id: <20060211131324.63d49cff.akpm@osdl.org>
In-Reply-To: <Pine.LNX.4.62.0602111054520.24060@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.62.0602092039230.13184@schroedinger.engr.sgi.com>
	<20060211045355.GA3318@dmt.cnet>
	<20060211013255.20832152.akpm@osdl.org>
	<Pine.LNX.4.62.0602111054520.24060@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: marcelo.tosatti@cyclades.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <clameter@engr.sgi.com> wrote:
>
> On Sat, 11 Feb 2006, Andrew Morton wrote:
> 
> > > But refill_inactive_list() is not used for swapping only. All evicted 
> > > pages go through that path - it can be _very_ hot.
> > 
> > A bit hot.  I guess it's worth fixing.
> 
> There is another issue of the anon_vma lock getting very hot during 
> zone_reclaim() because refill_inactive_list calls page_referenced(). So 
> does shrink_list(). zone_reclaim is only interested in unmapped pages and 
> thus checking for references is useless.
> 
> > scan_control was modelled on writeback_control.  But writeback_control
> > works, and scan_control doesn't.  I think this is because a)
> > writeback_control instances are always initialised at the declaration site
> > and b) writeback_control is just a lot simpler.
> 
> The zoned counter patchset eliminates at least the wbs structure.

Does that refer to writeback_state?

> Patch to fix the calling of page_referenced() follows. This is against 
> 2.6.16-rc2. We probably need another patch for current mm. In the case
> of VMSCAN_MAY_SWAP not set, we may just want to bypass the whole 
> calculation thing for reclaim_mapped.
> 

What's VMSCAN_MAY_SWAP?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
