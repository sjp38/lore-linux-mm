Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 26B3E6B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 09:40:28 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id et14so34260114pad.4
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 06:40:27 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id fw3si22602481pbb.182.2015.02.09.06.40.26
        for <linux-mm@kvack.org>;
        Mon, 09 Feb 2015 06:40:27 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <54c69dbb.9IbFgxgVUFfaIvqP%akpm@linux-foundation.org>
References: <54c69dbb.9IbFgxgVUFfaIvqP%akpm@linux-foundation.org>
Subject: RE: + mm-fix-false-positive-warning-on-exit-due-mm_nr_pmdsmm.patch
 added to -mm tree
Content-Transfer-Encoding: 7bit
Message-Id: <20150209144020.BA6726F9@black.fi.intel.com>
Date: Mon,  9 Feb 2015 16:40:20 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, gxt@mprc.pku.edu.cn, james.hogan@imgtec.com, linux@arm.linux.org.uk, nm@ti.com, tyler.baker@linaro.org, mm-commits@vger.kernel.org, linux-mm@kvack.org

akpm@ wrote:
> 
> The patch titled
>      Subject: mm: fix false-positive warning on exit due mm_nr_pmds(mm)
> has been added to the -mm tree.  Its filename is
>      mm-fix-false-positive-warning-on-exit-due-mm_nr_pmdsmm.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/mm-fix-false-positive-warning-on-exit-due-mm_nr_pmdsmm.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/mm-fix-false-positive-warning-on-exit-due-mm_nr_pmdsmm.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Subject: mm: fix false-positive warning on exit due mm_nr_pmds(mm)
> 
> The problem is that we check nr_ptes/nr_pmds in exit_mmap() which happens
> *before* pgd_free().  And if an arch does pte/pmd allocation in
> pgd_alloc() and frees them in pgd_free() we see offset in counters by the
> time of the checks.
> 
> We tried to workaround this by offsetting expected counter value according
> to FIRST_USER_ADDRESS for both nr_pte and nr_pmd in exit_mmap().  But it
> doesn't work in some cases:
> 
> 1. ARM with LPAE enabled also has non-zero USER_PGTABLES_CEILING, but
>    upper addresses occupied with huge pmd entries, so the trick with
>    offsetting expected counter value will get really ugly: we will have
>    to apply it nr_pmds, but not nr_ptes.
> 
> 2. Metag has non-zero FIRST_USER_ADDRESS, but doesn't do allocation
>    pte/pmd page tables allocation in pgd_alloc(), just setup a pgd entry
>    which is allocated at boot and shared accross all processes.
> 
> The proposal is to move the check to check_mm() which happens *after*
> pgd_free() and do proper accounting during pgd_alloc() and pgd_free()
> which would bring counters to zero if nothing leaked.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Tyler Baker <tyler.baker@linaro.org>
> Tested-by: Nishanth Menon <nm@ti.com>
> Cc: Russell King <linux@arm.linux.org.uk>
> Cc: James Hogan <james.hogan@imgtec.com>
> Cc: Guan Xuetao <gxt@mprc.pku.edu.cn>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---

Small fix up for the patch.
