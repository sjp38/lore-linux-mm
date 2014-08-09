Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id A0B416B0036
	for <linux-mm@kvack.org>; Sat,  9 Aug 2014 19:13:49 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id fa1so9103504pad.13
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 16:13:49 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id xi3si9311918pab.111.2014.08.09.16.13.48
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 09 Aug 2014 16:13:48 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id p10so8799255pdj.36
        for <linux-mm@kvack.org>; Sat, 09 Aug 2014 16:13:48 -0700 (PDT)
Date: Sat, 9 Aug 2014 16:12:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v2 3/3] mm/hugetlb: add migration entry check in
 hugetlb_change_protection
In-Reply-To: <1406914663-8631-3-git-send-email-n-horiguchi@ah.jp.nec.com>
Message-ID: <alpine.LSU.2.11.1408091611150.15311@eggly.anvils>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1406914663-8631-3-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, 1 Aug 2014, Naoya Horiguchi wrote:

> There is a race condition between hugepage migration and change_protection(),
> where hugetlb_change_protection() doesn't care about migration entries and
> wrongly overwrites them. That causes unexpected results like kernel crash.
> 
> This patch adds is_hugetlb_entry_(migration|hwpoisoned) check in this
> function and skip all such entries.
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: <stable@vger.kernel.org>  # [3.12+]
> ---
>  mm/hugetlb.c | 8 +++++++-
>  1 file changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git mmotm-2014-07-22-15-58.orig/mm/hugetlb.c mmotm-2014-07-22-15-58/mm/hugetlb.c
> index 863f45f63cd5..1da7ca2e2a02 100644
> --- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
> +++ mmotm-2014-07-22-15-58/mm/hugetlb.c
> @@ -3355,7 +3355,13 @@ unsigned long hugetlb_change_protection(struct vm_area_struct *vma,
>  			spin_unlock(ptl);
>  			continue;
>  		}
> -		if (!huge_pte_none(huge_ptep_get(ptep))) {
> +		pte = huge_ptep_get(ptep);
> +		if (unlikely(is_hugetlb_entry_migration(pte) ||
> +			     is_hugetlb_entry_hwpoisoned(pte))) {

Another instance of this pattern.  Oh well, perhaps we have to continue
this way while backporting fixes, but the repetition irritates me.
Or use is_swap_pte() as follow_hugetlb_page() does?

More importantly, the regular change_pte_range() has to
make_migration_entry_read() if is_migration_entry_write():
why is that not necessary here?

And have you compared hugetlb codepaths with normal codepaths, to see
if there are other huge places which need to check for a migration entry
now?  If you have checked, please reassure us in the commit message:
we would prefer not to have these fixes coming in one by one.

(I first thought __unmap_hugepage_range() would need it, but since
zap_pte_range() only checks it for rss stats, and hugetlb does not
participate in rss stats, it looks like no need.)

Hugh

> +			spin_unlock(ptl);
> +			continue;
> +		}
> +		if (!huge_pte_none(pte)) {
>  			pte = huge_ptep_get_and_clear(mm, address, ptep);
>  			pte = pte_mkhuge(huge_pte_modify(pte, newprot));
>  			pte = arch_make_huge_pte(pte, vma, NULL, 0);
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
