Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 267378E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 12:57:23 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id b8so1502461ywb.17
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:57:23 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n19sor3405508ywd.166.2019.01.23.09.57.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 23 Jan 2019 09:57:22 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
 <20190123145434.GK13149@quack2.suse.cz>
In-Reply-To: <20190123145434.GK13149@quack2.suse.cz>
From: Amir Goldstein <amir73il@gmail.com>
Date: Wed, 23 Jan 2019 19:57:10 +0200
Message-ID: <CAOQ4uxivipnXihRud_5cUmjeOj000MwH5+oVDWv_2kwGCsamDA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>

On Wed, Jan 23, 2019 at 4:54 PM Jan Kara <jack@suse.cz> wrote:
...
> >
> > At first glance, this requires dropping the assumption that a for an
> > uptodate clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
> > Is there really such an assumption in common vfs/mm code?  and what will
> > it take to drop it?
>
> There definitely is such assumption. Take for example page reclaim as one
> such place that will be non-trivial to deal with. You need to remove the
> page from page cache of all inodes that contain it without having any file
> context whatsoever. So you will need to create some way for this page->page
> caches mapping to happen. Jerome in his talk at LSF/MM last year [1] actually
> nicely summarized what it would take to get rid of page->mapping
> dereferences. He even had some preliminary patches. To sum it up, it's a
> lot of intrusive work but in principle it is possible.
>
> [1] https://lwn.net/Articles/752564/
>

That would be real nice if that work makes progress.
However, for the sake of discussion, for the narrow case of overlayfs page
sharing, if page->mapping is the overlay mapping, then it already has
references to the underlying inode/mapping and overlayfs mapping ops
can do the right thing for reclaim and migrate.

So the fact that there is a lot of code referencing page->mapping (I know that)
doesn't really answer my question of how hard it is to drop the assumption
that vmf->vma->vm_file->f_inode == page->mapping->host for read protected
uptodate pages from common code.
Because if overlayfs (or any other arbitrator) will make sure that dirty pages
and non uptodate pages abide by existing page->mapping semantics, then
block layer code (for example) can still safely dereference page->mapping.

In any case, I'd really love to see the first part of Jerome's work merged, with
mapping propagated to all common helpers, even if the fs-specific patches
and KSM patches will take longer to land.

Thanks,
Amir.
