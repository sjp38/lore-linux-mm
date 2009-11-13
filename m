Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3C0B86B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 10:27:50 -0500 (EST)
Received: by pzk27 with SMTP id 27so2201248pzk.12
        for <linux-mm@kvack.org>; Fri, 13 Nov 2009 07:27:49 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20091113164029.e7e8bcea.kamezawa.hiroyu@jp.fujitsu.com>
References: <20091113163544.d92561c7.kamezawa.hiroyu@jp.fujitsu.com>
	 <20091113164029.e7e8bcea.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 14 Nov 2009 00:27:48 +0900
Message-ID: <28c262360911130727s25c34179u30360765c08853e0@mail.gmail.com>
Subject: Re: [RFC MM 3/4] add mm version number
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: cl@linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi, Kame.

On Fri, Nov 13, 2009 at 4:40 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
> Add logical timestamp to mm_struct, which is incremented always
> mmap_sem(write) is got and released. By this, it works like seqlock's
> counter and indicates mm_struct is modified or not.
>
> And this adds vma_cache to each thread. Each thread remember the last
> faulted vma and grab reference count. Correctness of cache is checked by
> mm->generation timestamp. (mm struct's vma cache is not very good
> if mm is shared, I think)
>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
> =A0arch/x86/mm/fault.c =A0 =A0 =A0 | =A0 18 ++++++++++++++++--
> =A0fs/exec.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A04 ++++
> =A0include/linux/init_task.h | =A0 =A01 +
> =A0include/linux/mm_types.h =A0| =A0 11 ++++++++++-
> =A0include/linux/sched.h =A0 =A0 | =A0 =A04 ++++
> =A0kernel/exit.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A03 +++
> =A0kernel/fork.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A05 ++++-
> =A07 files changed, 42 insertions(+), 4 deletions(-)
>
> Index: mmotm-2.6.32-Nov2/include/linux/mm_types.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- mmotm-2.6.32-Nov2.orig/include/linux/mm_types.h
> +++ mmotm-2.6.32-Nov2/include/linux/mm_types.h
> @@ -216,6 +216,7 @@ struct mm_struct {
> =A0 =A0 =A0 =A0atomic_t mm_users; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0/* How many users with user space? */
> =A0 =A0 =A0 =A0atomic_t mm_count; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0/* How many references to "struct mm_struct" (users count as 1) */
> =A0 =A0 =A0 =A0int map_count; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0/* number of VMAs */
> + =A0 =A0 =A0 unsigned int generation; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* =
logical timestamp of last modification */
> =A0 =A0 =A0 =A0struct rw_semaphore sem;
> =A0 =A0 =A0 =A0spinlock_t page_table_lock; =A0 =A0 =A0 =A0 =A0 =A0 /* Pro=
tects page tables and some counters */
>
> @@ -308,16 +309,21 @@ static inline int mm_reader_trylock(stru
> =A0static inline void mm_writer_lock(struct mm_struct *mm)
> =A0{
> =A0 =A0 =A0 =A0down_write(&mm->sem);
> + =A0 =A0 =A0 mm->generation++;
> =A0}
>
> =A0static inline void mm_writer_unlock(struct mm_struct *mm)
> =A0{
> + =A0 =A0 =A0 mm->generation++;
> =A0 =A0 =A0 =A0up_write(&mm->sem);
> =A0}
>
> =A0static inline int mm_writer_trylock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 return down_write_trylock(&mm->sem);
> + =A0 =A0 =A0 int ret =3D down_write_trylock(&mm->sem);
> + =A0 =A0 =A0 if (!ret)

It seems your typo.
if (ret) ?

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mm->generation++;
> + =A0 =A0 =A0 return ret;
> =A0}

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
