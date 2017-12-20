Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 4C02D6B0260
	for <linux-mm@kvack.org>; Wed, 20 Dec 2017 11:19:26 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id i7so9749638plt.3
        for <linux-mm@kvack.org>; Wed, 20 Dec 2017 08:19:26 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id h9si12071120pgp.365.2017.12.20.08.19.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 20 Dec 2017 08:19:25 -0800 (PST)
Date: Wed, 20 Dec 2017 08:19:23 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 5/8] mm: Introduce _slub_counter_t
Message-ID: <20171220161923.GB1840@bombadil.infradead.org>
References: <20171216164425.8703-1-willy@infradead.org>
 <20171216164425.8703-6-willy@infradead.org>
 <20171219080731.GB2787@dhcp22.suse.cz>
 <20171219124605.GA13680@bombadil.infradead.org>
 <20171219130159.GT2787@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171219130159.GT2787@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Matthew Wilcox <mawilcox@microsoft.com>

On Tue, Dec 19, 2017 at 02:01:59PM +0100, Michal Hocko wrote:
> On Tue 19-12-17 04:46:05, Matthew Wilcox wrote:
> > On Tue, Dec 19, 2017 at 09:07:31AM +0100, Michal Hocko wrote:
> > > On Sat 16-12-17 08:44:22, Matthew Wilcox wrote:
> > > > From: Matthew Wilcox <mawilcox@microsoft.com>
> > > > 
> > > > Instead of putting the ifdef in the middle of the definition of struct
> > > > page, pull it forward to the rest of the ifdeffery around the SLUB
> > > > cmpxchg_double optimisation.
> > > > 
> > > > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > > 
> > > The definition of struct page looks better now. I think that slub.c
> > > needs some love as well. I haven't checked too deeply but it seems that
> > > it assumes counters to be unsigned long in some places. Maybe I've
> > > missed some ifdef-ery but using the native type would be much better
> > 
> > I may have missed something, but I checked its use of 'counters' while
> > I was working on this patch, and I didn't *see* a problem.
> 
> I didn't check too closely but I can see code like this in slub.c
> static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
> resp.
> static inline bool cmpxchg_double_slab(struct kmem_cache *s, struct page *page,
> 		void *freelist_old, unsigned long counters_old,
> 		void *freelist_new, unsigned long counters_new,
> 		const char *n)
> 
> which always uses unsigned long for the value rather than unsigned int.
> But maybe those paths are never dealing with an out-of-scope value.
> Using your new type there would cleanup that thing a bit.

OK, here's how I read the code in slub.  Christoph, please let me know
if I misunderstand.

slub wants to atomically update both freelist and its counters, so it has
96 bits of information to update atomically (on 64 bit), or 64 bits on
32-bit machines.  We don't have a 96-bit atomic-cmpxchg, but we do have
a 128-bit atomic-cmpxchg on some architectures.  So _if_ we're going
to use cmpxchg_double(), then we need counters to be an unsigned long.
If we're not then counters needs to be an unsigned int so it doesn't
overlap with _refcount, which is not going to be protected by slab_lock.

Now I look at it some more though, I wonder if it would hurt for counters
to always be unsigned long.  There is no problem on 32-bit as long and int
are the same size.  So on 64-bit, the cmpxchg_double path stays as it is.
There would then be the extra miniscule risk that __cmpxchg_double_slab()
fails due to a spurious _refcount modification due to an RCU-protected
pagecache lookup.  And there are a few places that would be a 64-bit
load rather than a 32-bit load.

I think if I were doing slub, I'd put in 'unsigned int counters_32'
and 'unsigned long counters_64'.  set_page_slub_counters() would then
become simply:

	page->counters_32 = counters_new;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
