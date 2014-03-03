Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f179.google.com (mail-ea0-f179.google.com [209.85.215.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4E7116B0035
	for <linux-mm@kvack.org>; Mon,  3 Mar 2014 13:07:37 -0500 (EST)
Received: by mail-ea0-f179.google.com with SMTP id q10so4760098ead.10
        for <linux-mm@kvack.org>; Mon, 03 Mar 2014 10:07:36 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id he7si11510029wjc.26.2014.03.03.10.07.34
        for <linux-mm@kvack.org>;
        Mon, 03 Mar 2014 10:07:35 -0800 (PST)
Date: Mon, 03 Mar 2014 13:07:07 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5314c4e7.47c0c20a.23ba.ffff94feSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <1392737235-27286-2-git-send-email-steve.capper@linaro.org>
References: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
 <1392737235-27286-2-git-send-email-steve.capper@linaro.org>
Subject: Re: [PATCH 1/5] mm: hugetlb: Introduce huge_pte_{page,present,young}
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: steve.capper@linaro.org
Cc: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org, will.deacon@arm.com, catalin.marinas@arm.com, arnd@arndb.de, dsaxena@linaro.org, robherring2@gmail.com

Hi Steve,

On Tue, Feb 18, 2014 at 03:27:11PM +0000, Steve Capper wrote:
> Introduce huge pte versions of pte_page, pte_present and pte_young.
> This allows ARM (without LPAE) to use alternative pte processing logic
> for huge ptes.
> 
> Where these functions are not defined by architectural code they
> fallback to the standard functions.
> 
> Signed-off-by: Steve Capper <steve.capper@linaro.org>
> ---
>  include/linux/hugetlb.h | 12 ++++++++++++
>  mm/hugetlb.c            | 22 +++++++++++-----------
>  2 files changed, 23 insertions(+), 11 deletions(-)

How about replacing other archs' arch-dependent code with new functions?

  [~/dev]$ find arch/ -name "hugetlbpage.c" | xargs grep pte_page
  arch/s390/mm/hugetlbpage.c:             pmd_val(pmd) |= pte_page(pte)[1].index;
  arch/powerpc/mm/hugetlbpage.c:  page = pte_page(*ptep);
  arch/powerpc/mm/hugetlbpage.c:  head = pte_page(pte);
  arch/x86/mm/hugetlbpage.c:      page = &pte_page(*pte)[vpfn % (HPAGE_SIZE/PAGE_SIZE)];
  arch/ia64/mm/hugetlbpage.c:     page = pte_page(*ptep);
  arch/mips/mm/hugetlbpage.c:     page = pte_page(*(pte_t *)pmd);
  arch/tile/mm/hugetlbpage.c:     page = pte_page(*(pte_t *)pmd);
  arch/tile/mm/hugetlbpage.c:     page = pte_page(*(pte_t *)pud);
  [~/dev]$ find arch/ -name "hugetlbpage.c" | xargs grep pte_present
  arch/s390/mm/hugetlbpage.c:     if (pte_present(pte)) {
  arch/sparc/mm/hugetlbpage.c:    if (!pte_present(*ptep) && pte_present(entry))
  arch/sparc/mm/hugetlbpage.c:    if (pte_present(entry))
  arch/tile/mm/hugetlbpage.c:     if (!pte_present(*ptep) && huge_shift[level] != 0) {
  arch/tile/mm/hugetlbpage.c:             if (pte_present(pte) && pte_super(pte))
  arch/tile/mm/hugetlbpage.c:     if (!pte_present(*pte))

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
