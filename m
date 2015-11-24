Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id CBD666B0038
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:09:33 -0500 (EST)
Received: by wmww144 with SMTP id w144so129199029wmw.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:09:33 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id pd8si25325656wjb.183.2015.11.24.01.09.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 01:09:32 -0800 (PST)
Received: by wmec201 with SMTP id c201so198163720wme.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:09:32 -0800 (PST)
Date: Tue, 24 Nov 2015 11:09:30 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH -mm v2] mm: add page_check_address_transhuge helper
Message-ID: <20151124090930.GB15712@node.shutemov.name>
References: <1448011913-12121-1-git-send-email-vdavydov@virtuozzo.com>
 <20151124042941.GE705@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151124042941.GE705@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 01:29:41PM +0900, Sergey Senozhatsky wrote:
> Hello,
> 
> On (11/20/15 12:31), Vladimir Davydov wrote:
> [..]
> > -	if (ptep_clear_flush_young_notify(vma, address, pte)) {
> > -		/*
> > -		 * Don't treat a reference through a sequentially read
> > -		 * mapping as such.  If the page has been used in
> > -		 * another mapping, we will catch it; if this other
> > -		 * mapping is already gone, the unmap path will have
> > -		 * set PG_referenced or activated the page.
> > -		 */
> > -		if (likely(!(vma->vm_flags & VM_SEQ_READ)))
> > +	if (pte) {
> > +		if (ptep_clear_flush_young_notify(vma, address, pte)) {
> > +			/*
> > +			 * Don't treat a reference through a sequentially read
> > +			 * mapping as such.  If the page has been used in
> > +			 * another mapping, we will catch it; if this other
> > +			 * mapping is already gone, the unmap path will have
> > +			 * set PG_referenced or activated the page.
> > +			 */
> > +			if (likely(!(vma->vm_flags & VM_SEQ_READ)))
> > +				referenced++;
> > +		}
> > +		pte_unmap(pte);
> > +	} else {
> > +		if (pmdp_clear_flush_young_notify(vma, address, pmd))
> >  			referenced++;
> >  	}
> 
> # CONFIG_TRANSPARENT_HUGEPAGE is not set
> 
> x86_64, 4.4.0-rc2-mm1
> 
> 
> mm/built-in.o: In function `page_referenced_one':
> rmap.c:(.text+0x32070): undefined reference to `pmdp_clear_flush_young'

Something like this?

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 374931f32ebc..4ea9c4ef5146 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -66,8 +66,12 @@ static int page_idle_clear_pte_refs_one(struct page *page,
 	if (pte) {
 		referenced = ptep_clear_young_notify(vma, addr, pte);
 		pte_unmap(pte);
-	} else
+	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
 		referenced = pmdp_clear_young_notify(vma, addr, pmd);
+	} else {
+		/* unexpected pmd-mapped page? */
+		WARN_ON_ONCE(1);
+	}
 
 	spin_unlock(ptl);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 27916086ac50..499b24511b1f 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -929,9 +929,12 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 				referenced++;
 		}
 		pte_unmap(pte);
-	} else {
+	} else if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE)) {
 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
 			referenced++;
+	} else {
+		/* unexpected pmd-mapped page? */
+		WARN_ON_ONCE(1);
 	}
 	spin_unlock(ptl);
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
