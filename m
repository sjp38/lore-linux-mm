Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 67F686B0004
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 05:21:39 -0500 (EST)
Date: Tue, 22 Jan 2013 11:21:34 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/1] mm/hugetlb: Set PTE as huge in
 hugetlb_change_protection
Message-ID: <20130122102130.GA28525@dhcp22.suse.cz>
References: <BAB94DBB0E89D8409949BC28AC95914C47B123D2@USMAExch1.tad.internal.tilera.com>
 <20130121100410.GE7798@dhcp22.suse.cz>
 <BAB94DBB0E89D8409949BC28AC95914C47B12789@USMAExch1.tad.internal.tilera.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BAB94DBB0E89D8409949BC28AC95914C47B12789@USMAExch1.tad.internal.tilera.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tony Lu <zlu@tilera.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Hillf Danton <dhillf@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Chris Metcalf <cmetcalf@tilera.com>

On Tue 22-01-13 02:37:15, Tony Lu wrote:
> >-----Original Message-----
> >From: Michal Hocko [mailto:mhocko@suse.cz]
> >Sent: Monday, January 21, 2013 6:04 PM
> >To: Tony Lu
> >Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org; Andrew Morton; Aneesh
> >Kumar K.V; Hillf Danton; KAMEZAWA Hiroyuki; Chris Metcalf
> >Subject: Re: [PATCH 1/1] mm/hugetlb: Set PTE as huge in
> >hugetlb_change_protection
> >
> >On Mon 21-01-13 04:13:07, Tony Lu wrote:
> >> From da8432aafd231e7cdcda9d15484829def4663cb0 Mon Sep 17 00:00:00 2001
> >> From: Zhigang Lu <zlu@tilera.com>
> >> Date: Mon, 21 Jan 2013 11:23:26 +0800
> >> Subject: [PATCH 1/1] mm/hugetlb: Set PTE as huge in hugetlb_change_protection
> >>
> >> When setting a huge PTE, besides calling pte_mkhuge(), we also need
> >> to call arch_make_huge_pte(), which we indeed do in make_huge_pte(),
> >> but we forget to do in hugetlb_change_protection().
> >
> >I guess you also need it in remove_migration_pte. This calls for a
> >helper which would do both pte_mkhuge() and arch_make_huge_pte.
> >
> >Besides that, tile seem to be the only arch which implements this arch
> >hook (introduced by 621b1955 in 3.5) so this should be considered for
> >stable.
> 
> Thank you. Yes, remove_migration_pte also needs it. Here is the updated patch.
> 
> From 44045d672aa72eb2e76be89f95ab720952b4b09c Mon Sep 17 00:00:00 2001
> From: Zhigang Lu <zlu@tilera.com>
> Date: Tue, 22 Jan 2013 09:58:58 +0800
> Subject: [PATCH 1/1] mm/hugetlb: Set PTE as huge in hugetlb_change_protection
>  and remove_migration_pte
> 
> When setting a huge PTE, besides calling pte_mkhuge(), we also need
> to call arch_make_huge_pte(), which we indeed do in make_huge_pte(),
> but we forget to do in hugetlb_change_protection() and
> remove_migration_pte().
> 
> Signed-off-by: Zhigang Lu <zlu@tilera.com>
> Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>

Reviewed-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/hugetlb.c |    1 +
>  mm/migrate.c |    4 +++-
>  2 files changed, 4 insertions(+), 1 deletion(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 4f3ea0b..546db81 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -3033,6 +3033,7 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>                 if (!huge_pte_none(huge_ptep_get(ptep))) {
>                         pte = huge_ptep_get_and_clear(mm, address, ptep);
>                         pte = pte_mkhuge(pte_modify(pte, newprot));
> +                       pte = arch_make_huge_pte(pte, vma, NULL, 0);
>                         set_huge_pte_at(mm, address, ptep, pte);
>                         pages++;
>                 }
> diff --git a/mm/migrate.c b/mm/migrate.c
> index c387786..2fd8b4a 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -160,8 +160,10 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
>         if (is_write_migration_entry(entry))
>                 pte = pte_mkwrite(pte);
>  #ifdef CONFIG_HUGETLB_PAGE
> -       if (PageHuge(new))
> +       if (PageHuge(new)) {
>                 pte = pte_mkhuge(pte);
> +               pte = arch_make_huge_pte(pte, vma, new, 0);
> +       }
>  #endif
>         flush_cache_page(vma, addr, pte_pfn(pte));
>         set_pte_at(mm, addr, ptep, pte);
> -- 
> 1.7.10.3

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
