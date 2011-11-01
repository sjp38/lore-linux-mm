Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id E35266B0069
	for <linux-mm@kvack.org>; Tue,  1 Nov 2011 19:02:27 -0400 (EDT)
Received: by gyg10 with SMTP id 10so634682gyg.14
        for <linux-mm@kvack.org>; Tue, 01 Nov 2011 16:02:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111101225342.GG18701@quack.suse.cz>
References: <CALCETrWoZeFpznU5Nv=+PvL9QRkTnS4atiGXx0jqZP_E3TJPqw@mail.gmail.com>
	<6e365cb75f3318ab45d7145aededcc55b8ededa3.1319844715.git.luto@amacapital.net>
	<20111101225342.GG18701@quack.suse.cz>
Date: Tue, 1 Nov 2011 16:02:24 -0700
Message-ID: <CALCETrW3ZZ=474cXY0HH1=fHTwKJUo--ufPfD1WLpGRC4_CPrw@mail.gmail.com>
Subject: Re: [PATCH] mm: Improve cmtime update on shared writable mmaps
From: Andy Lutomirski <luto@amacapital.net>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Andreas Dilger <adilger@dilger.ca>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-ext4@vger.kernel.org

On Tue, Nov 1, 2011 at 3:53 PM, Jan Kara <jack@suse.cz> wrote:
> On Fri 28-10-11 16:39:25, Andy Lutomirski wrote:
>> We used to update a file's time on do_wp_page. =A0This caused latency
>> whenever file_update_time would sleep (this happens on ext4). =A0It is
>> also, IMO, less than ideal: any copy, backup, or 'make' run taken
>> after do_wp_page but before an mmap user finished writing would see
>> the new timestamp but the old contents.
>>
>> With this patch, cmtime is updated after a page is written. =A0When the
>> mm code transfers the dirty bit from a pte to the associated struct
>> page, it also sets a new page flag indicating that the page was
>> modified directly from userspace. =A0The inode's time is then updated in
>> clear_page_dirty_for_io.
>>
>> We can't update cmtime in all contexts in which ptes are unmapped:
>> various reclaim paths can unmap ptes from GFP_NOFS paths.
>>
>> Signed-off-by: Andy Lutomirski <luto@amacapital.net>
>> ---
>>
>> I'm not thrilled about using a page flag for this, but I haven't
>> spotted a better way. =A0Updating the time in writepage would touch
>> a lot of files and would interact oddly with write.
> =A0I see two problems with this patch:
> 1) Using a page flags is really a no-go. We are rather short on page flag=
s
> so using them for such minor thing is a real wastage. Moreover it should =
be
> rather easy to just use an inode flag instead.

Am I allowed to set inode flags without holding any locks?

>
> 2) You cannot call inode_update_time_writable() from
> clear_page_dirty_for_io() because that is called under a page lock and th=
us
> would create lock inversion problems.
>

Hmm.  Isn't it permitted to at least read from an fs while holding the
page lock?  I thought that the page lock was held for the entire
duration of a read and at the beginning of writeback.

I can push this down to the ->writepage implementations or to the
clear_page_dirty_for_io callers, but that will result in a bigger
patch.

