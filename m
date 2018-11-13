Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id C998A6B0005
	for <linux-mm@kvack.org>; Tue, 13 Nov 2018 06:41:11 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id o206-v6so6832159oif.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:41:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a2-v6sor10009799oiy.10.2018.11.13.03.41.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 13 Nov 2018 03:41:10 -0800 (PST)
Received: from mail-oi1-f170.google.com (mail-oi1-f170.google.com. [209.85.167.170])
        by smtp.gmail.com with ESMTPSA id m18-v6sm3190966oic.14.2018.11.13.03.41.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Nov 2018 03:41:08 -0800 (PST)
Received: by mail-oi1-f170.google.com with SMTP id j202-v6so9981323oih.10
        for <linux-mm@kvack.org>; Tue, 13 Nov 2018 03:41:07 -0800 (PST)
MIME-Version: 1.0
References: <20181112231344.7161-1-timofey.titovets@synesis.ru> <20181113022516.45u6b536vtdjgvrf@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
In-Reply-To: <20181113022516.45u6b536vtdjgvrf@soleen.tm1wkky2jk1uhgkn0ivaxijq1c.bx.internal.cloudapp.net>
From: Timofey Titovets <timofey.titovets@synesis.ru>
Date: Tue, 13 Nov 2018 14:40:31 +0300
Message-ID: <CAGqmi744_8NA30V0aWCpFi_=WSaA+18h3njOTQG0SFUVdXi8bg@mail.gmail.com>
Subject: Re: [PATCH V3] KSM: allow dedup all tasks memory
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: pasha.tatashin@soleen.com
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-doc@vger.kernel.org

=D0=B2=D1=82, 13 =D0=BD=D0=BE=D1=8F=D0=B1. 2018 =D0=B3. =D0=B2 05:25, Pavel=
 Tatashin <pasha.tatashin@soleen.com>:
