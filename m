Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id A6E996B0005
	for <linux-mm@kvack.org>; Thu, 10 Mar 2016 04:54:01 -0500 (EST)
Received: by mail-wm0-f42.google.com with SMTP id p65so20987317wmp.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 01:54:01 -0800 (PST)
Received: from mail-wm0-x22d.google.com (mail-wm0-x22d.google.com. [2a00:1450:400c:c09::22d])
        by mx.google.com with ESMTPS id e67si3667674wme.27.2016.03.10.01.54.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Mar 2016 01:54:00 -0800 (PST)
Received: by mail-wm0-x22d.google.com with SMTP id l68so22031678wml.0
        for <linux-mm@kvack.org>; Thu, 10 Mar 2016 01:54:00 -0800 (PST)
Date: Thu, 10 Mar 2016 12:53:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: avoid unnecessary swapin in khugepaged
Message-ID: <20160310095358.GA25372@node.shutemov.name>
References: <1457560543-15910-1-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1457560543-15910-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com

On Wed, Mar 09, 2016 at 11:55:43PM +0200, Ebru Akagunduz wrote:
> Currently khugepaged makes swapin readahead to improve
> THP collapse rate. This patch checks vm statistics
> to avoid workload of swapin, if unnecessary. So that
> when system under pressure, khugepaged won't consume
> resources to swapin.
> 
> The patch was tested with a test program that allocates
> 800MB of memory, writes to it, and then sleeps. The system
> was forced to swap out all. Afterwards, the test program
> touches the area by writing, it skips a page in each
> 20 pages of the area. When waiting to swapin readahead
> left part of the test, the memory forced to be busy
> doing page reclaim. There was enough free memory during
> test, khugepaged did not swapin readahead due to business.
> 
> Test results:
> 
> 			After swapped out
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 450964 kB |  450560 kB    | 349036 kB |    %99    |
> -------------------------------------------------------------------
> Without patch | 351308 kB | 350208 kB     | 448692 kB |    %99    |
> -------------------------------------------------------------------
> 
>                         After swapped in (waiting 10 minutes)
> -------------------------------------------------------------------
>               | Anonymous | AnonHugePages | Swap      | Fraction  |
> -------------------------------------------------------------------
> With patch    | 637932 kB | 559104 kB     | 162068 kB |    %69    |
> -------------------------------------------------------------------
> Without patch | 586816 kB | 464896 kB     | 213184 kB |    %79    |
> -------------------------------------------------------------------
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>
> ---
>  mm/huge_memory.c | 15 ++++++++++++++-
>  1 file changed, 14 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7f75292..109a2af 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -102,6 +102,7 @@ static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
>   */
>  static unsigned int khugepaged_max_ptes_none __read_mostly;
>  static unsigned int khugepaged_max_ptes_swap __read_mostly;
> +static unsigned long int allocstall = 0;
>  
>  static int khugepaged(void *none);
>  static int khugepaged_slab_init(void);
> @@ -2411,6 +2412,7 @@ static void collapse_huge_page(struct mm_struct *mm,
>  	struct mem_cgroup *memcg;
>  	unsigned long mmun_start;	/* For mmu_notifiers */
>  	unsigned long mmun_end;		/* For mmu_notifiers */
> +	unsigned long events[NR_VM_EVENT_ITEMS], swap = 0;

collapse_huge_page() is nested under collapse_huge_page(), so you
effectively allocate 2 * NR_VM_EVENT_ITEMS * sizeof(long) on stack.
That's a lot for stack. And it's only get total value of ALLOCSTALL event.

Should we instead introduce a helper to sum values of a particular event
over all cpu? I'm surprised that we don't have any yet.

Something like this (totally untested):

unsigned long sum_vm_event(enum vm_event_item item)
{
	int cpu;
	unsigned long ret = 0;

	get_online_cpus();
	for_each_online_cpu(cpu)
		ret += per_cpu(vm_event_states, cpu).event[item];
	put_online_cpus();
	return ret;
}

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
