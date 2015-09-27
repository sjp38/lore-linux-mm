Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id F04AA6B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 19:26:49 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so58952472pab.3
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 16:26:49 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id oq6si23691257pab.88.2015.09.27.16.26.48
        for <linux-mm@kvack.org>;
        Sun, 27 Sep 2015 16:26:49 -0700 (PDT)
Date: Mon, 28 Sep 2015 09:26:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t
 sparse file
Message-ID: <20150927232645.GW3902@dastard>
References: <560723F8.3010909@gmail.com>
 <alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
 <560752C7.80605@gmail.com>
 <alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: angelo <angelo70@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Jeff Layton <jlayton@poochiereds.net>, Eryu Guan <eguan@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Sun, Sep 27, 2015 at 10:59:33AM -0700, Hugh Dickins wrote:
> On Sun, 27 Sep 2015, angelo wrote:
> > On 27/09/2015 03:36, Hugh Dickins wrote:
> > > Let's Cc linux-fsdevel, who will be more knowledgable.
> > > 
> > > On Sun, 27 Sep 2015, angelo wrote:
> > > 
> > > > Hi all,
> > > > 
> > > > running xfstests, generic 308 on whatever 32bit arch is possible
> > > > to observe cpu to hang near 100% on unlink.
> 
> I have since tried to repeat your result, but generic/308 on 32-bit just
> skipped the test for me.  I didn't investigate why: it's quite possible
> that I had a leftover 64-bit executable in the path that it tried to use,
> but didn't show the relevant error message.
>
> I did verify your result with a standalone test; and that proves that
> nobody has actually been using such files in practice before you,
> since unmounting the xfs filesystem would hang in the same way if
> they didn't unlink them.

It used to work - this is a regression. Just because nobody has
reported it recently simply means nobody has run xfstests on 32 bit
storage recently. There are 32 bit systems out there that expect
this to work, and we've broken it.

The regression was introduced in 3.11 by this commit:

commit 5a7203947a1d9b6f3a00a39fda08c2466489555f
Author: Lukas Czerner <lczerner@redhat.com>
Date:   Mon May 27 23:32:35 2013 -0400

    mm: teach truncate_inode_pages_range() to handle non page aligned ranges
    
    This commit changes truncate_inode_pages_range() so it can handle non
    page aligned regions of the truncate. Currently we can hit BUG_ON when
    the end of the range is not page aligned, but we can handle unaligned
    start of the range.
    
    Being able to handle non page aligned regions of the page can help file
    system punch_hole implementations and save some work, because once we're
    holding the page we might as well deal with it right away.
    
    In previous commits we've changed ->invalidatepage() prototype to accept
    'length' argument to be able to specify range to invalidate. No we can
    use that new ability in truncate_inode_pages_range().
    
    Signed-off-by: Lukas Czerner <lczerner@redhat.com>
    Cc: Andrew Morton <akpm@linux-foundation.org>
    Cc: Hugh Dickins <hughd@google.com>
    Signed-off-by: Theodore Ts'o <tytso@mit.edu>


> > > > The test removes a sparse file of length 16tera where only the last
> > > > 4096 bytes block is mapped.
> > > > At line 265 of truncate.c there is a
> > > > if (index >= end)
> > > >      break;
> > > > But if index is, as in this case, a 4294967295, it match -1 used as
> > > > eof. Hence the cpu loops 100% just after.
> > > > 
> > > That's odd.  I've not checked your patch, because I think the problem
> > > would go beyond truncate, and the root cause lie elsewhere.
> > > 
> > > My understanding is that the 32-bit
> > > #define MAX_LFS_FILESIZE (((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
> > > makes a page->index of -1 (or any "negative") impossible to reach.

We've supported > 8TB files on 32 bit XFS file systems since
since mid 2003:

http://oss.sgi.com/cgi-bin/gitweb.cgi?p=archive/xfs-import.git;a=commitdiff;h=d13d78f6b83eefbd90a6cac5c9fbe42560c6511e

And it's been documented as such for a long time, too:

http://xfs.org/docs/xfsdocs-xml-dev/XFS_User_Guide/tmp/en-US/html/ch02s04.html

(that was written, IIRC, back in 2007).

i.e. whatever the definition says about MAX_LFS_FILESIZE being an
8TB limit on 32 bit is stale and has been for a very long time.

> A surprise to me, and I expect to others, that 32-bit xfs is not
> respecting MAX_LFS_FILESIZE: going its own way with 0xfff ffffffff
> instead of 0x7ff ffffffff (on a PAGE_CACHE_SIZE 4096 system).
> 
> MAX_LFS_FILESIZE has been defined that way ever since v2.5.4:
> this is probably just an oversight from when xfs was later added
> into the Linux tree.

We supported >8 TB file offsets on 32 bit systems on 2.4 kernels
with XFS, so it sounds like it was wrong even when it was first
committed. Of course, XFS wasn't merged until 2.5.36, so I guess
nobody realised... ;)

> > But if s_maxbytes doesn't have to be greater than MAX_LFS_FILESIZE,
> > i agree the issue should be fixed in layers above.
> 
> There is a "filesystems should never set s_maxbytes larger than
> MAX_LFS_FILESIZE" comment in fs/super.c, but unfortunately its
> warning is written with just 64-bit in mind (testing for negative).

Yup, introduced here:

commit 42cb56ae2ab67390da34906b27bedc3f2ff1393b
Author: Jeff Layton <jlayton@redhat.com>
Date:   Fri Sep 18 13:05:53 2009 -0700

    vfs: change sb->s_maxbytes to a loff_t
    
    sb->s_maxbytes is supposed to indicate the maximum size of a file that can
    exist on the filesystem.  It's declared as an unsigned long long.

And yes, that will never fire on a 32bit filesystem, because loff_t
is a "long long" type....

> > The fact is that everything still works correct until an index as
> > 17592186044415 - 4096, and there can be users that could already
> > have so big files in use in their setup.
> 
> It's too soon to say "everything still works correct" before that:
> there may be a number of incorrect syscall argument validation checks,
> particularly at the mm end, or incorrect byte<->page offset conversions.

It's "worked correctly" for many years - that regression test used
to pass.  W.r.t to syscall arguments for for manipulating
files that large, they are 64 bit and hence "just work". W.r.t to
byte/page offset conversion, page->index is typed as pgoff_t,
which is:

#define pgoff_t unsigned long

So there should be no sign conversion issues in correctly written
code.

Further: block devices on 32 bit systems support 16TB, they
support buffered IO through the page cache and you can mmap them,
too:

# xfs_io -f -c "mmap 0 32k" -c "mwrite 0 4k" -c msync /dev/ram0
# hexdump /dev/ram0
0000000 5858 5858 5858 5858 5858 5858 5858 5858
*
0001000 0000 0000 0000 0000 0000 0000 0000 0000
*
#

Hence the mm subystem and the page cache *must* support operation up
to 16TB offsets on 32 bit systems regardless of MAX_LFS_FILESIZE
definitions, otherwise direct block device access goes wrong and
then we're really screwed....

> > What do you think ?
> 
> It's a matter for vfs and mm and xfs maintainers to decide.
> 
> FWIW, I don't expect there would be much enthusiasm for doubling
> MAX_LFS_FILESIZE now: it would involve more of a code audit than
> I'd want to spend time on myself.  So personally I'd favour xfs
> enforcing the lower limit, then we keep an eye open for whether
> any user regression is reported.

The horse has already bolted. The code used to work, there are users
out there that are using >8TB files on 32 bit systems. Hence we have
no choice but to fix the regression.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
