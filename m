Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id F31F16B0044
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 20:36:16 -0400 (EDT)
Received: by mail-vc0-f169.google.com with SMTP id fl17so4083633vcb.14
        for <linux-mm@kvack.org>; Thu, 01 Nov 2012 17:36:16 -0700 (PDT)
Date: Thu, 1 Nov 2012 20:36:08 -0400
From: Jeff Layton <jlayton@samba.org>
Subject: Re: [PATCH 3/3] fs: Fix remaining filesystems to wait for stable
 page writeback
Message-ID: <20121101203608.336aff49@corrin.poochiereds.net>
In-Reply-To: <20121101224730.GJ19591@blackbox.djwong.org>
References: <20121101075805.16153.64714.stgit@blackbox.djwong.org>
	<20121101075829.16153.92036.stgit@blackbox.djwong.org>
	<5092C2CE.7070209@panasas.com>
	<20121101162254.03dbbd9a@tlielax.poochiereds.net>
	<20121101224730.GJ19591@blackbox.djwong.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Darrick J. Wong" <darrick.wong@oracle.com>
Cc: Boaz Harrosh <bharrosh@panasas.com>, axboe@kernel.dk, lucho@ionkov.net, tytso@mit.edu, sage@inktank.com, ericvh@gmail.com, mfasheh@suse.com, dedekind1@gmail.com, adrian.hunter@intel.com, dhowells@redhat.com, sfrench@samba.org, jlbec@evilplan.org, rminnich@sandia.gov, linux-cifs@vger.kernel.org, jack@suse.cz, martin.petersen@oracle.com, neilb@suse.de, david@fromorbit.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-mtd@lists.infradead.org, linux-fsdevel@vger.kernel.org, v9fs-developer@lists.sourceforge.net, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-afs@lists.infradead.org, ocfs2-devel@oss.oracle.com

On Thu, 1 Nov 2012 15:47:30 -0700
"Darrick J. Wong" <darrick.wong@oracle.com> wrote:

