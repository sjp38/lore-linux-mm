Subject: Re: [RFC 0/7] Postphone reclaim laundry to write at high water
	marks
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20070820215040.937296148@sgi.com>
References: <20070820215040.937296148@sgi.com>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 12:36:26 +0200
Message-Id: <1187692586.6114.211.camel@twins>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, 2007-08-20 at 14:50 -0700, Christoph Lameter wrote:
> One of the problems with reclaim writeout is that it occurs when memory in a
> zone is low. A particular bad problem can occur if memory in a zone is
> already low and now the first page that we encounter during reclaim is dirty.
> So the writeout function is called without the filesystem or device having
> much of a reserve that would allow further allocations. Triggering writeout
> of dirty pages early does not improve the memory situation since the actual
> writeout of the page is a relatively long process. The call to writepage
> will therefore not improve the low memory situation but make it worse
> because extra memory may be needed to get the device to write the page.
> 
> This patchset fixes that issue by:
> 
> 1. First reclaiming non dirty pages. Dirty pages are deferred until reclaim
>    has reestablished the high marks. Then all the dirty pages (the laundry)
>    is written out.
> 
> 2. Reclaim is essentially complete during the writeout phase. So we remove
>    PF_MEMALLOC and allow recursive reclaim if we still run into trouble
>    during writeout.

This almost insta-OOMs with anonymous workloads.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
