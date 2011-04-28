Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D9638900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 19:17:29 -0400 (EDT)
Received: from hpaq11.eem.corp.google.com (hpaq11.eem.corp.google.com [172.25.149.11])
	by smtp-out.google.com with ESMTP id p3SNHQCC007117
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:17:26 -0700
Received: from wyb29 (wyb29.prod.google.com [10.241.225.93])
	by hpaq11.eem.corp.google.com with ESMTP id p3SNHPok003197
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:17:25 -0700
Received: by wyb29 with SMTP id 29so4023071wyb.17
        for <linux-mm@kvack.org>; Thu, 28 Apr 2011 16:17:25 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303775584-13347-1-git-send-email-vnagarnaik@google.com>
References: <1303513209-26436-1-git-send-email-vnagarnaik@google.com> <1303775584-13347-1-git-send-email-vnagarnaik@google.com>
From: Vaibhav Nagarnaik <vnagarnaik@google.com>
Date: Thu, 28 Apr 2011 16:16:55 -0700
Message-ID: <BANLkTikMgP1k0kKrGBaXhT4juD8admdcqA@mail.gmail.com>
Subject: Re: [PATCH] trace: Add tracepoints to fs subsystem
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Steven Rostedt <rostedt@goodmis.org>
Cc: Michael Rubin <mrubin@google.com>, David Sharp <dhsharp@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jiaying Zhang <jiayingz@google.com>, Vaibhav Nagarnaik <vnagarnaik@google.com>

Hi Alexander

Do you think this patch makes sense for mainline inclusion?

Thanks
Vaibhav Nagarnaik



