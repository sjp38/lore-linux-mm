Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6BA7B6B0038
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 08:49:42 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 55so5069342wrx.21
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 05:49:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g44sor4108832eda.28.2017.12.15.05.49.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Dec 2017 05:49:41 -0800 (PST)
Date: Fri, 15 Dec 2017 16:49:38 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv4 09/12] x86/mm: Provide pmdp_establish() helper
Message-ID: <20171215134938.q7cvpy2a2tkgka7n@node.shutemov.name>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
 <20171213105756.69879-10-kirill.shutemov@linux.intel.com>
 <20171213160951.249071f2aecdccb38b6bb646@linux-foundation.org>
 <20171214003318.xli42qgybplln754@node.shutemov.name>
 <20171213163639.7e1fb5c4082888d2e399b310@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213163639.7e1fb5c4082888d2e399b310@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Dec 13, 2017 at 04:36:39PM -0800, Andrew Morton wrote:
> On Thu, 14 Dec 2017 03:33:18 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:
> 
> > On Wed, Dec 13, 2017 at 04:09:51PM -0800, Andrew Morton wrote:
> > > > @@ -181,6 +182,40 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *pmdp)
> > > >  #define native_pmdp_get_and_clear(xp) native_local_pmdp_get_and_clear(xp)
> > > >  #endif
> > > >  
> > > > +#ifndef pmdp_establish
> > > > +#define pmdp_establish pmdp_establish
> > > > +static inline pmd_t pmdp_establish(struct vm_area_struct *vma,
> > > > +		unsigned long address, pmd_t *pmdp, pmd_t pmd)
> > > > +{
> > > > +	pmd_t old;
> > > > +
> > > > +	/*
> > > > +	 * If pmd has present bit cleared we can get away without expensive
> > > > +	 * cmpxchg64: we can update pmdp half-by-half without racing with
> > > > +	 * anybody.
> > > > +	 */
> > > > +	if (!(pmd_val(pmd) & _PAGE_PRESENT)) {
> > > > +		union split_pmd old, new, *ptr;
> > > > +
> > > > +		ptr = (union split_pmd *)pmdp;
> > > > +
> > > > +		new.pmd = pmd;
> > > > +
> > > > +		/* xchg acts as a barrier before setting of the high bits */
> > > > +		old.pmd_low = xchg(&ptr->pmd_low, new.pmd_low);
> > > > +		old.pmd_high = ptr->pmd_high;
> > > > +		ptr->pmd_high = new.pmd_high;
> > > > +		return old.pmd;
> > > > +	}
> > > > +
> > > > +	{
> > > > +		old = *pmdp;
> > > > +	} while (cmpxchg64(&pmdp->pmd, old.pmd, pmd.pmd) != old.pmd);
> > > 
> > > um, what happened here?
> > 
> > Ouch.. Yeah, we need 'do' here. :-/
> > 
> > Apparently, it's a valid C code that would run the body once and it worked for
> > me because I didn't hit the race condition.
> 
> So how the heck do we test this?  Add an artificial delay on the other
> side to open the race window?

Okay, here's a testcase I've come up with:

	#include <pthread.h>
	#include <sys/mman.h>

	#define MAP_BASE        ((void *)0x200000)
	#define MAP_SIZE        (0x200000)

	void *thread(void *p)
	{
		*(char *)p = 1;
		return NULL;
	}

	int main(void)
	{
		pthread_t t;
		char *p;

		p = mmap(MAP_BASE, MAP_SIZE, PROT_READ | PROT_WRITE,
				MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED, -1, 0);

		/* Allocate THP */
		*p = 1;

		/* Make page and PMD clean  */
		madvise(p, MAP_SIZE, MADV_FREE);

		/* New thread would make the PMD dirty again */
		pthread_create(&t, NULL, thread, p);

		/* Trigger split_huge_pmd(). It may lose dirty bit. */
		mprotect(p, 4096, PROT_READ | PROT_WRITE | PROT_EXEC);

		/*
		 * Wait thread to complete.
		 *
		 * Page or PTE by MAP_BASE address *must* be dirty here. If it's not we
		 * can lose data if the page is reclaimed.
		 */
		pthread_join(t, NULL);

		return 0;
	}

To make the bug triggered, I had to make race window larger.
See patch below.

I also check if the page is dirty on exit on kernel side. It's just easier
than make the page reclaimed from userspace and check if data is still
there.

With this patch, the testcase can trigger the race condition within 10 or
so runs in my KVM box.

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 2f2f5e774902..06f6a74ac36d 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -33,6 +33,7 @@
 #include <linux/page_idle.h>
 #include <linux/shmem_fs.h>
 #include <linux/oom.h>
+#include <linux/delay.h>
 
 #include <asm/tlb.h>
 #include <asm/pgalloc.h>
@@ -2131,6 +2132,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 	write = pmd_write(*pmd);
 	young = pmd_young(*pmd);
 	dirty = pmd_dirty(*pmd);
+	mdelay(100);
 	soft_dirty = pmd_soft_dirty(*pmd);
 
 	pmdp_huge_split_prepare(vma, haddr, pmd);
diff --git a/mm/memory.c b/mm/memory.c
index 5eb3d2524bdc..69a207bea1da 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1305,6 +1305,10 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			struct page *page;
 
 			page = _vm_normal_page(vma, addr, ptent, true);
+
+			if (addr == 0x200000)
+				BUG_ON(!(PageDirty(page) || pte_dirty(*pte)));
+
 			if (unlikely(details) && page) {
 				/*
 				 * unmap_shared_mapping_pages() wants to
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
