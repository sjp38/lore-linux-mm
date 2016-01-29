Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 71BB96B0253
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 05:39:45 -0500 (EST)
Received: by mail-wm0-f43.google.com with SMTP id l66so61560434wml.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:39:45 -0800 (PST)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id ee2si21312609wjd.88.2016.01.29.02.39.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 02:39:44 -0800 (PST)
Received: by mail-wm0-x22c.google.com with SMTP id p63so62107880wmp.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 02:39:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160128154746.GI12228@redhat.com>
References: <CACT4Y+Y908EjM2z=706dv4rV6dWtxTLK9nFg9_7DhRMLppBo2g@mail.gmail.com>
 <CALYGNiP6-T=LuBwzKys7TPpFAiGC-U7FymDT4kr3Zrcfo7CoiQ@mail.gmail.com>
 <CACT4Y+YNUZumEy2-OXhDku3rdn-4u28kCDRKtgYaO2uA9cYv5w@mail.gmail.com>
 <CACT4Y+afp8BaUvQ72h7RzQuMOX05iDEyP3p3wuZfjaKcW_Ud9A@mail.gmail.com>
 <20160127194132.GA896@redhat.com> <CACT4Y+Z86=NoNPrS-vgtJiB54Akwq6FfAPf2wnBA1FX2BHafWQ@mail.gmail.com>
 <20160128154746.GI12228@redhat.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 29 Jan 2016 11:39:24 +0100
Message-ID: <CACT4Y+Z=2Lcd13mwRx+ZVVvEofww2v2hAEdmHK-6aHWjaGJm+g@mail.gmail.com>
Subject: Re: mm: BUG in expand_downwards
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Oleg Nesterov <oleg@redhat.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Chen Gang <gang.chen.5i5j@gmail.com>, Michal Hocko <mhocko@suse.com>, Piotr Kwapulinski <kwapulinski.piotr@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <sasha.levin@oracle.com>, syzkaller <syzkaller@googlegroups.com>, Kostya Serebryany <kcc@google.com>, Alexander Potapenko <glider@google.com>

On Thu, Jan 28, 2016 at 4:47 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello,
>
> On Wed, Jan 27, 2016 at 10:11:44PM +0100, Dmitry Vyukov wrote:
>> Sorry, I meant only the second once. The mm bug.
>> I guess you need at least CONFIG_DEBUG_VM.  Run it in a tight parallel
>> loop with CPU oversubscription (e.g. 32 parallel processes on 2 cores)
>> for  at least an hour.
>
> Does this help for the mm bug?

Yes, it seems to fix the issue.
I will also run fuzzer with this patch and report if I see it again.

> From 0cc410ae59800444ca929e3dc48e4f1580a95be6 Mon Sep 17 00:00:00 2001
> From: Andrea Arcangeli <aarcange@redhat.com>
> Date: Thu, 28 Jan 2016 16:34:44 +0100
> Subject: [PATCH 1/1] mm: validate_mm browse_rb SMP race condition
>
> The mmap_sem for reading in validate_mm called from expand_stack is
> not enough to prevent the argumented rbtree rb_subtree_gap information
> to change from under us because expand_stack may be running from other
> threads concurrently which will hold the mmap_sem for reading too.
>
> The argumented rbtree is updated with vma_gap_update under the
> page_table_lock so use it in browse_rb() too to avoid false positives.
>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  mm/mmap.c | 7 +++++--
>  1 file changed, 5 insertions(+), 2 deletions(-)
>
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f384def..8389e03 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -389,8 +389,9 @@ static long vma_compute_subtree_gap(struct vm_area_struct *vma)
>  }
>
>  #ifdef CONFIG_DEBUG_VM_RB
> -static int browse_rb(struct rb_root *root)
> +static int browse_rb(struct mm_struct *mm)
>  {
> +       struct rb_root *root = &mm->mm_rb;
>         int i = 0, j, bug = 0;
>         struct rb_node *nd, *pn = NULL;
>         unsigned long prev = 0, pend = 0;
> @@ -413,12 +414,14 @@ static int browse_rb(struct rb_root *root)
>                                   vma->vm_start, vma->vm_end);
>                         bug = 1;
>                 }
> +               spin_lock(&mm->page_table_lock);
>                 if (vma->rb_subtree_gap != vma_compute_subtree_gap(vma)) {
>                         pr_emerg("free gap %lx, correct %lx\n",
>                                vma->rb_subtree_gap,
>                                vma_compute_subtree_gap(vma));
>                         bug = 1;
>                 }
> +               spin_unlock(&mm->page_table_lock);
>                 i++;
>                 pn = nd;
>                 prev = vma->vm_start;
> @@ -474,7 +477,7 @@ static void validate_mm(struct mm_struct *mm)
>                           mm->highest_vm_end, highest_address);
>                 bug = 1;
>         }
> -       i = browse_rb(&mm->mm_rb);
> +       i = browse_rb(mm);
>         if (i != mm->map_count) {
>                 if (i != -1)
>                         pr_emerg("map_count %d rb %d\n", mm->map_count, i);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
