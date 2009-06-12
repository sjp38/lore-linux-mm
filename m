Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2D8B46B004D
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 09:48:03 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 0AAB082C57A
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:05:17 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id FFafZsKEvI7f for <linux-mm@kvack.org>;
	Fri, 12 Jun 2009 10:05:16 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id D806582C5FE
	for <linux-mm@kvack.org>; Fri, 12 Jun 2009 10:05:10 -0400 (EDT)
Date: Fri, 12 Jun 2009 09:49:26 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: slab: setup allocators earlier in the boot sequence
In-Reply-To: <1244797659.30512.37.camel@penberg-laptop>
Message-ID: <alpine.DEB.1.10.0906120944540.15809@gentwo.org>
References: <200906111959.n5BJxFj9021205@hera.kernel.org>  <1244770230.7172.4.camel@pasglop>  <1244779009.7172.52.camel@pasglop>  <1244780756.7172.58.camel@pasglop> <1244783235.7172.61.camel@pasglop>  <Pine.LNX.4.64.0906120913460.26843@melkki.cs.Helsinki.FI>
  <1244792079.7172.74.camel@pasglop>  <1244792745.30512.13.camel@penberg-laptop>  <1244796045.7172.82.camel@pasglop>  <1244796211.30512.32.camel@penberg-laptop>  <1244796837.7172.95.camel@pasglop> <1244797659.30512.37.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, mingo@elte.hu, akpm@linux-foundation.org, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jun 2009, Pekka Enberg wrote:

> So I am sending the GFP_NOWAIT conversion for boot code even though you
> didn't seem to like it (but didn't explicitly NAK) as it fixes problems
> on x86.

The use GFP_NOWAIT means that the caller sites are still special cased for
an early boot situation. After bootstrap is complete the sites may use
GFP_KERNEL instead. Bad.

Best thing to do is to recognize the fact that we are still in early boot
in the allocators. Derived allocators (such as slab and vmalloc) mask bits
using GFP_RECLAIM_MASK and when doing allocations through the page
allocator. You could make GFP_RECLAIM_MASK a variable. During boot
__GFP_WAIT would not be set in GFP_RECLAIM_MASK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
