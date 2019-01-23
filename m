Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3DC248E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 09:54:38 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id b3so1056719edi.0
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 06:54:38 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fx12-v6si2763342ejb.302.2019.01.23.06.54.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 06:54:36 -0800 (PST)
Date: Wed, 23 Jan 2019 15:54:34 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
Message-ID: <20190123145434.GK13149@quack2.suse.cz>
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jerome Glisse <jglisse@redhat.com>

On Wed 23-01-19 10:48:58, Amir Goldstein wrote:
> In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
> up the subject of sharing pages between cloned files and the general vibe
> in room was that it could be done.
> 
> In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
> that Matthew Willcox was "working on that problem".
> 
> I have started working on a new overlayfs address space implementation
> that could also benefit from being able to share pages even for filesystems
> that do not support clones (for copy up anticipation state).
> 
> To simplify the problem, we can start with sharing only uptodate clean
> pages that map the same offset in respected files. While the same offset
> requirement somewhat limits the use cases that benefit from shared file
> pages, there is still a vast majority of use cases (i.e. clone full
> image), where sharing pages of similar offset will bring a lot of
> benefit.
> 
> At first glance, this requires dropping the assumption that a for an
> uptodate clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
> Is there really such an assumption in common vfs/mm code?  and what will
> it take to drop it?

There definitely is such assumption. Take for example page reclaim as one
such place that will be non-trivial to deal with. You need to remove the
page from page cache of all inodes that contain it without having any file
context whatsoever. So you will need to create some way for this page->page
caches mapping to happen. Jerome in his talk at LSF/MM last year [1] actually
nicely summarized what it would take to get rid of page->mapping
dereferences. He even had some preliminary patches. To sum it up, it's a
lot of intrusive work but in principle it is possible.

[1] https://lwn.net/Articles/752564/

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
