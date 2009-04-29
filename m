Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 93BC66B003D
	for <linux-mm@kvack.org>; Wed, 29 Apr 2009 04:16:50 -0400 (EDT)
Date: Wed, 29 Apr 2009 16:16:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] [13/16] POISON: The high level memory error handler in
	the VM II
Message-ID: <20090429081616.GA8339@localhost>
References: <20090407509.382219156@firstfloor.org> <20090407151010.E72A91D0471@basil.firstfloor.org> <1239210239.28688.15.camel@think.oraclecorp.com> <20090409072949.GF14687@one.firstfloor.org> <20090409075805.GG14687@one.firstfloor.org> <1239283829.23150.34.camel@think.oraclecorp.com> <20090409140257.GI14687@one.firstfloor.org> <1239287859.23150.57.camel@think.oraclecorp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1239287859.23150.57.camel@think.oraclecorp.com>
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Andi Kleen <andi@firstfloor.org>, hugh@veritas.com, npiggin@suse.de, riel@redhat.com, lee.schermerhorn@hp.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, x86@kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Apr 09, 2009 at 10:37:39AM -0400, Chris Mason wrote:
> On Thu, 2009-04-09 at 16:02 +0200, Andi Kleen wrote:
> > On Thu, Apr 09, 2009 at 09:30:29AM -0400, Chris Mason wrote:
> > > > Is that a correct assumption?
> > > 
> > > Yes, the page won't become writeback when you're holding the page lock.
> > > But, the FS usually thinks of try_to_releasepage as a polite request.
> > > It might fail internally for a bunch of reasons.
> > > 
> > > To make things even more fun, the page won't become writeback magically,
> > > but ext3 and reiser maintain lists of buffer heads for data=ordered, and
> > > they do the data=ordered IO on the buffer heads directly.  writepage is
> > > never called and the page lock is never taken, but the buffer heads go
> > > to disk.  I don't think any of the other filesystems do it this way.
> > 
> > Ok, so do you think my code handles this correctly?
> 
> Even though try_to_releasepage only checks page_writeback() the lower
> filesystems all bail on dirty pages or dirty buffers (see the checks
> done by try_to_free_buffers).
> 
> It looks like the only way we have to clean a page and all the buffers
> in it is the invalidatepage call.  But that doesn't return success or
> failure, so maybe invalidatepage followed by releasepage?
> 
> I'll have to read harder next week, the FS invalidatepage may expect
> truncate to be the only caller.

If direct de-dirty is hard for some pages, how about just ignore them?
There are the PG_writeback pages anyway. We can inject code to
intercept them at the last stage of IO request dispatching.

Some perceivable problems and solutions are
1) the intercepting overheads could be costly => inject code at runtime.
2) there are cases that the dirty page could be copied for IO:
   2.1) jbd2 has two copy-out cases => should be rare. just ignore them?
     2.1.1) do_get_write_access(): buffer sits in two active commits
     2.1.2) jbd2_journal_write_metadata_buffer(): buffer happens to start
            with JBD2_MAGIC_NUMBER
   2.2) btrfs have to read page for compress/encryption
     Chris: is btrfs_zlib_compress_pages() a good place for detecting
     poison pages? Or is it necessary at all for btrfs?(ie. it's
     already relatively easy to de-dirty btrfs pages.)
   2.3) maybe more cases...

> > 
> > > If we really want the page gone, we'll have to tell the FS
> > > drop-this-or-else....sorry, its some ugly stuff.
> > 
> > I would like to give a very strong hint at least. If it fails
> > we can still ignore it, but it will likely have negative consequences later.
> > 
> 
> Nod.
> 
> > > 
> > > The good news is, it is pretty rare.  I wouldn't hold up the whole patch
> > 
> > You mean pages with Private bit are rare? Are you suggesting to just
> > ignore those? How common is it to have Private pages which are not
> > locked by someone else?
> > 
> 
> PagePrivate is very common.  try_to_releasepage failing on a clean page
> without the writeback bit set and without dirty/locked buffers will be
> pretty rare.

Yup. btrfs seems to tag most(if not all) dirty pages with PG_private.
While ext4 won't.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