>
> On 18-11-13 02:13:44, Timofey Titovets wrote:
> > From: Timofey Titovets <nefelim4ag@gmail.com>
> >
> > ksm by default working only on memory that added by
> > madvise().
> >
> > And only way get that work on other applications:
> >   * Use LD_PRELOAD and libraries
> >   * Patch kernel
> >
> > Lets use kernel task list and add logic to import VMAs from tasks.
> >
> > That behaviour controlled by new attributes:
> >   * mode:
> >     I try mimic hugepages attribute, so mode have two states:
> >       * madvise      - old default behaviour
> >       * always [new] - allow ksm to get tasks vma and
> >                        try working on that.
> >   * seeker_sleep_millisecs:
> >     Add pauses between imports tasks VMA
> >
> > For rate limiting proporses and tasklist locking time,
> > ksm seeker thread only import VMAs from one task per loop.
> >
> > Some numbers from different not madvised workloads.
> > Formulas:
> >   Percentage ratio =3D (pages_sharing - pages_shared)/pages_unshared
> >   Memory saved =3D (pages_sharing - pages_shared)*4/1024 MiB
> >   Memory used =3D free -h
> >
> >   * Name: My working laptop
> >     Description: Many different chrome/electron apps + KDE
> >     Ratio: 5%
> >     Saved: ~100  MiB
> >     Used:  ~2000 MiB
> >
> >   * Name: K8s test VM
> >     Description: Some small random running docker images
> >     Ratio: 40%
> >     Saved: ~160 MiB
> >     Used:  ~920 MiB
> >
> >   * Name: Ceph test VM
> >     Description: Ceph Mon/OSD, some containers
> >     Ratio: 20%
> >     Saved: ~60 MiB
> >     Used:  ~600 MiB
> >
> >   * Name: BareMetal K8s backend server
> >     Description: Different server apps in containers C, Java, GO & etc
> >     Ratio: 72%
> >     Saved: ~5800 MiB
> >     Used:  ~35.7 GiB
> >
> >   * Name: BareMetal K8s processing server
> >     Description: Many instance of one CPU intensive application
> >     Ratio: 55%
> >     Saved: ~2600 MiB
> >     Used:  ~28.0 GiB
> >
> >   * Name: BareMetal Ceph node
> >     Description: Only OSD storage daemons running
> >     Raio: 2%
> >     Saved: ~190 MiB
> >     Used:  ~11.7 GiB
> >
> > Changes:
> >   v1 -> v2:
> >     * Rebase on v4.19.1 (must also apply on 4.20-rc2+)
> >   v2 -> v3:
> >     * Reformat patch description
> >     * Rename mode normal to madvise
> >     * Add some memory numbers
> >     * Fix checkpatch.pl warnings
> >     * Separate ksm vma seeker to another kthread
> >     * Fix: "BUG: scheduling while atomic: ksmd"
> >       by move seeker to another thread
> >
> > Signed-off-by: Timofey Titovets <nefelim4ag@gmail.com>
> > CC: Matthew Wilcox <willy@infradead.org>
> > CC: linux-mm@kvack.org
> > CC: linux-doc@vger.kernel.org
> > ---
> >  Documentation/admin-guide/mm/ksm.rst |  15 ++
> >  mm/ksm.c                             | 215 +++++++++++++++++++++++----
> >  2 files changed, 198 insertions(+), 32 deletions(-)
> >
> > diff --git a/Documentation/admin-guide/mm/ksm.rst b/Documentation/admin=
-guide/mm/ksm.rst
> > index 9303786632d1..7cffd47f9b38 100644
> > --- a/Documentation/admin-guide/mm/ksm.rst
> > +++ b/Documentation/admin-guide/mm/ksm.rst
> > @@ -116,6 +116,21 @@ run
> >          Default: 0 (must be changed to 1 to activate KSM, except if
> >          CONFIG_SYSFS is disabled)
> >
> > +mode
> > +        * set always to allow ksm deduplicate memory of every process
> > +        * set madvise to use only madvised memory
> > +
> > +        Default: madvise (dedupulicate only madvised memory as in
> > +        earlier releases)
> > +
> > +seeker_sleep_millisecs
> > +        how many milliseconds ksmd task seeker should sleep try anothe=
r
> > +        task.
> > +        e.g. ``echo 1000 > /sys/kernel/mm/ksm/seeker_sleep_millisecs``
> > +
> > +        Default: 1000 (chosen for rate limit purposes)
> > +
> > +
> >  use_zero_pages
> >          specifies whether empty pages (i.e. allocated pages that only
> >          contain zeroes) should be treated specially.  When set to 1,
> > diff --git a/mm/ksm.c b/mm/ksm.c
> > index 5b0894b45ee5..1a03b28b6288 100644
> > --- a/mm/ksm.c
> > +++ b/mm/ksm.c
> > @@ -273,6 +273,9 @@ static unsigned int ksm_thread_pages_to_scan =3D 10=
0;
> >  /* Milliseconds ksmd should sleep between batches */
> >  static unsigned int ksm_thread_sleep_millisecs =3D 20;
> >
> > +/* Milliseconds ksmd seeker should sleep between runs */
> > +static unsigned int ksm_thread_seeker_sleep_millisecs =3D 1000;
> > +
> >  /* Checksum of an empty (zeroed) page */
> >  static unsigned int zero_checksum __read_mostly;
> >
> > @@ -295,7 +298,12 @@ static int ksm_nr_node_ids =3D 1;
> >  static unsigned long ksm_run =3D KSM_RUN_STOP;
> >  static void wait_while_offlining(void);
> >
> > +#define KSM_MODE_MADVISE 0
> > +#define KSM_MODE_ALWAYS      1
> > +static unsigned long ksm_mode =3D KSM_MODE_MADVISE;
> > +
> >  static DECLARE_WAIT_QUEUE_HEAD(ksm_thread_wait);
> > +static DECLARE_WAIT_QUEUE_HEAD(ksm_seeker_thread_wait);
> >  static DEFINE_MUTEX(ksm_thread_mutex);
> >  static DEFINE_SPINLOCK(ksm_mmlist_lock);
> >
> > @@ -303,6 +311,11 @@ static DEFINE_SPINLOCK(ksm_mmlist_lock);
> >               sizeof(struct __struct), __alignof__(struct __struct),\
> >               (__flags), NULL)
> >
> > +static inline int ksm_mode_always(void)
> > +{
> > +     return (ksm_mode =3D=3D KSM_MODE_ALWAYS);
> > +}
> > +
> >  static int __init ksm_slab_init(void)
> >  {
> >       rmap_item_cache =3D KSM_KMEM_CACHE(rmap_item, 0);
> > @@ -2389,6 +2402,106 @@ static int ksmd_should_run(void)
> >       return (ksm_run & KSM_RUN_MERGE) && !list_empty(&ksm_mm_head.mm_l=
ist);
> >  }
> >
> > +
> > +static int ksm_enter(struct mm_struct *mm, unsigned long *vm_flags)
> > +{
> > +     int err;
> > +
> > +     if (*vm_flags & (VM_MERGEABLE | VM_SHARED  | VM_MAYSHARE   |
> > +                      VM_PFNMAP    | VM_IO      | VM_DONTEXPAND |
> > +                      VM_HUGETLB | VM_MIXEDMAP))
> > +             return 0;
> > +
> > +#ifdef VM_SAO
> > +     if (*vm_flags & VM_SAO)
> > +             return 0;
> > +#endif
> > +#ifdef VM_SPARC_ADI
> > +     if (*vm_flags & VM_SPARC_ADI)
> > +             return 0;
> > +#endif
> > +     if (!test_bit(MMF_VM_MERGEABLE, &mm->flags)) {
> > +             err =3D __ksm_enter(mm);
> > +             if (err)
> > +                     return err;
> > +     }
> > +
> > +     *vm_flags |=3D VM_MERGEABLE;
> > +
> > +     return 0;
> > +}
> > +
> > +/*
> > + * Register all vmas for all processes in the system with KSM.
> > + * Note that every call to ksm_, for a given vma, after the first
> > + * does nothing but set flags.
> > + */
> > +void ksm_import_task_vma(struct task_struct *task)
> > +{
> > +     struct vm_area_struct *vma;
> > +     struct mm_struct *mm;
> > +     int error;
> > +
> > +     mm =3D get_task_mm(task);
> > +     if (!mm)
> > +             return;
> > +     down_write(&mm->mmap_sem);
> > +     vma =3D mm->mmap;
> > +     while (vma) {
> > +             error =3D ksm_enter(vma->vm_mm, &vma->vm_flags);
> > +             vma =3D vma->vm_next;
> > +     }
> > +     up_write(&mm->mmap_sem);
> > +     mmput(mm);
> > +}
> > +
> > +static int ksm_seeker_thread(void *nothing)
>
> Is it really necessary to have an extra thread in ksm just to add vma's
> for scanning? Can we do it right from the scanner thread? Also, may be
> it is better to add vma's at their creation time when KSM_MODE_ALWAYS is
> enabled?
>
> Thank you,
> Pasha

Oh, thats a long story, and my english to bad for describe all things,
even that hard to find linux-mm conversation several years ago about that.

Anyway, so:
In V2 - i use scanner thread to add VMA, but i think scanner do that
with too high rate.
i.e. walk on task list, and get new task every 20ms, to wait write semaphor=
e,
to get VMA...
To high rate for task list scanner, i think it's overkill.

About add VMA from creation time,
UKSM add ksm_enter() hooks to mm subsystem, i port that to KSM.
But some mm people say what they not like add KSM hooks to other subsystems=
.
And want ksm do that internally by some way.

Frankly speaking i didn't have enough knowledge and skills to do that
another way in past time.
They also suggest me look to THP for that logic, but i can't find how
THP do that without hooks, and
where THP truly scan memory.

So, after all of that i implemented this in that way.
In first iteration as part of ksm scan thread, and in second, by
separate thread.
Because that allow to add VMA in fully independent way.

Thanks!
