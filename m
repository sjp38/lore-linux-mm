Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0D7B28E0041
	for <linux-mm@kvack.org>; Mon, 24 Sep 2018 17:22:51 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id z23-v6so10833527wma.2
        for <linux-mm@kvack.org>; Mon, 24 Sep 2018 14:22:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j64-v6sor125964wmd.15.2018.09.24.14.22.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Sep 2018 14:22:49 -0700 (PDT)
Date: Tue, 25 Sep 2018 00:22:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix COW faults after mlock()
Message-ID: <20180924212246.vmmsmgd5qw6xkfwh@kshutemo-mobl1>
References: <20180924130852.12996-1-ynorov@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924130852.12996-1-ynorov@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dan Williams <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Michel Lespinasse <walken@google.com>, Souptick Joarder <jrdr.linux@gmail.com>, Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 24, 2018 at 04:08:52PM +0300, Yury Norov wrote:
> After mlock() on newly mmap()ed shared memory I observe page faults.
> 
> The problem is that populate_vma_page_range() doesn't set FOLL_WRITE
> flag for writable shared memory in mlock() path, arguing that like:
> /*
>  * We want to touch writable mappings with a write fault in order
>  * to break COW, except for shared mappings because these don't COW
>  * and we would not want to dirty them for nothing.
>  */
> 
> But they are actually COWed. The most straightforward way to avoid it
> is to set FOLL_WRITE flag for shared mappings as well as for private ones.

Huh? How do shared mapping get CoWed?

In this context CoW means to create a private copy of the  page for the
process. It only makes sense for private mappings as all pages in shared
mappings do not belong to the process.

Shared mappings will still get faults, but a bit later -- after the page
is written back to disc, the page get clear and write protected to catch
the next write access.

Noticeable exception is tmpfs/shmem. These pages do not belong to normal
write back process. But the code path is used for other filesystems as
well.

Therefore, NAK. You only create unneeded write back traffic.

-- 
 Kirill A. Shutemov
