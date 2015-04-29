Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id E031F6B0032
	for <linux-mm@kvack.org>; Wed, 29 Apr 2015 05:13:00 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so22487043pab.2
        for <linux-mm@kvack.org>; Wed, 29 Apr 2015 02:13:00 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hj2si38466092pbc.103.2015.04.29.02.12.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Apr 2015 02:13:00 -0700 (PDT)
Date: Wed, 29 Apr 2015 12:12:48 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v3 3/3] proc: add kpageidle file
Message-ID: <20150429091248.GD1694@esperanza>
References: <cover.1430217477.git.vdavydov@parallels.com>
 <4c24a6bf2c9711dd4dbb72a43a16eba6867527b7.1430217477.git.vdavydov@parallels.com>
 <20150429043536.GB11486@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150429043536.GB11486@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Apr 29, 2015 at 01:35:36PM +0900, Minchan Kim wrote:
> On Tue, Apr 28, 2015 at 03:24:42PM +0300, Vladimir Davydov wrote:
> > diff --git a/fs/proc/page.c b/fs/proc/page.c
> > index 70d23245dd43..cfc55ba7fee6 100644
> > --- a/fs/proc/page.c
> > +++ b/fs/proc/page.c
> > @@ -275,6 +275,156 @@ static const struct file_operations proc_kpagecgroup_operations = {
> >  };
> >  #endif /* CONFIG_MEMCG */
> >  
> > +#ifdef CONFIG_IDLE_PAGE_TRACKING
> > +static struct page *kpageidle_get_page(unsigned long pfn)
> > +{
> > +	struct page *page;
> > +
> > +	if (!pfn_valid(pfn))
> > +		return NULL;
> > +	page = pfn_to_page(pfn);
> > +	/*
> > +	 * We are only interested in user memory pages, i.e. pages that are
> > +	 * allocated and on an LRU list.
> > +	 */
> > +	if (!page || page_count(page) == 0 || !PageLRU(page))
> 
> Why do you check (page_count == 0) even if we check it with get_page_unless_zero
> below?

I intended to avoid overhead of cmpxchg in case page_count is 0, but
diving deeper into get_page_unless_zero, I see that it already handles
such a scenario, so this check is useless. I'll remove it.

> 
> > +		return NULL;
> > +	if (!get_page_unless_zero(page))
> > +		return NULL;
> > +	if (unlikely(!PageLRU(page))) {
> 
> What lock protect the check PageLRU?
> If it is racing ClearPageLRU, what happens?

If we hold a reference to a page and see that it's on an LRU list, it
will surely remain a user memory page at least until we release the
reference to it, so it must be safe to play with idle/young flags. If we
race with isolate_lru_page, or any similar function temporarily clearing
PG_lru, we will silently skip the page w/o touching its idle/young
flags. We could consider isolated pages too, but that would increase the
cost of this function.

If you find this explanation OK, I'll add it to the comment to this
function.

> 
> > +		put_page(page);
> > +		return NULL;
> > +	}
> > +	return page;
> > +}
> > +
> > +static void kpageidle_clear_refs(struct page *page)
> > +{
> > +	unsigned long dummy;
> > +
> > +	if (page_referenced(page, 0, NULL, &dummy))
> > +		/*
> > +		 * This page was referenced. To avoid interference with the
> > +		 * reclaimer, mark it young so that the next call will also
> 
>                                                         next what call?
> 
> It just works with mapped page so kpageidle_clear_pte_refs as function name
> is more clear.
> 
> One more, kpageidle_clear_refs removes PG_idle via page_referenced which
> is important feature for the function. Please document it so we could
> understand why we need double check for PG_idle after calling
> kpageidle_clear_refs for pte access bit.

Sounds reasonable, will do.

> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index 24dd3f9fee27..12e73b758d9e 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -784,6 +784,13 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
> >  	if (referenced) {
> >  		pra->referenced++;
> >  		pra->vm_flags |= vma->vm_flags;
> > +		if (page_is_idle(page))
> > +			clear_page_idle(page);
> > +	}
> > +
> > +	if (page_is_young(page)) {
> > +		clear_page_young(page);
> > +		pra->referenced++;
> 
> If a page was page_is_young and referenced recenlty,
> pra->referenced is increased doubly and it changes current
> behavior for file-backed page promotion. Look at page_check_references.

Yeah, you're quite right, I missed that. Something like this should get
rid of this extra reference:

diff --git a/mm/rmap.c b/mm/rmap.c
index 24dd3f9fee27..eca7416f55d7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -781,6 +781,14 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
+	if (referenced && page_is_idle(page))
+		clear_page_idle(page);
+
+	if (page_is_young(page)) {
+		clear_page_young(page);
+		referenced++;
+	}
+
 	if (referenced) {
 		pra->referenced++;
 		pra->vm_flags |= vma->vm_flags;

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
