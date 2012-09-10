Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id B2FEC6B0069
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 11:07:15 -0400 (EDT)
Date: Mon, 10 Sep 2012 18:07:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v2 10/10] thp: implement refcounting for huge zero page
Message-ID: <20120910150747.GA23556@shutemov.name>
References: <1347282813-21935-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1347282813-21935-11-git-send-email-kirill.shutemov@linux.intel.com>
 <1347285759.1234.1645.camel@edumazet-glaptop>
 <20120910144438.GA31697@otc-wbsnb-06>
 <1347289079.1234.1706.camel@edumazet-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347289079.1234.1706.camel@edumazet-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org

On Mon, Sep 10, 2012 at 04:57:59PM +0200, Eric Dumazet wrote:
> On Mon, 2012-09-10 at 17:44 +0300, Kirill A. Shutemov wrote:
> 
> 
> > Yes, disabling preemption before alloc_pages() and enabling after
> > atomic_set() looks reasonable. Thanks.
> 
> In fact, as alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);
> might sleep, it would be better to disable preemption after calling it :

Yeah, I've alread thought about that. :)

> zero_page = alloc_pages(GFP_TRANSHUGE | __GFP_ZERO, HPAGE_PMD_ORDER);
> if (!zero_page)
> 	return 0;
> preempt_disable();
> if (cmpxchg(&huge_zero_pfn, 0, page_to_pfn(zero_page))) {
> 	preempt_enable();
> 	__free_page(zero_page);
> 	goto retry;
> }
> atomic_set(&huge_zero_refcount, 2);
> preempt_enable();
> 
> 

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
