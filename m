Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 83D646B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 07:09:31 -0400 (EDT)
Date: Thu, 14 Mar 2013 12:09:27 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2] mm/hugetlb: fix total hugetlbfs pages count when
 memory overcommit accouting
Message-ID: <20130314110927.GC11631@dhcp22.suse.cz>
References: <1363258189-24945-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363258189-24945-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 14-03-13 18:49:49, Wanpeng Li wrote:
> Changelog:
>  v1 -> v2:
>   * update patch description, spotted by Michal
> 
> hugetlb_total_pages() does not account for all the supported hugepage
> sizes.

> This can lead to incorrect calculation of the total number of
> page frames used by hugetlb. This patch corrects the issue.

Sorry to be so picky but this doesn't tell us much. Why do we need to
have the total number of hugetlb pages?

What about the following:
"hugetlb_total_pages is used for overcommit calculations but the
current implementation considers only default hugetlb page size (which
is either the first defined hugepage size or the one specified by
default_hugepagesz kernel boot parameter).

If the system is configured for more than one hugepage size (which is
possible since a137e1cc hugetlbfs: per mount huge page sizes) then
the overcommit estimation done by __vm_enough_memory (resp. shown by
meminfo_proc_show) is not precise - there is an impression of more
available/allowed memory. This can lead to an unexpected ENOMEM/EFAULT
resp. SIGSEGV when memory is accounted."

I think this is also worth pushing to the stable tree (it goes back to
2.6.27)

> Testcase:
> boot: hugepagesz=1G hugepages=1
> before patch:
> egrep 'CommitLimit' /proc/meminfo
> CommitLimit:     55434168 kB
> after patch:
> egrep 'CommitLimit' /proc/meminfo
> CommitLimit:     54909880 kB

This gives some more confusion to a reader because there is only
something like 500M difference here without any explanation.

> 
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> ---
>  mm/hugetlb.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index cdb64e4..9e25040 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2124,8 +2124,11 @@ int hugetlb_report_node_meminfo(int nid, char *buf)
>  /* Return the number pages of memory we physically have, in PAGE_SIZE units. */
>  unsigned long hugetlb_total_pages(void)
>  {
> -	struct hstate *h = &default_hstate;
> -	return h->nr_huge_pages * pages_per_huge_page(h);
> +	struct hstate *h;
> +	unsigned long nr_total_pages = 0;
> +	for_each_hstate(h)
> +		nr_total_pages += h->nr_huge_pages * pages_per_huge_page(h);
> +	return nr_total_pages;
>  }
>  
>  static int hugetlb_acct_memory(struct hstate *h, long delta)
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
