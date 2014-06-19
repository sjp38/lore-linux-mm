Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 137F66B0037
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 08:00:09 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id u56so2189511wes.21
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 05:00:09 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id q17si6530260wiv.54.2014.06.19.05.00.08
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 05:00:08 -0700 (PDT)
Date: Thu, 19 Jun 2014 13:00:04 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm: Report attempts to overwrite PTE from
 remap_pfn_range()
Message-ID: <20140619120004.GC25975@nuc-i3427.alporthouse.com>
References: <20140616134124.0ED73E00A2@blue.fi.intel.com>
 <1403162349-14512-1-git-send-email-chris@chris-wilson.co.uk>
 <20140619115018.412D2E00A3@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140619115018.412D2E00A3@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Thu, Jun 19, 2014 at 02:50:18PM +0300, Kirill A. Shutemov wrote:
> > +	if (err) {
> >  		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
> > +		if (err != -EBUSY)
> > +			zap_page_range_single(vma, addr, size, NULL);
> 
> Hm. If I read it correctly, you zap whole range, not only what you've
> set up. Looks wrong.

Yes. I didn't fancy threading the last touched pte back, but that should
be easier if moving to a struct.
 
> And for after zap, you probably whant to return -EBUSY to caller of
> remap_pfn_range(), not -EINVAL.

No, it has to be EINVAL for my purpose. If we return EBUSY, the caller
will just report VM_NOPAGE back to the fault handler, and the fault will
be retriggered - but the overlapping object will still be present. So the
EINVAL is there to report that the range conflicts with another and that
the caller should abort. It's a nasty semantic that works only when the
concurrent pagefaults are serialised around the call to remap_pfn_range().

The alternative would be to always report EINVAL and clean up, and
export pte_exists() so that the caller can detect when the PTEs have
already been populated by the concurrent fault.
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
