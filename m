Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f181.google.com (mail-we0-f181.google.com [74.125.82.181])
	by kanga.kvack.org (Postfix) with ESMTP id 7B9DA6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 10:53:10 -0400 (EDT)
Received: by mail-we0-f181.google.com with SMTP id w61so5181500wes.26
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 07:53:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id dl7si5050401wjb.39.2014.06.02.07.53.07
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 07:53:09 -0700 (PDT)
Message-ID: <538c8fd5.a75fc20a.0720.ffffcdcbSMTPIN_ADDED_BROKEN@mx.google.com>
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH 2/3] mm: introduce fincore()
Date: Mon,  2 Jun 2014 10:52:35 -0400
In-Reply-To: <20140602122322.GB8691@node.dhcp.inet.fi>
References: <20140521193336.5df90456.akpm@linux-foundation.org> <1401686699-9723-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1401686699-9723-3-git-send-email-n-horiguchi@ah.jp.nec.com> <20140602122322.GB8691@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 02, 2014 at 03:23:22PM +0300, Kirill A. Shutemov wrote:
> On Mon, Jun 02, 2014 at 01:24:58AM -0400, Naoya Horiguchi wrote:
> > This patch provides a new system call fincore(2), which provides mincore()-
> > like information, i.e. page residency of a given file. But unlike mincore(),
> > fincore() can have a mode flag and it enables us to extract more detailed
> > information about page cache like pfn and page flag. This kind of information
> > is very helpful for example when applications want to know the file cache
> > status to control IO on their own way.
> > 
> > Detail about the data format being passed to userspace are explained in
> > inline comment, but generally in long entry format, we can choose which
> > information is extraced flexibly, so you don't have to waste memory by
> > extracting unnecessary information. And with FINCORE_SKIP_HOLE flag,
> > we can skip hole pages (not on memory,) which makes us avoid a flood of
> > meaningless zero entries when calling on extremely large (but only few
> > pages of it are loaded on memory) file.
> > 
> > Basic testset is added in a next patch on tools/testing/selftests/fincore/.
> > 
> > [1] http://thread.gmane.org/gmane.linux.kernel/1439212/focus=1441919
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> 
> ...
> 
> > diff --git v3.15-rc7.orig/mm/fincore.c v3.15-rc7/mm/fincore.c
> > new file mode 100644
> > index 000000000000..3fc3ef465471
> > --- /dev/null
> > +++ v3.15-rc7/mm/fincore.c
> > @@ -0,0 +1,362 @@
> > +/*
> > + * fincore(2) system call
> > + *
> > + * Copyright (C) 2014 NEC Corporation, Naoya Horiguchi
> > + */
> > +
> > +#include <linux/syscalls.h>
> > +#include <linux/pagemap.h>
> > +#include <linux/file.h>
> > +#include <linux/fs.h>
> > +#include <linux/mm.h>
> > +#include <linux/slab.h>
> > +#include <linux/hugetlb.h>
> > +
> > +/*
> > + * You can control how the buffer in userspace is filled with this mode
> > + * parameters:
> > + *
> > + * - FINCORE_BMAP:
> > + *     The page status is returned in a vector of bytes.
> > + *     The least significant bit of each byte is 1 if the referenced page
> > + *     is in memory, otherwise it is zero.
> 
> I'm okay with bytemap. Just wounder why not bitmap?

I think that we should return the exactly same information as that of mincore()
for this specific mode, so if someone extend mincore() to start using upper bits,
this interface should do it too, so 8-bit looks better to me.

> > + *
> > + * - FINCORE_PFN:
> > + *     stores pfn, using 8 bytes.
> > + *
> > + * - FINCORE_PAGEFLAGS:
> > + *     stores page flags, using 8 bytes. See definition of KPF_* for details.
> > + *
> > + * - FINCORE_PAGECACHE_TAGS:
> > + *     stores pagecache tags, using 8 bytes. See definition of PAGECACHE_TAG_*
> > + *     for details.
> 
> Is it safe to expose this info to unprivilaged process (consider all three
> flags above)?

Sorry to talk about an unmerged feature, but this mode is necessary with
PAGECACHE_TAG_ERROR which I'm suggesting in memory/IO error handling patches.
The purpose of it is to show which address of the file is affected by
memory/IO error without touching the page. This operation is supposed to
be called by unprivileged processes. So I'd like to make it open for them.

> > + * - FINCORE_SKIP_HOLE: if this flag is set, fincore() doesn't store any
> > + *     information about hole. Instead each records per page has the entry
> > + *     of page offset (using 8 bytes.) This mode is useful if we handle
> > + *     large file and only few pages are on memory for the file.
> 
> Hm.. It's probably overkill, but instead of filling userspace buffer we
> could return file descriptor and define lseek(SEEK_HOLE). Just thinking.

I'm not sure but it's interesting. If you come up with the whole idea in
this direction, please let me know.

> > + *
> > + * FINCORE_BMAP shouldn't be used combined with any other flags, and returnd
> > + * data in this mode is like this:
> > + *
> > + *   page offset  0   1   2   3   4
> > + *              +---+---+---+---+---+
> > + *              | 1 | 0 | 0 | 1 | 1 | ...
> > + *              +---+---+---+---+---+
> > + *               <->
> > + *              1 byte
> > + *
> > + * For FINCORE_PFN, page data is formatted like this:
> > + *
> > + *   page offset    0       1       2       3       4
> > + *              +-------+-------+-------+-------+-------+
> > + *              |  pfn  |  pfn  |  pfn  |  pfn  |  pfn  | ...
> > + *              +-------+-------+-------+-------+-------+
> > + *               <----->
> > + *               8 byte
> > + *
> > + * We can use multiple flags among FINCORE_(PFN|PAGEFLAGS|PAGECACHE_TAGS).
> > + * For example, when the mode is FINCORE_PFN|FINCORE_PAGEFLAGS, the per-page
> > + * information is stored like this:
> > + *
> > + *    page offset 0    page offset 1   page offset 2
> > + *   +-------+-------+-------+-------+-------+-------+
> > + *   |  pfn  | flags |  pfn  | flags |  pfn  | flags | ...
> > + *   +-------+-------+-------+-------+-------+-------+
> > + *    <-------------> <-------------> <------------->
> > + *       16 bytes        16 bytes        16 bytes
> > + *
> > + * When FINCORE_SKIP_HOLE is set, we ignore holes and add page offset entry
> > + * (8 bytes) instead. For example, the data format of mode
> > + * FINCORE_PFN|FINCORE_SKIP_HOLE is like follows:
> > + *
> > + *   +-------+-------+-------+-------+-------+-------+
> > + *   | pgoff |  pfn  | pgoff |  pfn  | pgoff |  pfn  | ...
> > + *   +-------+-------+-------+-------+-------+-------+
> > + *    <-------------> <-------------> <------------->
> > + *       16 bytes        16 bytes        16 bytes
> > + */
> > +#define FINCORE_BMAP		0x01	/* bytemap mode */
> > +#define FINCORE_PFN		0x02
> > +#define FINCORE_PAGE_FLAGS	0x04
> > +#define FINCORE_PAGECACHE_TAGS	0x08
> > +#define FINCORE_SKIP_HOLE	0x10
> 
> FINCORE_SKIP_HOLE is greater then FINCORE_PFN but pgoff precedes pfn in
> records. It's confusing. We need clear definition of record format.
> 
> What about rename FINCORE_SKIP_HOLE -> FINCORE_PGOFF, move it before
> FINCORE_PFN. So FINCORE_PGOFF is less than FINCORE_PFN, which is less than
> FINCORE_PAGE_FLAGS, which is less than FINCORE_PAGECACHE_TAGS. It matches
> order in records:
> 
> FINCORE_PGOFF|FINCORE_PFN|FINCORE_PAGEFLAGS|FINCORE_PAGECACHE_TAGS
> 
>  +-------+-------+-------+-------+-------+-------+-------+-------+
>  | pgoff |  pfn  | flags |  tags | pgoff |  pfn  | flags |  tags | ...
>  +-------+-------+-------+-------+-------+-------+-------+-------+
>   <-----------------------------> <------------------------------>
>              32 bytes                        32 bytes

Great, that's correct.
I'll do this.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
