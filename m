Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 10D966B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 18:08:54 -0400 (EDT)
Subject: Re: [patch 2/2] fs: fix page_mkwrite error cases in core code and
 btrfs
From: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20090311035503.GI16561@wotan.suse.de>
References: <20090311035318.GH16561@wotan.suse.de>
	 <20090311035503.GI16561@wotan.suse.de>
Content-Type: text/plain
Date: Thu, 12 Mar 2009 18:08:44 -0400
Message-Id: <1236895724.7179.71.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Chris Mason <chris.mason@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-03-11 at 04:55 +0100, Nick Piggin wrote:
> page_mkwrite is called with neither the page lock nor the ptl held. This
> means a page can be concurrently truncated or invalidated out from underneath
> it. Callers are supposed to prevent truncate races themselves, however
> previously the only thing they can do in case they hit one is to raise a
> SIGBUS. A sigbus is wrong for the case that the page has been invalidated
> or truncated within i_size (eg. hole punched). Callers may also have to
> perform memory allocations in this path, where again, SIGBUS would be wrong.
> 
> The previous patch made it possible to properly specify errors. Convert
> the generic buffer.c code and btrfs to return sane error values
> (in the case of page removed from pagecache, VM_FAULT_NOPAGE will cause the
> fault handler to exit without doing anything, and the fault will be retried 
> properly).
> 
> This fixes core code, and converts btrfs as a template/example. All other
> filesystems defining their own page_mkwrite should be fixed in a similar
> manner.

There appears to be another atomicity problem in the same area of
code...

The lack of locking between the call to ->page_mkwrite() and the
subsequent call to set_page_dirty_balance() means that the filesystem
may actually already have written out the page by the time you get round
to calling set_page_dirty_balance().

How then is the filesystem supposed to guarantee that whatever structure
it allocated in page_mkwrite() is still around when the page gets marked
as dirty a second time?

Trond

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
