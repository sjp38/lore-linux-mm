Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id EDBA56B00B2
	for <linux-mm@kvack.org>; Mon,  9 Jun 2014 17:51:10 -0400 (EDT)
Received: by mail-pd0-f172.google.com with SMTP id fp1so5324061pdb.31
        for <linux-mm@kvack.org>; Mon, 09 Jun 2014 14:51:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id em3si31990466pbb.194.2014.06.09.14.51.09
        for <linux-mm@kvack.org>;
        Mon, 09 Jun 2014 14:51:10 -0700 (PDT)
Message-ID: <53962C4D.30600@intel.com>
Date: Mon, 09 Jun 2014 14:51:09 -0700
From: Dave Hansen <dave.hansen@intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/7] mm/pagewalk: replace mm_walk->skip with more general
 mm_walk->control
References: <1402095520-10109-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402095520-10109-3-git-send-email-n-horiguchi@ah.jp.nec.com> <539612A8.8080303@intel.com> <1402349339-n9udlcv2@n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1402349339-n9udlcv2@n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

On 06/09/2014 02:29 PM, Naoya Horiguchi wrote:
>   static int subpage_walk_pmd_entry(pmd_t *pmd, unsigned long addr,
>                                    unsigned long end, struct mm_walk *walk)
>   {
>          struct vm_area_struct *vma = walk->vma;
> +        spin_unlock(walk->ptl);
>          split_huge_page_pmd(vma, addr, pmd);
> +        spin_lock(walk->ptl);
>          return 0;
>   }
> 
> I thought it's straightforward but dirty, but my workaround in this patch
> was dirty too. So I'm fine to give up the control stuff and take this one.

I think there's essentially no way to fix this with the current
handlers.  This needs the locks to not be held, and everything else
needs them held so that they don't have to do it themselves.

Instead of a flag to control the walk directly, we could have one that
controls whether the locks are held, although that seems quite prone to
breakage.

I think this is rare-enough code that we can live with the hack that
you've got above, although we need to run it by the ppc folks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
