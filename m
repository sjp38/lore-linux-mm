Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f199.google.com (mail-ob0-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id ABB2C6B0005
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 23:15:48 -0400 (EDT)
Received: by mail-ob0-f199.google.com with SMTP id hx8so4776419obb.2
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 20:15:48 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id 3si9672476pft.27.2016.06.16.20.15.47
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 20:15:48 -0700 (PDT)
From: "Huang\, Ying" <ying.huang@intel.com>
Subject: Re: [PATCH] MADVISE_FREE, THP: Fix madvise_free_huge_pmd return value after splitting
References: <1466132640-18932-1-git-send-email-ying.huang@intel.com>
Date: Thu, 16 Jun 2016 20:15:47 -0700
In-Reply-To: <1466132640-18932-1-git-send-email-ying.huang@intel.com> (Ying
	Huang's message of "Thu, 16 Jun 2016 20:03:54 -0700")
Message-ID: <87oa70ld3w.fsf@yhuang-mobile.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

"Huang, Ying" <ying.huang@intel.com> writes:

> From: Huang Ying <ying.huang@intel.com>
>
> madvise_free_huge_pmd should return 0 if the fallback PTE operations are
> required.  In madvise_free_huge_pmd, if part pages of THP are discarded,
> the THP will be split and fallback PTE operations should be used if
> splitting succeeds.  But the original code will make fallback PTE
> operations skipped, after splitting succeeds.  Fix that via make
> madvise_free_huge_pmd return 0 after splitting successfully, so that the
> fallback PTE operations will be done.
>
> Know issues: if my understanding were correct, return 1 from
> madvise_free_huge_pmd means the following processing for the PMD should
> be skipped, while return 0 means the following processing is still
> needed.  So the function should return 0 only if the THP is split
> successfully or the PMD is not trans huge.  But the pmd_trans_unstable
> after madvise_free_huge_pmd guarantee the following processing will be
> skipped for huge PMD.  So current code can run properly.  But if my
> understanding were correct, we can clean up return code of
> madvise_free_huge_pmd accordingly.
>

This patch was tested with the below program, given some memory
pressure, the the value read back is 0 with the patch, that is, THP is
split, freed and zero page is mapped.  Without the patch, the value read
back is still 1, that is, the page is not freed.

Best Regards,
Huang, Ying

------------------------------->
#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <stdlib.h>
#include <sys/mman.h>

#ifndef MADV_FREE
#define MADV_FREE	8		/* free pages only if memory pressure */
#endif

#define ONE_MB		(1024 * 1024)
#define THP_SIZE	(2 * ONE_MB)
#define THP_MASK	(THP_SIZE - 1)
#define MAP_SIZE	(16 * ONE_MB)

#define ERR_EXIT_ON(cond, msg)					\
	do {							\
		int __cond_in_macro = (cond);			\
		if (__cond_in_macro)				\
			error_exit(__cond_in_macro, (msg));	\
	} while (0)

void error_exit(int ret, const char *msg)
{
	fprintf(stderr, "Error: %s, ret : %d, error: %s",
		msg, ret, strerror(errno));
	exit(1);
}

void write_and_free()
{
	int ret;
	void *addr;
	int *pn;

	addr = mmap(NULL, MAP_SIZE, PROT_READ | PROT_WRITE,
		    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
	ERR_EXIT_ON(ret, "mmap");
	ret = madvise(addr, MAP_SIZE, MADV_HUGEPAGE);
	ERR_EXIT_ON(ret, "advise hugepage");
	pn = (int *)(((unsigned long)addr + THP_SIZE) & ~THP_MASK);
	*pn = 1;
	printf("map 1 THP, hit any key to free part of it: ");
 	fgetc(stdin);
	ret = madvise(pn, ONE_MB, MADV_FREE);
	ERR_EXIT_ON(ret, "advise free");
	printf("freed part of THP, hit any key to get the new value: ");
 	fgetc(stdin);
	printf("val: %d\n", *pn);
}

int main(int argc, char *argv[])
{
	write_and_free();
	return 0;
}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
