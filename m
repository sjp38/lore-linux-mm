Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 2CE2A6B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 04:02:04 -0400 (EDT)
Received: by mail-oa0-f41.google.com with SMTP id i10so761532oag.28
        for <linux-mm@kvack.org>; Wed, 13 Mar 2013 01:02:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1363158511-21272-1-git-send-email-liwanp@linux.vnet.ibm.com>
References: <1363158511-21272-1-git-send-email-liwanp@linux.vnet.ibm.com>
Date: Wed, 13 Mar 2013 16:02:03 +0800
Message-ID: <CAJd=RBBVU8uvHZ3AHkBqOWe-hEqFQ5-5Mf5dGXYuGczvM6EpUw@mail.gmail.com>
Subject: Re: [PATCH] mm/hugetlb: fix total hugetlbfs pages count when memory
 overcommit accouting
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>

[cc Andi]
On Wed, Mar 13, 2013 at 3:08 PM, Wanpeng Li <liwanp@linux.vnet.ibm.com> wrote:
> After commit 42d7395f ("mm: support more pagesizes for MAP_HUGETLB/SHM_HUGETLB")
> be merged, kernel permit multiple huge page sizes, and when the system administrator
> has configured the system to provide huge page pools of different sizes, application
> can choose the page size used for their allocation. However, just default size of
> huge page pool is statistical when memory overcommit accouting, the bad is that this
> will result in innocent processes be killed by oom-killer later. Fix it by statistic
> all huge page pools of different sizes provided by administrator.
>
Can we enrich the output of hugetlb_report_meminfo() ?

thanks
Hillf

> Testcase:
> boot: hugepagesz=1G hugepages=1
> before patch:
> egrep 'CommitLimit' /proc/meminfo
> CommitLimit:     55434168 kB
> after patch:
> egrep 'CommitLimit' /proc/meminfo
> CommitLimit:     54909880 kB
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
> -       struct hstate *h = &default_hstate;
> -       return h->nr_huge_pages * pages_per_huge_page(h);
> +       struct hstate *h;
> +       unsigned long nr_total_pages = 0;
> +       for_each_hstate(h)
> +               nr_total_pages += h->nr_huge_pages * pages_per_huge_page(h);
> +       return nr_total_pages;
>  }
>
>  static int hugetlb_acct_memory(struct hstate *h, long delta)
> --
> 1.7.11.7
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
