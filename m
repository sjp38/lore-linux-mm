Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8141B6B0273
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:35:48 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id t3-v6so14775171pgp.0
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 08:35:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t1-v6sor2141586pgj.35.2018.10.15.08.35.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 08:35:47 -0700 (PDT)
Date: Mon, 15 Oct 2018 18:35:41 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] mm: thp: relocate flush_cache_range() in
 migrate_misplaced_transhuge_page()
Message-ID: <20181015153541.kgcnlo2ao2v3padj@kshutemo-mobl1>
References: <20181013002430.698-4-aarcange@redhat.com>
 <201810141746.0UhjFtof%fengguang.wu@intel.com>
 <20181014195853.GA2711@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181014195853.GA2711@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, Aaron Tomlin <atomlin@redhat.com>, Mel Gorman <mgorman@suse.de>, Jerome Glisse <jglisse@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>

On Sun, Oct 14, 2018 at 03:58:53PM -0400, Andrea Arcangeli wrote:
> On Sun, Oct 14, 2018 at 05:58:27PM +0800, kbuild test robot wrote:
> > Hi Andrea,
> > 
> > Thank you for the patch! Yet something to improve:
> > 
> > [auto build test ERROR on linux-sof-driver/master]
> > [also build test ERROR on v4.19-rc7 next-20181012]
> > [if your patch is applied to the wrong git tree, please drop us a note to help improve the system]
> > 
> > url:    https://github.com/0day-ci/linux/commits/Andrea-Arcangeli/mm-thp-fix-MADV_DONTNEED-vs-migrate_misplaced_transhuge_page-race-condition/20181014-143004
> > base:   https://github.com/thesofproject/linux master
> > config: arm64-defconfig (attached as .config)
> > compiler: aarch64-linux-gnu-gcc (Debian 7.2.0-11) 7.2.0
> > reproduce:
> >         wget https://raw.githubusercontent.com/intel/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
> >         chmod +x ~/bin/make.cross
> >         # save the attached .config to linux build tree
> >         GCC_VERSION=7.2.0 make.cross ARCH=arm64 
> > 
> > All errors (new ones prefixed by >>):
> > 
> >    mm/migrate.c: In function 'migrate_misplaced_transhuge_page':
> > >> mm/migrate.c:2054:32: error: 'end' undeclared (first use in this function); did you mean '_end'?
> >      flush_cache_range(vma, start, end + HPAGE_PMD_SIZE);
> >                                    ^~~
> >                                    _end
> >    mm/migrate.c:2054:32: note: each undeclared identifier is reported only once for each function it appears in
> 
> Nice non-x86 coverage. I intended converted "end" to "start +
> HPAGE_PMD_SIZE" to delete the "end" variable purely to shut off a
> warning about unused "end" var from gcc on x86, but the s/end/start/
> was missed and it still build fine on x86 but not anymore on aarch64.
> 
> Anyway I'm waiting some feedback about the whole patchset, before
> resending patch 3/3.
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 9bf5fe9a1008..8afb41167641 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -2050,7 +2050,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
>  	new_page->mapping = page->mapping;
>  	new_page->index = page->index;
>  	/* flush the cache before copying using the kernel virtual address */
> -	flush_cache_range(vma, start, end + HPAGE_PMD_SIZE);
> +	flush_cache_range(vma, start, start + HPAGE_PMD_SIZE);
>  	migrate_page_copy(new_page, page);
>  	WARN_ON(PageLRU(new_page));
>  
> 

Looks good to me with the fixup.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov
