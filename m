Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D2DB66B0033
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 12:06:34 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p1so18636309pfp.13
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 09:06:34 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id t80si15315045pfa.29.2017.12.21.09.06.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 21 Dec 2017 09:06:33 -0800 (PST)
Date: Thu, 21 Dec 2017 09:06:28 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] Move kfree_call_rcu() to slab_common.c
Message-ID: <20171221170628.GA25009@bombadil.infradead.org>
References: <1513844387-2668-1-git-send-email-rao.shoaib@oracle.com>
 <20171221155434.GT7829@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171221155434.GT7829@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: rao.shoaib@oracle.com, linux-kernel@vger.kernel.org, brouer@redhat.com, linux-mm@kvack.org

On Thu, Dec 21, 2017 at 07:54:34AM -0800, Paul E. McKenney wrote:
> > +/* Queue an RCU callback for lazy invocation after a grace period.
> > + * Currently there is no way of tagging the lazy RCU callbacks in the
> > + * list of pending callbacks. Until then, this function may only be
> > + * called from kfree_call_rcu().
> 
> But now we might have a way.
> 
> If the value in ->func is too small to be a valid function, RCU invokes
> a fixed function name.  This function can then look at ->func and do
> whatever it wants, for example, maintaining an array indexed by the
> ->func value that says what function to call and what else to pass it,
> including for example the slab pointer and offset.
> 
> Thoughts?

Thought 1 is that we can force functions to be quad-byte aligned on all
architectures (gcc option -falign-functions=...), so we can have more
than the 4096 different values we currently use.  We can get 63.5 bits of
information into that ->func argument if we align functions to at least
4 bytes, or 63 if we only force alignment to a 2-byte boundary.  I'm not
sure if we support any architecture other than x86 with byte-aligned
instructions.  (I'm assuming that function descriptors as used on POWER
and ia64 will also be sensibly aligned).

Thought 2 is that the slab is quite capable of getting the slab pointer
from the address of the object -- virt_to_head_page(p)->slab_cache
So sorting objects by address is as good as storing their slab caches
and offsets.

Thought 3 is that we probably don't want to overengineer this.
Just allocating a 14-entry buffer (along with an RCU head) is probably
enough to give us at least 90% of the wins that a more complex solution
would give.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
