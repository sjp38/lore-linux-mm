Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id A75B16B004D
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 03:54:21 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 838123EE0BD
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:54:19 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6693845DE5E
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:54:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 473BA45DE54
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:54:19 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 329381DB8054
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:54:19 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DDEC51DB8048
	for <linux-mm@kvack.org>; Tue, 12 Jun 2012 16:54:18 +0900 (JST)
Message-ID: <4FD6F530.6050603@jp.fujitsu.com>
Date: Tue, 12 Jun 2012 16:52:16 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH -V8 10/16] hugetlb/cgroup: Add the cgroup pointer to page
 lru
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
In-Reply-To: <1339232401-14392-11-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

(2012/06/09 17:59), Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V"<aneesh.kumar@linux.vnet.ibm.com>
> 
> Add the hugetlb cgroup pointer to 3rd page lru.next. This limit
> the usage to hugetlb cgroup to only hugepages with 3 or more
> normal pages. I guess that is an acceptable limitation.
> 
> Signed-off-by: Aneesh Kumar K.V<aneesh.kumar@linux.vnet.ibm.com>
> ---
>   include/linux/hugetlb_cgroup.h |   31 +++++++++++++++++++++++++++++++
>   mm/hugetlb.c                   |    4 ++++
>   2 files changed, 35 insertions(+)
> 
> diff --git a/include/linux/hugetlb_cgroup.h b/include/linux/hugetlb_cgroup.h
> index 5794be4..ceff1d5 100644
> --- a/include/linux/hugetlb_cgroup.h
> +++ b/include/linux/hugetlb_cgroup.h
> @@ -26,6 +26,26 @@ struct hugetlb_cgroup {
>   };
> 
>   #ifdef CONFIG_CGROUP_HUGETLB_RES_CTLR
> +static inline struct hugetlb_cgroup *hugetlb_cgroup_from_page(struct page *page)
> +{
> +	if (!PageHuge(page))
> +		return NULL;

I'm not very sure but....

	VM_BUG_ON(!PageHuge(page)) ??



> +	if (compound_order(page)<  3)
> +		return NULL;
> +	return (struct hugetlb_cgroup *)page[2].lru.next;
> +}
> +
> +static inline
> +int set_hugetlb_cgroup(struct page *page, struct hugetlb_cgroup *h_cg)
> +{
> +	if (!PageHuge(page))
> +		return -1;

ditto.

> +	if (compound_order(page)<  3)
> +		return -1;
> +	page[2].lru.next = (void *)h_cg;
> +	return 0;
> +}
> +

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
