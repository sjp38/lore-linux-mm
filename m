Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 293736B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 11:35:39 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id o41so13471768qtf.8
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 08:35:39 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u35si420212qtd.228.2017.06.15.08.35.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Jun 2017 08:35:38 -0700 (PDT)
Date: Thu, 15 Jun 2017 11:35:34 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [HMM-CDM 3/5] mm/memcontrol: allow to uncharge page without
 using page->lru field
Message-ID: <20170615153533.GA3837@redhat.com>
References: <20170614201144.9306-1-jglisse@redhat.com>
 <20170614201144.9306-4-jglisse@redhat.com>
 <20170615133128.2fe2c33f@firefly.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170615133128.2fe2c33f@firefly.ozlabs.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, cgroups@vger.kernel.org

On Thu, Jun 15, 2017 at 01:31:28PM +1000, Balbir Singh wrote:
> On Wed, 14 Jun 2017 16:11:42 -0400
> Jerome Glisse <jglisse@redhat.com> wrote:
> 
> > HMM pages (private or public device pages) are ZONE_DEVICE page and
> > thus you can not use page->lru fields of those pages. This patch
> > re-arrange the uncharge to allow single page to be uncharge without
> > modifying the lru field of the struct page.
> > 
> > There is no change to memcontrol logic, it is the same as it was
> > before this patch.
> > 
> > Signed-off-by: Jerome Glisse <jglisse@redhat.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Michal Hocko <mhocko@kernel.org>
> > Cc: Vladimir Davydov <vdavydov.dev@gmail.com>
> > Cc: cgroups@vger.kernel.org
> > ---
> >  mm/memcontrol.c | 168 +++++++++++++++++++++++++++++++-------------------------
> >  1 file changed, 92 insertions(+), 76 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index e3fe4d0..b93f5fe 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -5509,48 +5509,102 @@ void mem_cgroup_cancel_charge(struct page *page, struct mem_cgroup *memcg,
> >  	cancel_charge(memcg, nr_pages);
> >  }
> >  
> > -static void uncharge_batch(struct mem_cgroup *memcg, unsigned long pgpgout,
> > -			   unsigned long nr_anon, unsigned long nr_file,
> > -			   unsigned long nr_kmem, unsigned long nr_huge,
> > -			   unsigned long nr_shmem, struct page *dummy_page)
> > +struct uncharge_gather {
> > +	struct mem_cgroup *memcg;
> > +	unsigned long pgpgout;
> > +	unsigned long nr_anon;
> > +	unsigned long nr_file;
> > +	unsigned long nr_kmem;
> > +	unsigned long nr_huge;
> > +	unsigned long nr_shmem;
> > +	struct page *dummy_page;
> > +};
> > +
> > +static inline void uncharge_gather_clear(struct uncharge_gather *ug)
> >  {
> > -	unsigned long nr_pages = nr_anon + nr_file + nr_kmem;
> > +	memset(ug, 0, sizeof(*ug));
> > +}
> > +
> > +static void uncharge_batch(const struct uncharge_gather *ug)
> > +{
> 
> Can we pass page as an argument so that we can do check events on the page?

Well it is what dummy page is for, i wanted to keep code as close
to existing to make it easier for people to see that there was no
logic change with that patch.


[...]

> > +static void uncharge_page(struct page *page, struct uncharge_gather *ug)
> > +{
> > +	VM_BUG_ON_PAGE(PageLRU(page), page);
> > +	VM_BUG_ON_PAGE(!PageHWPoison(page) && page_count(page), page);
> > +
> > +	if (!page->mem_cgroup)
> > +		return;
> > +
> > +	/*
> > +	 * Nobody should be changing or seriously looking at
> > +	 * page->mem_cgroup at this point, we have fully
> > +	 * exclusive access to the page.
> > +	 */
> > +
> > +	if (ug->memcg != page->mem_cgroup) {
> > +		if (ug->memcg) {
> > +			uncharge_batch(ug);
> 
> What is ug->dummy_page set to at this point? ug->dummy_page is assigned below

So at begining ug->memcg is NULL and so is ug->dummy_page, after first
call to uncharge_page() if ug->memcg isn't NULL then ug->dummy_page
points to a valid page. So uncharge_batch() can never be call with
dummy_page == NULL same as before this patch.


[...]

> >  static void uncharge_list(struct list_head *page_list)
> >  {
> > -	struct mem_cgroup *memcg = NULL;
> > -	unsigned long nr_shmem = 0;
> > -	unsigned long nr_anon = 0;
> > -	unsigned long nr_file = 0;
> > -	unsigned long nr_huge = 0;
> > -	unsigned long nr_kmem = 0;
> > -	unsigned long pgpgout = 0;
> > +	struct uncharge_gather ug;
> >  	struct list_head *next;
> > -	struct page *page;
> > +
> > +	uncharge_gather_clear(&ug);
> >  
> >  	/*
> >  	 * Note that the list can be a single page->lru; hence the
> > @@ -5558,57 +5612,16 @@ static void uncharge_list(struct list_head *page_list)
> >  	 */
> >  	next = page_list->next;
> >  	do {
> > +		struct page *page;
> > +
> 
> Nit pick
> 
> VM_WARN_ON(is_zone_device_page(page));

Yeah probably good thing to add. I will add it as part of the
other memcontrol patch as i want to keep this one about moving
stuff around with no logic change.

Thanks for reviewing
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
