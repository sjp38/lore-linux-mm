Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 688026B00FE
	for <linux-mm@kvack.org>; Sat, 30 May 2009 22:24:05 -0400 (EDT)
Date: Sat, 30 May 2009 19:21:58 -0700
From: "Larry H." <research@subreption.com>
Subject: Re: [PATCH] Change ZERO_SIZE_PTR to point at unmapped space
Message-ID: <20090531022158.GA9033@oblivion.subreption.com>
References: <20090530192829.GK6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301528540.3435@localhost.localdomain> <20090530230022.GO6535@oblivion.subreption.com> <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.01.0905301902010.3435@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 19:02 Sat 30 May     , Linus Torvalds wrote:
> 
> 
> On Sat, 30 May 2009, Larry H. wrote:
> > 
> > Like I said in the reply to Peter, this is 3 extra bytes for amd64 with
> > gcc 4.3.3. I can't be bothered to check other architectures at the
> > moment.
> 
> .. and I can't be bothered with applying this. I'm just not convinced.

The changes don't conflict with anything else (including ERR_PTR and
company). When I said bothered, I implied the change was obviously not
going to differ in any significant way for other architectures.

Like I said, small changes like this are done so we don't need to rely
on mmap_min_addr, which is disabled by default (albeit some
distributions enable it, normally set to 65536).

Let me provide you with a realistic scenario:

	1. foo.c network protocol implementation takes a sockopt which
	sets some ACME_OPTLEN value taken from userland.

	2. the length is not validated properly: it can be zero or an
	integer overflow / signedness issue allows it to wrap to zero.

	3. kmalloc(0) ensues, and data is copied to the pointer
	returned. if this is the default ZERO_SIZE_PTR*, a malicious user
	can mmap a page at NULL, and read data leaked from kernel memory
	everytime that setsockopt is issued.
	(*: kmalloc of zero returns ZERO_SIZE_PTR)

If ZERO_SIZE_PTR points to an unmapped top memory address, this will
trigger a distinctive page fault and the user won't be able to abuse
this for elevating privileges or read kernel memory. Variations of the
scenario above have been present in the kernel, some with exploits being
made available publicly. Most recently, a SCTP sockopt issue.

> It's 3 extra bytes just for the constant. It's also another test, and 
> another branch.

What's the total difference, less than 40 bytes? Do the users of this
macro get impacted? No. Who uses the macro? kzfree/kfree/do_kmalloc/etc.
A dozen users, all in SLAB.

The performance impact, if any, is completely negligible. The security
benefits of this utterly simple change well surpass the downsides.

	Larry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
