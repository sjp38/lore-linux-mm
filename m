Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0008B8E001A
	for <linux-mm@kvack.org>; Wed, 23 Jan 2019 10:26:20 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id k90so2802394qte.0
        for <linux-mm@kvack.org>; Wed, 23 Jan 2019 07:26:20 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q11si7618407qkc.214.2019.01.23.07.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Jan 2019 07:26:19 -0800 (PST)
Date: Wed, 23 Jan 2019 10:26:14 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
Message-ID: <20190123152613.GB3097@redhat.com>
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
 <20190123145434.GK13149@quack2.suse.cz>
 <20190123151228.GA3097@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190123151228.GA3097@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Amir Goldstein <amir73il@gmail.com>, lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Wed, Jan 23, 2019 at 10:12:29AM -0500, Jerome Glisse wrote:
> On Wed, Jan 23, 2019 at 03:54:34PM +0100, Jan Kara wrote:
> > On Wed 23-01-19 10:48:58, Amir Goldstein wrote:
> > > In his session about "reflink" in LSF/MM 2016 [1], Darrick Wong brought
> > > up the subject of sharing pages between cloned files and the general vibe
> > > in room was that it could be done.
> > > 
> > > In his talk about XFS subvolumes and snapshots [2], Dave Chinner said
> > > that Matthew Willcox was "working on that problem".
> > > 
> > > I have started working on a new overlayfs address space implementation
> > > that could also benefit from being able to share pages even for filesystems
> > > that do not support clones (for copy up anticipation state).
> > > 
> > > To simplify the problem, we can start with sharing only uptodate clean
> > > pages that map the same offset in respected files. While the same offset
> > > requirement somewhat limits the use cases that benefit from shared file
> > > pages, there is still a vast majority of use cases (i.e. clone full
> > > image), where sharing pages of similar offset will bring a lot of
> > > benefit.
> > > 
> > > At first glance, this requires dropping the assumption that a for an
> > > uptodate clean page, vmf->vma->vm_file->f_inode == page->mapping->host.
> > > Is there really such an assumption in common vfs/mm code?  and what will
> > > it take to drop it?
> > 
> > There definitely is such assumption. Take for example page reclaim as one
> > such place that will be non-trivial to deal with. You need to remove the
> > page from page cache of all inodes that contain it without having any file
> > context whatsoever. So you will need to create some way for this page->page
> > caches mapping to happen. Jerome in his talk at LSF/MM last year [1] actually
> > nicely summarized what it would take to get rid of page->mapping
> > dereferences. He even had some preliminary patches. To sum it up, it's a
> > lot of intrusive work but in principle it is possible.
> > 
> > [1] https://lwn.net/Articles/752564/
> > 
> 
> I intend to post a v2 of my patchset doing that sometime soon. For
> various reasons this had been push to the bottom of my todo list since
> last year. It is now almost at the top and it will stay at the top.
> So i will be resuming work on that.
> 
> I wanted to propose this topic again as a joint session with mm so
> here is my proposal:
> 
> 
> I would like to discuss the removal of page mapping field dependency
> in most kernel code path so the we can overload that field for generic
> page write protection (KSM) for file back pages. The whole idea behind
> this is that we almost always have the mapping a page belongs to within
> the call stack for any function that operate on a file or on a vma do
> have it:
>     - syscall/kernel on a file (file -> inode -> mapping)
>     - syscall/kernel on virtual address (vma -> file -> mapping)
>     - write back for a given mapping
> 
> Note that the plan is not to free up the mapping field in struct page
> but to reduce the number of place that needs the mapping corresponding
> to a page to as few places as possible. The few exceptions are:
>     - page reclaim
>     - memory compaction
>     - set_page_dirty() on GUPed (get_user_pages*()) pages
> 
> For page reclaim and memory compaction we do not care about mapping
> exactly but about being able to unmap/migrate a page. So any over-
> loading of mapping needs to keep providing helpers to handle those
> cases.
> 
> For set_page_dirty() on GUPed pages we can take a slow path if the
> page has an overloaded mapping field.
> 
> 
> Previous patchset:
> https://lore.kernel.org/lkml/20180404191831.5378-1-jglisse@redhat.com/

Stupid me forget to say what i want to talk about during LSF/MM
session:
    - very quick overlook of the patchset and then taking questions on it
    - gather people feeling/opinion (does it looks good ?)
    - merging strategy for which i have some thought and would like to
      gather feedback on them

I expect to post a v2 long before LSF/MM probably in February so
people will have sometime to look at it. A warning it is almost
entirely all done with coccinelle as it is almost only mechanical
changes.

Cheers,
Jérôme
