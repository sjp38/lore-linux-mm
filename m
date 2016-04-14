From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH 01/10] mm: update_lru_size warn and reset bad lru_size
Date: Thu, 14 Apr 2016 13:56:41 +0200
Message-ID: <570F8579.2070201@suse.cz>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
 <alpine.LSU.2.11.1604051337450.5965@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.11.1604051337450.5965@eggly.anvils>
Sender: linux-kernel-owner@vger.kernel.org
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov@virtuozzo.com>
List-Id: linux-mm.kvack.org

On 04/05/2016 10:40 PM, Hugh Dickins wrote:
> Though debug kernels have a VM_BUG_ON to help protect from misaccounting
> lru_size, non-debug kernels are liable to wrap it around: and then the
> vast unsigned long size draws page reclaim into a loop of repeatedly
> doing nothing on an empty list, without even a cond_resched().
>
> That soft lockup looks confusingly like an over-busy reclaim scenario,
> with lots of contention on the lru_lock in shrink_inactive_list():
> yet has a totally different origin.
>
> Help differentiate with a custom warning in mem_cgroup_update_lru_size(),
> even in non-debug kernels; and reset the size to avoid the lockup.  But
> the particular bug which suggested this change was mine alone, and since
> fixed.

In my opinion, the code now looks quite complicated, not sure it's a good 
tradeoff for a rare (?) development bug. But I guess it's up to memcg 
maintainers which I note are not explicitly CC'd, so adding them now.

Maybe more generally, we can discuss in LSF/MM's mm debugging session, what it 
means that DEBUG_VM check has to become unconditional. Does it mean insufficient 
testing with DEBUG_VM during development/integration phase? Or are some bugs so 
rare we can't depend on that phase to catch them? IIRC Fedora kernels are built 
with DEBUG_VM, unless that changed...

> Make it a WARN_ONCE: the first occurrence is the most informative, a
> flurry may follow, yet even when rate-limited little more is learnt.
>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>   include/linux/mm_inline.h |    2 +-
>   mm/memcontrol.c           |   24 ++++++++++++++++++++----
>   2 files changed, 21 insertions(+), 5 deletions(-)
>
> --- a/include/linux/mm_inline.h
> +++ b/include/linux/mm_inline.h
> @@ -35,8 +35,8 @@ static __always_inline void del_page_fro
>   				struct lruvec *lruvec, enum lru_list lru)
>   {
>   	int nr_pages = hpage_nr_pages(page);
> -	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
>   	list_del(&page->lru);
> +	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
>   	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
>   }
>
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1022,22 +1022,38 @@ out:
>    * @lru: index of lru list the page is sitting on
>    * @nr_pages: positive when adding or negative when removing
>    *
> - * This function must be called when a page is added to or removed from an
> - * lru list.
> + * This function must be called under lru_lock, just before a page is added
> + * to or just after a page is removed from an lru list (that ordering being
> + * so as to allow it to check that lru_size 0 is consistent with list_empty).
>    */
>   void mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
>   				int nr_pages)
>   {
>   	struct mem_cgroup_per_zone *mz;
>   	unsigned long *lru_size;
> +	long size;
> +	bool empty;

Could there be more descriptive names? lru_size vs size looks confusing.

>
>   	if (mem_cgroup_disabled())
>   		return;
>
>   	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
>   	lru_size = mz->lru_size + lru;
> -	*lru_size += nr_pages;
> -	VM_BUG_ON((long)(*lru_size) < 0);
> +	empty = list_empty(lruvec->lists + lru);
> +
> +	if (nr_pages < 0)
> +		*lru_size += nr_pages;
> +
> +	size = *lru_size;
> +	if (WARN_ONCE(size < 0 || empty != !size,

Maybe I'm just not used enough to constructs like "empty != !size", but it 
really takes me longer than I'd like to get the meaning :(

> +		"%s(%p, %d, %d): lru_size %ld but %sempty\n",
> +		__func__, lruvec, lru, nr_pages, size, empty ? "" : "not ")) {
> +		VM_BUG_ON(1);
> +		*lru_size = 0;
> +	}
> +
> +	if (nr_pages > 0)
> +		*lru_size += nr_pages;
>   }
>
>   bool task_in_mem_cgroup(struct task_struct *task, struct mem_cgroup *memcg)
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
