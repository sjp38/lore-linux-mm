Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id D62076B0006
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 09:04:51 -0400 (EDT)
Date: Thu, 14 Mar 2013 14:04:49 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3] mm/hugetlb: fix total hugetlbfs pages count when
 memory overcommit accouting
Message-ID: <20130314130449.GE11631@dhcp22.suse.cz>
References: <1363260646-26896-1-git-send-email-liwanp@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1363260646-26896-1-git-send-email-liwanp@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 14-03-13 19:30:46, Wanpeng Li wrote:
> Changelog:
>  v2 -> v3:
>   * update patch description, spotted by Michal
>  v1 -> v2:
>   * update patch description, spotted by Michal
> 
> "hugetlb_total_pages is used for overcommit calculations but the
> current implementation considers only default hugetlb page size (which
> is either the first defined hugepage size or the one specified by
> default_hugepagesz kernel boot parameter).
> 
> If the system is configured for more than one hugepage size (which is
> possible since a137e1cc hugetlbfs: per mount huge page sizes) then
> the overcommit estimation done by __vm_enough_memory (resp. shown by
> meminfo_proc_show) is not precise - there is an impression of more
> available/allowed memory. This can lead to an unexpected ENOMEM/EFAULT
> resp. SIGSEGV when memory is accounted."

Any reason for keeping the quotes I put in the previous email just to
show what changelog I had in mind?
 
> The patch should also push to 2.6.27 stable tree.

There are no such trees, I have mentioned that only to point out which
kernels are affected.

> 
> Testcase:
> boot: hugepagesz=1G hugepages=1
> the default overcommit ratio is 50
> before patch:
> egrep 'CommitLimit' /proc/meminfo
> CommitLimit:     55434168 kB
> after patch:
> egrep 'CommitLimit' /proc/meminfo
> CommitLimit:     54909880 kB
>

Is this information useful at all?

Cc: <stable@vger.kernel.org> # 3.0+
please

> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

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
