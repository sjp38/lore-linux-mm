Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 944806B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 05:05:21 -0400 (EDT)
Date: Wed, 29 Apr 2009 17:05:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in
	the VM II
Message-ID: <20090429090501.GB15488@localhost>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com> <20090409072949.GF14687@one.firstfloor.org> <20090409075805.GG14687@one.firstfloor.org> <1239283829.23150.34.camel@think.oraclecorp.com> <20090409140257.GI14687@one.firstfloor.org> <1239287859.23150.57.camel@think.oraclecorp.com> <20090429081616.GA8339@localhost> <20090429083655.GA23223@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090429083655.GA23223@one.firstfloor.org>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Chris Mason <chris.mason@oracle.com>, "hugh@veritas.com" <hugh@veritas.com>, "npiggin@suse.de" <npiggin@suse.de>, "riel@redhat.com" <riel@redhat.com>, "lee.schermerhorn@hp.com" <lee.schermerhorn@hp.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "x86@kernel.org" <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 29, 2009 at 04:36:55PM +0800, Andi Kleen wrote:
> > > I'll have to read harder next week, the FS invalidatepage may expect
> > > truncate to be the only caller.
> > 
> > If direct de-dirty is hard for some pages, how about just ignore them?
> 
> You mean just ignoring it for the pages where it is hard?

Yes.

> Yes that is what it is essentially doing right now. But at least
> some dirty pages need to be handled because most user space
> pages tend to be dirty.

Sure.  There are three types of dirty pages:

A. now dirty, can be de-dirty in the current code
B. now dirty, cannot be de-dirty
C. now dirty and writeback, cannot be de-dirty

I mean B and C can be handled in one single place - the block layer.

If B is hard to be de-dirtied now, ignore them for now and they will
eventually be going to IO and become C.

> > There are the PG_writeback pages anyway. We can inject code to
> > intercept them at the last stage of IO request dispatching.
> 
> That would require adding error out code through all the file systems,
> right?

Not necessarily. The file systems deal with buffer head, extend map
and bios, they normally won't touch the poisoned page content at all.

So it's mostly safe to add one single door-keeper at the low level
request dispatch queue.

> > 
> > Some perceivable problems and solutions are
> > 1) the intercepting overheads could be costly => inject code at runtime.
> > 2) there are cases that the dirty page could be copied for IO:
> 
> At some point we should probably add poison checks before these operations

Maybe some ext4 developers can drop us more hint one these two cases.
We can also do some instruments to see how often (2.1.x) will happen.

But I guess a simple PagePoison() test is cheap anyway.

> yes. At least for read it should be the same code path as EIO --
> you have to check PG_error anyways  (or at least you ought to)
> The main difference is that for write you have to check it too.

Check which on write? You mean Copy-out?

Another copy path is the bounced read/write... I guess it won't be
common in 64bit system though.

> >    2.1) jbd2 has two copy-out cases => should be rare. just ignore them?
> >      2.1.1) do_get_write_access(): buffer sits in two active commits
> >      2.1.2) jbd2_journal_write_metadata_buffer(): buffer happens to start
> >             with JBD2_MAGIC_NUMBER
> >    2.2) btrfs have to read page for compress/encryption
> >      Chris: is btrfs_zlib_compress_pages() a good place for detecting
> >      poison pages? Or is it necessary at all for btrfs?(ie. it's
> >      already relatively easy to de-dirty btrfs pages.)
> 
> I think btrfs' IO error handling is not very great right now. But once
> it matures i hope poison pages can be handled in the same way as
> regular IO errors.

OK.

> >    2.3) maybe more cases...
> 
> Undoubtedly. Goal is just to handle the common cases that cover a lot 
> of memory. This will never be 100%.

Right. We'll discover/cover more cases as time goes by.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
