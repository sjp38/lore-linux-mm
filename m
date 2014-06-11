Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6CC0D6B0132
	for <linux-mm@kvack.org>; Tue, 10 Jun 2014 22:12:51 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so6841232pbb.25
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:12:51 -0700 (PDT)
Received: from mail-pd0-x231.google.com (mail-pd0-x231.google.com [2607:f8b0:400e:c02::231])
        by mx.google.com with ESMTPS id x3si4809221pas.214.2014.06.10.19.12.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 10 Jun 2014 19:12:50 -0700 (PDT)
Received: by mail-pd0-f177.google.com with SMTP id g10so6678835pdj.36
        for <linux-mm@kvack.org>; Tue, 10 Jun 2014 19:12:50 -0700 (PDT)
Message-ID: <1402452686.28433.28.camel@debian>
Subject: Re: [PATCH v2] HWPOISON: Fix the handling path of the victimized
 page frame that belong to non-LUR
From: Chen Yucong <slaoub@gmail.com>
Date: Wed, 11 Jun 2014 10:11:26 +0800
In-Reply-To: <538ebf9c.c71de50a.0f39.32bdSMTPIN_ADDED_BROKEN@mx.google.com>
References: <1401860898-11486-1-git-send-email-slaoub@gmail.com>
	 <538ebf9c.c71de50a.0f39.32bdSMTPIN_ADDED_BROKEN@mx.google.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: ak@linux.intel.com, Wu Fengguang <fengguang.wu@intel.com>, linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

Hi Andrew Morton,

The following message should be cc'ed to you. This is my negligence.

thx!
cyc
On Wed, 2014-06-04 at 02:41 -0400, Naoya Horiguchi wrote:
> On Wed, Jun 04, 2014 at 01:48:18PM +0800, Chen Yucong wrote:
> > Until now, the kernel has the same policy to handle victimized page frames that
> > belong to kernel-space(reserved/slab-subsystem) or non-LRU(unknown page state).
> > In other word, the result of handling either of these victimized page frames is
> > (IGNORED | FAILED), and the return value of memory_failure() is -EBUSY.
> > 
> > This patch is to avoid that memory_failure() returns very soon due to the "true"
> > value of (!PageLRU(p)), and it also ensures that action_result() can report more
> > precise information("reserved kernel",  "kernel slab", and "unknown page state")
> > instead of "non LRU", especially for memory errors which are detected by memory-scrubbing.
> > 
> > Changes since v1: http://www.spinics.net/lists/linux-mm/msg74044.html
> >   - Call goto just after if (hwpoison_filter(p)) block, and jump directly to just 
> >     before the code determining the page_state, as suggested by Naoya Horiguchi.
> > 
> > Signed-off-by: Chen Yucong <slaoub@gmail.com>
> 
> Looks good to me, thanks!
> 
> Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> > ---
> >  mm/memory-failure.c |    9 +++++----
> >  1 file changed, 5 insertions(+), 4 deletions(-)
> > 
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index e3154d9..1340b30 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -862,7 +862,7 @@ static int hwpoison_user_mappings(struct page *p, unsigned long pfn,
> >  	struct page *hpage = *hpagep;
> >  	struct page *ppage;
> >  
> > -	if (PageReserved(p) || PageSlab(p))
> > +	if (PageReserved(p) || PageSlab(p) || !PageLRU(p))
> >  		return SWAP_SUCCESS;
> >  
> >  	/*
> > @@ -1126,9 +1126,6 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
> >  					action_result(pfn, "free buddy, 2nd try", DELAYED);
> >  				return 0;
> >  			}
> > -			action_result(pfn, "non LRU", IGNORED);
> > -			put_page(p);
> > -			return -EBUSY;
> >  		}
> >  	}
> >  
> > @@ -1161,6 +1158,9 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
> >  		return 0;
> >  	}
> >  
> > +	if (!PageHuge(p) && !PageTransTail(p) && !PageLRU(p))
> > +		goto identify_page_state;
> > +
> >  	/*
> >  	 * For error on the tail page, we should set PG_hwpoison
> >  	 * on the head page to show that the hugepage is hwpoisoned
> > @@ -1210,6 +1210,7 @@ int memory_failure(unsigned long pfn, int trapno, int flags)
> >  		goto out;
> >  	}
> >  
> > +identify_page_state:
> >  	res = -EBUSY;
> >  	/*
> >  	 * The first check uses the current page flags which may not have any
> > -- 
> > 1.7.10.4
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> > 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
