Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 355C26B0032
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 22:37:43 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so42449507igb.1
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 19:37:43 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com. [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id o77si3473483ioi.30.2015.03.25.19.37.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Mar 2015 19:37:42 -0700 (PDT)
Received: by igcxg11 with SMTP id xg11so42892706igc.0
        for <linux-mm@kvack.org>; Wed, 25 Mar 2015 19:37:42 -0700 (PDT)
Date: Wed, 25 Mar 2015 19:37:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch 1/4] fs, jfs: remove slab object constructor
In-Reply-To: <alpine.LRH.2.02.1503252157330.6657@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.DEB.2.10.1503251935180.16714@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com> <alpine.LRH.2.02.1503252157330.6657@file01.intranet.prod.int.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mikulas Patocka <mpatocka@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jfs-discussion@lists.sourceforge.net

On Wed, 25 Mar 2015, Mikulas Patocka wrote:

> > Mempools based on slab caches with object constructors are risky because
> > element allocation can happen either from the slab cache itself, meaning
> > the constructor is properly called before returning, or from the mempool
> > reserve pool, meaning the constructor is not called before returning,
> > depending on the allocation context.
> 
> I don't think there is any problem. If the allocation is hapenning from 
> the slab cache, the constructor is called from the slab sybsystem.
> 
> If the allocation is hapenning from the mempool reserve, the constructor 
> was called in the past (when the mempool reserve was refilled from the 
> cache). So, in both cases, the object allocated frmo the mempool is 
> constructed.
> 

That would be true only for

	ptr = mempool_alloc(gfp, pool);
	mempool_free(ptr, pool);

and nothing in between, and that's pretty pointless.  Typically, callers 
allocate memory, modify it, and then free it.  When that happens with 
mempools, and we can't allocate slab because of the gfp context, mempools 
will return elements in the state in which they were freed (modified, not 
as constructed).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
