Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id E6CC16B0005
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 22:00:21 -0500 (EST)
Date: Mon, 25 Feb 2013 12:00:20 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: Better integration of compression with the broader linux-mm
Message-ID: <20130225030020.GC6498@blaptop>
References: <d7dec1e1-86fd-42b6-83c6-01340ece8d4a@default>
 <20130222004030.GI16950@blaptop>
 <5126C6B0.6080103@gmail.com>
 <20130222011918.GJ16950@blaptop>
 <5126C957.3070902@gmail.com>
 <20130222163815.GA14280@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130222163815.GA14280@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Konrad Wilk <konrad.wilk@oracle.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>

Hello,

On Fri, Feb 22, 2013 at 10:38:16AM -0600, Robert Jennings wrote:
> * Ric Mason (ric.masonn@gmail.com) wrote:
> > On 02/22/2013 09:19 AM, Minchan Kim wrote:
> > >On Fri, Feb 22, 2013 at 09:15:28AM +0800, Ric Mason wrote:
> > >>On 02/22/2013 08:40 AM, Minchan Kim wrote:
> > >>>On Thu, Feb 21, 2013 at 12:49:21PM -0800, Dan Magenheimer wrote:
> > >>>>Hi Mel, Rik, Hugh, Andrea --
> > >>>>
> > >>>>(Andrew and others also invited to read/comment!)
> > >>>>
> > >>>>In the last couple of years, I've had conversations or email
> > >>>>discussions with each of you which touched on a possibly
> > >>>>important future memory management policy topic.  After
> > >>>>giving it some deep thought, I wonder if I might beg for
> > >>>>a few moments of your time to think about it with me and
> > >>>>provide some feedback?
> > >>>>
> > >>>>There are now three projects that use in-kernel compression
> > >>>>to increase the amount of data that can be stored in RAM
> > >>>>(zram, zcache, and now zswap).  Each uses pages of data
> > >>>>"hooked" from the MM subsystem, compresses the pages of data
> > >>>>(into "zpages"), allocates pageframes from the MM subsystem,
> > >>>>and uses those allocated pageframes to store the zpages.
> > >>>>Other hooks decompress the data on demand back into pageframes.
> > >>>>Any pageframes containing zpages are managed by the
> > >>>>compression project code and, to the MM subsystem, the RAM
> > >>>>is just gone, the same as if the pageframes were absorbed
> > >>>>by a RAM-voracious device driver.
> > >>>>
> > >>>>Storing more data in RAM is generally a "good thing".
> > >>>>What may be a "bad thing", however, is that the MM
> > >>>>subsystem is losing control of a large fraction of the
> > >>>>RAM that it would otherwise be managing.  Since it
> > >>>>is MM's job to "load balance" different memory demands
> > >>>>on the kernel, compression may be positively improving
> > >>>>the efficiency of one class of memory while impairing
> > >>>>overall RAM "harmony" across the set of all classes.
> > >>>>(This is a question that, in some form, all of you
> > >>>>have asked me.)
> > >>>>
> > >>>>In short, the issue becomes: Is it possible to get the
> > >>>>"good thing" without the "bad thing"?  In other words,
> > >>>>is there a way to more closely integrate the management
> > >>>>of zpages along with the rest of RAM, and ensure that
> > >>>>MM is responsible for both?  And is it possible to do
> > >>>>this without a radical rewrite of MM, which would never
> > >>>>get merged?  And, if so... a question at the top of my
> > >>>>mind right now... how should this future integration
> > >>>>impact the design/redesign/merging of zram/zcache/zswap?
> > >>>>
> > >>>>So here's what I'm thinking...
> > >>>>
> > >>>>First, it's important to note that currently the only
> > >>>>two classes of memory that are "hooked" are clean
> > >>>>pagecache pages (by zcache only) and anonymous pages
> > >>>>(by all three).  There is potential that other classes
> > >>>>(dcache?) may be candidates for compression in the future
> > >>>>but let's ignore them for now.
> > >>>>
> > >>>>Both "file" pages and "anon" pages are currently
> > >>>>subdivided into "inactive" and "active" subclasses and
> > >>>>kswapd currently "load balances" the four subclasses:
> > >>>>file_active, file_inactive, anon_active, and anon_inactive.
> > >>>>
> > >>>>What I'm thinking is that compressed pages are really
> > >>>>just a third type of subclass, i.e. active, inactive,
> > >>>>and compressed ("very inactive").  However, since the
> > >>>>size of a zpage varies dramatically and unpredictably --
> > >>>>and thus so does the storage density -- the MM subsystem
> > >>>>should care NOT about the number of zpages, but the
> > >>>>number of pageframes currently being used to store zpages!
> > >>>>
> > >>>>So we want the MM subsystem to track and manage:
> > >>>>
> > >>>>1a) quantity of pageframes containing file_active pages
> > >>>>1b) quantity of pageframes containing file_inactive pages
> > >>>>1c) quantity of pageframes containing file_zpages
> > >>>>2a) quantity of pageframes containing anon_active pages
> > >>>>2b) quantity of pageframes containing anon_inactive pages
> > >>>>2c) quantity of pageframes containing anon_zpages
> > >>>>
> > >>>>For (1a/2a) and (1b/2b), of course, quantity of pageframes
> > >>>>is exactly the same as the number of pages, and the
> > >>>>kernel already tracks and manages these.  For (1c/2c)
> > >>>>however, MM only need care about the number of pageframes, not
> > >>>>the number of zpages.  It is the MM-compression sub-subsystem's
> > >>>>responsibility to take direction from the MM subsystem as
> > >>>>to the total number of pageframes it uses... how (and how
> > >>>>efficiently) it stores zpages in that number of pageframes
> > >>>>is its own business.  If MM tells MM-compression to
> > >>>>reduce "quantity of pageframes containing anon_zpages"
> > >>>>it must be able to do that.
> > >>>>
> > >>>>OK, does that make sense?  If so, I have thoughts on
> > >>>I think that's a good idea.
> > >>>MM can give general API like alloc_pages(GFP_ZSPAGE) and put together
> > >>>sub pages of zspage into LRU_[FILE|ANON]_ZPAGES which would be
> > >>>zone/node aware as well as system-wide LRU.
> > >>>
> > >>>Each sub pages could have a function pointer in struct page somewhere.
> > >>>which would be each MM-compression subsystem's reclaim function.
> > >>>So MM can ask to MM-compression subsystem to reclaim the page
> > >>>when needs happens.
> > >>Why need function pointer in struct page? Since zspages are on
> > >>LRU_[FILE|ANON]_ZPAGES, page reclaim subsystem call reclaim them
> > >>directly.
> > >It would be a subpage of zspage and zspage format might be different in each
> > >MM-compression subsystem so MM layter can't reclaim them without helping from
> > >MM-compression subsytsem, IMHO.
> > 
> > Thanks for your clarify. Also I think zspages result in memory can't
> > hotplug.
> 
> There is an isolation notifier chain which could be used.  It allows
> users of non-migratable pages to free memory for hotplug.  It was added
> in commit 925cc71 (see description there) and moved to current location
> by commit ee6f509.
> 
> This improves the chances for memory hotplug removal and where possible
> users of non-migratable pages should employ this notifier.  There's no
> guanantee that memory can be removed because a section which has
> non-migratable pages may have some pages that are not covered by an
> isolation notifier.
> 
> The notifier tries to account for all non-migratable pages through the
> memory_isolate_chain.  If that is sucessful it is expected that those
> pages will be freed later through the memory notifier chain and removal
> contines for that section.

It would be a solution in short-term but I think we need more fundamental
one without notifier call chain which works only for memory-hotplug.
I mean higher order page allocation with compaction should work with z*
families so for it, new ezreclaimable LRU and compaction awareneess would
be good.

> 

> --Rob Jennings
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
