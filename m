Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 842B96B0295
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 08:02:01 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id k126so1177329wmd.5
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 05:02:01 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n191si1219753wmd.126.2017.12.19.05.02.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Dec 2017 05:02:00 -0800 (PST)
Date: Tue, 19 Dec 2017 14:01:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 5/8] mm: Introduce _slub_counter_t
Message-ID: <20171219130159.GT2787@dhcp22.suse.cz>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-6-willy@infradead.org>
 <20171219080731.GB2787@dhcp22.suse.cz>
 <20171219124605.GA13680@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219124605.GA13680@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue 19-12-17 04:46:05, Matthew Wilcox wrote:
> On Tue, Dec 19, 2017 at 09:07:31AM +0100, Michal Hocko wrote:
> > On Sat 16-12-17 08:44:22, Matthew Wilcox wrote:
> > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > Instead of putting the ifdef in the middle of the definition of struct
> > > page, pull it forward to the rest of the ifdeffery around the SLUB
> > > cmpxchg_double optimisation.
> > > 
> > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > The definition of struct page looks better now. I think that slub.c
> > needs some love as well. I haven't checked too deeply but it seems that
> > it assumes counters to be unsigned long in some places. Maybe I've
> > missed some ifdef-ery but using the native type would be much better
> 
> I may have missed something, but I checked its use of 'counters' while
> I was working on this patch, and I didn't *see* a problem.

I didn't check too closely but I can see code like this in slub.c
static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
resp.
static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
		void *freelist_old, unsigned long counters_old,
		void *freelist_new, unsigned long counters_new,
		const char *n)

which always uses unsigned long for the value rather than unsigned int.
But maybe those paths are never dealing with an out-of-scope value.
Using your new type there would cleanup that thing a bit.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
