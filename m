Received: by ug-out-1314.google.com with SMTP id u40so241689ugc.29
        for <linux-mm@kvack.org>; Fri, 29 Feb 2008 04:29:08 -0800 (PST)
Message-ID: <84144f020802290429v25bd4ab2j8ab640e2ccb48140@mail.gmail.com>
Date: Fri, 29 Feb 2008 14:29:06 +0200
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 00/28] Swap over NFS -v16
In-Reply-To: <1204287533.6243.105.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080220144610.548202000@chello.nl>
	 <20080223000620.7fee8ff8.akpm@linux-foundation.org>
	 <18371.43950.150842.429997@notabene.brown>
	 <1204023042.6242.271.camel@lappy>
	 <18372.64081.995262.986841@notabene.brown>
	 <1204099113.6242.353.camel@lappy>
	 <84144f020802270005p3bfbd04ar9da2875218ef98c4@mail.gmail.com>
	 <1204285912.6243.93.camel@lappy>
	 <84144f020802290358t2774f7bwd87efe79e7bd4235@mail.gmail.com>
	 <1204287533.6243.105.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Neil Brown <neilb@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, trond.myklebust@fys.uio.no, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Feb 29, 2008 at 2:18 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>  Clearing PG_emergency would mean kmem_is_emergency() would return false
>  in kfree_reserve() and fail to un-charge the object.
>
>  Previously objects would track their account status themselves (when
>  needed) and freeing PG_emergency wouldn't be a problem.
>
>  > and allocate a new fresh page to the reserves?
>
>  Not sure I understand this properly. We would only do this once the page
>  watermarks are high enough, so the reserves are full again.

The problem with PG_emergency is that, once the watermarks are high
again, SLUB keeps holding to the emergency page and it cannot be used
for regular kmalloc allocations, right?

So the way to fix this is to batch uncharge the objects and clear
PG_emergency for the said SLUB pages thus freeing them for regular
allocations. And to compensate for the loss in the reserves, we ask
the page allocator to give a new one that SLUB knows nothing about.

If you don't do this, the reserve page can only contain few objects
making them unavailable for regular allocations. So we're might be
forced into "emergency mode" even though there's enough memory
available to satisfy the allocation.

                          Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