--Andy

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
>>
>> =A0fs/inode.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 51 +++++++++++++++++=
+++++++++++++-------------
>> =A0include/linux/fs.h =A0 =A0 =A0 =A0 | =A0 =A01 +
>> =A0include/linux/page-flags.h | =A0 =A05 ++++
>> =A0mm/page-writeback.c =A0 =A0 =A0 =A0| =A0 19 +++++++++++++---
>> =A0mm/rmap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 18 +++++++++++++-
>> =A05 files changed, 72 insertions(+), 22 deletions(-)
>>
>> diff --git a/fs/inode.c b/fs/inode.c
>> index ec79246..ee93a25 100644
>> --- a/fs/inode.c
>> +++ b/fs/inode.c
>> @@ -1461,21 +1461,8 @@ void touch_atime(struct vfsmount *mnt, struct den=
try *dentry)
>> =A0}
>> =A0EXPORT_SYMBOL(touch_atime);
>>
>> -/**
>> - * =A0 file_update_time =A0 =A0 =A0 =A0- =A0 =A0 =A0 update mtime and c=
time time
>> - * =A0 @file: file accessed
>> - *
>> - * =A0 Update the mtime and ctime members of an inode and mark the inod=
e
>> - * =A0 for writeback. =A0Note that this function is meant exclusively f=
or
>> - * =A0 usage in the file write path of filesystems, and filesystems may
>> - * =A0 choose to explicitly ignore update via this function with the
>> - * =A0 S_NOCMTIME inode flag, e.g. for network filesystem where these
>> - * =A0 timestamps are handled by the server.
>> - */
>> -
>> -void file_update_time(struct file *file)
>> +static void do_inode_update_time(struct file *file, struct inode *inode=
)
>> =A0{
>> - =A0 =A0 struct inode *inode =3D file->f_path.dentry->d_inode;
>> =A0 =A0 =A0 struct timespec now;
>> =A0 =A0 =A0 enum { S_MTIME =3D 1, S_CTIME =3D 2, S_VERSION =3D 4 } sync_=
it =3D 0;
>>
>> @@ -1497,7 +1484,7 @@ void file_update_time(struct file *file)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 /* Finally allowed to write? Takes lock. */
>> - =A0 =A0 if (mnt_want_write_file(file))
>> + =A0 =A0 if (file && mnt_want_write_file(file))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>>
>> =A0 =A0 =A0 /* Only change inode inside the lock region */
>> @@ -1508,10 +1495,42 @@ void file_update_time(struct file *file)
>> =A0 =A0 =A0 if (sync_it & S_MTIME)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 inode->i_mtime =3D now;
>> =A0 =A0 =A0 mark_inode_dirty_sync(inode);
>> - =A0 =A0 mnt_drop_write(file->f_path.mnt);
>> +
>> + =A0 =A0 if (file)
>> + =A0 =A0 =A0 =A0 =A0 =A0 mnt_drop_write(file->f_path.mnt);
>> +}
>> +
>> +/**
>> + * =A0 file_update_time =A0 =A0 =A0 =A0- =A0 =A0 =A0 update mtime and c=
time time
>> + * =A0 @file: file accessed
>> + *
>> + * =A0 Update the mtime and ctime members of an inode and mark the inod=
e
>> + * =A0 for writeback. =A0Note that this function is meant exclusively f=
or
>> + * =A0 usage in the file write path of filesystems, and filesystems may
>> + * =A0 choose to explicitly ignore update via this function with the
>> + * =A0 S_NOCMTIME inode flag, e.g. for network filesystem where these
>> + * =A0 timestamps are handled by the server.
>> + */
>> +
>> +void file_update_time(struct file *file)
>> +{
>> + =A0 =A0 do_inode_update_time(file, file->f_path.dentry->d_inode);
>> =A0}
>> =A0EXPORT_SYMBOL(file_update_time);
>>
>> +/**
>> + * =A0 inode_update_time_writable =A0 =A0 =A0- =A0 =A0 =A0 update mtime=
 and ctime
>> + * =A0 @inode: inode accessed
>> + *
>> + * =A0 Same as file_update_time, except that the caller is responsible
>> + * =A0 for checking that the mount is writable.
>> + */
>> +
>> +void inode_update_time_writable(struct inode *inode)
>> +{
>> + =A0 =A0 do_inode_update_time(0, inode);
>> +}
>> +
>> =A0int inode_needs_sync(struct inode *inode)
>> =A0{
>> =A0 =A0 =A0 if (IS_SYNC(inode))
>> diff --git a/include/linux/fs.h b/include/linux/fs.h
>> index 277f497..9e28927 100644
>> --- a/include/linux/fs.h
>> +++ b/include/linux/fs.h
>> @@ -2553,6 +2553,7 @@ extern int inode_newsize_ok(const struct inode *, =
loff_t offset);
>> =A0extern void setattr_copy(struct inode *inode, const struct iattr *att=
r);
>>
>> =A0extern void file_update_time(struct file *file);
>> +extern void inode_update_time_writable(struct inode *inode);
>>
>> =A0extern int generic_show_options(struct seq_file *m, struct vfsmount *=
mnt);
>> =A0extern void save_mount_options(struct super_block *sb, char *options)=
;
>> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
>> index e90a673..4eed012 100644
>> --- a/include/linux/page-flags.h
>> +++ b/include/linux/page-flags.h
>> @@ -107,6 +107,7 @@ enum pageflags {
>> =A0#ifdef CONFIG_TRANSPARENT_HUGEPAGE
>> =A0 =A0 =A0 PG_compound_lock,
>> =A0#endif
>> + =A0 =A0 PG_update_cmtime, =A0 =A0 =A0 /* Dirtied via writable mapping.=
 */
>> =A0 =A0 =A0 __NR_PAGEFLAGS,
>>
>> =A0 =A0 =A0 /* Filesystems */
>> @@ -273,6 +274,10 @@ PAGEFLAG_FALSE(HWPoison)
>> =A0#define __PG_HWPOISON 0
>> =A0#endif
>>
>> +/* Whoever clears PG_update_cmtime must update the cmtime. */
>> +SETPAGEFLAG(UpdateCMTime, update_cmtime)
>> +TESTCLEARFLAG(UpdateCMTime, update_cmtime)
>> +
>> =A0u64 stable_page_flags(struct page *page);
>>
>> =A0static inline int PageUptodate(struct page *page)
>> diff --git a/mm/page-writeback.c b/mm/page-writeback.c
>> index 0e309cd..41c48ea 100644
>> --- a/mm/page-writeback.c
>> +++ b/mm/page-writeback.c
>> @@ -1460,7 +1460,8 @@ EXPORT_SYMBOL(set_page_dirty_lock);
>>
>> =A0/*
>> =A0 * Clear a page's dirty flag, while caring for dirty memory accountin=
g.
>> - * Returns true if the page was previously dirty.
>> + * Returns true if the page was previously dirty. =A0Also updates inode=
 time
>> + * if necessary.
>> =A0 *
>> =A0 * This is for preparing to put the page under writeout. =A0We leave =
the page
>> =A0 * tagged as dirty in the radix tree so that a concurrent write-for-s=
ync
>> @@ -1474,6 +1475,7 @@ EXPORT_SYMBOL(set_page_dirty_lock);
>> =A0 */
>> =A0int clear_page_dirty_for_io(struct page *page)
>> =A0{
>> + =A0 =A0 int ret;
>> =A0 =A0 =A0 struct address_space *mapping =3D page_mapping(page);
>>
>> =A0 =A0 =A0 BUG_ON(!PageLocked(page));
>> @@ -1520,11 +1522,20 @@ int clear_page_dirty_for_io(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_zone_page_state(page, NR=
_FILE_DIRTY);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dec_bdi_stat(mapping->backin=
g_dev_info,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 BDI_RECLAIMABLE);
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 1;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> - =A0 =A0 =A0 =A0 =A0 =A0 return 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 0;
>> + =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>> - =A0 =A0 return TestClearPageDirty(page);
>> + =A0 =A0 ret =3D TestClearPageDirty(page);
>> +
>> +out:
>> + =A0 =A0 /* We know that the inode (if any) is on a writable mount. */
>> + =A0 =A0 if (mapping && mapping->host && TestClearPageUpdateCMTime(page=
))
>> + =A0 =A0 =A0 =A0 =A0 =A0 inode_update_time_writable(mapping->host);
>> +
>> + =A0 =A0 return ret;
>> =A0}
>> =A0EXPORT_SYMBOL(clear_page_dirty_for_io);
>>
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 8005080..2ee595d 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -937,6 +937,16 @@ int page_mkclean(struct page *page)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct address_space *mapping =3D page_mappi=
ng(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (mapping) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D page_mkclean_file(ma=
pping, page);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /*
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* If dirtied via shared wri=
table mapping, cmtime
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* needs to be updated. =A0I=
f dirtied only through
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* write(), etc, then the wr=
iter already updated
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0* cmtime.
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0*/
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ret)
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageUpdateC=
MTime(page);
>> +
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_test_and_clear_dirt=
y(page_to_pfn(page), 1))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret =3D 1;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> @@ -1203,8 +1213,10 @@ int try_to_unmap_one(struct page *page, struct vm=
_area_struct *vma,
>> =A0 =A0 =A0 pteval =3D ptep_clear_flush_notify(vma, address, pte);
>>
>> =A0 =A0 =A0 /* Move the dirty bit to the physical page now the pte is go=
ne. */
>> - =A0 =A0 if (pte_dirty(pteval))
>> + =A0 =A0 if (pte_dirty(pteval)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 SetPageUpdateCMTime(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_dirty(page);
>> + =A0 =A0 }
>>
>> =A0 =A0 =A0 /* Update high watermark before we lower rss */
>> =A0 =A0 =A0 update_hiwater_rss(mm);
>> @@ -1388,8 +1400,10 @@ static int try_to_unmap_cluster(unsigned long cur=
sor, unsigned int *mapcount,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_pte_at(mm, address, pte,=
 pgoff_to_pte(page->index));
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Move the dirty bit to the physical page n=
ow the pte is gone. */
>> - =A0 =A0 =A0 =A0 =A0 =A0 if (pte_dirty(pteval))
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (pte_dirty(pteval)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 SetPageUpdateCMTime(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 set_page_dirty(page);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_remove_rmap(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 page_cache_release(page);
>> --
>> 1.7.6.4
>>
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>



--=20
Andy Lutomirski
AMA Capital Management, LLC
Office: (310) 553-5322
Mobile: (650) 906-0647

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
