Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 43CFA6B0038
	for <linux-mm@kvack.org>; Sun,  6 Sep 2015 21:29:56 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so72423459wic.0
        for <linux-mm@kvack.org>; Sun, 06 Sep 2015 18:29:55 -0700 (PDT)
Received: from mail1.vodafone.ie (mail1.vodafone.ie. [213.233.128.43])
        by mx.google.com with ESMTP id sd17si18006172wjb.102.2015.09.06.18.29.54
        for <linux-mm@kvack.org>;
        Sun, 06 Sep 2015 18:29:54 -0700 (PDT)
Message-ID: <55ECE891.7030309@draigBrady.com>
Date: Mon, 07 Sep 2015 02:29:53 +0100
From: =?UTF-8?B?UMOhZHJhaWcgQnJhZHk=?= <P@draigBrady.com>
MIME-Version: 1.0
Subject: Re: [PATCH v5 1/2] mm: hugetlb: proc: add HugetlbPages field to /proc/PID/smaps
References: <20150812000336.GB32192@hori1.linux.bs1.fc.nec.co.jp> <1440059182-19798-1-git-send-email-n-horiguchi@ah.jp.nec.com> <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1440059182-19798-2-git-send-email-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, =?UTF-8?B?SsO2cm4gRW5nZWw=?= <joern@purestorage.com>, Mike Kravetz <mike.kravetz@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

On 20/08/15 09:26, Naoya Horiguchi wrote:
> Currently /proc/PID/smaps provides no usage info for vma(VM_HUGETLB), which
> is inconvenient when we want to know per-task or per-vma base hugetlb usage.
> To solve this, this patch adds a new line for hugetlb usage like below:
> 
>   Size:              20480 kB
>   Rss:                   0 kB
>   Pss:                   0 kB
>   Shared_Clean:          0 kB
>   Shared_Dirty:          0 kB
>   Private_Clean:         0 kB
>   Private_Dirty:         0 kB
>   Referenced:            0 kB
>   Anonymous:             0 kB
>   AnonHugePages:         0 kB
>   HugetlbPages:      18432 kB
>   Swap:                  0 kB
>   KernelPageSize:     2048 kB
>   MMUPageSize:        2048 kB
>   Locked:                0 kB
>   VmFlags: rd wr mr mw me de ht
> 
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Acked-by: Joern Engel <joern@logfs.org>
> Acked-by: David Rientjes <rientjes@google.com>
> ---
> v3 -> v4:
> - suspend Acked-by tag because v3->v4 change is not trivial
> - I stated in previous discussion that HugetlbPages line can contain page
>   size info, but that's not necessary because we already have KernelPageSize
>   info.
> - merged documentation update, where the current documentation doesn't mention
>   AnonHugePages, so it's also added.
> ---
>  Documentation/filesystems/proc.txt |  7 +++++--
>  fs/proc/task_mmu.c                 | 29 +++++++++++++++++++++++++++++
>  2 files changed, 34 insertions(+), 2 deletions(-)
> 
> diff --git v4.2-rc4/Documentation/filesystems/proc.txt v4.2-rc4_patched/Documentation/filesystems/proc.txt
> index 6f7fafde0884..22e40211ef64 100644
> --- v4.2-rc4/Documentation/filesystems/proc.txt
> +++ v4.2-rc4_patched/Documentation/filesystems/proc.txt
> @@ -423,6 +423,8 @@ Private_Clean:         0 kB
>  Private_Dirty:         0 kB
>  Referenced:          892 kB
>  Anonymous:             0 kB
> +AnonHugePages:         0 kB
> +HugetlbPages:          0 kB
>  Swap:                  0 kB
>  KernelPageSize:        4 kB
>  MMUPageSize:           4 kB
> @@ -440,8 +442,9 @@ indicates the amount of memory currently marked as referenced or accessed.
>  "Anonymous" shows the amount of memory that does not belong to any file.  Even
>  a mapping associated with a file may contain anonymous pages: when MAP_PRIVATE
>  and a page is modified, the file page is replaced by a private anonymous copy.
> -"Swap" shows how much would-be-anonymous memory is also used, but out on
> -swap.
> +"AnonHugePages" shows the ammount of memory backed by transparent hugepage.
> +"HugetlbPages" shows the ammount of memory backed by hugetlbfs page.
> +"Swap" shows how much would-be-anonymous memory is also used, but out on swap.

There is no distinction between "private" and "shared" in this "huge page" accounting right?
Would it be possible to account for the huge pages in the {Private,Shared}_{Clean,Dirty} fields?
Or otherwise split the huge page accounting into shared/private?

thanks!
PA!draig.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
