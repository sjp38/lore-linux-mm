Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CFD176B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 20:42:21 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id e189so68820454pfa.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 17:42:21 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id a6si104935pfb.49.2016.07.19.17.42.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jul 2016 17:42:20 -0700 (PDT)
Received: by mail-pa0-x236.google.com with SMTP id iw10so12048388pac.2
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 17:42:20 -0700 (PDT)
Date: Tue, 19 Jul 2016 17:42:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] ksm: set anon_vma of first rmap_item of ksm page to
 page's anon_vma other than vma's anon_vma
In-Reply-To: <1466688834-127613-1-git-send-email-zhouxianrong@huawei.com>
Message-ID: <alpine.LSU.2.11.1607191602590.5225@eggly.anvils>
References: <1466688834-127613-1-git-send-email-zhouxianrong@huawei.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: zhouxianrong@huawei.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Susheel Khiani <skhiani@codeaurora.org>, hughd@google.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com, dave.hansen@linux.intel.com, zhouchengming1@huawei.com, geliangtang@163.com, zhouxiyu@huawei.com, wanghaijun5@huawei.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 23 Jun 2016, zhouxianrong@huawei.com wrote:
> From: z00281421 <z00281421@notesmail.huawei.com>
> 
> set anon_vma of first rmap_item of ksm page to page's anon_vma
> other than vma's anon_vma so that we can lookup all the forked

s/other/rather/

> vma of kpage via reserve map. thus we can try_to_unmap ksm page

s/reserve/reverse/

> completely and reclaim or migrate the ksm page successfully and
> need not to merg other forked vma addresses of ksm page with
> building a rmap_item for it ever after.
> 
> a forked more mapcount ksm page with partially merged vma addresses and
> a ksm page mapped into non-VM_MERGEABLE vma due to setting MADV_MERGEABLE
> on one of the forked vma can be unmapped completely by try_to_unmap.

Sorry, I found that very hard to understand; and I'm only now beginning
to understand you.  And at last I realize that what you are *aiming for*
is a very good idea - thank you.

