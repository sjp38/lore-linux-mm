Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 943626B0047
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 06:34:45 -0500 (EST)
Date: Tue, 2 Mar 2010 12:34:41 +0100
From: Andrea Righi <arighi@develer.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Message-ID: <20100302113441.GD1921@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
 <1267478620-5276-4-git-send-email-arighi@develer.com>
 <cc557aab1003020211h391947f0p3eae04a298127d32@mail.gmail.com>
 <20100302110239.GB1921@linux>
 <cc557aab1003020309y37587110i685d0d968bfba9f4@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <cc557aab1003020309y37587110i685d0d968bfba9f4@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 02, 2010 at 01:09:24PM +0200, Kirill A. Shutemov wrote:
> On Tue, Mar 2, 2010 at 1:02 PM, Andrea Righi <arighi@develer.com> wrote:
> > On Tue, Mar 02, 2010 at 12:11:10PM +0200, Kirill A. Shutemov wrote:
> >> On Mon, Mar 1, 2010 at 11:23 PM, Andrea Righi <arighi@develer.com> wrote:
> >> > Apply the cgroup dirty pages accounting and limiting infrastructure to
> >> > the opportune kernel functions.
> >> >
> >> > Signed-off-by: Andrea Righi <arighi@develer.com>
> >> > ---
> >> >  fs/fuse/file.c      |    5 +++
> >> >  fs/nfs/write.c      |    4 ++
> >> >  fs/nilfs2/segment.c |   10 +++++-
> >> >  mm/filemap.c        |    1 +
> >> >  mm/page-writeback.c |   84 ++++++++++++++++++++++++++++++++------------------
> >> >  mm/rmap.c           |    4 +-
> >> >  mm/truncate.c       |    2 +
> >> >  7 files changed, 76 insertions(+), 34 deletions(-)
> >> >
> >> > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
> >> > index a9f5e13..dbbdd53 100644
> >> > --- a/fs/fuse/file.c
> >> > +++ b/fs/fuse/file.c
> >> > @@ -11,6 +11,7 @@
> >> >  #include <linux/pagemap.h>
> >> >  #include <linux/slab.h>
> >> >  #include <linux/kernel.h>
> >> > +#include <linux/memcontrol.h>
> >> >  #include <linux/sched.h>
> >> >  #include <linux/module.h>
> >> >
> >> > @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_conn *fc, struct fuse_req *req)
> >> >
> >> >        list_del(&req->writepages_entry);
> >> >        dec_bdi_stat(bdi, BDI_WRITEBACK);
> >> > +       mem_cgroup_update_stat(req->pages[0],
> >> > +                       MEM_CGROUP_STAT_WRITEBACK_TEMP, -1);
> >> >        dec_zone_page_state(req->pages[0], NR_WRITEBACK_TEMP);
> >> >        bdi_writeout_inc(bdi);
> >> >        wake_up(&fi->page_waitq);
> >> > @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *page)
> >> >        req->inode = inode;
> >> >
> >> >        inc_bdi_stat(mapping->backing_dev_info, BDI_WRITEBACK);
> >> > +       mem_cgroup_update_stat(tmp_page,
> >> > +                       MEM_CGROUP_STAT_WRITEBACK_TEMP, 1);
> >> >        inc_zone_page_state(tmp_page, NR_WRITEBACK_TEMP);
> >> >        end_page_writeback(page);
> >> >
> >> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
> >> > index b753242..7316f7a 100644
> >> > --- a/fs/nfs/write.c
> >> > +++ b/fs/nfs/write.c
> >> > @@ -439,6 +439,7 @@ nfs_mark_request_commit(struct nfs_page *req)
> >> >                        req->wb_index,
> >> >                        NFS_PAGE_TAG_COMMIT);
> >> >        spin_unlock(&inode->i_lock);
> >> > +       mem_cgroup_update_stat(req->wb_page, MEM_CGROUP_STAT_UNSTABLE_NFS, 1);
> >> >        inc_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> >> >        inc_bdi_stat(req->wb_page->mapping->backing_dev_info, BDI_UNSTABLE);
> >> >        __mark_inode_dirty(inode, I_DIRTY_DATASYNC);
> >> > @@ -450,6 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
> >> >        struct page *page = req->wb_page;
> >> >
> >> >        if (test_and_clear_bit(PG_CLEAN, &(req)->wb_flags)) {
> >> > +               mem_cgroup_update_stat(page, MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
> >> >                dec_zone_page_state(page, NR_UNSTABLE_NFS);
> >> >                dec_bdi_stat(page->mapping->backing_dev_info, BDI_UNSTABLE);
> >> >                return 1;
> >> > @@ -1273,6 +1275,8 @@ nfs_commit_list(struct inode *inode, struct list_head *head, int how)
> >> >                req = nfs_list_entry(head->next);
> >> >                nfs_list_remove_request(req);
> >> >                nfs_mark_request_commit(req);
> >> > +               mem_cgroup_update_stat(req->wb_page,
> >> > +                               MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
> >> >                dec_zone_page_state(req->wb_page, NR_UNSTABLE_NFS);
> >> >                dec_bdi_stat(req->wb_page->mapping->backing_dev_info,
> >> >                                BDI_UNSTABLE);
> >> > diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
> >> > index ada2f1b..aef6d13 100644
> >> > --- a/fs/nilfs2/segment.c
> >> > +++ b/fs/nilfs2/segment.c
> >> > @@ -1660,8 +1660,11 @@ nilfs_copy_replace_page_buffers(struct page *page, struct list_head *out)
> >> >        } while (bh = bh->b_this_page, bh2 = bh2->b_this_page, bh != head);
> >> >        kunmap_atomic(kaddr, KM_USER0);
> >> >
> >> > -       if (!TestSetPageWriteback(clone_page))
> >> > +       if (!TestSetPageWriteback(clone_page)) {
> >> > +               mem_cgroup_update_stat(clone_page,
> >>
> >> s/clone_page/page/
> >
> > mmh... shouldn't we use the same page used by TestSetPageWriteback() and
> > inc_zone_page_state()?
> 
> Sorry, I've commented wrong hunk. It's for the next one.

Yes. Good catch! Will fix in the next version.

Thanks,
-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
