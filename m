Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC6B6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:23:56 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b13so1881447pgw.1
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 07:23:56 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g7si3434078pfm.106.2018.04.19.07.23.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 19 Apr 2018 07:23:55 -0700 (PDT)
Date: Thu, 19 Apr 2018 07:23:54 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 07/14] slub: Remove page->counters
Message-ID: <20180419142354.GB25406@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-8-willy@infradead.org>
 <0d049d18-ebde-82ec-ed1d-85daabf6582f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0d049d18-ebde-82ec-ed1d-85daabf6582f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>

On Thu, Apr 19, 2018 at 03:42:37PM +0200, Vlastimil Babka wrote:
> On 04/18/2018 08:49 PM, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > Use page->private instead, now that these two fields are in the same
> > location.  Include a compile-time assert that the fields don't get out
> > of sync.
> > 
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> 
> Why not retain a small union of "counters" and inuse/objects/frozens
> within the SLUB's sub-structure? IMHO it would be more obvious and
> reduce churn?

Could do.  Same issues with five layers of indentation though.
If there's consensus that that's a better way to go, then I'll redo
the series to look that way.

There is a way to reduce the indentation ... but we'd have to compile
with -fms-extensions (or -fplan9-extensions, but that wasn't added until
gcc 4.6, whereas -fms-extensions was added back in the egcs days).

-fms-extensions lets you do this:

struct a { int b; int c; };
struct d { struct a; int e; };
int init(struct d *);

int main(void)
{
	struct d d;
	init(&d);
	return d.b + d.c + d.e;
}

so we could then:

struct slub_counters {
	union {
		unsigned long counters;
		struct {
			unsigned inuse:16;
			unsigned objects:15;
			unsigned frozen:1;
		};
	};
};

struct page {
	union {
		struct {
			union {
				void *s_mem;
				struct slub_counters;

Given my employer, a request to add -fms-extensions to the Makefile
might be regarded with a certain amount of suspicion ;-)

> > @@ -358,17 +359,10 @@ static __always_inline void slab_unlock(struct page *page)
> >  
> >  static inline void set_page_slub_counters(struct page *page, unsigned long counters_new)
> >  {
> > -	struct page tmp;
> > -	tmp.counters = counters_new;
> > -	/*
> > -	 * page->counters can cover frozen/inuse/objects as well
> > -	 * as page->_refcount.  If we assign to ->counters directly
> > -	 * we run the risk of losing updates to page->_refcount, so
> > -	 * be careful and only assign to the fields we need.
> > -	 */
> > -	page->frozen  = tmp.frozen;
> > -	page->inuse   = tmp.inuse;
> > -	page->objects = tmp.objects;
> 
> BTW was this ever safe to begin with? IIRC bitfields are frowned upon as
> a potential RMW. Or is there still at least guarantee the RMW happens
> only within the 32bit struct and not the whole 64bit word, which used to
> include also _refcount?

I prefer not to think about it.  Indeed, I don't think that doing
page->tmp = tmp; where both are 32-bit quantities is guaranteed to not
do an RMW.
