Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id DA4856B0279
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 06:05:22 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id z6so24693376pgc.13
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 03:05:22 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id h9si615774pln.181.2017.06.09.03.05.21
        for <linux-mm@kvack.org>;
        Fri, 09 Jun 2017 03:05:22 -0700 (PDT)
Date: Fri, 9 Jun 2017 11:05:29 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170609100529.GD13955@arm.com>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
 <20170608104056.ujuytybmwumuty64@black.fi.intel.com>
 <dac18c98-55e7-ea6b-d020-0f6065e969ad@suse.cz>
 <20170608112433.GH6071@arm.com>
 <20170608125059.4iufydsp7dsopsbz@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608125059.4iufydsp7dsopsbz@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 02:50:59PM +0200, Peter Zijlstra wrote:
> On Thu, Jun 08, 2017 at 12:24:33PM +0100, Will Deacon wrote:
> > [+ PeterZ]
> > 
> > On Thu, Jun 08, 2017 at 01:07:02PM +0200, Vlastimil Babka wrote:
> > > On 06/08/2017 12:40 PM, Kirill A. Shutemov wrote:
> > > > On Thu, Jun 08, 2017 at 11:38:21AM +0200, Vlastimil Babka wrote:
> > > >> On 06/06/2017 07:58 PM, Will Deacon wrote:
> > > >>>  include/linux/page_ref.h | 1 +
> > > >>>  1 file changed, 1 insertion(+)
> > > >>>
> > > >>> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> > > >>> index 610e13271918..74d32d7905cb 100644
> > > >>> --- a/include/linux/page_ref.h
> > > >>> +++ b/include/linux/page_ref.h
> > > >>> @@ -174,6 +174,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
> > > >>>  	VM_BUG_ON_PAGE(page_count(page) != 0, page);
> > > >>>  	VM_BUG_ON(count == 0);
> > > >>>  
> > > >>> +	smp_mb__before_atomic();
> > > >>>  	atomic_set(&page->_refcount, count);
> 
> So depending on what it actually required, we do have
> atomic_set_release() (atomic_t equivalent to smp_store_release()).

Yeah, I was wondering about that this morning. I think it should do the
trick here, but smp_mb() would be a better fit for the other parts of this
API (page_ref_freeze uses atomic_cmpxchg and page_cache_get_speculative
uses atomic_add_unless).

I'll send a v2 with the full barrier.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
