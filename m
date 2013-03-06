Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id BA2A26B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 17:20:13 -0500 (EST)
Date: Wed, 6 Mar 2013 14:20:11 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH resend] rmap: recompute pgoff for unmapping huge page
Message-Id: <20130306142011.c6260e416cef6a906660fa4d@linux-foundation.org>
In-Reply-To: <CAJd=RBD0UWxpMv7W78fH0U_zBAOozP1owaMePGaUEVitotRfBg@mail.gmail.com>
References: <CAJd=RBD0UWxpMv7W78fH0U_zBAOozP1owaMePGaUEVitotRfBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Michel Lespinasse <walken@google.com>

On Mon, 4 Mar 2013 20:47:31 +0800 Hillf Danton <dhillf@gmail.com> wrote:

> [Resend due to error in delivering to linux-kernel@vger.kernel.org,
> caused probably by the rich format provided by the mail agent by default.]
> 
> We have to recompute pgoff if the given page is huge, since result based on
> HPAGE_SIZE is not approapriate for scanning the vma interval tree, as shown
> by commit 36e4f20af833(hugetlb: do not use vma_hugecache_offset() for
> vma_prio_tree_foreach)
> 
> Signed-off-by: Hillf Danton <dhillf@gmail.com>
> ---
> 
> --- a/mm/rmap.c	Mon Mar  4 20:00:00 2013
> +++ b/mm/rmap.c	Mon Mar  4 20:02:16 2013
> @@ -1513,6 +1513,9 @@ static int try_to_unmap_file(struct page
>  	unsigned long max_nl_size = 0;
>  	unsigned int mapcount;
> 
> +	if (PageHuge(page))
> +		pgoff = page->index << compound_order(page);
> +
>  	mutex_lock(&mapping->i_mmap_mutex);
>  	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
>  		unsigned long address = vma_address(page, vma);

How are we getting here for hugepages?  Trying to migrate a hugetlbfs
page?

Can we just do this?

--- a/mm/rmap.c~a
+++ a/mm/rmap.c
@@ -1505,7 +1505,7 @@ static int try_to_unmap_anon(struct page
 static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 {
 	struct address_space *mapping = page->mapping;
-	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	pgoff_t pgoff;
 	struct vm_area_struct *vma;
 	int ret = SWAP_AGAIN;
 	unsigned long cursor;
@@ -1513,6 +1513,7 @@ static int try_to_unmap_file(struct page
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
+	pgoff = page->index << compound_order(page);
 	mutex_lock(&mapping->i_mmap_mutex);
 	vma_interval_tree_foreach(vma, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
_

It's a lot less fuss.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
