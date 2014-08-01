Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id C37346B0035
	for <linux-mm@kvack.org>; Fri,  1 Aug 2014 06:17:36 -0400 (EDT)
Received: by mail-ie0-f179.google.com with SMTP id rl12so5620819iec.10
        for <linux-mm@kvack.org>; Fri, 01 Aug 2014 03:17:36 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id tr4si5290181igb.7.2014.08.01.03.17.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 01 Aug 2014 03:17:36 -0700 (PDT)
Message-ID: <1406888211.4935.245.camel@pasglop>
Subject: Re: [RFC][PATCH 0/5] VM_PINNED
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 01 Aug 2014 20:16:51 +1000
In-Reply-To: <20140526203232.GC5444@laptop.programming.kicks-ass.net>
References: <20140526145605.016140154@infradead.org>
	 <CALYGNiMG1NVBUS4TJrYJMr92yWGZHSdGUdCGtBJDHoUMMhE+Wg@mail.gmail.com>
	 <20140526203232.GC5444@laptop.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Roland Dreier <roland@kernel.org>, Sean Hefty <sean.hefty@intel.com>, Hal Rosenstock <hal.rosenstock@gmail.com>, Mike Marciniszyn <infinipath@intel.com>, Alex Williamson <alex.williamson@redhat.com>, Alexey Kardashevskiy <aik@au1.ibm.com>

On Mon, 2014-05-26 at 22:32 +0200, Peter Zijlstra wrote:

> Not sure what you mean, the one bit is perfectly fine for what I want it
> to do.
> 
> > This supposed to supports pinning only by one user and only in its own mm?
> 
> Pretty much, that's adequate for all users I'm aware of and mirrors the
> mlock semantics.

Ok so I only just saw this. CC'ing Alex Williamson

There is definitely another potential user for that stuff which is KVM
with passed-through devices.

What vfio does today on x86 is "interesting":

Look at drivers/vfio/vfio_iommu_type1.c and functions vfio_pin_pages()

I especially like the racy "delayed" accounting ...

The problem is that in the generic case of VFIO, we don't know in
advance what needs to be pinned. The user might pin pages on demand and
it has to be a reasonably fast path.

Additionally, a given page can be mapped multiple times and we don't
have a good place to keep a counter....

So the one bit of state is definitely not enough.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
