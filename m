Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] fix page_count in ->iomap_migrate_page()
Date: Fri, 14 Dec 2018 14:35:38 +0100
Message-ID: <5520068.cAKZ7BqcUI@blindfold>
In-Reply-To: <2b19b3c4-2bc4-15fa-15cc-27a13e5c7af1@aol.com>
References: <1544766961-3492-1-git-send-email-openzhangj@gmail.com> <1618433.IpySj692Hd@blindfold> <2b19b3c4-2bc4-15fa-15cc-27a13e5c7af1@aol.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"
Sender: linux-kernel-owner@vger.kernel.org
To: Gao Xiang <hsiangkao@aol.com>, Artem Bityutskiy <dedekind1@gmail.com>
Cc: zhangjun <openzhangj@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, hch@lst.de, bfoster@redhat.com, Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, aarcange@redhat.com, willy@infradead.org, linux@dominikbrodowski.net, linux-mm@kvack.org, Gao Xiang <gaoxiang25@huawei.com>
List-ID: <linux-mm.kvack.org>

Am Freitag, 14. Dezember 2018, 13:26:28 CET schrieb Gao Xiang:
> Hi Richard,
> 
> On 2018/12/14 19:25, Richard Weinberger wrote:
> > This is the third place which needs this workaround.
> > UBIFS, F2FS, and now iomap.
> > 
> > I agree with Dave that nobody can assume that PG_private implies an additional
> > page reference.
> > But page migration does that. Including parts of the write back code.
> 
> It seems that it's clearly documented in
> https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h#n780
> 
>  * A pagecache page contains an opaque `private' member, which belongs to the
>  * page's address_space. Usually, this is the address of a circular list of
>  * the page's disk buffers. PG_private must be set to tell the VM to call
>  * into the filesystem to release these pages.
>  *
>  * A page may belong to an inode's memory mapping. In this case, page->mapping
>  * is the pointer to the inode, and page->index is the file offset of the page,
>  * in units of PAGE_SIZE.
>  *
>  * If pagecache pages are not associated with an inode, they are said to be
>  * anonymous pages. These may become associated with the swapcache, and in that
>  * case PG_swapcache is set, and page->private is an offset into the swapcache.
>  *
>  * In either case (swapcache or inode backed), the pagecache itself holds one
>  * reference to the page. Setting PG_private should also increment the
>  * refcount. The each user mapping also has a reference to the page.
> 
> and when I looked into that, I found
> https://lore.kernel.org/lkml/3CB3CA93.D141680B@zip.com.au/

Hmm, in case of UBIFS it seems easy. We can add a get/put_page() around setting/clearing
the flag.
I did that now and so far none of my tests exploded.

Artem, do you remember why UBIFS never raised the page counter when setting PG_private?

Thanks,
//richard
