Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 8D7826B0031
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 22:08:04 -0400 (EDT)
Received: by mail-oa0-f45.google.com with SMTP id j1so5163330oag.18
        for <linux-mm@kvack.org>; Thu, 18 Jul 2013 19:08:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <87hafrdatb.fsf@linux.vnet.ibm.com>
References: <20130717153223.GD27731@redhat.com>
	<20130718000901.GA31972@blaptop>
	<87hafrdatb.fsf@linux.vnet.ibm.com>
Date: Fri, 19 Jul 2013 10:08:03 +0800
Message-ID: <CAJd=RBA0UDCJGE5ua7m44hOQp5g9EQdkeC00iWSEDkmLhc0rDw@mail.gmail.com>
Subject: Re: hugepage related lockdep trace.
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Minchan Kim <minchan@kernel.org>, Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 19, 2013 at 1:42 AM, Aneesh Kumar K.V
<aneesh.kumar@linux.vnet.ibm.com> wrote:
> Minchan Kim <minchan@kernel.org> writes:
>> IMHO, it's a false positive because i_mmap_mutex was held by kswapd
>> while one in the middle of fault path could be never on kswapd context.
>>
>> It seems lockdep for reclaim-over-fs isn't enough smart to identify
>> between background and direct reclaim.
>>
>> Wait for other's opinion.
>
> Is that reasoning correct ?. We may not deadlock because hugetlb pages
> cannot be reclaimed. So the fault path in hugetlb won't end up
> reclaiming pages from same inode. But the report is correct right ?
>
>
> Looking at the hugetlb code we have in huge_pmd_share
>
> out:
>         pte = (pte_t *)pmd_alloc(mm, pud, addr);
>         mutex_unlock(&mapping->i_mmap_mutex);
>         return pte;
>
> I guess we should move that pmd_alloc outside i_mmap_mutex. Otherwise
> that pmd_alloc can result in a reclaim which can call shrink_page_list ?
>
Hm, can huge pages be reclaimed, say by kswapd currently?

> Something like  ?
>
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 83aff0a..2cb1be3 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3266,8 +3266,8 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud)
>                 put_page(virt_to_page(spte));
>         spin_unlock(&mm->page_table_lock);
>  out:
> -       pte = (pte_t *)pmd_alloc(mm, pud, addr);
>         mutex_unlock(&mapping->i_mmap_mutex);
> +       pte = (pte_t *)pmd_alloc(mm, pud, addr);
>         return pte;
>  }
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
