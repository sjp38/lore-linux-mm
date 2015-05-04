Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 07F906B0038
	for <linux-mm@kvack.org>; Sun,  3 May 2015 23:17:36 -0400 (EDT)
Received: by pacyx8 with SMTP id yx8so149198206pac.1
        for <linux-mm@kvack.org>; Sun, 03 May 2015 20:17:35 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id t12si18031927pbs.27.2015.05.03.20.17.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 May 2015 20:17:35 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so151416984pdb.0
        for <linux-mm@kvack.org>; Sun, 03 May 2015 20:17:34 -0700 (PDT)
Date: Mon, 4 May 2015 12:17:22 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150504031722.GA2768@blaptop>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
 <20150429043536.GB11486@blaptop>
 <20150429091248.GD1694@esperanza>
 <20150430082531.GD21771@blaptop>
 <20150430145055.GB17640@esperanza>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150430145055.GB17640@esperanza>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Thu, Apr 30, 2015 at 05:50:55PM +0300, Vladimir Davydov wrote:
> On Thu, Apr 30, 2015 at 05:25:31PM +0900, Minchan Kim wrote:
> > On Wed, Apr 29, 2015 at 12:12:48PM +0300, Vladimir Davydov wrote:
> > > On Wed, Apr 29, 2015 at 01:35:36PM +0900, Minchan Kim wrote:
> > > > On Tue, Apr 28, 2015 at 03:24:42PM +0300, Vladimir Davydov wrote:
> > > > > +#ifdef CONFIG_IDLE_PAGE_TRACKING
> > > > > +static struct page *kpageidle_get_page(unsigned long pfn)
> > > > > +{
> > > > > +	struct page *page;
> > > > > +
> > > > > +	if (!pfn_valid(pfn))
> > > > > +		return NULL;
> > > > > +	page = pfn_to_page(pfn);
> > > > > +	/*
> > > > > +	 * We are only interested in user memory pages, i.e. pages that are
> > > > > +	 * allocated and on an LRU list.
> > > > > +	 */
> > > > > +	if (!page || page_count(page) == 0 || !PageLRU(page))
> > > > > +		return NULL;
> > > > > +	if (!get_page_unless_zero(page))
> > > > > +		return NULL;
> > > > > +	if (unlikely(!PageLRU(page))) {
> > > > 
> > > > What lock protect the check PageLRU?
> > > > If it is racing ClearPageLRU, what happens?
> > > 
> > > If we hold a reference to a page and see that it's on an LRU list, it
> > > will surely remain a user memory page at least until we release the
> > > reference to it, so it must be safe to play with idle/young flags. If we
> > 
> > The problem is that you pass the page in rmap reverse logic(ie, page_referenced)
> > once you judge it's LRU page so if it is false-positive, what happens?
> > A question is SetPageLRU, PageLRU, ClearPageLRU keeps memory ordering?
> > IOW, all of fields from struct page rmap can acccess should be set up completely
> > before LRU checking. Otherwise, something will be broken.
> 
> So, basically you are concerned about the case when we encounter a
> freshly allocated page, which has PG_lru bit set and it's going to
> become anonymous, but it is still in the process of rmap initialization,
> i.e. its ->mapping or ->mapcount may still be uninitialized, right?
> 
> AFAICS, page_referenced should handle such pages fine. Look, it only
> needs ->index, ->mapping, and ->mapcount.
> 
> If ->mapping is unset, than it is NULL and rmap_walk_anon_lock ->
> page_lock_anon_vma_read will return NULL so that rmap_walk will be a
> no-op.
> 
> If ->index is not initialized, than at worst we will go to
> anon_vma_interval_tree_foreach over a wrong interval, in which case we
> will see that the page is actually not mapped in page_referenced_one ->
> page_check_address and again do nothing.
> 
> If ->mapcount is not initialized it is -1, and page_lock_anon_vma_read
> will return NULL, just as it does in case ->mapping = NULL.
> 
> For file pages, we always take PG_locked before checking ->mapping, so
> it must be valid.
> 
> Thanks,
> Vladimir


do_anonymous_page
page_add_new_anon_rmap
atomic_set(&page->_mapcount, 0);
__page_set_anon_rmap
   anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
   page->mapping = (struct address_space *) anon_vma;
   page->index = linear_page_index(vma, address);
lru_cache_add 
  __pagevec_lru_add_fn
  SetPageLRU(page);

During the procedure, there is no lock to prevent race. Then, at least,
we need a write memory barrier to guarantee other fields set up before
SetPageLRU. (Of course, PageLRU should have read-memory barrier to work
well) But I can't find any barrier, either.

IOW, any fields you said could be out of order store without any lock or
memory barrier. You might argue atomic op is a barrier on x86 but it
doesn't guarantee other arches work like that so we need explict momory
barrier or lock.

Let's have a theoretical example.

        CPU 0                                                                           CPU 1

do_anonymous_page
  __page_set_anon_rmap
  /* out of order happened so SetPageLRU is done ahead */
  SetPageLRU(page)
  /* Compilr changed store operation like below */
  page->mapping = (struct address_space *) anon_vma;
  /* Big stall happens */
                                                                /* idletacking judged it as LRU page so pass the page
                                                                   in page_reference */
                                                                page_refernced
                                                                        page_rmapping return true because
                                                                        page->mapping has some vaule but not complete
                                                                        so it calls rmap_walk_file.
                                                                        it's okay to pass non-completed anon page in rmap_walk_file?

  page->mapping = (struct address_space *)
        ((void *)page_mapping + PAGE_MAPPING_ANON);

It's too theoretical so it might be hard to happen in real practice.
My point is there is nothing to prevent explict race.
Even if there is no problem with other lock, it's fragile.
Do I miss something?

I think general way to handle PageLRU are ahead isolation or zone->lru_lock.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
