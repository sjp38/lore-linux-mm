Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com [209.85.192.49])
	by kanga.kvack.org (Postfix) with ESMTP id 6D4CD6B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 13:50:25 -0400 (EDT)
Received: by qgh62 with SMTP id 62so43904143qgh.1
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:50:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x7si17330904qce.15.2015.03.18.10.42.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 10:43:12 -0700 (PDT)
Date: Wed, 18 Mar 2015 13:42:38 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH v2] mm: don't count preallocated pmds
In-Reply-To: <20150318165313.GB5822@node.dhcp.inet.fi>
Message-ID: <alpine.LRH.2.02.1503181328450.17058@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1503181057340.14516@file01.intranet.prod.int.rdu2.redhat.com> <20150318161246.GA5822@node.dhcp.inet.fi> <alpine.LRH.2.02.1503181219001.6223@file01.intranet.prod.int.rdu2.redhat.com> <20150318165313.GB5822@node.dhcp.inet.fi>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-parisc@vger.kernel.org, jejb@parisc-linux.org, dave.anglin@bell.net



On Wed, 18 Mar 2015, Kirill A. Shutemov wrote:

> On Wed, Mar 18, 2015 at 12:25:11PM -0400, Mikulas Patocka wrote:
> > 
> > 
> > On Wed, 18 Mar 2015, Kirill A. Shutemov wrote:
> > 
> > > On Wed, Mar 18, 2015 at 11:16:42AM -0400, Mikulas Patocka wrote:
> > > > Hi
> > > > 
> > > > Here I'm sending a patch that fixes numerous "BUG: non-zero nr_pmds on 
> > > > freeing mm: -1" errors on 64-bit PA-RISC kernel.
> > > > 
> > > > I think the patch posted here 
> > > > http://www.spinics.net/lists/linux-parisc/msg05981.html is incorrect, it 
> > > > wouldn't work if the affected address range is freed and allocated 
> > > > multiple times.
> > > > 	- 1. alloc pgd with built-in pmd, the count of pmds is 1
> > > > 	- 2. free the range covered by the built-in pmd, the count of pmds 
> > > > 		is 0, but the built-in pmd is still present
> > > 
> > > Hm. Okay. I didn't realize you have special case in pmd_clear() for these
> > > pmds.
> > > 
> > > What about adding mm_inc_nr_pmds() in pmd_clear() for PxD_FLAG_ATTACHED
> > > to compensate mm_dec_nr_pmds() in free_pmd_range()?
> > 
> > pmd_clear clears one entry in the pmd, it wouldn't work. You need to add 
> > it to pgd_clear. That clears the pointer to the pmd (and does nothing if 
> > it is asked to clear the pointer to the preallocated pmd). But pgd_clear 
> > doesn't receive the pointer to mm.
> 
> I meant pmd_free(), not pmd_clear(). This should work fine.

OK, here is the updated patch.


From: Mikulas Patocka <mpatocka@redhat.com>

The patch dc6c9a35b66b520cf67e05d8ca60ebecad3b0479 that counts pmds
allocated for a process introduced a bug on 64-bit PA-RISC kernels.

The PA-RISC architecture preallocates one pmd with each pgd. This
preallocated pmd can never be freed - pmd_free does nothing when it is
called with this pmd. When the kernel attempts to free this preallocated
pmd, it decreases the count of allocated pmds. The result is that the
counter underflows and this error is reported.

This patch fixes the bug by artifically incrementing the counter in
pmd_free when the kernel tries to free the preallocated pmd.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 arch/parisc/include/asm/pgalloc.h |    9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

Index: linux-4.0-rc4/arch/parisc/include/asm/pgalloc.h
===================================================================
--- linux-4.0-rc4.orig/arch/parisc/include/asm/pgalloc.h	2015-03-18 18:02:16.000000000 +0100
+++ linux-4.0-rc4/arch/parisc/include/asm/pgalloc.h	2015-03-18 18:03:26.000000000 +0100
@@ -74,8 +74,13 @@ static inline void pmd_free(struct mm_st
 {
 #ifdef CONFIG_64BIT
 	if(pmd_flag(*pmd) & PxD_FLAG_ATTACHED)
-		/* This is the permanent pmd attached to the pgd;
-		 * cannot free it */
+		/*
+		 * This is the permanent pmd attached to the pgd;
+		 * cannot free it.
+		 * Increment the counter to compensate for the decrement
+		 * done by generic mm code.
+		 */
+		mm_inc_nr_pmds(mm);
 		return;
 #endif
 	free_pages((unsigned long)pmd, PMD_ORDER);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
