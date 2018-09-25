Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D8288E0072
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 06:48:37 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id s77-v6so9813379pgs.2
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 03:48:37 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 199-v6sor260418pfz.15.2018.09.25.03.48.35
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 03:48:35 -0700 (PDT)
Date: Tue, 25 Sep 2018 13:48:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: fix COW faults after mlock()
Message-ID: <20180925104829.jld5xd6evr7uhwfw@kshutemo-mobl1>
References: <20180924130852.12996-1-ynorov@caviumnetworks.com>
 <20180924212246.vmmsmgd5qw6xkfwh@kshutemo-mobl1>
 <20180924234843.GA23726@yury-thinkpad>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180924234843.GA23726@yury-thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yury Norov <ynorov@caviumnetworks.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Dan Williams <dan.j.williams@intel.com>, Huang Ying <ying.huang@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Michel Lespinasse <walken@google.com>, Souptick Joarder <jrdr.linux@gmail.com>, Willy Tarreau <w@1wt.eu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 25, 2018 at 02:48:43AM +0300, Yury Norov wrote:
> On Tue, Sep 25, 2018 at 12:22:47AM +0300, Kirill A. Shutemov wrote:
> > External Email
> > 
> > On Mon, Sep 24, 2018 at 04:08:52PM +0300, Yury Norov wrote:
> > > After mlock() on newly mmap()ed shared memory I observe page faults.
> > >
> > > The problem is that populate_vma_page_range() doesn't set FOLL_WRITE
> > > flag for writable shared memory in mlock() path, arguing that like:
> > > /*
> > >  * We want to touch writable mappings with a write fault in order
> > >  * to break COW, except for shared mappings because these don't COW
> > >  * and we would not want to dirty them for nothing.
> > >  */
> > >
> > > But they are actually COWed. The most straightforward way to avoid it
> > > is to set FOLL_WRITE flag for shared mappings as well as for private ones.
> > 
> > Huh? How do shared mapping get CoWed?
> > 
> > In this context CoW means to create a private copy of the  page for the
> > process. It only makes sense for private mappings as all pages in shared
> > mappings do not belong to the process.
> > 
> > Shared mappings will still get faults, but a bit later -- after the page
> > is written back to disc, the page get clear and write protected to catch
> > the next write access.
> > 
> > Noticeable exception is tmpfs/shmem. These pages do not belong to normal
> > write back process. But the code path is used for other filesystems as
> > well.
> > 
> > Therefore, NAK. You only create unneeded write back traffic.
> 
> Hi Kirill,
> 
> (My first reaction was exactly like yours indeed, but) on my real
> system (Cavium OcteonTX2), and on my qemu simulation I can reproduce
> the same behavior: just mlock()ed memory causes faults. That faults
> happen because page is mapped to the process as read-only, while
> underlying VMA is read-write. So faults get resolved well by just
> setting write access to the page.

mlock() doesn't guarntee that you'll never get a *minor* fault. Write back
or page migration will get these pages write-protected.

Making pages write protected is what we rely on for proper dirty
accounting: filesystems need to know when page gets dirty and allocate
resources for properly write back the page. Once page is written back to
storage the page gets write protected again to catch the next write access
to the page.

I guess we can situation a bit better for shmem/tmpfs: we can populate
such shared mappings with FOLL_WRITE. But this patch is not good for the
task.

-- 
 Kirill A. Shutemov
