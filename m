Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 273EA6B0035
	for <linux-mm@kvack.org>; Thu, 17 Jul 2014 18:57:48 -0400 (EDT)
Received: by mail-pd0-f170.google.com with SMTP id g10so3896963pdj.15
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 15:57:47 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id pb2si3849354pac.28.2014.07.17.15.57.46
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 17 Jul 2014 15:57:47 -0700 (PDT)
Received: by mail-pd0-f178.google.com with SMTP id w10so3949385pde.9
        for <linux-mm@kvack.org>; Thu, 17 Jul 2014 15:57:46 -0700 (PDT)
Date: Thu, 17 Jul 2014 15:55:40 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: hugetlb: fix copy_hugetlb_page_range() (Re: [BUG]
 new copy_hugetlb_page_range() causing crashes)
In-Reply-To: <20140717223824.GA828@nhori.bos.redhat.com>
Message-ID: <alpine.LSU.2.11.1407171553560.2544@eggly.anvils>
References: <019768ac467043a4aaea3e455cb74db7@BPXC18GP.gisp.nec.co.jp> <FC3CA273EA98D94B96901B237F5F506BB61DC0@irvmail101.necam.prv> <20140717201203.GA23591@bender.morinfr.org> <20140717213332.GA20284@nhori.bos.redhat.com> <20140717215936.GA28949@bender.morinfr.org>
 <20140717223824.GA828@nhori.bos.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Guillaume Morin <guillaume@morinfr.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>, linux-mm@kvack.org

On Thu, 17 Jul 2014, Naoya Horiguchi wrote:

> # CCed Andrew, and linux-mm 
> 
> On Thu, Jul 17, 2014 at 11:59:36PM +0200, Guillaume Morin wrote:
> > On 17 Jul 17:33, Naoya Horiguchi wrote:
> ...
> > > And it seems that this also happens on v3.16-rc5.
> > > So it might be an upstream bug, not a stable-specific matter.
> > 
> > That's my understanding as well. I just reported it for 3.4 and 3.14
> > since these were the kernels I could easily try my original test with.
> 
> OK. I've checked the fix you suggested below on mainline, and
> it passed our test program.
> 
> > > It looks strange to me that the problem is gone by removing the commit
> > > 4a705fef98 (although I confirmed it is,) because the kernel's behavior
> > > shouldn't change unless (is_hugetlb_entry_migration(entry) ||
> > > is_hugetlb_entry_hwpoisoned(entry)) is true. And I checked with systemtap
> > > that both these check returned false in the above test program.
> > > So I'm wondering why the commit makes difference for this test program.
> > 
> > I don't know why I am just thinking about that now.  Isn't this the fact
> > that your patch moved the huge_ptep_get() before
> > huge_ptep_set_wrprotect() in the pte_present() cow case?
> 
> Ah, right. I was really blind :(
> 
> > 
> > Actually, I've just tried to re-add the huge_ptep_get call for that
> > case and it's fixing the problem for me...
> > 
> > Hmm, want a patch?
> 
> Thanks, but it's just a oneliner, so I wrote the one.
> 
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Thu, 17 Jul 2014 18:11:22 -0400
> Subject: [PATCH] mm: hugetlb: fix copy_hugetlb_page_range()
> 
> commit 4a705fef98 ("hugetlb: fix copy_hugetlb_page_range() to handle
> migration/hwpoisoned entry") changed the order of huge_ptep_set_wrprotect()
> and huge_ptep_get(), which leads to break some workload like hugepage-backed
> heap allocation via libhugetlbfs. This patch fixes it.
> 
> The test program for the problem is shown below:
> 
>   $ cat heap.c
>   #include <unistd.h>
>   #include <stdlib.h>
>   #include <string.h>
> 
>   #define HPS 0x200000
> 
>   int main() {
>   	int i;
>   	char *p = malloc(HPS);
>   	memset(p, '1', HPS);
>   	for (i = 0; i < 5; i++) {
>   		if (!fork()) {
>   			memset(p, '2', HPS);
>   			p = malloc(HPS);
>   			memset(p, '3', HPS);
>   			free(p);
>   			return 0;
>   		}
>   	}
>   	sleep(1);
>   	free(p);
>   	return 0;
>   }
> 
>   $ export HUGETLB_MORECORE=yes ; export HUGETLB_NO_PREFAULT= ; hugectl --heap ./heap
> 
> Reported-by: Guillaume Morin <guillaume@morinfr.org>
> Suggested-by: Guillaume Morin <guillaume@morinfr.org>
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Acked-by: Hugh Dickins <hughd@google.com>

Yes, indeed: I'm ashamed not to have noticed that - sorry.

> Cc: stable@vger.kernel.org
> ---
>  mm/hugetlb.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index a8d4155eb019..7263c770e9b3 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -2597,6 +2597,7 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
>  		} else {
>  			if (cow)
>  				huge_ptep_set_wrprotect(src, addr, src_pte);
> +			entry = huge_ptep_get(src_pte);
>  			ptepage = pte_page(entry);
>  			get_page(ptepage);
>  			page_dup_rmap(ptepage);
> -- 
> 1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
