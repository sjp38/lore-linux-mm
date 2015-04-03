Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f179.google.com (mail-ig0-f179.google.com [209.85.213.179])
	by kanga.kvack.org (Postfix) with ESMTP id 4B3FE6B0032
	for <linux-mm@kvack.org>; Thu,  2 Apr 2015 21:04:03 -0400 (EDT)
Received: by ignm3 with SMTP id m3so58026712ign.0
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 18:04:03 -0700 (PDT)
Received: from mail-ie0-x22d.google.com (mail-ie0-x22d.google.com. [2607:f8b0:4001:c03::22d])
        by mx.google.com with ESMTPS id 65si5850916ioq.94.2015.04.02.18.04.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Apr 2015 18:04:02 -0700 (PDT)
Received: by iedfl3 with SMTP id fl3so92113349ied.1
        for <linux-mm@kvack.org>; Thu, 02 Apr 2015 18:04:02 -0700 (PDT)
Date: Thu, 2 Apr 2015 18:04:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch v2 4/4] mm, mempool: poison elements backed by page
 allocator
In-Reply-To: <551A861B.7020701@samsung.com>
Message-ID: <alpine.DEB.2.10.1504021803170.20229@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503241607240.21805@chino.kir.corp.google.com> <alpine.DEB.2.10.1503241609370.21805@chino.kir.corp.google.com> <CAPAsAGwipUr7NBWjQ_xjA0CfeiZ0NuYAg13M4jYmWVe4V8Jjmg@mail.gmail.com> <alpine.DEB.2.10.1503261542060.16259@chino.kir.corp.google.com>
 <551A861B.7020701@samsung.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Kleikamp <shaggy@kernel.org>, Christoph Hellwig <hch@lst.de>, Sebastian Ott <sebott@linux.vnet.ibm.com>, Mikulas Patocka <mpatocka@redhat.com>, Catalin Marinas <catalin.marinas@arm.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, jfs-discussion@lists.sourceforge.net

On Tue, 31 Mar 2015, Andrey Ryabinin wrote:

> > We don't have a need to set PAGE_EXT_DEBUG_POISON on these pages sitting 
> > in the reserved pool, nor do we have a need to do kmap_atomic() since it's 
> > already mapped and must be mapped to be on the reserved pool, which is 
> > handled by mempool_free().
> > 
> 
> Hmm.. I just realized that this statement might be wrong.
> Why pages has to be mapped to be on reserved pool?
> mempool could be used for highmem pages and there is no need to kmap()
> until these pages will be used.
> 
> drbd (drivers/block/drbd) already uses mempool for highmem pages:
> 

Yes, you're exactly right, I didn't see this because the mempool is 
created in one file and then solely used in another file, but regardless 
we still need protection from this usecase.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
