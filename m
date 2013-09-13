Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 81DE16B0031
	for <linux-mm@kvack.org>; Fri, 13 Sep 2013 10:23:13 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <20130913131907.GC21832@twins.programming.kicks-ass.net>
References: <20130910074748.GA2971@gmail.com>
 <1379077576-2472-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1379077576-2472-4-git-send-email-kirill.shutemov@linux.intel.com>
 <20130913131907.GC21832@twins.programming.kicks-ass.net>
Subject: Re: [PATCH 3/9] mm: introduce api for split page table lock for PMD
 level
Content-Transfer-Encoding: 7bit
Message-Id: <20130913142253.11FCFE0090@blue.fi.intel.com>
Date: Fri, 13 Sep 2013 17:22:52 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Alex Thorlton <athorlton@sgi.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Eric W . Biederman" <ebiederm@xmission.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Al Viro <viro@zeniv.linux.org.uk>, Andi Kleen <ak@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Dave Jones <davej@redhat.com>, David Howells <dhowells@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Kees Cook <keescook@chromium.org>, Mel Gorman <mgorman@suse.de>, Michael Kerrisk <mtk.manpages@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Robin Holt <robinmholt@gmail.com>, Sedat Dilek <sedat.dilek@gmail.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Peter Zijlstra wrote:
> On Fri, Sep 13, 2013 at 04:06:10PM +0300, Kirill A. Shutemov wrote:
> > Basic api, backed by mm->page_table_lock for now. Actual implementation
> > will be added later.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > ---
> >  include/linux/mm.h | 13 +++++++++++++
> >  1 file changed, 13 insertions(+)
> > 
> > diff --git a/include/linux/mm.h b/include/linux/mm.h
> > index 6cf8ddb..d4361e7 100644
> > --- a/include/linux/mm.h
> > +++ b/include/linux/mm.h
> > @@ -1294,6 +1294,19 @@ static inline void pgtable_page_dtor(struct page *page)
> >  	((unlikely(pmd_none(*(pmd))) && __pte_alloc_kernel(pmd, address))? \
> >  		NULL: pte_offset_kernel(pmd, address))
> >  
> > +static inline spinlock_t *huge_pmd_lockptr(struct mm_struct *mm, pmd_t *pmd)
> > +{
> > +	return &mm->page_table_lock;
> > +}
> > +
> > +
> > +static inline spinlock_t *huge_pmd_lock(struct mm_struct *mm, pmd_t *pmd)
> > +{
> > +	spinlock_t *ptl = huge_pmd_lockptr(mm, pmd);
> > +	spin_lock(ptl);
> > +	return ptl;
> > +}
> 
> Why not call the thing pmd_lock()? The pmd bit differentiates it from
> pte_lock() enough IMIO.

Okay, will rename it.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
