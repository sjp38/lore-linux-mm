Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 900DE6B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 22:42:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 1BA923EE0BD
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:42:49 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 01FBE45DE55
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:42:49 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id DC9AD45DE50
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:42:48 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C3F221DB803A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:42:48 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A3BE08001
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:42:48 +0900 (JST)
Message-ID: <4F669CC3.9070007@jp.fujitsu.com>
Date: Mon, 19 Mar 2012 11:41:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V4 05/10] hugetlb: add charge/uncharge calls for HugeTLB
 alloc/free
References: <1331919570-2264-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1331919570-2264-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1331919570-2264-6-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mgorman@suse.de, dhillf@gmail.com, aarcange@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/03/17 2:39), Aneesh Kumar K.V wrote:

> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> This adds necessary charge/uncharge calls in the HugeTLB code
> 
> Acked-by: Hillf Danton <dhillf@gmail.com>
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>


Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
A nitpick below.

> ---
>  mm/hugetlb.c    |   21 ++++++++++++++++++++-
>  mm/memcontrol.c |    5 +++++
>  2 files changed, 25 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index c672187..91361a0 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -21,6 +21,8 @@
>  #include <linux/rmap.h>
>  #include <linux/swap.h>
>  #include <linux/swapops.h>
> +#include <linux/memcontrol.h>
> +#include <linux/page_cgroup.h>
>  
>  #include <asm/page.h>
>  #include <asm/pgtable.h>
> @@ -542,6 +544,9 @@ static void free_huge_page(struct page *page)
>  	BUG_ON(page_mapcount(page));
>  	INIT_LIST_HEAD(&page->lru);
>  
> +	if (mapping)
> +		mem_cgroup_hugetlb_uncharge_page(hstate_index(h),
> +						 pages_per_huge_page(h), page);
>  	spin_lock(&hugetlb_lock);
>  	if (h->surplus_huge_pages_node[nid] && huge_page_order(h) < MAX_ORDER) {
>  		update_and_free_page(h, page);
> @@ -1019,12 +1024,15 @@ static void vma_commit_reservation(struct hstate *h,
>  static struct page *alloc_huge_page(struct vm_area_struct *vma,
>  				    unsigned long addr, int avoid_reserve)
>  {
> +	int ret, idx;
>  	struct hstate *h = hstate_vma(vma);
>  	struct page *page;
> +	struct mem_cgroup *memcg = NULL;


Can't we this initialization in mem_cgroup_hugetlb_charge_page() ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
