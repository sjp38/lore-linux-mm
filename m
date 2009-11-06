Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 765836B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 10:41:42 -0500 (EST)
Received: by pzk34 with SMTP id 34so761260pzk.11
        for <linux-mm@kvack.org>; Fri, 06 Nov 2009 07:41:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
	 <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>
Date: Sat, 7 Nov 2009 00:41:40 +0900
Message-ID: <28c262360911060741x3f7ab0a2k15be645e287e05ac@mail.gmail.com>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
	instead
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Hi, Christoph.

How about change from 'mm_readers' to 'is_readers' to improve your
goal 'scalibility'?
=3D=3D=3D
static inline int is_readers(struct mm_struct *mm)
{
       int cpu;
       int ret =3D 0;

       for_each_possible_cpu(cpu) {
               if (per_cpu(mm->rss->readers, cpu)) {
                      ret =3D 1;
                      break;
                 }
       }

       return ret;
}
=3D=3D=3D


On Fri, Nov 6, 2009 at 4:20 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> From: Christoph Lamter <cl@linux-foundation.org>
> Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter instead
>
> Instead of a rw semaphore use a mutex and a per cpu counter for the numbe=
r
> of the current readers. read locking then becomes very cheap requiring on=
ly
> the increment of a per cpu counter.
>
> Write locking is more expensive since the writer must scan the percpu arr=
ay
> and wait until all readers are complete. Since the readers are not holdin=
g
> semaphores we have no wait queue from which the writer could wakeup. In t=
his
> draft we simply wait for one millisecond between scans of the percpu
> array. A different solution must be found there.
>
> Patch is on top of -next and the percpu counter patches that I posted
> yesterday. The patch adds another per cpu counter to the file and anon rs=
s
> counters.
>
> Signed-off-by: Christoph Lamter <cl@linux-foundation.org>
>
> ---
> =A0include/linux/mm_types.h | =A0 68 ++++++++++++++++++++++++++++++++++++=
++---------
> =A0mm/init-mm.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A02 -
> =A02 files changed, 56 insertions(+), 14 deletions(-)
>
> Index: linux-2.6/include/linux/mm_types.h
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/include/linux/mm_types.h =A0 =A0 2009-11-05 13:03:11.0=
00000000 -0600
> +++ linux-2.6/include/linux/mm_types.h =A02009-11-05 13:06:31.000000000 -=
0600
> @@ -14,6 +14,7 @@
> =A0#include <linux/page-debug-flags.h>
> =A0#include <asm/page.h>
> =A0#include <asm/mmu.h>
> +#include <linux/percpu.h>
>
> =A0#ifndef AT_VECTOR_SIZE_ARCH
> =A0#define AT_VECTOR_SIZE_ARCH 0
> @@ -27,6 +28,7 @@ struct address_space;
> =A0struct mm_counter {
> =A0 =A0 =A0 =A0long file;
> =A0 =A0 =A0 =A0long anon;
> + =A0 =A0 =A0 long readers;
> =A0};
>
> =A0/*
> @@ -214,7 +216,7 @@ struct mm_struct {
> =A0 =A0 =A0 =A0atomic_t mm_users; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0/* How many users with user space? */
> =A0 =A0 =A0 =A0atomic_t mm_count; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0/* How many references to "struct mm_struct" (users count as 1) */
> =A0 =A0 =A0 =A0int map_count; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0/* number of VMAs */
> - =A0 =A0 =A0 struct rw_semaphore sem;
> + =A0 =A0 =A0 struct mutex lock;
> =A0 =A0 =A0 =A0spinlock_t page_table_lock; =A0 =A0 =A0 =A0 =A0 =A0 /* Pro=
tects page tables and some counters */
>
> =A0 =A0 =A0 =A0struct list_head mmlist; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*=
 List of maybe swapped mm's. =A0These are globally strung
> @@ -285,64 +287,104 @@ struct mm_struct {
> =A0#endif
> =A0};
>
> +static inline int mm_readers(struct mm_struct *mm)
> +{
> + =A0 =A0 =A0 int cpu;
> + =A0 =A0 =A0 int readers =3D 0;
> +
> + =A0 =A0 =A0 for_each_possible_cpu(cpu)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 readers +=3D per_cpu(mm->rss->readers, cpu)=
;
> +
> + =A0 =A0 =A0 return readers;
> +}
> +
> =A0static inline void mm_reader_lock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 down_read(&mm->sem);
> +redo:
> + =A0 =A0 =A0 this_cpu_inc(mm->rss->readers);
> + =A0 =A0 =A0 if (mutex_is_locked(&mm->lock)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_dec(mm->rss->readers);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Need to wait till mutex is released */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&mm->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&mm->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto redo;
> + =A0 =A0 =A0 }
> =A0}
>
> =A0static inline void mm_reader_unlock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 up_read(&mm->sem);
> + =A0 =A0 =A0 this_cpu_dec(mm->rss->readers);
> =A0}
>
> =A0static inline int mm_reader_trylock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 return down_read_trylock(&mm->sem);
> + =A0 =A0 =A0 this_cpu_inc(mm->rss->readers);
> + =A0 =A0 =A0 if (mutex_is_locked(&mm->lock)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 this_cpu_dec(mm->rss->readers);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 1;
> =A0}
>
> =A0static inline void mm_writer_lock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 down_write(&mm->sem);
> +redo:
> + =A0 =A0 =A0 mutex_lock(&mm->lock);
> + =A0 =A0 =A0 if (mm_readers(mm) =3D=3D 0)

We can change this.

if (!is_readers(mm))
         return;

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 mutex_unlock(&mm->lock);
> + =A0 =A0 =A0 msleep(1);
> + =A0 =A0 =A0 goto redo;
> =A0}
>
> =A0static inline void mm_writer_unlock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 up_write(&mm->sem);
> + =A0 =A0 =A0 mutex_unlock(&mm->lock);
> =A0}
>
> =A0static inline int mm_writer_trylock(struct mm_struct *mm)
> =A0{
> - =A0 =A0 =A0 return down_write_trylock(&mm->sem);
> + =A0 =A0 =A0 if (!mutex_trylock(&mm->lock))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto fail;
> +
> + =A0 =A0 =A0 if (mm_readers(mm) =3D=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;

if (!is_readers(mm))
        return 1;

> +
> + =A0 =A0 =A0 mutex_unlock(&mm->lock);
> +fail:
> + =A0 =A0 =A0 return 0;
> =A0}
>

--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
