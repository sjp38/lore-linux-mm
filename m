Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5961A6B0655
	for <linux-mm@kvack.org>; Fri, 18 May 2018 13:46:53 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id e2-v6so5567687oii.20
        for <linux-mm@kvack.org>; Fri, 18 May 2018 10:46:53 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s8-v6si2880816ota.184.2018.05.18.10.46.52
        for <linux-mm@kvack.org>;
        Fri, 18 May 2018 10:46:52 -0700 (PDT)
From: Punit Agrawal <punit.agrawal@arm.com>
Subject: Re: [PATCH v2 3/7] memcg: use compound_order rather than hpage_nr_pages
References: <e863529b-7ce5-4fbe-8cff-581b5789a5f9@ascade.co.jp>
	<262267fe-d98c-0b25-9013-3dafb52e8679@ascade.co.jp>
Date: Fri, 18 May 2018 18:46:49 +0100
In-Reply-To: <262267fe-d98c-0b25-9013-3dafb52e8679@ascade.co.jp> (TSUKADA
	Koutaro's message of "Fri, 18 May 2018 13:34:26 +0900")
Message-ID: <87wow0zwja.fsf@e105922-lin.cambridge.arm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: TSUKADA Koutaro <tsukada@ascade.co.jp>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, Jonathan Corbet <corbet@lwn.net>, "Luis R. Rodriguez" <mcgrof@kernel.org>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Roman Gushchin <guro@fb.com>, David Rientjes <rientjes@google.com>, Mike Kravetz <mike.kravetz@oracle.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Marc-Andre Lureau <marcandre.lureau@redhat.com>, Dan Williams <dan.j.williams@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org

Tsukada-san,

I am not familiar with memcg so can't comment about whether the patchset
is the right way to solve the problem outlined in the cover letter but
had a couple of comments about this patch.

TSUKADA Koutaro <tsukada@ascade.co.jp> writes:

> The current memcg implementation assumes that the compound page is THP.
> In order to be able to charge surplus hugepage, we use compound_order.
>
> Signed-off-by: TSUKADA Koutaro <tsukada@ascade.co.jp>

Please move this before Patch 1/7. This is to prevent wrong accounting
of pages to memcg for size != PMD_SIZE.

> ---
>  memcontrol.c |   10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 2bd3df3..a8f1ff8 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4483,7 +4483,7 @@ static int mem_cgroup_move_account(struct page *page,
>  				   struct mem_cgroup *to)
>  {
>  	unsigned long flags;
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;

Instead of replacing calls to hpage_nr_pages(), is it possible to modify
it to do the calculation?

Thanks,
Punit

>  	int ret;
>  	bool anon;
>
> @@ -5417,7 +5417,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  			  bool compound)
>  {
>  	struct mem_cgroup *memcg = NULL;
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>  	int ret = 0;
>
>  	if (mem_cgroup_disabled())
> @@ -5478,7 +5478,7 @@ int mem_cgroup_try_charge(struct page *page, struct mm_struct *mm,
>  void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  			      bool lrucare, bool compound)
>  {
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>
>  	VM_BUG_ON_PAGE(!page->mapping, page);
>  	VM_BUG_ON_PAGE(PageLRU(page) && !lrucare, page);
> @@ -5522,7 +5522,7 @@ void mem_cgroup_commit_charge(struct page *page, struct mem_cgroup *memcg,
>  void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
>  		bool compound)
>  {
> -	unsigned int nr_pages = compound ? hpage_nr_pages(page) : 1;
> +	unsigned int nr_pages = compound ? (1 << compound_order(page)) : 1;
>
>  	if (mem_cgroup_disabled())
>  		return;
> @@ -5729,7 +5729,7 @@ void mem_cgroup_migrate(struct page *oldpage, struct page *newpage)
>
>  	/* Force-charge the new page. The old one will be freed soon */
>  	compound = PageTransHuge(newpage);
> -	nr_pages = compound ? hpage_nr_pages(newpage) : 1;
> +	nr_pages = compound ? (1 << compound_order(newpage)) : 1;
>
>  	page_counter_charge(&memcg->memory, nr_pages);
>  	if (do_memsw_account())
