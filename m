Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8C06B0037
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 21:09:40 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id ft15so6232729pdb.35
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 18:09:40 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id df8si5437770pdb.68.2014.07.07.18.09.37
        for <linux-mm@kvack.org>;
        Mon, 07 Jul 2014 18:09:39 -0700 (PDT)
Date: Tue, 8 Jul 2014 10:09:36 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v10 6/7] ARM: add pmd_[dirty|mkclean] for THP
Message-ID: <20140708010936.GC6076@bbox>
References: <1404694438-10272-1-git-send-email-minchan@kernel.org>
 <1404694438-10272-7-git-send-email-minchan@kernel.org>
 <20140707092247.GA15168@linaro.org>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="oyUTqETQ0mS9luUI"
Content-Disposition: inline
In-Reply-To: <20140707092247.GA15168@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steve Capper <steve.capper@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org


--oyUTqETQ0mS9luUI
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

On Mon, Jul 07, 2014 at 10:22:48AM +0100, Steve Capper wrote:
> On Mon, Jul 07, 2014 at 09:53:57AM +0900, Minchan Kim wrote:
> > MADV_FREE needs pmd_dirty and pmd_mkclean for detecting recent
> > overwrite of the contents since MADV_FREE syscall is called for
> > THP page.
> > 
> > This patch adds pmd_dirty and pmd_mkclean for THP page MADV_FREE
> > support.
> > 
> > Cc: Catalin Marinas <catalin.marinas@arm.com>
> > Cc: Will Deacon <will.deacon@arm.com>
> > Cc: Steve Capper <steve.capper@linaro.org>
> > Cc: Russell King <linux@arm.linux.org.uk>
> > Cc: linux-arm-kernel@lists.infradead.org
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  arch/arm64/include/asm/pgtable.h | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/arch/arm64/include/asm/pgtable.h b/arch/arm64/include/asm/pgtable.h
> > index 579702086488..f3ec01cef04f 100644
> > --- a/arch/arm64/include/asm/pgtable.h
> > +++ b/arch/arm64/include/asm/pgtable.h
> > @@ -240,10 +240,12 @@ static inline pmd_t pte_pmd(pte_t pte)
> >  #endif
> >  
> >  #define pmd_young(pmd)		pte_young(pmd_pte(pmd))
> > +#define pmd_dirty(pmd)		pte_dirty(pmd_pte(pmd))
> >  #define pmd_wrprotect(pmd)	pte_pmd(pte_wrprotect(pmd_pte(pmd)))
> >  #define pmd_mksplitting(pmd)	pte_pmd(pte_mkspecial(pmd_pte(pmd)))
> >  #define pmd_mkold(pmd)		pte_pmd(pte_mkold(pmd_pte(pmd)))
> >  #define pmd_mkwrite(pmd)	pte_pmd(pte_mkwrite(pmd_pte(pmd)))
> > +#define pmd_mkclean(pmd)	pte_pmd(pte_mkclean(pmd_pte(pmd)))
> >  #define pmd_mkdirty(pmd)	pte_pmd(pte_mkdirty(pmd_pte(pmd)))
> >  #define pmd_mkyoung(pmd)	pte_pmd(pte_mkyoung(pmd_pte(pmd)))
> >  #define pmd_mknotpresent(pmd)	(__pmd(pmd_val(pmd) & ~PMD_TYPE_MASK))
> > -- 
> > 2.0.0
> >
> 
> Hi Minchan,

Hello Steve and Will,

> 
> This looks good to me too.
> As Will said this applies to arm64, we will also need a version for:
> arch/arm/include/asm/pgtable-3level.h.

Does it work?

diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 85c60adc8b60..3a7bb8dc7d05 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -220,6 +220,8 @@ static inline pmd_t *pmd_offset(pud_t *pud, unsigned long addr)
 #define pmd_trans_splitting(pmd) (pmd_val(pmd) & PMD_SECT_SPLITTING)
 #endif
 
+#define pmd_dirty	(pmd_val(pmd) & PMD_SECT_DIRTY)
+
 #define PMD_BIT_FUNC(fn,op) \
 static inline pmd_t pmd_##fn(pmd_t pmd) { pmd_val(pmd) op; return pmd; }
 
@@ -228,6 +230,7 @@ PMD_BIT_FUNC(mkold,	&= ~PMD_SECT_AF);
 PMD_BIT_FUNC(mksplitting, |= PMD_SECT_SPLITTING);
 PMD_BIT_FUNC(mkwrite,   &= ~PMD_SECT_RDONLY);
 PMD_BIT_FUNC(mkdirty,   |= PMD_SECT_DIRTY);
+PMD_BIT_FUNC(mkclean,   &= ~PMD_SECT_DIRTY);
 PMD_BIT_FUNC(mkyoung,   |= PMD_SECT_AF);
 
 #define pmd_mkhuge(pmd)		(__pmd(pmd_val(pmd) & ~PMD_TABLE_BIT))
-- 
2.0.0

> 
> Is there a testcase we can run to check that this patch set is working
> well for arm/arm64?

I just run several instance of attached simple stress with heavy kernel
build in parallel on 1G RAM machine.

Thanks for the review!

> 
> Cheers,
> -- 
> Steve 
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--oyUTqETQ0mS9luUI
Content-Type: text/x-csrc; charset=utf-8
Content-Disposition: attachment; filename="thp_alloc.c"

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <pthread.h>

#define CHUNK_SIZE (20<<20)
#define SLEEP_TIME_SEC 	2
#define NUM_THREAD	12
#define QUIT		1000

int quit;

void alloc_thp()
{
	int i;
	int ret;
	char *ptr;

	/* should be aligned with 2M which is THP page size */
	ret = posix_memalign((void**)&ptr, 2<<20, CHUNK_SIZE);
	if (ret) {
		fprintf(stderr, "fail to allocate\n");
		return;
	}
		
	memset(ptr, 'a', CHUNK_SIZE);
	ret = madvise(ptr, CHUNK_SIZE, 5);
	if (ret) {
		perror("fail to madvise");
		return;
	}

	sleep(SLEEP_TIME_SEC);

	memset(ptr, 'b', CHUNK_SIZE);
	sleep(SLEEP_TIME_SEC);

	for (i = 0; i < CHUNK_SIZE; i++) {
		if (ptr[i] != 'b') {
			fprintf(stderr, "fail to verify\n");
			fprintf(stderr, "Something wrong\n");
			return;
		}
	}

	free(ptr);
}

void *thread_alloc(void *priv)
{
	int n = 0;

	while(!quit) {
		alloc_thp();
		if (!(n++ % 5))
			printf("I'm working\n");
		if (n == QUIT)
			return;
	}
}

int main()
{
	int i, ret;
	pthread_t thread[NUM_THREAD];

	for (i = 0; i < NUM_THREAD; i++) {
		ret = pthread_create(&thread[i], NULL, thread_alloc, NULL);
		if (ret) {
			perror("fail to create thread\n");
			return 1;
		}
	}

	scanf("%d", &quit);
	for (i = 0; i < NUM_THREAD; i++)
		pthread_join(thread[i], NULL);

	printf("Test Done\n");	
	return 0;
}

--oyUTqETQ0mS9luUI--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
