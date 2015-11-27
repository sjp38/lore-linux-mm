Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 80CC76B0255
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 05:16:57 -0500 (EST)
Received: by lfs39 with SMTP id 39so121448144lfs.3
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 02:16:56 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id p70si21039524lfd.147.2015.11.27.02.16.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 02:16:56 -0800 (PST)
Date: Fri, 27 Nov 2015 13:16:40 +0300
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: Re: linux-next: Tree for Nov 27 (mm stuff)
Message-ID: <20151127101640.GO29014@esperanza>
References: <20151127160514.7b2022f2@canb.auug.org.au>
 <56580097.8050405@infradead.org>
 <20151127091047.GA585@swordfish>
 <20151127091739.GB585@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20151127091739.GB585@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, linux-next@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, Linux MM <linux-mm@kvack.org>

On Fri, Nov 27, 2015 at 06:17:39PM +0900, Sergey Senozhatsky wrote:
> Cc Vladimir, Kirill, Andrew
> 
> On (11/27/15 18:10), Sergey Senozhatsky wrote:
> > On (11/26/15 23:04), Randy Dunlap wrote:
> > > 
> > > on i386:
> > > 
> > > mm/built-in.o: In function `page_referenced_one':
> > > rmap.c:(.text+0x362a2): undefined reference to `pmdp_clear_flush_young'
> > > mm/built-in.o: In function `page_idle_clear_pte_refs_one':
> > > page_idle.c:(.text+0x4b2b8): undefined reference to `pmdp_test_and_clear_young'
> > > 
> > 
> > Hello,
> > 
> > https://lkml.org/lkml/2015/11/24/160
> > 
> > corresponding patch mm-add-page_check_address_transhuge-helper-fix.patch added
> > to -mm tree.
> > 
> 
> my bad, it's in -next already.

Sigh, this fails for me too :-( Kirill was right that this hack might
not always work.

So, we still need to check explicitly if CONFIG_TRANSPARENT_HUGEPAGE is
enabled whenever we use page_check_address_transhuge, as Kirill proposed
initially. The patch below does the trick. The previous "fix" is still
useful though, because it reduces the size of kernels compiled w/o
tranparent huge page feature.

Andrew, could you please merge this patch too?

Sorry for all the trouble.

Thanks,
Vladimir
---
diff --git a/mm/page_idle.c b/mm/page_idle.c
index 374931f..aa7ca61 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -66,7 +66,7 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 	if (pte) {
 		referenced = ptep_clear_young_notify(vma, addr, pte);
 		pte_unmap(pte);
-	} else
+	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		referenced = pmdp_clear_young_notify(vma, addr, pmd);
 
 	spin_unlock(ptl);
diff --git a/mm/rmap.c b/mm/rmap.c
index 6f37126..3286d49 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -931,7 +931,7 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 				referenced++;
 		}
 		pte_unmap(pte);
-	} else {
+	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
