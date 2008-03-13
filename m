Date: Thu, 13 Mar 2008 11:22:33 +0000
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH] hugetlb: vmstat events for huge page allocations v2
Message-ID: <20080313112224.GA1210@shadowen.org>
References: <1205354686.7191.9.camel@grover.beaverton.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1205354686.7191.9.camel@grover.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eric B Munson <ebmunson@us.ibm.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Mar 12, 2008 at 01:44:46PM -0700, Eric B Munson wrote:
> Changed from v1: fixed whitespace mangling.
> 
> From: Adam Litke <agl@us.ibm.com>
> 
> Allocating huge pages directly from the buddy allocator is not guaranteed
> to succeed.  Success depends on several factors (such as the amount of
> physical memory available and the level of fragmentation).  With the
> addition of dynamic hugetlb pool resizing, allocations can occur much more
> frequently.  For these reasons it is desirable to keep track of huge page
> allocation successes and failures.
> 
> Add two new vmstat entries to track huge page allocations that succeed and
> fail.  The presence of the two entries is contingent upon
> CONFIG_HUGETLB_PAGE being enabled.
> 
> This patch was created against linux-2.6.25-rc5
> 
> Signed-off-by: Adam Litke <agl@us.ibm.com>
> Signed-off-by: Eric Munson <ebmunson@us.ibm.com>
> 
> ---
> 
>  include/linux/vmstat.h |    4 +++-
>  mm/hugetlb.c           |    7 +++++++
>  mm/vmstat.c            |    2 ++
>  3 files changed, 12 insertions(+), 1 deletions(-)
> 
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index 9f1b4b4..70f6861 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -27,6 +27,8 @@
> 
>  #define FOR_ALL_ZONES(xx) DMA_ZONE(xx) DMA32_ZONE(xx) xx##_NORMAL HIGHMEM_ZONE(xx) , xx##_MOVABLE
> 
> +#define HTLB_STATS     HTLB_ALLOC_SUCCESS, HTLB_ALLOC_FAIL
> +

Looking at where we are incrementing these, these are success and failures
allocating pages from the buddy into the hugetlb pool.  From the names
I had assumed they were success/failure allocating to userspace out of
the pool.  As we might at some point want to count allocations on that side
of the pool too, I think we should be very careful about the naming and in
particular be explicit that these are buddy fill events you are counting.

If I was adding events for the events from the consumer side of the huge
page pool I would think prefixing the normal names with HTLB_ would make
sense, so that would "consume" HTLB_PGALLOC, and HTLB_PGFREE.  As these
are success and failures allocating from the buddy into the hugetlb pool
perhaps they should contain buddy in their name.  HTLB_BUDDY_PGALLOC,
and HTLB_BUDDY_PGALLOC_FAIL perhaps?

While discussing what these stats meant I realised that I has started
out assuming these would be stats for fill operators relating to the
dynamic pool resize operations.  Clearly tracking success rates for that
is helpful, as those operations occur "transparently" in the backgroud.
I worry that including the normal fills for manual resizes might pollute
those figures.  I wonder if what we really want is HTLB_DYNRESIZE_PGALLOC
etc.

Finally should these be conditionally compiled under CONFIG_HUGETLBFS or
similar, the leader says it is, but I do not see anything making it so.
There is precident in this file for useless entries being elided based on
config options.  The NUMA options are only present when NUMA is enabled
for example.

>  enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> 		FOR_ALL_ZONES(PGALLOC),
> 		PGFREE, PGACTIVATE, PGDEACTIVATE,
> @@ -36,7 +38,7 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
> 		FOR_ALL_ZONES(PGSCAN_KSWAPD),
> 		FOR_ALL_ZONES(PGSCAN_DIRECT),
> 		PGINODESTEAL, SLABS_SCANNED, KSWAPD_STEAL, KSWAPD_INODESTEAL,
> -		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
> +		PAGEOUTRUN, ALLOCSTALL, PGROTATED, HTLB_STATS,
> 		NR_VM_EVENT_ITEMS
>  };
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index dcacc81..1507697 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -239,6 +239,11 @@ static int alloc_fresh_huge_page(void)
> 		hugetlb_next_nid = next_nid;
> 	} while (!page && hugetlb_next_nid != start_nid);
> 
> +	if (ret)
> +		count_vm_event(HTLB_ALLOC_SUCCESS);
> +	else
> +		count_vm_event(HTLB_ALLOC_FAIL);
> +

This is tracking the static pool changes.  So if we only wanted the
dynamic ones this would not be needed.

> 	return ret;
>  }
> 
> @@ -293,9 +298,11 @@ static struct page *alloc_buddy_huge_page(struct vm_area_struct *vma,
> 		 */
> 		nr_huge_pages_node[nid]++;
> 		surplus_huge_pages_node[nid]++;
> +		count_vm_event(HTLB_ALLOC_SUCCESS);
> 	} else {
> 		nr_huge_pages--;
> 		surplus_huge_pages--;
> +		count_vm_event(HTLB_ALLOC_FAIL);

These two here are inside a spinlock, and those disable preempt by
definition.  So I believe you should use the __count_vm_event interfaces
for these.

> 	}
> 	spin_unlock(&hugetlb_lock);
> 
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 422d960..045a8d7 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -644,6 +644,8 @@ static const char * const vmstat_text[] = {
> 	"allocstall",
> 
> 	"pgrotated",
> +	"htlb_alloc_success",
> +	"htlb_alloc_fail",
>  #endif
>  };

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
