Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3C3186B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 13:59:50 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so151839293pac.0
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 10:59:49 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id on4si22112595pbc.147.2015.09.27.10.59.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 10:59:49 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so151891415pad.1
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 10:59:48 -0700 (PDT)
Date: Sun, 27 Sep 2015 10:59:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t sparse
 file
In-Reply-To: <560752C7.80605@gmail.com>
Message-ID: <alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
References: <560723F8.3010909@gmail.com> <alpine.LSU.2.11.1509261835360.9917@eggly.anvils> <560752C7.80605@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: angelo <angelo70@gmail.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Jeff Layton <jlayton@poochiereds.net>, Eryu Guan <eguan@redhat.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, 27 Sep 2015, angelo wrote:
> On 27/09/2015 03:36, Hugh Dickins wrote:
> > Let's Cc linux-fsdevel, who will be more knowledgable.
> > 
> > On Sun, 27 Sep 2015, angelo wrote:
> > 
> > > Hi all,
> > > 
> > > running xfstests, generic 308 on whatever 32bit arch is possible
> > > to observe cpu to hang near 100% on unlink.

I have since tried to repeat your result, but generic/308 on 32-bit just
skipped the test for me.  I didn't investigate why: it's quite possible
that I had a leftover 64-bit executable in the path that it tried to use,
but didn't show the relevant error message.

I did verify your result with a standalone test; and that proves that
nobody has actually been using such files in practice before you,
since unmounting the xfs filesystem would hang in the same way if
they didn't unlink them.

> > > The test removes a sparse file of length 16tera where only the last
> > > 4096 bytes block is mapped.
> > > At line 265 of truncate.c there is a
> > > if (index >= end)
> > >      break;
> > > But if index is, as in this case, a 4294967295, it match -1 used as
> > > eof. Hence the cpu loops 100% just after.
> > > 
> > That's odd.  I've not checked your patch, because I think the problem
> > would go beyond truncate, and the root cause lie elsewhere.
> > 
> > My understanding is that the 32-bit
> > #define MAX_LFS_FILESIZE (((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
> > makes a page->index of -1 (or any "negative") impossible to reach.
> > 
> > I don't know offhand the rules for mounting a filesystem populated with
> > a 64-bit kernel on a 32-bit kernel, what's to happen when a too-large
> > file is encountered; but assume that's not the case here - you're
> > just running xfstests/tests/generic/308.
> > 
> > Is pwrite missing a check for offset beyond s_maxbytes?
> > 
> > Or is this filesystem-dependent?  Which filesystem?
>
> Hi Hugh,
> 
> thanks for the fast reply..
> 
> Looks like the XFS file system can support files until 16 Tera
> when CONFIG_LBDAF is enabled.
> 
> On XFS, 32 bit arch, s_maxbytes is actually set (CONFIG_LBDAF=y) as
> 17592186044415.

This is a valuable catch, no doubt of that, thank you.

A surprise to me, and I expect to others, that 32-bit xfs is not
respecting MAX_LFS_FILESIZE: going its own way with 0xfff ffffffff
instead of 0x7ff ffffffff (on a PAGE_CACHE_SIZE 4096 system).

MAX_LFS_FILESIZE has been defined that way ever since v2.5.4:
this is probably just an oversight from when xfs was later added
into the Linux tree.

I can't tell you why MAX_LFS_FILESIZE was defined to exclude half
of the available range.  I've always assumed that it's because there
were known or feared areas of the code, which manipulate between
bytes and pages, and might hit sign extension issues - though
I cannot identify those places myself.

> 
> But if s_maxbytes doesn't have to be greater than MAX_LFS_FILESIZE,
> i agree the issue should be fixed in layers above.

There is a "filesystems should never set s_maxbytes larger than
MAX_LFS_FILESIZE" comment in fs/super.c, but unfortunately its
warning is written with just 64-bit in mind (testing for negative).

> 
> The fact is that everything still works correct until an index as
> 17592186044415 - 4096, and there can be users that could already
> have so big files in use in their setup.

It's too soon to say "everything still works correct" before that:
there may be a number of incorrect syscall argument validation checks,
particularly at the mm end, or incorrect byte<->page offset conversions.

> 
> What do you think ?

It's a matter for vfs and mm and xfs maintainers to decide.

FWIW, I don't expect there would be much enthusiasm for doubling
MAX_LFS_FILESIZE now: it would involve more of a code audit than
I'd want to spend time on myself.  So personally I'd favour xfs
enforcing the lower limit, then we keep an eye open for whether
any user regression is reported.

There have been suggestions that there should be a 32-bit CONFIG
with a 64-bit page->index, to allow a 32-bit kernel to access a
fully 64-bit filesystem; but that's a different and larger task.

Hugh

> 
> Best regards
> Angelo Dureghello
> 
> > 
> > Hugh
> > 
> > > -------------------
> > > 
> > > On 32bit archs, with CONFIG_LBDAF=y, if truncating last page
> > > of a 16tera file, "index" variable is set to 4294967295, and hence
> > > matches with -1 used as EOF value. This result in an inifite loop
> > > when unlink is executed on this file.
> > > 
> > > Signed-off-by: Angelo Dureghello <angelo@sysam.it>
> > > ---
> > >   mm/truncate.c | 11 ++++++-----
> > >   1 file changed, 6 insertions(+), 5 deletions(-)
> > > 
> > > diff --git a/mm/truncate.c b/mm/truncate.c
> > > index 76e35ad..3751034 100644
> > > --- a/mm/truncate.c
> > > +++ b/mm/truncate.c
> > > @@ -283,14 +283,15 @@ void truncate_inode_pages_range(struct
> > > address_space
> > > *mapping,
> > >                  pagevec_remove_exceptionals(&pvec);
> > >                  pagevec_release(&pvec);
> > >                  cond_resched();
> > > -               index++;
> > > +               if (index < end)
> > > +                       index++;
> > >          }
> > > 
> > >          if (partial_start) {
> > >                  struct page *page = find_lock_page(mapping, start - 1);
> > >                  if (page) {
> > >                          unsigned int top = PAGE_CACHE_SIZE;
> > > -                       if (start > end) {
> > > +                       if (start > end && end != -1) {
> > >                                  /* Truncation within a single page */
> > >                                  top = partial_end;
> > >                                  partial_end = 0;
> > > @@ -322,7 +323,7 @@ void truncate_inode_pages_range(struct address_space
> > > *mapping,
> > >           * If the truncation happened within a single page no pages
> > >           * will be released, just zeroed, so we can bail out now.
> > >           */
> > > -       if (start >= end)
> > > +       if (start >= end && end != -1)
> > >                  return;
> > > 
> > >          index = start;
> > > @@ -337,7 +338,7 @@ void truncate_inode_pages_range(struct address_space
> > > *mapping,
> > >                          index = start;
> > >                          continue;
> > >                  }
> > > -               if (index == start && indices[0] >= end) {
> > > +               if (index == start && (indices[0] >= end && end != -1)) {
> > >                          /* All gone out of hole to be punched, we're
> > > done */
> > >                          pagevec_remove_exceptionals(&pvec);
> > >                          pagevec_release(&pvec);
> > > @@ -348,7 +349,7 @@ void truncate_inode_pages_range(struct address_space
> > > *mapping,
> > > 
> > >                          /* We rely upon deletion not changing
> > > page->index */
> > >                          index = indices[i];
> > > -                       if (index >= end) {
> > > +                       if (index >= end && (end != -1)) {
> > >                                  /* Restart punch to make sure all gone
> > > */
> > >                                  index = start - 1;
> > >                                  break;
> > > -- 
> > > 2.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
