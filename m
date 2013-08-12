Return-Path: <owner-linux-mm@kvack.org>
Date: Sun, 11 Aug 2013 23:16:47 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: [RFC PATCH v2 0/4] mm: reclaim zbud pages on migration and compaction
Message-ID: <20130812031647.GB8043@kvack.org>
References: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com> <20130812022535.GA18832@bbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130812022535.GA18832@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Krzysztof Kozlowski <k.kozlowski@samsung.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, guz.fnst@cn.fujitsu.com

Hello Minchan,

On Mon, Aug 12, 2013 at 11:25:35AM +0900, Minchan Kim wrote:
> Hello,
> 
> On Fri, Aug 09, 2013 at 12:22:16PM +0200, Krzysztof Kozlowski wrote:
> > Hi,
> > 
> > Currently zbud pages are not movable and they cannot be allocated from CMA
> > region. These patches try to address the problem by:
> 
> The zcache, zram and GUP pages for memory-hotplug and/or CMA are
> same situation.
> 
> > 1. Adding a new form of reclaim of zbud pages.
> > 2. Reclaiming zbud pages during migration and compaction.
> > 3. Allocating zbud pages with __GFP_RECLAIMABLE flag.
> 
> So I'd like to solve it with general approach.
> 
> Each subsystem or GUP caller who want to pin pages long time should
> create own migration handler and register the page into pin-page
> control subsystem like this.
> 
> driver/foo.c
> 
> int foo_migrate(struct page *page, void *private);
> 
> static struct pin_page_owner foo_migrate = {
>         .migrate = foo_migrate;
> };
> 
> int foo_allocate()
> {
>         struct page *newpage = alloc_pages();
>         set_pinned_page(newpage, &foo_migrate);
> }
> 
> And in compaction.c or somewhere where want to move/reclaim the page,
> general VM can ask to owner if it founds it's pinned page.
> 
> mm/compaction.c
> 
>         if (PagePinned(page)) {
>                 struct pin_page_info *info = get_page_pin_info(page);
>                 info->migrate(page);
>                 
>         }
> 
> Only hurdle for that is that we should introduce a new page flag and
> I believe if we all agree this approch, we can find a solution at last.
> 
> What do you think?

I don't like this approach.  There will be too many collisions in the 
hash that's been implemented (read: I don't think you can get away with 
a naive implementation for core infrastructure that has to suite all 
users), you've got a global spin lock, and it doesn't take into account 
NUMA issues.  The address space migratepage method doesn't have those 
issues (at least where it is usable as in aio's use-case).

If you're going to go down this path, you'll have to decide if *all* users 
of pinned pages are going to have to subscribe to supporting the un-pinning 
of pages, and that means taking a real hard look at how O_DIRECT pins pages.  
Once you start thinking about that, you'll find that addressing the 
performance concerns is going to be an essential part of any design work to 
be done in this area.

		-ben
-- 
"Thought is the essence of where you are now."

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
