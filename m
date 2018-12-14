Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 75EA08E01D1
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:26:41 -0500 (EST)
Received: by mail-pf1-f199.google.com with SMTP id 68so4203815pfr.6
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 04:26:41 -0800 (PST)
Received: from sonic311-21.consmr.mail.gq1.yahoo.com (sonic311-21.consmr.mail.gq1.yahoo.com. [98.137.65.202])
        by mx.google.com with ESMTPS id o2si4037599pfb.166.2018.12.14.04.26.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 04:26:40 -0800 (PST)
Subject: Re: [PATCH] fix page_count in ->iomap_migrate_page()
References: <1544766961-3492-1-git-send-email-openzhangj@gmail.com>
 <1618433.IpySj692Hd@blindfold>
From: Gao Xiang <hsiangkao@aol.com>
Message-ID: <2b19b3c4-2bc4-15fa-15cc-27a13e5c7af1@aol.com>
Date: Fri, 14 Dec 2018 20:26:28 +0800
MIME-Version: 1.0
In-Reply-To: <1618433.IpySj692Hd@blindfold>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard@nod.at>
Cc: zhangjun <openzhangj@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Darrick J . Wong" <darrick.wong@oracle.com>, hch@lst.de, bfoster@redhat.com, Dave Chinner <david@fromorbit.com>, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, n-horiguchi@ah.jp.nec.com, mgorman@techsingularity.net, aarcange@redhat.com, willy@infradead.org, linux@dominikbrodowski.net, linux-mm@kvack.org, Gao Xiang <gaoxiang25@huawei.com>

Hi Richard,

On 2018/12/14 19:25, Richard Weinberger wrote:
> This is the third place which needs this workaround.
> UBIFS, F2FS, and now iomap.
> 
> I agree with Dave that nobody can assume that PG_private implies an additional
> page reference.
> But page migration does that. Including parts of the write back code.

It seems that it's clearly documented in
https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/include/linux/mm.h#n780

 * A pagecache page contains an opaque `private' member, which belongs to the
 * page's address_space. Usually, this is the address of a circular list of
 * the page's disk buffers. PG_private must be set to tell the VM to call
 * into the filesystem to release these pages.
 *
 * A page may belong to an inode's memory mapping. In this case, page->mapping
 * is the pointer to the inode, and page->index is the file offset of the page,
 * in units of PAGE_SIZE.
 *
 * If pagecache pages are not associated with an inode, they are said to be
 * anonymous pages. These may become associated with the swapcache, and in that
 * case PG_swapcache is set, and page->private is an offset into the swapcache.
 *
 * In either case (swapcache or inode backed), the pagecache itself holds one
 * reference to the page. Setting PG_private should also increment the
 * refcount. The each user mapping also has a reference to the page.

and when I looked into that, I found
https://lore.kernel.org/lkml/3CB3CA93.D141680B@zip.com.au/


Thanks,
Gao Xiang
