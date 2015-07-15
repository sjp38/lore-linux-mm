Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f176.google.com (mail-ig0-f176.google.com [209.85.213.176])
	by kanga.kvack.org (Postfix) with ESMTP id 169D32802A6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:17:03 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so79352619igb.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:17:02 -0700 (PDT)
Received: from mail-ie0-x233.google.com (mail-ie0-x233.google.com. [2607:f8b0:4001:c03::233])
        by mx.google.com with ESMTPS id s100si4453197ioe.52.2015.07.15.12.17.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 12:17:02 -0700 (PDT)
Received: by iecuq6 with SMTP id uq6so40800782iec.2
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:17:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <024b60a19e5ef246c9af3c5ff7652e71576e0bcc.1436967694.git.vdavydov@parallels.com>
References: <cover.1436967694.git.vdavydov@parallels.com>
	<024b60a19e5ef246c9af3c5ff7652e71576e0bcc.1436967694.git.vdavydov@parallels.com>
Date: Wed, 15 Jul 2015 12:17:02 -0700
Message-ID: <CAJu=L58+L9nQDeW0VeaX3fmKy0EWG7js_rg3eWSVTg1D3WWHkg@mail.gmail.com>
Subject: Re: [PATCH -mm v8 7/7] proc: export idle flag via kpageflags
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 15, 2015 at 6:54 AM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> As noted by Minchan, a benefit of reading idle flag from
> /proc/kpageflags is that one can easily filter dirty and/or unevictable
> pages while estimating the size of unused memory.
>
> Note that idle flag read from /proc/kpageflags may be stale in case the
> page was accessed via a PTE, because it would be too costly to iterate
> over all page mappings on each /proc/kpageflags read to provide an
> up-to-date value. To make sure the flag is up-to-date one has to read
> /proc/kpageidle first.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

Reviewed-by: Andres Lagar-Cavilla <andreslc@google.com>

> ---
>  Documentation/vm/pagemap.txt           | 6 ++++++
>  fs/proc/page.c                         | 3 +++
>  include/uapi/linux/kernel-page-flags.h | 1 +
>  3 files changed, 10 insertions(+)
>
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index c9266340852c..5896b7d7fd74 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -64,6 +64,7 @@ There are five components to pagemap:
>      22. THP
>      23. BALLOON
>      24. ZERO_PAGE
> +    25. IDLE
>
>   * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
>     memory cgroup each page is charged to, indexed by PFN. Only available when
> @@ -124,6 +125,11 @@ Short descriptions to the page flags:
>  24. ZERO_PAGE
>      zero page for pfn_zero or huge_zero page
>
> +25. IDLE
> +    page has not been accessed since it was marked idle (see /proc/kpageidle)
> +    Note that this flag may be stale in case the page was accessed via a PTE.
> +    To make sure the flag is up-to-date one has to read /proc/kpageidle first.
> +
>      [IO related page flags]
>   1. ERROR     IO error occurred
>   3. UPTODATE  page has up-to-date data
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 273537885ab4..13dcb823fe4e 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -150,6 +150,9 @@ u64 stable_page_flags(struct page *page)
>         if (PageBalloon(page))
>                 u |= 1 << KPF_BALLOON;
>
> +       if (page_is_idle(page))
> +               u |= 1 << KPF_IDLE;
> +
>         u |= kpf_copy_bit(k, KPF_LOCKED,        PG_locked);
>
>         u |= kpf_copy_bit(k, KPF_SLAB,          PG_slab);
> diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
> index a6c4962e5d46..5da5f8751ce7 100644
> --- a/include/uapi/linux/kernel-page-flags.h
> +++ b/include/uapi/linux/kernel-page-flags.h
> @@ -33,6 +33,7 @@
>  #define KPF_THP                        22
>  #define KPF_BALLOON            23
>  #define KPF_ZERO_PAGE          24
> +#define KPF_IDLE               25
>
>
>  #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
> --
> 2.1.4
>



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
