Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 958316B0003
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 18:13:45 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id k1-v6so13422283pfg.13
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 15:13:45 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id a13-v6si2483206pgi.474.2018.10.12.15.13.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 15:13:44 -0700 (PDT)
Date: Fri, 12 Oct 2018 15:13:41 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm, slab: avoid high-order slab pages when it does not
 reduce waste
Message-Id: <20181012151341.286cd91321cdda9b6bde4de9@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1810121424420.116562@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, 12 Oct 2018 14:24:57 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> The slab allocator has a heuristic that checks whether the internal
> fragmentation is satisfactory and, if not, increases cachep->gfporder to
> try to improve this.
> 
> If the amount of waste is the same at higher cachep->gfporder values,
> there is no significant benefit to allocating higher order memory.  There
> will be fewer calls to the page allocator, but each call will require
> zone->lock and finding the page of best fit from the per-zone free areas.
> 
> Instead, it is better to allocate order-0 memory if possible so that pages
> can be returned from the per-cpu pagesets (pcp).
> 
> There are two reasons to prefer this over allocating high order memory:
> 
>  - allocating from the pcp lists does not require a per-zone lock, and
> 
>  - this reduces stranding of MIGRATE_UNMOVABLE pageblocks on pcp lists
>    that increases slab fragmentation across a zone.

Confused.  Higher-order slab pages never go through the pcp lists, do
they?  I'd have thought that by tending to increase the amount of
order-0 pages which are used by slab, such stranding would be
*increased*?

> We are particularly interested in the second point to eliminate cases
> where all other pages on a pageblock are movable (or free) and fallback to
> pageblocks of other migratetypes from the per-zone free areas causes
> high-order slab memory to be allocated from them rather than from free
> MIGRATE_UNMOVABLE pages on the pcp.
> 
>  mm/slab.c | 15 +++++++++++++++

Do slub and slob also suffer from this effect?
