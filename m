Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 576786B0005
	for <linux-mm@kvack.org>; Fri, 20 Apr 2018 16:27:41 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id b18so3165550pgv.14
        for <linux-mm@kvack.org>; Fri, 20 Apr 2018 13:27:41 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c1-v6si6342219plo.88.2018.04.20.13.27.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 20 Apr 2018 13:27:39 -0700 (PDT)
Date: Fri, 20 Apr 2018 13:27:37 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 05/14] mm: Move 'private' union within struct page
Message-ID: <20180420202737.GE10788@bombadil.infradead.org>
References: <20180418184912.2851-1-willy@infradead.org>
 <20180418184912.2851-6-willy@infradead.org>
 <alpine.DEB.2.20.1804201024090.18006@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1804201024090.18006@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>

On Fri, Apr 20, 2018 at 10:25:14AM -0500, Christopher Lameter wrote:
> On Wed, 18 Apr 2018, Matthew Wilcox wrote:
> > +	union {
> > +		unsigned long private;
> > +#if USE_SPLIT_PTE_PTLOCKS
> > +#if ALLOC_SPLIT_PTLOCKS
> > +		spinlock_t *ptl;
> > +#else
> > +		spinlock_t ptl;
> 
> ^^^^ This used to be defined at the end of the struct so that you could
> have larger structs for spinlocks here (debugging and some such thing).
> 
> Could this not misalign the rest?

Nope:

include/linux/mm_types_task.h:#define ALLOC_SPLIT_PTLOCKS       (SPINLOCK_SIZE > BITS_PER_LONG/8)

So we'll only store a spinlock here if it's <= sizeof(long); otherwise
we'll store a pointer here.
