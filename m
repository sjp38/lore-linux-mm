Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 22EB46B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 04:07:33 -0400 (EDT)
Message-ID: <1343894848.2874.15.camel@dabdike.int.hansenpartnership.com>
Subject: Re: Any reason to use put_page in slub.c?
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Date: Thu, 02 Aug 2012 09:07:28 +0100
In-Reply-To: <alpine.DEB.2.00.1208011307450.4606@router.home>
References: <1343391586-18837-1-git-send-email-glommer@parallels.com>
	 <alpine.DEB.2.00.1207271054230.18371@router.home>
	 <50163D94.5050607@parallels.com>
	 <alpine.DEB.2.00.1207301421150.27584@router.home>
	 <5017968C.6050301@parallels.com>
	 <alpine.DEB.2.00.1207310906350.32295@router.home>
	 <5017E72D.2060303@parallels.com>
	 <alpine.DEB.2.00.1207310915150.32295@router.home>
	 <5017E929.70602@parallels.com>
	 <alpine.DEB.2.00.1207310927420.32295@router.home>
	 <1343746344.8473.4.camel@dabdike.int.hansenpartnership.com>
	 <50192453.9080706@parallels.com>
	 <alpine.DEB.2.00.1208011307450.4606@router.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>

On Wed, 2012-08-01 at 13:10 -0500, Christoph Lameter wrote:
> On Wed, 1 Aug 2012, Glauber Costa wrote:
> 
> > I've audited all users of get_page() in the drivers/ directory for
> > patterns like this. In general, they kmalloc something like a table of
> > entries, and then get_page() the entries. The entries are either user
> > pages, pages allocated by the page allocator, or physical addresses
> > through their pfn (in 2 cases from the vga ones...)
> >
> > I took a look about some other instances where virt_to_page occurs
> > together with kmalloc as well, and they all seem to fall in the same
> > category.
> 
> The case that was notorious in the past was a scsi control structure
> allocated from slab that was then written to the device via DMA. And it
> was not on x86 but some esoteric platform (powerpc?),
> 
> A reference to the discussion of this issue in 2007:
> 
> http://lkml.indiana.edu/hypermail/linux/kernel/0706.3/0424.html

What you wrote above bears no relation to the thread.  The thread is a
long argument about what flush_dcache_page() should be doing if called
on slab memory.  Hugh told you about five times: "nothing".  Which is
the correct answer since flush_dcache_page() is our user to kernel
memory coherence API ... it's actually nothing to do with DMA although
it can be used to cause coherence for the purposes for DMA, but often
it's simply used to allow the kernel to write to or read from user
memory.

What you seem to be worried about is DMA cache line interference caused
by object misalignment?  But even in what you wrote above it's clear you
don't understand what that actually is.

As long as you flush correctly, you can never actually get DMA cache
line interference on memory being sent to a device via DMA ... however
misaligned it is.  The killer case is unresolvable incoherencies when
you DMA *from* a device.  For this case, if you have a cache line
overlapping an object like this

--------------------------------
  OBJ     | Other OBJ
--------------------------------
  | CPU Cache line |
--------------------------------

If OBJ gets its underlying page altered by DMA at the same time someone
writes to other OBJ (causing the CPU to pull in the cache line with the
old pre-DMA value for OBJ and then dirty the component for Other OBJ),
you have both a dirty cache line and altered (i.e. dirty) underlying
memory.  Here an invalidate will destroy the update to other OBJ and a
flush will destroy the DMA update to OBJ, so the alias is unresolvable.

Is that what the worry is?

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
