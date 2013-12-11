Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f54.google.com (mail-yh0-f54.google.com [209.85.213.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1691A6B0038
	for <linux-mm@kvack.org>; Wed, 11 Dec 2013 17:45:28 -0500 (EST)
Received: by mail-yh0-f54.google.com with SMTP id z12so5681188yhz.13
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:45:27 -0800 (PST)
Received: from mail-yh0-x230.google.com (mail-yh0-x230.google.com [2607:f8b0:4002:c01::230])
        by mx.google.com with ESMTPS id z48si19384290yha.156.2013.12.11.14.45.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Dec 2013 14:45:27 -0800 (PST)
Received: by mail-yh0-f48.google.com with SMTP id f73so5715269yha.35
        for <linux-mm@kvack.org>; Wed, 11 Dec 2013 14:45:26 -0800 (PST)
Date: Wed, 11 Dec 2013 14:45:23 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/2] mm: slab/slub: use page->list consistently instead
 of page->lru
In-Reply-To: <20131211223631.51094A3D@viggo.jf.intel.com>
Message-ID: <alpine.DEB.2.02.1312111443130.7354@chino.kir.corp.google.com>
References: <20131211223631.51094A3D@viggo.jf.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@gentwo.org, kirill.shutemov@linux.intel.com, Andi Kleen <ak@linux.intel.com>, akpm@linux-foundation.org

On Wed, 11 Dec 2013, Dave Hansen wrote:

> From: Dave Hansen <dave.hansen@linux.intel.com>
> 
> 'struct page' has two list_head fields: 'lru' and 'list'.
> Conveniently, they are unioned together.  This means that code
> can use them interchangably, which gets horribly confusing like
> with this nugget from slab.c:
> 
> >	list_del(&page->lru);
> >	if (page->active == cachep->num)
> >		list_add(&page->list, &n->slabs_full);
> 
> This patch makes the slab and slub code use page->list
> universally instead of mixing ->list and ->lru.
> 
> It also adds some comments to attempt to keep new users from
> picking up uses of ->list.
> 
> So, the new rule is: page->list is what the slabs use.  page->lru
> is for everybody else.  This is a pretty arbitrary rule, but we
> need _something_.  Maybe we should just axe the ->list one and
> make the sl?bs use ->lru.
> 

I'd recommend this suggestion, I don't see why the slab allocators can't 
use a page->lru field to maintain their lists of slab pages and it makes 
the code much cleaner.  Anybody hacking thise code will know it's not 
really a lru and we're just reusing a field from struct page without 
adding unnecessary complexity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
