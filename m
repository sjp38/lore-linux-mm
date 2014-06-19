Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id EBCD46B0031
	for <linux-mm@kvack.org>; Thu, 19 Jun 2014 09:22:45 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id b13so2247631wgh.11
        for <linux-mm@kvack.org>; Thu, 19 Jun 2014 06:22:45 -0700 (PDT)
Received: from fireflyinternet.com (mail.fireflyinternet.com. [87.106.93.118])
        by mx.google.com with ESMTP id we9si7213879wjb.88.2014.06.19.06.22.44
        for <linux-mm@kvack.org>;
        Thu, 19 Jun 2014 06:22:44 -0700 (PDT)
Date: Thu, 19 Jun 2014 14:22:40 +0100
From: Chris Wilson <chris@chris-wilson.co.uk>
Subject: Re: [PATCH] mm: Report attempts to overwrite PTE from
 remap_pfn_range()
Message-ID: <20140619132240.GF25975@nuc-i3427.alporthouse.com>
References: <20140616134124.0ED73E00A2@blue.fi.intel.com>
 <1403162349-14512-1-git-send-email-chris@chris-wilson.co.uk>
 <20140619115018.412D2E00A3@blue.fi.intel.com>
 <20140619120004.GC25975@nuc-i3427.alporthouse.com>
 <20140619125746.25A03E00A3@blue.fi.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140619125746.25A03E00A3@blue.fi.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: intel-gfx@lists.freedesktop.org, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Cyrill Gorcunov <gorcunov@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

On Thu, Jun 19, 2014 at 03:57:46PM +0300, Kirill A. Shutemov wrote:
> Chris Wilson wrote:
> > On Thu, Jun 19, 2014 at 02:50:18PM +0300, Kirill A. Shutemov wrote:
> > > > +	if (err) {
> > > >  		untrack_pfn(vma, pfn, PAGE_ALIGN(size));
> > > > +		if (err != -EBUSY)
> > > > +			zap_page_range_single(vma, addr, size, NULL);
> > > 
> > > Hm. If I read it correctly, you zap whole range, not only what you've
> > > set up. Looks wrong.
> > 
> > Yes. I didn't fancy threading the last touched pte back, but that should
> > be easier if moving to a struct.
> >  
> > > And for after zap, you probably whant to return -EBUSY to caller of
> > > remap_pfn_range(), not -EINVAL.
> > 
> > No, it has to be EINVAL for my purpose. If we return EBUSY, the caller
> > will just report VM_NOPAGE back to the fault handler, and the fault will
> > be retriggered - but the overlapping object will still be present.
> 
> IIUC, what you're saying makes sense only if the range starts from PTE
> you've got fault to. I failed to see why this assumption should be part of
> remap_pfn_range() interface.

That I agree with.
 
> One possible option is to create a variant of remap_pfn_range() which will
> return how many PTEs it was able to setup, before hitting the !pte_none().
> Caller will decide what to do with partially filled range.

Looked at just returning the address remap_pfn_range() got up to, which is
easy enough, but I think given that remap_pfn_range() will clean up
correctly after a failed remap, any EBUSY from partway through would be
a pathological driver error. 
-Chris

-- 
Chris Wilson, Intel Open Source Technology Centre

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
