From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: mm-more-likely-reclaim-madv_sequential-mappings.patch
Date: Fri, 17 Oct 2008 00:43:26 +1100
References: <20081015162232.f673fa59.akpm@linux-foundation.org>
In-Reply-To: <20081015162232.f673fa59.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200810170043.26922.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Johannes Weiner <hannes@saeurebad.de>
List-ID: <linux-mm.kvack.org>

On Thursday 16 October 2008 10:22, Andrew Morton wrote:
> I have a note here that this patch needs better justification.  But the
> changelog looks good and there are pretty graphs, so maybe my note is
> stale.

I think I was hoping for our VM to generically not be quite so stupid about
use-once access patterns and not behave so badly without this. But easier
said than done, and now I see the graphs show this is a fairly reasonable
change. One thing...

>
> Can people please check it?
>
> Thanks.
>
>
>
>
> From: Johannes Weiner <hannes@saeurebad.de>
>
> File pages accessed only once through sequential-read mappings between
> fault and scan time are perfect candidates for reclaim.
>
> This patch makes page_referenced() ignore these singular references and
> the pages stay on the inactive list where they likely fall victim to the
> next reclaim phase.
>
> Already activated pages are still treated normally.  If they were accessed
> multiple times and therefor promoted to the active list, we probably want
> to keep them.
>
> Benchmarks show that big (relative to the system's memory) MADV_SEQUENTIAL
> mappings read sequentially cause much less kernel activity.  Especially
> less LRU moving-around because we never activate read-once pages in the
> first place just to demote them again.
>
> And leaving these perfect reclaim candidates on the inactive list makes
> it more likely for the real working set to survive the next reclaim
> scan.
>
> Benchmark graphs and the test-application can be found here:
>
> 	http://hannes.saeurebad.de/madvseq/
>
> Signed-off-by: Johannes Weiner <hannes@saeurebad.de>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Cc: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
>
>  mm/rmap.c |   20 +++++++++++++++-----
>  1 file changed, 15 insertions(+), 5 deletions(-)
>
> diff -puN mm/rmap.c~mm-more-likely-reclaim-madv_sequential-mappings
> mm/rmap.c --- a/mm/rmap.c~mm-more-likely-reclaim-madv_sequential-mappings
> +++ a/mm/rmap.c
> @@ -327,8 +327,18 @@ static int page_referenced_one(struct pa
>  		goto out_unmap;
>  	}
>
> -	if (ptep_clear_flush_young_notify(vma, address, pte))
> -		referenced++;
> +	if (ptep_clear_flush_young_notify(vma, address, pte)) {
> +		/*
> +		 * If there was just one sequential access to the
> +		 * page, ignore it.  Otherwise, mark_page_accessed()
> +		 * will have promoted the page to the active list and
> +		 * it should be kept.
> +		 */
> +		if (VM_SequentialReadHint(vma) && !PageActive(page))
> +			ClearPageReferenced(page);
> +		else
> +			referenced++;
> +	}

ClearPageReferenced I don't know if it should be cleared like this.
PageReferenced is more of a bit for the mark_page_accessed state machine,
rather than the pte_young stuff. Although when unmapping, the latter
somewhat collapses back to the former, but I don't know if there is a
very good reason to fiddle with it here.

Ignoring the young bit in the pte for sequential hint maybe is OK (and
seems to be effective as per the benchmarks). But I would prefer not to
merge the PageReferenced parts unless they get their own justification.

So I'm happy with the ignoring pte_young part of the patch.


BTW. it seems like zap_pte_range should do a mark_page_accessed(), because
setting PG_accessed alone is quite a weak hint to reclaim... I don't think
it makes sense for mmap(), touch, munmap() access to arbitrarily be worth
less than a read(2).

I guess I should test and submit the patch...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
