Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 533226B004F
	for <linux-mm@kvack.org>; Wed,  4 Mar 2009 05:21:11 -0500 (EST)
Date: Wed, 4 Mar 2009 11:21:07 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] mm: page_mkwrite change prototype to match fault
Message-ID: <20090304102107.GE27043@wotan.suse.de>
References: <20090303103838.GC17042@wotan.suse.de> <20090303155835.GA28851@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090303155835.GA28851@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 10:58:35AM -0500, Christoph Hellwig wrote:
> On Tue, Mar 03, 2009 at 11:38:38AM +0100, Nick Piggin wrote:
> > 
> > Change the page_mkwrite prototype to take a struct vm_fault, and return
> > VM_FAULT_xxx flags. Same as ->fault handler. Should be no change in
> > behaviour.
> 
> How about just merging it into ->fault?
> 
> > This is required for a subsequent fix. And will also make it easier to
> > merge page_mkwrite() with fault() in future.
> 
> Ah, I should read until the end :)  Any reason not to do the merge just
> yet?

Getting there... after my proposed locking change as well it should
be even another step closer.

The only thing is that we probably need to keep the page_mkwrite callback
in the fs layer, but just move it out of the VM. Because it is hard to
make a generic fault function that does the right page_mkwrite thing
for all filesystems.

But at least pushing it down that step will give better efficiency and
be simpler in the VM. (full page fault today has to lock and unlock the
page 3 times with page_mkwrite, wheras it should go to 2 after my locking
change, and then 1 when page_mkwrite gets merged into fault).

It's coming... just a bit slowly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
