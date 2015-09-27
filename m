Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f174.google.com (mail-qk0-f174.google.com [209.85.220.174])
	by kanga.kvack.org (Postfix) with ESMTP id DA8756B0038
	for <linux-mm@kvack.org>; Sun, 27 Sep 2015 19:57:01 -0400 (EDT)
Received: by qkcf65 with SMTP id f65so61808691qkc.3
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 16:57:01 -0700 (PDT)
Received: from mail-qg0-f49.google.com (mail-qg0-f49.google.com. [209.85.192.49])
        by mx.google.com with ESMTPS id j101si13292081qkh.30.2015.09.27.16.57.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 27 Sep 2015 16:57:00 -0700 (PDT)
Received: by qgx61 with SMTP id 61so108692820qgx.3
        for <linux-mm@kvack.org>; Sun, 27 Sep 2015 16:57:00 -0700 (PDT)
Date: Sun, 27 Sep 2015 19:56:55 -0400
From: Jeff Layton <jlayton@poochiereds.net>
Subject: Re: [PATCH] mm: fix cpu hangs on truncating last page of a 16t
 sparse file
Message-ID: <20150927195655.18e20003@tlielax.poochiereds.net>
In-Reply-To: <20150927232645.GW3902@dastard>
References: <560723F8.3010909@gmail.com>
	<alpine.LSU.2.11.1509261835360.9917@eggly.anvils>
	<560752C7.80605@gmail.com>
	<alpine.LSU.2.11.1509270953460.1024@eggly.anvils>
	<20150927232645.GW3902@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Hugh Dickins <hughd@google.com>, angelo <angelo70@gmail.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Eryu Guan <eguan@redhat.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Sep 2015 09:26:45 +1000
Dave Chinner <david@fromorbit.com> wrote:

