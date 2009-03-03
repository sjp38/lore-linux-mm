Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AFB0E6B009C
	for <linux-mm@kvack.org>; Tue,  3 Mar 2009 09:41:50 -0500 (EST)
Date: Tue, 3 Mar 2009 15:41:46 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch 2/2] buffer, btrfs: fix page_mkwrite error cases
Message-ID: <20090303144146.GA18142@wotan.suse.de>
References: <20090303103838.GC17042@wotan.suse.de> <20090303104114.GD17042@wotan.suse.de> <1236090363.782.6.camel@think.oraclecorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1236090363.782.6.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 03, 2009 at 09:26:03AM -0500, Chris Mason wrote:
> On Tue, 2009-03-03 at 11:41 +0100, Nick Piggin wrote:
> > page_mkwrite is called with neither the page lock nor the ptl held. This
> > means a page can be concurrently truncated or invalidated out from underneath
> > it. Callers are supposed to prevent truncate races themselves, however
> > previously the only thing they can do in case they hit one is to raise a
> > SIGBUS. A sigbus is wrong for the case that the page has been invalidated
> > or truncated within i_size (eg. hole punched). Callers may also have to
> > perform memory allocations in this path, where again, SIGBUS would be wrong.
> > 
> > The previous patch made it possible to properly specify errors. Convert
> > the generic buffer.c code and btrfs to return sane error values
> > (in the case of page removed from pagecache, VM_FAULT_NOPAGE will cause the
> > fault handler to exit without doing anything, and the fault will be retried 
> > properly).
> > 
> 
> Thanks Nick.  I think the btrfs patch needs an extra } to compile, but
> it looks fine.

OK... btrfs is obviously untested :) I just got to btrfs and realised
that probably most of the non-trivial ones will want fs maintainers to
take a look. I *think* the following errors should mostly be right:

!page->mapping ==> VM_FAULT_NOPAGE (just cause the VM to retry the fault)
-ENOMEM ==> VM_FAULT_OOM
any other error ==> VM_FAULT_SIGBUS

But there are a lot of possible error paths in some fs'es...

[ For anyone unclear, SIGBUS is to be used when the physical object under
the virtual mapping is invalid/unavailable, as opposed to SIGSEGV for
when the virtual mapping itself if invalid. Obviously fs is below the
virtual memory layer, so SIGBUS / OOM are the only errors that make sense. ]

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
