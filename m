Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 020256B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 21:56:49 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id l66so1430164oih.23
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 18:56:48 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x44sor1196973otd.168.2018.02.07.18.56.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 07 Feb 2018 18:56:47 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180208021112.GB14918@bombadil.infradead.org>
References: <20180208021112.GB14918@bombadil.infradead.org>
From: Jann Horn <jannh@google.com>
Date: Thu, 8 Feb 2018 03:56:26 +0100
Message-ID: <CAG48ez2-MTJ2YrS5fPZi19RY6P_6NWuK1U5CcQpJ25=xrGSy_A@mail.gmail.com>
Subject: Re: [RFC] Warn the user when they could overflow mapcount
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Kernel Hardening <kernel-hardening@lists.openwall.com>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

On Thu, Feb 8, 2018 at 3:11 AM, Matthew Wilcox <willy@infradead.org> wrote:
> Kirill and I were talking about trying to overflow page->_mapcount
> the other day and realised that the default settings of pid_max and
> max_map_count prevent it [1].  But there isn't even documentation to
> warn a sysadmin that they've just opened themselves up to the possibility
> that they've opened their system up to a sufficiently-determined attacker.
>
> I'm not sufficiently wise in the ways of the MM to understand exactly
> what goes wrong if we do wrap mapcount.  Kirill says:
>
>   rmap depends on mapcount to decide when the page is not longer mapped.
>   If it sees page_mapcount() == 0 due to 32-bit wrap we are screwed;
>   data corruption, etc.

How much memory would you need to trigger this? You need one
vm_area_struct per increment, and those are 200 bytes? So at least
800GiB of memory for the vm_area_structs, and maybe more for other
data structures?

I wouldn't be too surprised if there are more 32-bit overflows that
start being realistic once you put something on the order of terabytes
of memory into one machine, given that refcount_t is 32 bits wide -
for example, the i_count. See
https://bugs.chromium.org/p/project-zero/issues/detail?id=809 for an
example where, given a sufficiently high RLIMIT_MEMLOCK, it was
possible to overflow a 32-bit refcounter on a system with just ~32GiB
of free memory (minimum required to store 2^32 64-bit pointers).

On systems with RAM on the order of terabytes, it's probably a good
idea to turn on refcount hardening to make issues like that
non-exploitable for now.

> That seems pretty bad.  So here's a patch which adds documentation to the
> two sysctls that a sysadmin could use to shoot themselves in the foot,
> and adds a warning if they change either of them to a dangerous value.

I have negative feelings about this patch, mostly because AFAICS:

 - It documents an issue instead of fixing it.
 - It likely only addresses a small part of the actual problem.

> It's possible to get into a dangerous situation without triggering this
> warning (already have the file mapped a lot of times, then lower pid_max,
> then raise max_map_count, then map the file a lot more times), but it's
> unlikely to happen.
>
> Comments?
>
> [1] map_count counts the number of times that a page is mapped to
> userspace; max_map_count restricts the number of times a process can
> map a page and pid_max restricts the number of processes that can exist.
> So map_count can never be larger than pid_max * max_map_count.
[...]
> +int sysctl_pid_max(struct ctl_table *table, int write,
> +                  void __user *buffer, size_t *lenp, loff_t *ppos)
> +{
> +       struct ctl_table t;
> +       int ret;
> +
> +       t = *table;
> +       t.data = &pid_max;
> +       t.extra1 = &pid_max_min;
> +       t.extra2 = &pid_max_max;
> +
> +       ret = proc_douintvec_minmax(&t, write, buffer, lenp, ppos);
> +       if (ret || !write)
> +               return ret;
> +
> +       if ((INT_MAX / max_map_count) > pid_max)
> +               pr_warn("pid_max is dangerously large\n");

This in reordered is "if (pid_max * max_map_count < INT_MAX)
pr_warn(...);", no? That doesn't make sense to me. Same thing again
further down.

[...]
> diff --git a/mm/madvise.c b/mm/madvise.c
> index 4d3c922ea1a1..5b66a4a48192 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -147,7 +147,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
>         *prev = vma;
>
>         if (start != vma->vm_start) {
> -               if (unlikely(mm->map_count >= sysctl_max_map_count)) {
> +               if (unlikely(mm->map_count >= max_map_count)) {

Why the renaming?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
