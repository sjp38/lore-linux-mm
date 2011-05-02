Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EEFA6B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 19:57:38 -0400 (EDT)
Subject: Re: mmotm 2011-04-29 - wonky VmRSS and VmHWM values after swapping
In-Reply-To: Your message of "Mon, 02 May 2011 16:44:30 PDT."
             <20110502164430.eb7d451d.akpm@linux-foundation.org>
From: Valdis.Kletnieks@vt.edu
References: <201104300002.p3U02Ma2026266@imap1.linux-foundation.org> <49683.1304296014@localhost> <8185.1304347042@localhost>
            <20110502164430.eb7d451d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1304380652_5156P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Date: Mon, 02 May 2011 19:57:32 -0400
Message-ID: <51961.1304380652@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>

--==_Exmh_1304380652_5156P
Content-Type: text/plain; charset=us-ascii

On Mon, 02 May 2011 16:44:30 PDT, Andrew Morton said:

> hm, me too.  After boot, hald has a get_mm_counter(mm, MM_ANONPAGES) of
> 0xffffffffffff3c27.  Bisected to Pater's
> mm-extended-batches-for-generic-mmu_gather.patch, can't see how it did
> that.

Looking at it:
@@ -177,15 +205,24 @@ tlb_finish_mmu(struct mmu_gather *tlb, u
  */
 static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
 {
+       struct mmu_gather_batch *batch;
+
        tlb->need_flush = 1;
+
        if (tlb_fast_mode(tlb)) {
                free_page_and_swap_cache(page);
                return 1; /* avoid calling tlb_flush_mmu() */
        }
-       tlb->pages[tlb->nr++] = page;
-       VM_BUG_ON(tlb->nr > tlb->max);

-       return tlb->max - tlb->nr;
+       batch = tlb->active;
+       batch->pages[batch->nr++] = page;
+       VM_BUG_ON(batch->nr > batch->max);
+       if (batch->nr == batch->max) {
+               if (!tlb_next_batch(tlb))
+                       return 0;
+       }
+
+       return batch->max - batch->nr;
 }

Who's intializing/setting batch->max?  Perhaps whoever set up tlb->active
failed to do so?



--==_Exmh_1304380652_5156P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNv0TscC3lWbTT17ARAnL3AJ9mTDyrWh6ZIkzcyX2o3v4QygwktQCfbzP4
Rk4oeQjHDGys3zlM1mOVXjU=
=9+8J
-----END PGP SIGNATURE-----

--==_Exmh_1304380652_5156P--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
