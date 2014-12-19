Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f52.google.com (mail-qa0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id A7C3B6B0038
	for <linux-mm@kvack.org>; Fri, 19 Dec 2014 05:31:29 -0500 (EST)
Received: by mail-qa0-f52.google.com with SMTP id x12so410924qac.25
        for <linux-mm@kvack.org>; Fri, 19 Dec 2014 02:31:29 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g75si11358566qge.83.2014.12.19.02.31.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Dec 2014 02:31:28 -0800 (PST)
Date: Fri, 19 Dec 2014 11:31:13 +0100
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] Slab infrastructure for array operations
Message-ID: <20141219113113.477fd18f@redhat.com>
In-Reply-To: <20141218140629.393972c7bd8b3b884507264c@linux-foundation.org>
References: <alpine.DEB.2.11.1412181031520.2962@gentwo.org>
	<20141218140629.393972c7bd8b3b884507264c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, akpm@linuxfoundation.org, Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Linux Memory Management List <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, brouer@redhat.com


On Thu, 18 Dec 2014 14:06:29 -0800 Andrew Morton <akpm@linux-foundation.org> wrote:

> On Thu, 18 Dec 2014 10:33:23 -0600 (CST) Christoph Lameter <cl@linux.com> wrote:
> 
> > This patch adds the basic infrastructure for alloc / free operations
> > on pointer arrays.
> 
> Please provide the justification/reason for making this change.

I agree that this needs more justification.

I (think) the reason behind this is a first step towards "bulk" alloc
and free.  And the reason behind that is to save/amortize the cost of
the locking/CAS operations.


> > Allocators must define _HAVE_SLAB_ALLOCATOR_OPERATIONS in their
> > header files in order to implement their own fast version for
> > these array operations.

I would like to see an implementation of a fast-version.  Else it is
difficult to evaluate if the API is the right one.  E.g. if it would be
beneficial for the MM system, we could likely restrict the API to only
work with power-of-two, from the beginning.


> Why?  What's driving this?

The network stack have a pattern of allocating 64 SKBs while pulling
out packets of the NICs RX-ring.  Packets are placing into the TX-ring,
and later at TX-completing time, we free up-to 256 SKBs (depending on
driver).

Another use-case, which need smaller bulk's, could be tree-structures
that need to expand, allocating two elems in one-shot should cut the
alloc overhead in half.

I'm implemented a prove-of-concept[1] lockless bulk alloc and free
scheme, that demonstrate this can benefit the network stack.  Now,
Christoph and I are trying to integrate some of the ideas into the slub
allocator.


[1] http://thread.gmane.org/gmane.linux.network/342347/focus=126138 
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