> On Sun, Sep 27, 2015 at 10:59:33AM -0700, Hugh Dickins wrote:
> > On Sun, 27 Sep 2015, angelo wrote:
> > > On 27/09/2015 03:36, Hugh Dickins wrote:
> > > > Let's Cc linux-fsdevel, who will be more knowledgable.
> > > > 
> > > > On Sun, 27 Sep 2015, angelo wrote:
> > > > 
> > > > > Hi all,
> > > > > 
> > > > > running xfstests, generic 308 on whatever 32bit arch is possible
> > > > > to observe cpu to hang near 100% on unlink.
> > 
> > I have since tried to repeat your result, but generic/308 on 32-bit just
> > skipped the test for me.  I didn't investigate why: it's quite possible
> > that I had a leftover 64-bit executable in the path that it tried to use,
> > but didn't show the relevant error message.
> >
> > I did verify your result with a standalone test; and that proves that
> > nobody has actually been using such files in practice before you,
> > since unmounting the xfs filesystem would hang in the same way if
> > they didn't unlink them.
> 
> It used to work - this is a regression. Just because nobody has
> reported it recently simply means nobody has run xfstests on 32 bit
> storage recently. There are 32 bit systems out there that expect
> this to work, and we've broken it.
> 
> The regression was introduced in 3.11 by this commit:
> 
> commit 5a7203947a1d9b6f3a00a39fda08c2466489555f
> Author: Lukas Czerner <lczerner@redhat.com>
> Date:   Mon May 27 23:32:35 2013 -0400
> 
>     mm: teach truncate_inode_pages_range() to handle non page aligned ranges
>     
>     This commit changes truncate_inode_pages_range() so it can handle non
>     page aligned regions of the truncate. Currently we can hit BUG_ON when
>     the end of the range is not page aligned, but we can handle unaligned
>     start of the range.
>     
>     Being able to handle non page aligned regions of the page can help file
>     system punch_hole implementations and save some work, because once we're
>     holding the page we might as well deal with it right away.
>     
>     In previous commits we've changed ->invalidatepage() prototype to accept
>     'length' argument to be able to specify range to invalidate. No we can
>     use that new ability in truncate_inode_pages_range().
>     
>     Signed-off-by: Lukas Czerner <lczerner@redhat.com>
>     Cc: Andrew Morton <akpm@linux-foundation.org>
>     Cc: Hugh Dickins <hughd@google.com>
>     Signed-off-by: Theodore Ts'o <tytso@mit.edu>
> 
> 
> > > > > The test removes a sparse file of length 16tera where only the last
> > > > > 4096 bytes block is mapped.
> > > > > At line 265 of truncate.c there is a
> > > > > if (index >= end)
> > > > >      break;
> > > > > But if index is, as in this case, a 4294967295, it match -1 used as
> > > > > eof. Hence the cpu loops 100% just after.
> > > > > 
> > > > That's odd.  I've not checked your patch, because I think the problem
> > > > would go beyond truncate, and the root cause lie elsewhere.
> > > > 
> > > > My understanding is that the 32-bit
> > > > #define MAX_LFS_FILESIZE (((loff_t)PAGE_CACHE_SIZE << (BITS_PER_LONG-1))-1)
> > > > makes a page->index of -1 (or any "negative") impossible to reach.
> 
> We've supported > 8TB files on 32 bit XFS file systems since
> since mid 2003:
> 
> http://oss.sgi.com/cgi-bin/gitweb.cgi?p=archive/xfs-import.git;a=commitdiff;h=d13d78f6b83eefbd90a6cac5c9fbe42560c6511e
> 
> And it's been documented as such for a long time, too:
> 
> http://xfs.org/docs/xfsdocs-xml-dev/XFS_User_Guide/tmp/en-US/html/ch02s04.html
> 
> (that was written, IIRC, back in 2007).
> 
> i.e. whatever the definition says about MAX_LFS_FILESIZE being an
> 8TB limit on 32 bit is stale and has been for a very long time.
> 
> > A surprise to me, and I expect to others, that 32-bit xfs is not
> > respecting MAX_LFS_FILESIZE: going its own way with 0xfff ffffffff
> > instead of 0x7ff ffffffff (on a PAGE_CACHE_SIZE 4096 system).
> > 
> > MAX_LFS_FILESIZE has been defined that way ever since v2.5.4:
> > this is probably just an oversight from when xfs was later added
> > into the Linux tree.
> 
> We supported >8 TB file offsets on 32 bit systems on 2.4 kernels
> with XFS, so it sounds like it was wrong even when it was first
> committed. Of course, XFS wasn't merged until 2.5.36, so I guess
> nobody realised... ;)
> 
> > > But if s_maxbytes doesn't have to be greater than MAX_LFS_FILESIZE,
> > > i agree the issue should be fixed in layers above.
> > 
> > There is a "filesystems should never set s_maxbytes larger than
> > MAX_LFS_FILESIZE" comment in fs/super.c, but unfortunately its
> > warning is written with just 64-bit in mind (testing for negative).
> 
> Yup, introduced here:
> 
> commit 42cb56ae2ab67390da34906b27bedc3f2ff1393b
> Author: Jeff Layton <jlayton@redhat.com>
> Date:   Fri Sep 18 13:05:53 2009 -0700
> 
>     vfs: change sb->s_maxbytes to a loff_t
>     
>     sb->s_maxbytes is supposed to indicate the maximum size of a file that can
>     exist on the filesystem.  It's declared as an unsigned long long.
> 
> And yes, that will never fire on a 32bit filesystem, because loff_t
> is a "long long" type....
> 

Hmm...should we change that to something like this instead?

    WARN(((unsigned long long)sb->s_maxbytes > (unsigned long long)MAX_LFS_FILESIZE,
	"%s set sb->s_maxbytes to too large a value (0x%llx)\n", type->name, sb->s_maxbytes);

-- 
Jeff Layton <jlayton@poochiereds.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
