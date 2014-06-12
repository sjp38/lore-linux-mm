Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3056B0039
	for <linux-mm@kvack.org>; Thu, 12 Jun 2014 18:36:52 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id q59so1993643wes.13
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 15:36:51 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id f13si3809642wjz.137.2014.06.12.15.36.49
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 15:36:50 -0700 (PDT)
Message-ID: <539a2b82.4d55c20a.4b2c.ffff905bSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH -mm v2 06/11] pagewalk: add size to struct mm_walk
Date: Thu, 12 Jun 2014 18:36:40 -0400
In-Reply-To: <539A248F.2090306@intel.com>
References: <1402609691-13950-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1402609691-13950-7-git-send-email-n-horiguchi@ah.jp.nec.com> <539A248F.2090306@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org

Hello Dave,

On Thu, Jun 12, 2014 at 03:07:11PM -0700, Dave Hansen wrote:
> On 06/12/2014 02:48 PM, Naoya Horiguchi wrote:
> > This variable is helpful if we try to share the callback function between
> > multiple slots (for example between pte_entry() and pmd_entry()) as done
> > in later patches.
> 
> smaps_pte() already does this:
> 
> static int smaps_pte(pte_t *pte, unsigned long addr, unsigned long end,
>                         struct mm_walk *walk)
> ...
>         unsigned long ptent_size = end - addr;
> 
> Other than the hugetlb handler, can't we always imply the size from
> end-addr?

Good point, thanks. I didn't care about this variable.

Currently we call this walk via walk_page_vma() so addr and end is
always between [vma->vm_start, vma->vm_end]. If a vma is not aligned
to pmd-boundary, this size might have incorrect value.
But using end-addr seems to cause no practical problem because in
such case first or final pmd never have a thp.
I'm not sure every caller (especially callers of walk_page_range())
assumes addr/end is page aligned, but walk->size approach looks safer
to me.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
