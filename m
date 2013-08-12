Return-Path: <owner-linux-mm@kvack.org>
Date: Mon, 12 Aug 2013 11:25:35 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC PATCH v2 0/4] mm: reclaim zbud pages on migration and
 compaction
Message-ID: <20130812022535.GA18832@bbox>
References: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1376043740-10576-1-git-send-email-k.kozlowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Krzysztof Kozlowski <k.kozlowski@samsung.com>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Kyungmin Park <kyungmin.park@samsung.com>, Dave Hansen <dave.hansen@intel.com>, guz.fnst@cn.fujitsu.com, bcrl@kvack.org

Hello,

On Fri, Aug 09, 2013 at 12:22:16PM +0200, Krzysztof Kozlowski wrote:
> Hi,
> 
> Currently zbud pages are not movable and they cannot be allocated from CMA
> region. These patches try to address the problem by:

The zcache, zram and GUP pages for memory-hotplug and/or CMA are
same situation.

> 1. Adding a new form of reclaim of zbud pages.
> 2. Reclaiming zbud pages during migration and compaction.
> 3. Allocating zbud pages with __GFP_RECLAIMABLE flag.

So I'd like to solve it with general approach.

Each subsystem or GUP caller who want to pin pages long time should
create own migration handler and register the page into pin-page
control subsystem like this.

driver/foo.c

int foo_migrate(struct page *page, void *private);

static struct pin_page_owner foo_migrate = {
        .migrate = foo_migrate;
};

int foo_allocate()
{
        struct page *newpage = alloc_pages();
        set_pinned_page(newpage, &foo_migrate);
}

And in compaction.c or somewhere where want to move/reclaim the page,
general VM can ask to owner if it founds it's pinned page.

mm/compaction.c

        if (PagePinned(page)) {
                struct pin_page_info *info = get_page_pin_info(page);
                info->migrate(page);
                
        }

Only hurdle for that is that we should introduce a new page flag and
I believe if we all agree this approch, we can find a solution at last.

What do you think?
