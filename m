Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 84F848E007A
	for <linux-mm@kvack.org>; Thu, 24 Jan 2019 05:39:14 -0500 (EST)
Received: by mail-pf1-f197.google.com with SMTP id t2so4273657pfj.15
        for <linux-mm@kvack.org>; Thu, 24 Jan 2019 02:39:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b5sor32482587pgq.18.2019.01.24.02.39.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 24 Jan 2019 02:39:13 -0800 (PST)
Date: Thu, 24 Jan 2019 13:39:06 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
Message-ID: <20190124103906.iwbttyrf6lddieou@kshutemo-mobl1>
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
 <20190123145434.GK13149@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190123145434.GK13149@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Amir Goldstein <amir73il@gmail.com>, lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>

On Wed, Jan 23, 2019 at 03:54:34PM +0100, Jan Kara wrote:
> On Wed 23-01-19 10:48:58, Amir Goldstein wrote:
> > In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
> > up the subject of sharing pages between cloned files and the general vibe
> > in room was that it could be done.
> > 
> > In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
> > that Matthew Willcox was "working on that problem".
> > 
> > I have started working on a new overlayfs address space implementation
> > that could also benefit from being able to share pages even for filesystems
> > that do not support clones (for copy up anticipation state).
> > 
> > To simplify the problem, we can start with sharing only uptodate clean
> > pages that map the same offset in respected files. While the same offset
> > requirement somewhat limits the use cases that benefit from shared file
> > pages, there is still a vast majority of use cases (i.e. clone full
> > image), where sharing pages of similar offset will bring a lot of
> > benefit.
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
> caches mapping to happen.

We have it solved for anon pages where we need to find all VMA the page
might be mapped to. I think we should look into adopting anon_vma
approach[1] for files too. From the first look the problemspace looks very
similar.

[1] https://lwn.net/Articles/383162/

-- 
 Kirill A. Shutemov
