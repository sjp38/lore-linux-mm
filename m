Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 0F5786B004D
	for <linux-mm@kvack.org>; Thu, 28 May 2009 10:49:56 -0400 (EDT)
Date: Thu, 28 May 2009 22:50:21 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090528145021.GA5503@localhost>
References: <200905271012.668777061@firstfloor.org> <20090527201239.C2C9C1D0294@basil.firstfloor.org> <20090528082616.GG6920@wotan.suse.de> <20090528093141.GD1065@one.firstfloor.org> <20090528120854.GJ6920@wotan.suse.de> <20090528134520.GH1065@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528134520.GH1065@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Nick Piggin <npiggin@suse.de>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 09:45:20PM +0800, Andi Kleen wrote:
> On Thu, May 28, 2009 at 02:08:54PM +0200, Nick Piggin wrote:

[snip]

> > 
> > BTW. I don't know if you are checking for PG_writeback often enough?
> > You can't remove a PG_writeback page from pagecache. The normal
> > pattern is lock_page(page); wait_on_page_writeback(page); which I
> 
> So pages can be in writeback without being locked? I still
> wasn't able to find such a case (in fact unless I'm misreading
> the code badly the writeback bit is only used by NFS and a few  
> obscure cases)

Yes the writeback page is typically not locked. Only read IO requires
to be exclusive. Read IO is in fact page *writer*, while writeback IO
is page *reader* :-)

The writeback bit is _widely_ used.  test_set_page_writeback() is
directly used by NFS/AFS etc. But its main user is in fact
set_page_writeback(), which is called in 26 places.

> > think would be safest 
> 
> Okay. I'll just add it after the page lock.
> 
> > (then you never have to bother with the writeback bit again)
> 
> Until Fengguang does something fancy with it.

Yes I'm going to do it without wait_on_page_writeback().

The reason truncate_inode_pages_range() has to wait on writeback page
is to ensure data integrity. Otherwise if there comes two events:
        truncate page A at offset X
        populate page B at offset X
If A and B are all writeback pages, then B can hit disk first and then
be overwritten by A. Which corrupts the data at offset X from user's POV.

But for hwpoison, there are no such worries. If A is poisoned, we do
our best to isolate it as well as intercepting its IO. If the interception
fails, it will trigger another machine check before hitting the disk.

After all, poisoned A means the data at offset X is already corrupted.
It doesn't matter if there comes another B page.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