On Mon, Apr 25, 2011 at 4:53 PM, Vaibhav Nagarnaik
<vnagarnaik@google.com> wrote:
> From: Jiaying Zhang <jiayingz@google.com>
>
> These few fs tracepoints are useful while debugging latency issues in
> filesystems and were used specifically for debugging various writeback
> subsystem issues. This patch adds entry and exit tracepoints for the
> following functions, viz.:
> wait_on_buffer
> block_write_full_page
> mpage_readpages
> file_read
>
> Signed-off-by: Vaibhav Nagarnaik <vnagarnaik@google.com>
> ---
> =A0fs/buffer.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 +++
> =A0fs/mpage.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +
> =A0include/trace/events/fs.h | =A0162 +++++++++++++++++++++++++++++++++++=
++++++++++
> =A0mm/filemap.c =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A04 +-
> =A04 files changed, 178 insertions(+), 1 deletions(-)
> =A0create mode 100644 include/trace/events/fs.h
>
> diff --git a/fs/buffer.c b/fs/buffer.c
> index a08bb8e..1c118f4 100644
> --- a/fs/buffer.c
> +++ b/fs/buffer.c
> @@ -42,6 +42,9 @@
> =A0#include <linux/mpage.h>
> =A0#include <linux/bit_spinlock.h>
>
> +#define CREATE_TRACE_POINTS
> +#include <trace/events/fs.h>
> +
> =A0static int fsync_buffers_list(spinlock_t *lock, struct list_head *list=
);
>
> =A0#define BH_ENTRY(list) list_entry((list), struct buffer_head, b_assoc_=
buffers)
> @@ -82,7 +85,9 @@ EXPORT_SYMBOL(unlock_buffer);
> =A0*/
> =A0void __wait_on_buffer(struct buffer_head * bh)
> =A0{
> + =A0 =A0 =A0 trace_fs_buffer_wait_enter(bh);
> =A0 =A0 =A0 =A0wait_on_bit(&bh->b_state, BH_Lock, sleep_on_buffer, TASK_U=
NINTERRUPTIBLE);
> + =A0 =A0 =A0 trace_fs_buffer_wait_exit(bh);
> =A0}
> =A0EXPORT_SYMBOL(__wait_on_buffer);
>
> @@ -1647,6 +1652,8 @@ static int __block_write_full_page(struct inode *in=
ode, struct page *page,
> =A0 =A0 =A0 =A0head =3D page_buffers(page);
> =A0 =A0 =A0 =A0bh =3D head;
>
> + =A0 =A0 =A0 trace_block_write_full_page_enter(inode, block, last_block)=
;
> +
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Get all the dirty buffers mapped to disk addresses and
> =A0 =A0 =A0 =A0 * handle any aliases from the underlying blockdev's mappi=
ng.
> @@ -1736,6 +1743,9 @@ done:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * here on.
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 trace_block_write_full_page_exit(inode, nr_underway, err);
> +
> =A0 =A0 =A0 =A0return err;
>
> =A0recover:
> diff --git a/fs/mpage.c b/fs/mpage.c
> index 0afc809..1c3b8e1 100644
> --- a/fs/mpage.c
> +++ b/fs/mpage.c
> @@ -28,6 +28,7 @@
> =A0#include <linux/backing-dev.h>
> =A0#include <linux/pagevec.h>
>
> +#include <trace/events/fs.h>
> =A0/*
> =A0* I/O completion handler for multipage BIOs.
> =A0*
> @@ -373,6 +374,8 @@ mpage_readpages(struct address_space *mapping, struct=
 list_head *pages,
> =A0 =A0 =A0 =A0for (page_idx =3D 0; page_idx < nr_pages; page_idx++) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct page *page =3D list_entry(pages->pr=
ev, struct page, lru);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (page_idx =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mpage_readpages(page,=
 mapping, nr_pages);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prefetchw(&page->flags);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_del(&page->lru);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (!add_to_page_cache_lru(page, mapping,
> diff --git a/include/trace/events/fs.h b/include/trace/events/fs.h
> new file mode 100644
> index 0000000..95f7bc8
> --- /dev/null
> +++ b/include/trace/events/fs.h
> @@ -0,0 +1,162 @@
> +#undef TRACE_SYSTEM
> +#define TRACE_SYSTEM fs
> +
> +#if !defined(_TRACE_FS_H) || defined(TRACE_HEADER_MULTI_READ)
> +#define _TRACE_FS_H
> +
> +#include <linux/tracepoint.h>
> +
> +DECLARE_EVENT_CLASS(fs_buffer_wait,
> +
> + =A0 =A0 =A0 TP_PROTO(struct buffer_head *bh),
> +
> + =A0 =A0 =A0 TP_ARGS(bh),
> +
> + =A0 =A0 =A0 TP_STRUCT__entry(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0void *, bh =A0 =A0 =
=A0)
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_fast_assign(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->bh =3D bh;
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_printk("bh %p", __entry->bh)
> +);
> +
> +DEFINE_EVENT(fs_buffer_wait, fs_buffer_wait_enter,
> +
> + =A0 =A0 =A0 TP_PROTO(struct buffer_head *bh),
> +
> + =A0 =A0 =A0 TP_ARGS(bh)
> +);
> +
> +DEFINE_EVENT(fs_buffer_wait, fs_buffer_wait_exit,
> +
> + =A0 =A0 =A0 TP_PROTO(struct buffer_head *bh),
> +
> + =A0 =A0 =A0 TP_ARGS(bh)
> +);
> +
> +TRACE_EVENT(block_write_full_page_enter,
> +
> + =A0 =A0 =A0 TP_PROTO(struct inode *inode, sector_t block, sector_t last=
_block),
> +
> + =A0 =A0 =A0 TP_ARGS(inode, block, last_block),
> +
> + =A0 =A0 =A0 TP_STRUCT__entry(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0dev_t, =A0 =A0 =A0 =
=A0 =A0dev =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0unsigned long, =A0i=
no =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0sector_t, =A0 =A0 =
=A0 block =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0sector_t, =A0 =A0 =
=A0 last_block =A0 =A0 =A0)
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_fast_assign(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->dev =A0 =A0 =A0 =A0 =A0 =A0=3D ino=
de->i_sb->s_dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino =A0 =A0 =A0 =A0 =A0 =A0=3D ino=
de->i_ino;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->block =A0 =A0 =A0 =A0 =A0=3D block=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->last_block =A0 =A0 =3D last_block;
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_printk("dev %d,%d ino %lu block %lu last block %lu",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAJOR(__entry->dev), MINOR(__entry->dev=
),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long)__entry->block,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long)__entry->last_block)
> +);
> +
> +TRACE_EVENT(block_write_full_page_exit,
> +
> + =A0 =A0 =A0 TP_PROTO(struct inode *inode, int nr_underway, int err),
> +
> + =A0 =A0 =A0 TP_ARGS(inode, nr_underway, err),
> +
> + =A0 =A0 =A0 TP_STRUCT__entry(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0dev_t, =A0 =A0 =A0 =
=A0 =A0dev =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0unsigned long, =A0i=
no =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0int, =A0 =A0 =A0 =
=A0 =A0 =A0nr_underway =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0int, =A0 =A0 =A0 =
=A0 =A0 =A0err =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_fast_assign(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->dev =A0 =A0 =A0 =A0 =A0 =A0=3D ino=
de->i_sb->s_dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino =A0 =A0 =A0 =A0 =A0 =A0=3D ino=
de->i_ino;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_underway =A0 =A0=3D nr_underway=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->err =A0 =A0 =A0 =A0 =A0 =A0=3D err=
;
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_printk("dev %d,%d ino %lu nr_underway %d err %d",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAJOR(__entry->dev), MINOR(__entry->dev=
),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino, __entry->nr_underway, __e=
ntry->err)
> +);
> +
> +DECLARE_EVENT_CLASS(file_read,
> + =A0 =A0 =A0 TP_PROTO(struct inode *inode, loff_t pos, size_t len),
> +
> + =A0 =A0 =A0 TP_ARGS(inode, pos, len),
> +
> + =A0 =A0 =A0 TP_STRUCT__entry(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0ino_t, =A0ino =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0dev_t, =A0dev =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0loff_t, pos =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0size_t, len =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_fast_assign(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino =A0 =A0=3D inode->i_ino;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->dev =A0 =A0=3D inode->i_sb->s_dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->pos =A0 =A0=3D pos;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->len =A0 =A0=3D len;
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_printk("dev %d,%d ino %lu pos %llu len %lu",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAJOR(__entry->dev), MINOR(__entry->dev=
),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long) __entry->ino,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__entry->pos, =A0__entry->len)
> +);
> +
> +DEFINE_EVENT(file_read, file_read_enter,
> +
> + =A0 =A0 =A0 TP_PROTO(struct inode *inode, loff_t pos, size_t len),
> +
> + =A0 =A0 =A0 TP_ARGS(inode, pos, len)
> +);
> +
> +DEFINE_EVENT(file_read, file_read_exit,
> +
> + =A0 =A0 =A0 TP_PROTO(struct inode *inode, loff_t pos, size_t len),
> +
> + =A0 =A0 =A0 TP_ARGS(inode, pos, len)
> +);
> +
> +TRACE_EVENT(mpage_readpages,
> + =A0 =A0 =A0 TP_PROTO(struct page *page, struct address_space *mapping,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned nr_pages),
> +
> + =A0 =A0 =A0 TP_ARGS(page, mapping, nr_pages),
> +
> + =A0 =A0 =A0 TP_STRUCT__entry(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0pgoff_t, index =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0ino_t, =A0ino =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0dev_t, =A0dev =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 )
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __field( =A0 =A0 =A0 =A0unsigned, =A0 =A0 =
=A0 nr_pages =A0 =A0 =A0 =A0)
> +
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_fast_assign(
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->index =A0=3D page->index;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->ino =A0 =A0=3D mapping->host->i_in=
o;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->dev =A0 =A0=3D mapping->host->i_sb=
->s_dev;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->nr_pages =A0 =A0 =A0 =3D nr_pages;
> + =A0 =A0 =A0 ),
> +
> + =A0 =A0 =A0 TP_printk("dev %d,%d ino %lu page_index %lu nr_pages %u",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 MAJOR(__entry->dev), MINOR(__entry->dev=
),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (unsigned long) __entry->ino,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __entry->index, __entry->nr_pages)
> +);
> +
> +#endif /* _TRACE_FS_H */
> +
> +/* This part must be outside protection */
> +#include <trace/define_trace.h>
> +
> diff --git a/mm/filemap.c b/mm/filemap.c
> index c641edf..94e549c 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -42,7 +42,7 @@
> =A0#include <linux/buffer_head.h> /* for try_to_free_buffers */
>
> =A0#include <asm/mman.h>
> -
> +#include <trace/events/fs.h>
> =A0/*
> =A0* Shared mappings implemented 30.11.1994. It's not fully working yet,
> =A0* though.
> @@ -1054,6 +1054,7 @@ static void do_generic_file_read(struct file *filp,=
 loff_t *ppos,
> =A0 =A0 =A0 =A0unsigned int prev_offset;
> =A0 =A0 =A0 =A0int error;
>
> + =A0 =A0 =A0 trace_file_read_enter(inode, *ppos, desc->count);
> =A0 =A0 =A0 =A0index =3D *ppos >> PAGE_CACHE_SHIFT;
> =A0 =A0 =A0 =A0prev_index =3D ra->prev_pos >> PAGE_CACHE_SHIFT;
> =A0 =A0 =A0 =A0prev_offset =3D ra->prev_pos & (PAGE_CACHE_SIZE-1);
> @@ -1254,6 +1255,7 @@ out:
> =A0 =A0 =A0 =A0ra->prev_pos <<=3D PAGE_CACHE_SHIFT;
> =A0 =A0 =A0 =A0ra->prev_pos |=3D prev_offset;
>
> + =A0 =A0 =A0 trace_file_read_exit(inode, *ppos, desc->written);
> =A0 =A0 =A0 =A0*ppos =3D ((loff_t)index << PAGE_CACHE_SHIFT) + offset;
> =A0 =A0 =A0 =A0file_accessed(filp);
> =A0}
> --
> 1.7.3.1
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
