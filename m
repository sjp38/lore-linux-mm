Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9DFD6B006C
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 22:18:58 -0400 (EDT)
Received: by qgf60 with SMTP id 60so60384091qgf.3
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 19:18:58 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z31si4040059qkg.9.2015.03.25.19.18.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 19:18:58 -0700 (PDT)
Date: Wed, 25 Mar 2015 22:18:48 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [patch 1/4] fs, jfs: remove slab object constructor
In-Reply-To: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
Message-ID: <alpine.LRH.2.02.1503252157330.6657@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net



On Tue, 24 Mar 2015, David Rientjes wrote:

> Mempools based on slab caches with object constructors are risky because
> element allocation can happen either from the slab cache itself, meaning
> the constructor is properly called before returning, or from the mempool
> reserve pool, meaning the constructor is not called before returning,
> depending on the allocation context.

I don't think there is any problem. If the allocation is hapenning from 
the slab cache, the constructor is called from the slab sybsystem.

If the allocation is hapenning from the mempool reserve, the constructor 
was called in the past (when the mempool reserve was refilled from the 
cache). So, in both cases, the object allocated frmo the mempool is 
constructed.

Mikulas

> For this reason, we should disallow creating mempools based on slab
> caches that have object constructors.  Callers of mempool_alloc() will
> be responsible for properly initializing the returned element.
> 
> Then, it doesn't matter if the element came from the slab cache or the
> mempool reserved pool.
> 
> The only occurrence of a mempool being based on a slab cache with an
> object constructor in the tree is in fs/jfs/jfs_metapage.c.  Remove it
> and properly initialize the element in alloc_metapage().
> 
> At the same time, META_free is never used, so remove it as well.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
