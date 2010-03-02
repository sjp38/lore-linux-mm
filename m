Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7579B6B007E
	for <linux-mm@kvack.org>; Tue,  2 Mar 2010 06:09:26 -0500 (EST)
Received: by wwb22 with SMTP id 22so55115wwb.14
        for <linux-mm@kvack.org>; Tue, 02 Mar 2010 03:09:24 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20100302110239.GB1921@linux>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	 <1267478620-5276-4-git-send-email-arighi@develer.com>
	 <cc557aab1003020211h391947f0p3eae04a298127d32@mail.gmail.com>
	 <20100302110239.GB1921@linux>
Date: Tue, 2 Mar 2010 13:09:24 +0200
Message-ID: <cc557aab1003020309y37587110i685d0d968bfba9f4@mail.gmail.com>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrea Righi <arighi@develer.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 2, 2010 at 1:02 PM, Andrea Righi <arighi@develer.com> wrote:
> On Tue, Mar 02, 2010 at 12:11:10PM +0200, Kirill A. Shutemov wrote:
>> On Mon, Mar 1, 2010 at 11:23 PM, Andrea Righi <arighi@develer.com> wrote=
:
>> > Apply the cgroup dirty pages accounting and limiting infrastructure to
>> > the opportune kernel functions.
>> >
>> > Signed-off-by: Andrea Righi <arighi@develer.com>
>> > ---
>> > =C2=A0fs/fuse/file.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A05 +++
>> > =C2=A0fs/nfs/write.c =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A04 ++
>> > =C2=A0fs/nilfs2/segment.c | =C2=A0 10 +++++-
>> > =C2=A0mm/filemap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0| =C2=A0 =C2=A01 +
>> > =C2=A0mm/page-writeback.c | =C2=A0 84 ++++++++++++++++++++++++++++++++=
------------------
>> > =C2=A0mm/rmap.c =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A04 +-
>> > =C2=A0mm/truncate.c =C2=A0 =C2=A0 =C2=A0 | =C2=A0 =C2=A02 +
>> > =C2=A07 files changed, 76 insertions(+), 34 deletions(-)
>> >
>> > diff --git a/fs/fuse/file.c b/fs/fuse/file.c
>> > index a9f5e13..dbbdd53 100644
>> > --- a/fs/fuse/file.c
>> > +++ b/fs/fuse/file.c
>> > @@ -11,6 +11,7 @@
>> > =C2=A0#include <linux/pagemap.h>
>> > =C2=A0#include <linux/slab.h>
>> > =C2=A0#include <linux/kernel.h>
>> > +#include <linux/memcontrol.h>
>> > =C2=A0#include <linux/sched.h>
>> > =C2=A0#include <linux/module.h>
>> >
>> > @@ -1129,6 +1130,8 @@ static void fuse_writepage_finish(struct fuse_co=
nn *fc, struct fuse_req *req)
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0list_del(&req->writepages_entry);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_bdi_stat(bdi, BDI_WRITEBACK);
>> > + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_stat(req->pages[0],
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 MEM_CGROUP_STAT_WRITEBACK_TEMP, -1);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_zone_page_state(req->pages[0], NR_WRITE=
BACK_TEMP);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0bdi_writeout_inc(bdi);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0wake_up(&fi->page_waitq);
>> > @@ -1240,6 +1243,8 @@ static int fuse_writepage_locked(struct page *pa=
ge)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0req->inode =3D inode;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0inc_bdi_stat(mapping->backing_dev_info, BDI=
_WRITEBACK);
>> > + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_stat(tmp_page,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 MEM_CGROUP_STAT_WRITEBACK_TEMP, 1);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0inc_zone_page_state(tmp_page, NR_WRITEBACK_=
TEMP);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0end_page_writeback(page);
>> >
>> > diff --git a/fs/nfs/write.c b/fs/nfs/write.c
>> > index b753242..7316f7a 100644
>> > --- a/fs/nfs/write.c
>> > +++ b/fs/nfs/write.c
>> > @@ -439,6 +439,7 @@ nfs_mark_request_commit(struct nfs_page *req)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0req->wb_index,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0NFS_PAGE_TAG_COMMIT);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0spin_unlock(&inode->i_lock);
>> > + =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_stat(req->wb_page, MEM_CGROUP=
_STAT_UNSTABLE_NFS, 1);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0inc_zone_page_state(req->wb_page, NR_UNSTAB=
LE_NFS);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0inc_bdi_stat(req->wb_page->mapping->backing=
_dev_info, BDI_UNSTABLE);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0__mark_inode_dirty(inode, I_DIRTY_DATASYNC)=
;
>> > @@ -450,6 +451,7 @@ nfs_clear_request_commit(struct nfs_page *req)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0struct page *page =3D req->wb_page;
>> >
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if (test_and_clear_bit(PG_CLEAN, &(req)->wb=
_flags)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_s=
tat(page, MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_zone_page_s=
tate(page, NR_UNSTABLE_NFS);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_bdi_stat(pa=
ge->mapping->backing_dev_info, BDI_UNSTABLE);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return 1;
>> > @@ -1273,6 +1275,8 @@ nfs_commit_list(struct inode *inode, struct list=
_head *head, int how)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0req =3D nfs_lis=
t_entry(head->next);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nfs_list_remove=
_request(req);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0nfs_mark_reques=
t_commit(req);
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_s=
tat(req->wb_page,
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 MEM_CGROUP_STAT_UNSTABLE_NFS, -1);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_zone_page_s=
tate(req->wb_page, NR_UNSTABLE_NFS);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0dec_bdi_stat(re=
q->wb_page->mapping->backing_dev_info,
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0BDI_UNSTABLE);
>> > diff --git a/fs/nilfs2/segment.c b/fs/nilfs2/segment.c
>> > index ada2f1b..aef6d13 100644
>> > --- a/fs/nilfs2/segment.c
>> > +++ b/fs/nilfs2/segment.c
>> > @@ -1660,8 +1660,11 @@ nilfs_copy_replace_page_buffers(struct page *pa=
ge, struct list_head *out)
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0} while (bh =3D bh->b_this_page, bh2 =3D bh=
2->b_this_page, bh !=3D head);
>> > =C2=A0 =C2=A0 =C2=A0 =C2=A0kunmap_atomic(kaddr, KM_USER0);
>> >
>> > - =C2=A0 =C2=A0 =C2=A0 if (!TestSetPageWriteback(clone_page))
>> > + =C2=A0 =C2=A0 =C2=A0 if (!TestSetPageWriteback(clone_page)) {
>> > + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 mem_cgroup_update_s=
tat(clone_page,
>>
>> s/clone_page/page/
>
> mmh... shouldn't we use the same page used by TestSetPageWriteback() and
> inc_zone_page_state()?

Sorry, I've commented wrong hunk. It's for the next one.

>>
>> And #include <linux/memcontrol.h> is missed.
>
> OK.
>
> I'll apply your fixes and post a new version.
>
> Thanks for reviewing,
> -Andrea
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
