Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id A6A786B0006
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 10:12:07 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e4-v6so13554262qtj.5
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 07:12:07 -0700 (PDT)
Received: from a9-46.smtp-out.amazonses.com (a9-46.smtp-out.amazonses.com. [54.240.9.46])
        by mx.google.com with ESMTPS id 31-v6si1536458qtx.31.2018.08.07.07.12.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 07 Aug 2018 07:12:06 -0700 (PDT)
Date: Tue, 7 Aug 2018 14:12:06 +0000
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH] proc: add percpu populated pages count to meminfo
In-Reply-To: <20180807005607.53950-1-dennisszhou@gmail.com>
Message-ID: <0100016514bb069d-a6532c9a-b1ca-4eba-8644-c5b3935e3bd8-000000@email.amazonses.com>
References: <20180807005607.53950-1-dennisszhou@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 6 Aug 2018, Dennis Zhou wrote:

> diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
> index 2fb04846ed11..ddd5249692e9 100644
> --- a/fs/proc/meminfo.c
> +++ b/fs/proc/meminfo.c
> @@ -7,6 +7,7 @@
>  #include <linux/mman.h>
>  #include <linux/mmzone.h>
>  #include <linux/proc_fs.h>
> +#include <linux/percpu.h>
>  #include <linux/quicklist.h>
>  #include <linux/seq_file.h>
>  #include <linux/swap.h>
> @@ -121,6 +122,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
>  		   (unsigned long)VMALLOC_TOTAL >> 10);
>  	show_val_kb(m, "VmallocUsed:    ", 0ul);
>  	show_val_kb(m, "VmallocChunk:   ", 0ul);
> +	show_val_kb(m, "PercpuPopulated:", pcpu_nr_populated_pages());

Populated? Can we avoid this for simplicities sake: "Percpu"?

We do not count pages that are not present elsewhere either and those
counters do not have "populated" in them.

>  int pcpu_nr_empty_pop_pages;
>
> +/*
> + * The number of populated pages in use by the allocator, protected by
> + * pcpu_lock.  This number is kept per a unit per chunk (i.e. when a page gets
> + * allocated/deallocated, it is allocated/deallocated in all units of a chunk
> + * and increments/decrements this count by 1).
> + */
> +static int pcpu_nr_populated;

pcpu_nr_pages?
