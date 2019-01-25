Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id CBEF58E00C8
	for <linux-mm@kvack.org>; Fri, 25 Jan 2019 03:39:33 -0500 (EST)
Received: by mail-yw1-f70.google.com with SMTP id i2so4654204ywb.1
        for <linux-mm@kvack.org>; Fri, 25 Jan 2019 00:39:33 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x125sor10816529ybx.117.2019.01.25.00.39.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 Jan 2019 00:39:32 -0800 (PST)
MIME-Version: 1.0
References: <CAOQ4uxj4DiU=vFqHCuaHQ=4XVkTeJrXci0Y6YUX=22dE+iygqA@mail.gmail.com>
 <20190123145434.GK13149@quack2.suse.cz> <20190124103906.iwbttyrf6lddieou@kshutemo-mobl1>
In-Reply-To: <20190124103906.iwbttyrf6lddieou@kshutemo-mobl1>
From: Amir Goldstein <amir73il@gmail.com>
Date: Fri, 25 Jan 2019 10:39:20 +0200
Message-ID: <CAOQ4uxgfkzWsh+=gKGL4YGiBGLYvhcOCy13X5L2ycVdghYhrOA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Sharing file backed pages
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>, Jerome Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>
Cc: lsf-pc@lists.linux-foundation.org, Al Viro <viro@zeniv.linux.org.uk>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, Matthew Wilcox <willy@infradead.org>, Chris Mason <clm@fb.com>, Miklos Szeredi <miklos@szeredi.hu>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>

On Thu, Jan 24, 2019 at 12:39 PM Kirill A. Shutemov
<kirill@shutemov.name> wrote:
>
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
> > caches mapping to happen.
>
> We have it solved for anon pages where we need to find all VMA the page
> might be mapped to. I think we should look into adopting anon_vma
> approach[1] for files too. From the first look the problemspace looks very
> similar.
>

Yes there are many similarities and we should definitely adopt existing
solutions for shared anon pages. There are also differences and we need
to make sure we cover them in the design.

For example, reclaiming a multiply shared page may prove to be more
expensive then reclaiming a non shared page. Depending on how the page
has ended up being shared (perhaps by KSM or by a special copy_file_range()
mode on an fs that doesn't support clone_file_range), the next time
the instances
of the shared page are faulted in, they may not be shared anymore and may
consume more cache space.

I'd also like to discuss which control the filesystem gets over
unsharing a page.
Will fs have a say before page is COWed? By which order of VMAs?
I think most people currently view the shared pages concept as symetric for
all VMAs that share the page, but for overlayfs, a "master-slave" or "stacked"
model might be a better fit, so that, for example, "master" can make a call to
notify the "slave" about page being dirty instead of breaking the sharing.

Jerome,

Do you think we will have time to cover these issues in the joint session.
Perhaps we should tentatively plan for a filesystem track session for
filesystem followup issues?

Some issues I can think of are:
- Which control filesystem gets for new functionality (see above)
- Common code to help sharing pages, i.e. for generic vfs interfaces
  like clone/dedupe/copy_range
- Can/should blockdev pages (of same block) be shared with file
  pages of the filesystem on that blockdev by common mpage_ helpers?
- A common use case is that filesystem images are cloned and loop mounted.
  How can we propagate the knowledge about files data on loop mounted fs
  originating from the same underlying block though the loop device? (*)

(*) loop device is just a simple example, but same can apply to other
storage stacks as well where block layer has dedupe.

Thanks,
Amir.