Whether it can be (quickly and simply) achieved, I'll have to give a lot
more thought to.  But what is certain is that your current implementation
is broken (and I'm worried that your testing did not notice such errors).

Trying 4.7-rc7-mm1 with KSM under swapping load,
one machine gave me many
WARNING: CPU: N PID: NNNN at mm/rmap.c:412 .unlink_anon_vmas+0x144/0x1c8
that's		VM_WARN_ON(anon_vma->degree);

and another machine gave me many
cache `anon_vma': double free detected
ending in slab_put_obj()'s kernel BUG at mm/slab.c:2647!

and another machine gave me
kernel BUG at mm/migrate.c:1019!
that's		VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma,
				page);

No such problems once I reverted your patch.  So, definitely NAK to
your present patch, and Andrew please remove it from the mmotm tree.

I have not tried to work out exactly why this and that error occur,
because there is a more fundamental problem with your patch: more on
that below.

> 
> Signed-off-by: z00281421 <z00281421@notesmail.huawei.com>

As I said before, that should be Signed-off-by: Real Name <emailaddress>

> ---
>  mm/ksm.c |   19 ++++++++++++++++---
>  1 file changed, 16 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/ksm.c b/mm/ksm.c
> index 4786b41..6bacc08 100644
> --- a/mm/ksm.c
> +++ b/mm/ksm.c
> @@ -971,11 +971,13 @@ out:
>   * @page: the PageAnon page that we want to replace with kpage
>   * @kpage: the PageKsm page that we want to map instead of page,
>   *         or NULL the first time when we want to use page as kpage.
> + * @anon_vma: output the anon_vma of page used as kpage
>   *
>   * This function returns 0 if the pages were merged, -EFAULT otherwise.
>   */
>  static int try_to_merge_one_page(struct vm_area_struct *vma,
> -				 struct page *page, struct page *kpage)
> +				 struct page *page, struct page *kpage,
> +				 struct anon_vma **anon_vma)

Nit: is it necessary to change try_to_merge_one_page()?  I thought it
was good enough just to take a snapshot of page_anon_vma(page) before
calling it from try_to_merge_with_ksm_page(), then use that there.

It's true that doing it in here you capture anon_vma while the page
is locked, but I don't think that actually matters (page_move_anon_rmap
might race and change it, but it's a benign race).

>  {
>  	pte_t orig_pte = __pte(0);
>  	int err = -EFAULT;
> @@ -1015,6 +1017,8 @@ static int try_to_merge_one_page(struct vm_area_struct *vma,
>  			 * PageAnon+anon_vma to PageKsm+NULL stable_node:
>  			 * stable_tree_insert() will update stable_node.
>  			 */
> +			if (anon_vma != NULL)
> +				*anon_vma = page_anon_vma(page);
>  			set_page_stable_node(page, NULL);
>  			mark_page_accessed(page);
>  			/*
> @@ -1055,6 +1059,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
>  {
>  	struct mm_struct *mm = rmap_item->mm;
>  	struct vm_area_struct *vma;
> +	struct anon_vma *anon_vma = NULL;
>  	int err = -EFAULT;
>  
>  	down_read(&mm->mmap_sem);
> @@ -1062,7 +1067,7 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
>  	if (!vma)
>  		goto out;
>  
> -	err = try_to_merge_one_page(vma, page, kpage);
> +	err = try_to_merge_one_page(vma, page, kpage, &anon_vma);
>  	if (err)
>  		goto out;
>  
> @@ -1070,7 +1075,10 @@ static int try_to_merge_with_ksm_page(struct rmap_item *rmap_item,
>  	remove_rmap_item_from_tree(rmap_item);
>  
>  	/* Must get reference to anon_vma while still holding mmap_sem */
> -	rmap_item->anon_vma = vma->anon_vma;
> +	if (anon_vma != NULL)
> +		rmap_item->anon_vma = anon_vma;
> +	else
> +		rmap_item->anon_vma = vma->anon_vma;

I had something like that in the patch I was trying (but never
completed or posted) last year.  But it did not actually do much good,
not in my testing anyway.  A much more significant effect was that an
rmap_item needed to locate the page for rmap later, could be removed
from the stable tree when its mm exited, leaving nothing behind to
locate those ptes which were forked from this one, but not yet scanned
by ksmd.  So most of my incomplete patch was trying to deal with that.

A link to that thread is marc.info/?l=linux-mm&m=142907899327574&w=2

>  	get_anon_vma(vma->anon_vma);
>  out:
>  	up_read(&mm->mmap_sem);
> @@ -1435,6 +1443,11 @@ static void cmp_and_merge_page(struct page *page, struct rmap_item *rmap_item)
>  
>  	remove_rmap_item_from_tree(rmap_item);
>  
> +	if (kpage == page) {
> +		put_page(kpage);
> +		return;
> +	}
> +

And there I think we come to what's so good and what's so bad with your
patch.  You are trying to avoid doing unnecessary work on the forked
kpage: good.  But since you don't attach its rmap_item to the stable
tree, you're making the effect I mentioned in my previous paragraph even
worse: you are entirely dependent on the original rmap_item, which might
get removed from the stable tree when its mm exits, leaving the forked
ptes impossible to locate thereafter - bad.

Avoiding repeated unnecessary work on the stable tree is good, not just
to save time when building the tree up, but also whenever searching it
thereafter.  I had not fully realized this until very recently, but I'm
now afraid that the KSM rmap lookup (as it stands) can get frighteningly
inefficient with forked pages.

Because each rmap_item attached to the stable tree represents, not so
much the position of a pte, as the specification of an anon_vma lookup
for the pte.  And the way it works on a forked page at present, it is
duplicating those lookups unnecessarily.  Not so bad for try_to_unmap()
(when the search terminates once all ptes have been unmapped), but
terrible for page_referenced(), which advances to the search_new_forks
stage and does a full anon_vma lookup on every rmap_item for the page.

I wasn't thinking about that at all when I tried to put together last
year's patch: all I was thinking about was maximizing the ability of
the lookup to locate ptes (and checking how successful it is at that);
but now the inefficient lookup seems like a priority to think about.

Am I right to assume that efficient handling of forked pages is a
serious concern for your product, rather than just an interesting
academic exercise for your own amusement?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
