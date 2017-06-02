Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3131F6B0279
	for <linux-mm@kvack.org>; Fri,  2 Jun 2017 00:00:43 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h4so67392447oib.5
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 21:00:43 -0700 (PDT)
Received: from mail-oi0-x235.google.com (mail-oi0-x235.google.com. [2607:f8b0:4003:c06::235])
        by mx.google.com with ESMTPS id t82si9226134oig.108.2017.06.01.21.00.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Jun 2017 21:00:41 -0700 (PDT)
Received: by mail-oi0-x235.google.com with SMTP id l18so77767351oig.2
        for <linux-mm@kvack.org>; Thu, 01 Jun 2017 21:00:41 -0700 (PDT)
Date: Thu, 1 Jun 2017 21:00:32 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 4.12-rc ppc64 4k-page needs costly allocations
In-Reply-To: <878tlb2igt.fsf@concordia.ellerman.id.au>
Message-ID: <alpine.LSU.2.11.1706012045240.4854@eggly.anvils>
References: <alpine.LSU.2.11.1705301151090.2133@eggly.anvils> <87h9014j7t.fsf@concordia.ellerman.id.au> <alpine.DEB.2.20.1705310906570.14920@east.gentwo.org> <alpine.LSU.2.11.1705311112290.1839@eggly.anvils> <alpine.DEB.2.20.1706011027310.8835@east.gentwo.org>
 <alpine.LSU.2.11.1706011002130.3014@eggly.anvils> <alpine.DEB.2.20.1706011306560.11993@east.gentwo.org> <alpine.LSU.2.11.1706011128490.3622@eggly.anvils> <878tlb2igt.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Hugh Dickins <hughd@google.com>, Christoph Lameter <cl@linux.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Fri, 2 Jun 2017, Michael Ellerman wrote:
> Hugh Dickins <hughd@google.com> writes:
> > On Thu, 1 Jun 2017, Christoph Lameter wrote:
> >> 
> >> Ok so debugging was off but the slab cache has a ctor callback which
> >> mandates that the free pointer cannot use the free object space when
> >> the object is not in use. Thus the size of the object must be increased to
> >> accomodate the freepointer.
> >
> > Thanks a lot for working that out.  Makes sense, fully understood now,
> > nothing to worry about (though makes one wonder whether it's efficient
> > to use ctors on high-alignment caches; or whether an internal "zero-me"
> > ctor would be useful).
> 
> Or should we just be using kmem_cache_zalloc() when we allocate from
> those slabs?
> 
> Given all the ctor's do is memset to 0.

I'm not sure.  From a memory-utilization point of view, with SLUB,
using kmem_cache_zalloc() there would certainly be better.

But you may be forgetting that the constructor is applied only when a
new slab of objects is allocated, not each time an object is allocated
from that slab (and the user of those objects agrees to free objects
back to the cache in a reusable state: zeroed in this case).

So from a cpu-utilization point of view, it's better to use the ctor:
it's saving you lots of redundant memsets.

SLUB versus SLAB, cpu versus memory?  Since someone has taken the
trouble to write it with ctors in the past, I didn't feel on firm
enough ground to recommend such a change.  But it may be obvious
to someone else that your suggestion would be better (or worse).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