> On Thu, Nov 01, 2012 at 04:22:54PM -0400, Jeff Layton wrote:
> > On Thu, 1 Nov 2012 11:43:26 -0700
> > Boaz Harrosh <bharrosh@panasas.com> wrote:
> > 
> > > On 11/01/2012 12:58 AM, Darrick J. Wong wrote:
> > > > Fix up the filesystems that provide their own ->page_mkwrite handlers to
> > > > provide stable page writes if necessary.
> > > > 
> > > > Signed-off-by: Darrick J. Wong <darrick.wong@oracle.com>
> > > > ---
> > > >  fs/9p/vfs_file.c |    1 +
> > > >  fs/afs/write.c   |    4 ++--
> > > >  fs/ceph/addr.c   |    1 +
> > > >  fs/cifs/file.c   |    1 +
> > > >  fs/ocfs2/mmap.c  |    1 +
> > > >  fs/ubifs/file.c  |    4 ++--
> > > >  6 files changed, 8 insertions(+), 4 deletions(-)
> > > > 
> > > > 
> > > > diff --git a/fs/9p/vfs_file.c b/fs/9p/vfs_file.c
> > > > index c2483e9..aa253f0 100644
> > > > --- a/fs/9p/vfs_file.c
> > > > +++ b/fs/9p/vfs_file.c
> > > > @@ -620,6 +620,7 @@ v9fs_vm_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> > > >  	lock_page(page);
> > > >  	if (page->mapping != inode->i_mapping)
> > > >  		goto out_unlock;
> > > > +	wait_on_stable_page_write(page);
> > > >  
> > > 
> > > Good god thanks, yes please ;-)
> > > 
> > > >  	return VM_FAULT_LOCKED;
> > > >  out_unlock:
> > > > diff --git a/fs/afs/write.c b/fs/afs/write.c
> > > > index 9aa52d9..39eb2a4 100644
> > > > --- a/fs/afs/write.c
> > > > +++ b/fs/afs/write.c
> > > > @@ -758,7 +758,7 @@ int afs_page_mkwrite(struct vm_area_struct *vma, struct page *page)
> > > 
> > > afs, is it not a network filesystem? which means that it has it's own emulated none-block-device
> > > BDI, registered internally. So if you do need stable pages someone should call
> > > bdi_require_stable_pages()
> > > 
> > > But again since it is a network filesystem I don't see how it is needed, and/or it might be
> > > taken care of already.
> > > 
> > > >  #ifdef CONFIG_AFS_FSCACHE
> > > >  	fscache_wait_on_page_write(vnode->cache, page);
> > > >  #endif
> > > > -
> > > > +	wait_on_stable_page_write(page);
> > > >  	_leave(" = 0");
> > > > -	return 0;
> > > > +	return VM_FAULT_LOCKED;
> > > >  }
> > > > diff --git a/fs/ceph/addr.c b/fs/ceph/addr.c
> > > 
> > > CEPH for sure has it's own "emulated none-block-device BDI". This one is also
> > > a pure networking filesystem.
> > > 
> > > And it already does what it needs to do with wait_on_writeback().
> > > 
> > > So i do not think you should touch CEPH
> > > 
> > > > index 6690269..e9734bf 100644
> > > > --- a/fs/ceph/addr.c
> > > > +++ b/fs/ceph/addr.c
> > > > @@ -1208,6 +1208,7 @@ static int ceph_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> > > >  		set_page_dirty(page);
> > > >  		up_read(&mdsc->snap_rwsem);
> > > >  		ret = VM_FAULT_LOCKED;
> > > > +		wait_on_stable_page_write(page);
> > > >  	} else {
> > > >  		if (ret == -ENOMEM)
> > > >  			ret = VM_FAULT_OOM;
> > > > diff --git a/fs/cifs/file.c b/fs/cifs/file.c
> > > 
> > > Cifs also self-BDI network filesystem, but
> > > 
> > > > index edb25b4..a8770bf 100644
> > > > --- a/fs/cifs/file.c
> > > > +++ b/fs/cifs/file.c
> > > > @@ -2997,6 +2997,7 @@ cifs_page_mkwrite(struct vm_area_struct *vma, struct vm_fault *vmf)
> > > >  	struct page *page = vmf->page;
> > > >  
> > > >  	lock_page(page);
> > > 
> > > It waits by locking the page, that's cifs naive way of waiting for writeback
> > > 
> > > > +	wait_on_stable_page_write(page);
> > > 
> > > Instead it could do better and not override page_mkwrite at all, and all it needs
> > > to do is call bdi_require_stable_pages() at it's own registered BDI
> > > 
> > 
> > Hmm...I don't know...
> > 
> > I've never been crazy about using the page lock for this, but in the
> > absence of a better way to guarantee stable pages, it was what I ended
> > up with at the time. cifs_writepages will hold the page lock until
> > kernel_sendmsg returns. At that point the TCP layer will have copied
> > off the page data so it's safe to release it.
> > 
> > With this change though, we're going to end up blocking until the
> > writeback flag clears, right? And I think that will happen when the
> > reply comes in? So, we'll end up blocking for much longer than is
> > really necessary in page_mkwrite with this change.
> 
> That's a very good point to make-- network FSes can stop the stable-waiting
> after the request is sent.

Well, it depends...

If the fs in question uses kernel_sendpage (or the equivalent) then the
page will be inlined into the fraglist of the skb. If you use that,
then you can't just drop it after the send. It's also possible that the
fs doesn't care about page stability at all (like if signatures aren't
being used).

So I think you probably need to account for several different
possibilities of "page stability lifetimes" here...

> Can I interest you in a new page flag (PG_stable)
> that indicates when a page has to be held for stable write?  Along with a
> modification to wait_on_stable_page_write that uses the new PG_stable flag
> instead of just writeback?  Then, you can clear PG_stable right after the
> sendmsg() and release the page for further activity without having to overload
> the page lock.
> 
> I wrote a patch that does exactly that as part of my work to defer the
> integrity checksumming until the last possible instant.  However, I haven't
> gotten that part to work yet, so I left the PG_stable patch out of this
> submission.  On the other hand, it sounds like you could use it.
> 

That sounds much more suitable for CIFS and possibly for others too.

-- 
Jeff Layton <jlayton@samba.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
