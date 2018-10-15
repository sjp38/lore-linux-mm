Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id E33EF6B0266
	for <linux-mm@kvack.org>; Mon, 15 Oct 2018 14:42:20 -0400 (EDT)
Received: by mail-ot1-f70.google.com with SMTP id 36so14931987ott.22
        for <linux-mm@kvack.org>; Mon, 15 Oct 2018 11:42:20 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m197-v6sor6481250oig.90.2018.10.15.11.42.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 15 Oct 2018 11:42:19 -0700 (PDT)
MIME-Version: 1.0
References: <20181015183841.114341-1-yuzhao@google.com>
In-Reply-To: <20181015183841.114341-1-yuzhao@google.com>
From: Jann Horn <jannh@google.com>
Date: Mon, 15 Oct 2018 20:41:52 +0200
Message-ID: <CAG48ez1AEpYx_nDCaNUbw7RdtsCBvAR8=SKSgyaoeSrhqRZ27w@mail.gmail.com>
Subject: Re: [PATCH] mm: detect numbers of vmstat keys/values mismatch
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yuzhao@google.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, jack@suse.cz, David Rientjes <rientjes@google.com>, kemi.wang@intel.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Steven Rostedt <rostedt@goodmis.org>, guro@fb.com, Kees Cook <keescook@chromium.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, bigeasy@linutronix.de, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Mon, Oct 15, 2018 at 8:38 PM Yu Zhao <yuzhao@google.com> wrote:
> There were mismatches between number of vmstat keys and number of
> vmstat values. They were fixed recently by:
>   commit 58bc4c34d249 ("mm/vmstat.c: skip NR_TLB_REMOTE_FLUSH* properly")
>   commit 28e2c4bb99aa ("mm/vmstat.c: fix outdated vmstat_text")
>
> Add a BUILD_BUG_ON to detect such mismatch and hopefully prevent
> it from happening again.

A BUILD_BUG_ON() like this is already in the mm tree:
https://ozlabs.org/~akpm/mmotm/broken-out/mm-vmstat-assert-that-vmstat_text-is-in-sync-with-stat_items_size.patch

> Signed-off-by: Yu Zhao <yuzhao@google.com>
> ---
>  include/linux/vmstat.h |  4 ++++
>  mm/vmstat.c            | 18 ++++++++----------
>  2 files changed, 12 insertions(+), 10 deletions(-)
>
> diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
> index f25cef84b41d..33fdd37124cb 100644
> --- a/include/linux/vmstat.h
> +++ b/include/linux/vmstat.h
> @@ -78,6 +78,10 @@ extern void vm_events_fold_cpu(int cpu);
>
>  #else
>
> +struct vm_event_state {
> +       unsigned long event[0];
> +};
> +
>  /* Disable counters */
>  static inline void count_vm_event(enum vm_event_item item)
>  {
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 7878da76abf2..7ebf871b4cc9 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -1647,23 +1647,21 @@ enum writeback_stat_item {
>         NR_VM_WRITEBACK_STAT_ITEMS,
>  };
>
> +#define NR_VM_STAT_ITEMS (NR_VM_ZONE_STAT_ITEMS + NR_VM_NUMA_STAT_ITEMS + \
> +                         NR_VM_NODE_STAT_ITEMS + NR_VM_WRITEBACK_STAT_ITEMS + \
> +                         ARRAY_SIZE(((struct vm_event_state *)0)->event))
> +
>  static void *vmstat_start(struct seq_file *m, loff_t *pos)
>  {
> +       int i;
>         unsigned long *v;
> -       int i, stat_items_size;
> +
> +       BUILD_BUG_ON(ARRAY_SIZE(vmstat_text) != NR_VM_STAT_ITEMS);
>
>         if (*pos >= ARRAY_SIZE(vmstat_text))
>                 return NULL;
> -       stat_items_size = NR_VM_ZONE_STAT_ITEMS * sizeof(unsigned long) +
> -                         NR_VM_NUMA_STAT_ITEMS * sizeof(unsigned long) +
> -                         NR_VM_NODE_STAT_ITEMS * sizeof(unsigned long) +
> -                         NR_VM_WRITEBACK_STAT_ITEMS * sizeof(unsigned long);
> -
> -#ifdef CONFIG_VM_EVENT_COUNTERS
> -       stat_items_size += sizeof(struct vm_event_state);
> -#endif
>
> -       v = kmalloc(stat_items_size, GFP_KERNEL);
> +       v = kmalloc_array(NR_VM_STAT_ITEMS, sizeof(unsigned long), GFP_KERNEL);
>         m->private = v;
>         if (!v)
>                 return ERR_PTR(-ENOMEM);
> --
> 2.19.1.331.ge82ca0e54c-goog
>
