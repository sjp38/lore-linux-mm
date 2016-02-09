Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f53.google.com (mail-lf0-f53.google.com [209.85.215.53])
	by kanga.kvack.org (Postfix) with ESMTP id 4A1C26B0009
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 13:37:57 -0500 (EST)
Received: by mail-lf0-f53.google.com with SMTP id j78so121144860lfb.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 10:37:57 -0800 (PST)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id l12si1224973lfe.241.2016.02.09.10.37.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 10:37:55 -0800 (PST)
Received: by mail-lb0-x229.google.com with SMTP id cw1so105272238lbb.1
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 10:37:55 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160209151135.GE30868@esperanza>
References: <145475318946.9321.5193007062423922667.stgit@zurg>
	<20160209151135.GE30868@esperanza>
Date: Tue, 9 Feb 2016 21:37:55 +0300
Message-ID: <CALYGNiPBv+81DB4Xwn5_4YG5pWZir93JUVeuyyMu-gxFg36AyQ@mail.gmail.com>
Subject: Re: [PATCH] tools/vm/page-types.c: add memory cgroup dumping and filtering
From: Konstantin Khlebnikov <koct9i@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@virtuozzo.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Feb 9, 2016 at 6:11 PM, Vladimir Davydov <vdavydov@virtuozzo.com> wrote:
> On Sat, Feb 06, 2016 at 01:06:29PM +0300, Konstantin Khlebnikov wrote:
> ...
>>  static int           opt_list;       /* list pages (in ranges) */
>>  static int           opt_no_summary; /* don't show summary */
>>  static pid_t         opt_pid;        /* process to walk */
>> -const char *         opt_file;
>> +const char *         opt_file;       /* file or directory path */
>> +static int64_t               opt_cgroup = -1;/* cgroup inode */
>
> ino should be a positive number, so we could use uint64_t here. Of
> course, ino=0 could be used for filtering pages not charged to any
> cgroup (as it is in this patch), but I doubt this would be useful.

Yep, this kludge for dumping non-cgroup pages.
I'm trying to keep this simple as possible but I'm afraid this tool
will get BPF someday.

>
> Also, this patch conflicts with the recent change by Naoya introducing
> support of dumping swap entries - https://lkml.org/lkml/2016/2/4/50
>
> I attached a fixlet that addresses these two issues. What do you think
> about it?
>
> Other than that the patch looks good to me,
>
> Reviewed-by: Vladimir Davydov <vdavydov@virtuozzo.com>
>
> Thanks,
> Vladimir
>
> ---
> diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
> index a85c5e7a98ed..dab61c377f54 100644
> --- a/tools/vm/page-types.c
> +++ b/tools/vm/page-types.c
> @@ -170,7 +170,7 @@ static int          opt_list;       /* list pages (in ranges) */
>  static int             opt_no_summary; /* don't show summary */
>  static pid_t           opt_pid;        /* process to walk */
>  const char *           opt_file;       /* file or directory path */
> -static int64_t         opt_cgroup = -1;/* cgroup inode */
> +static uint64_t                opt_cgroup;     /* cgroup inode */
>  static int             opt_list_cgroup;/* list page cgroup */
>
>  #define MAX_ADDR_RANGES        1024
> @@ -604,7 +604,7 @@ static void add_page(unsigned long voffset, unsigned long offset,
>         if (!bit_mask_ok(flags))
>                 return;
>
> -       if (opt_cgroup >= 0 && cgroup != (uint64_t)opt_cgroup)
> +       if (opt_cgroup && cgroup != (uint64_t)opt_cgroup)
>                 return;
>
>         if (opt_hwpoison)
> @@ -659,10 +659,13 @@ static void walk_swap(unsigned long voffset, uint64_t pme)
>         if (!bit_mask_ok(flags))
>                 return;
>
> +       if (opt_cgroup)
> +               return;
> +
>         if (opt_list == 1)
> -               show_page_range(voffset, pagemap_swap_offset(pme), 1, flags);
> +               show_page_range(voffset, pagemap_swap_offset(pme), 1, flags, 0);
>         else if (opt_list == 2)
> -               show_page(voffset, pagemap_swap_offset(pme), flags);
> +               show_page(voffset, pagemap_swap_offset(pme), flags, 0);
>
>         nr_pages[hash_slot(flags)]++;
>         total_pages++;
> @@ -1240,7 +1243,7 @@ int main(int argc, char *argv[])
>                 }
>         }
>
> -       if (opt_cgroup >= 0 || opt_list_cgroup)
> +       if (opt_cgroup || opt_list_cgroup)
>                 kpagecgroup_fd = checked_open(PROC_KPAGECGROUP, O_RDONLY);
>
>         if (opt_list && opt_pid)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
