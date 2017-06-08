Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id AAA0F6B0279
	for <linux-mm@kvack.org>; Thu,  8 Jun 2017 08:51:06 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id y77so11254571ioe.15
        for <linux-mm@kvack.org>; Thu, 08 Jun 2017 05:51:06 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [205.233.59.134])
        by mx.google.com with ESMTPS id q62si5402980ioe.176.2017.06.08.05.51.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Jun 2017 05:51:05 -0700 (PDT)
Date: Thu, 8 Jun 2017 14:50:59 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 2/3] mm/page_ref: Ensure page_ref_unfreeze is ordered
 against prior accesses
Message-ID: <20170608125059.4iufydsp7dsopsbz@hirez.programming.kicks-ass.net>
References: <1496771916-28203-1-git-send-email-will.deacon@arm.com>
 <1496771916-28203-3-git-send-email-will.deacon@arm.com>
 <b6677057-54d6-4336-93a0-5d0770434aa7@suse.cz>
 <20170608104056.ujuytybmwumuty64@black.fi.intel.com>
 <dac18c98-55e7-ea6b-d020-0f6065e969ad@suse.cz>
 <20170608112433.GH6071@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170608112433.GH6071@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mark.rutland@arm.com, akpm@linux-foundation.org, Punit.Agrawal@arm.com, mgorman@suse.de, steve.capper@arm.com

On Thu, Jun 08, 2017 at 12:24:33PM +0100, Will Deacon wrote:
> [+ PeterZ]
> 
> On Thu, Jun 08, 2017 at 01:07:02PM +0200, Vlastimil Babka wrote:
> > On 06/08/2017 12:40 PM, Kirill A. Shutemov wrote:
> > > On Thu, Jun 08, 2017 at 11:38:21AM +0200, Vlastimil Babka wrote:
> > >> On 06/06/2017 07:58 PM, Will Deacon wrote:
> > >>>  include/linux/page_ref.h | 1 +
> > >>>  1 file changed, 1 insertion(+)
> > >>>
> > >>> diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
> > >>> index 610e13271918..74d32d7905cb 100644
> > >>> --- a/include/linux/page_ref.h
> > >>> +++ b/include/linux/page_ref.h
> > >>> @@ -174,6 +174,7 @@ static inline void page_ref_unfreeze(struct page *page, int count)
> > >>>  	VM_BUG_ON_PAGE(page_count(page) != 0, page);
> > >>>  	VM_BUG_ON(count == 0);
> > >>>  
> > >>> +	smp_mb__before_atomic();
> > >>>  	atomic_set(&page->_refcount, count);

So depending on what it actually required, we do have
atomic_set_release() (atomic_t equivalent to smp_store_release()).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
