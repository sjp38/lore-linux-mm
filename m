Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 44BD6440313
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 00:55:07 -0400 (EDT)
Received: by pablk4 with SMTP id lk4so163783205pab.3
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 21:55:07 -0700 (PDT)
Received: from mail-pa0-x236.google.com (mail-pa0-x236.google.com. [2607:f8b0:400e:c03::236])
        by mx.google.com with ESMTPS id fd1si37297282pad.44.2015.10.04.21.55.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 04 Oct 2015 21:55:06 -0700 (PDT)
Received: by pacfv12 with SMTP id fv12so168035357pac.2
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 21:55:05 -0700 (PDT)
Date: Sun, 4 Oct 2015 21:55:02 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v4 4/4] mm, procfs: Display VmAnon, VmFile and VmShm in
 /proc/pid/status
In-Reply-To: <1443792951-13944-5-git-send-email-vbabka@suse.cz>
Message-ID: <alpine.LSU.2.11.1510042128170.15067@eggly.anvils>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz> <1443792951-13944-5-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

On Fri, 2 Oct 2015, Vlastimil Babka wrote:

> From: Jerome Marchand <jmarchan@redhat.com>
> 
> It's currently inconvenient to retrieve MM_ANONPAGES value from status
> and statm files and there is no way to separate MM_FILEPAGES and
> MM_SHMEMPAGES. Add RssAnon, RssFile and RssShm lines in /proc/<pid>/status
> to solve these issues.
> 
> Signed-off-by: Jerome Marchand <jmarchan@redhat.com>
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
> Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Acked-by: Michal Hocko <mhocko@suse.com>

Mostly
Acked-by: Hugh Dickins <hughd@google.com>
but I loathe the alignment...

> ---
>  Documentation/filesystems/proc.txt | 10 +++++++++-
>  fs/proc/task_mmu.c                 | 14 ++++++++++++--
>  2 files changed, 21 insertions(+), 3 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index 82d3657..c887a42 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -169,6 +169,9 @@ For example, to get the status information of a process, all you have to do is
>    VmLck:         0 kB
>    VmHWM:       476 kB
>    VmRSS:       476 kB
> +  RssAnon      352 kB
> +  RssFile:     120 kB
> +  RssShm:        4 kB

That looks nice...

>    VmData:      156 kB
>    VmStk:        88 kB
>    VmExe:        68 kB
> @@ -231,7 +234,12 @@ Table 1-2: Contents of the status files (as of 4.1)
>   VmSize                      total program size
>   VmLck                       locked memory size
>   VmHWM                       peak resident set size ("high water mark")
> - VmRSS                       size of memory portions
> + VmRSS                       size of memory portions. It contains the three
> +                             following parts (VmRSS = RssAnon + RssFile + RssShm)
> + RssAnon                     size of resident anonymous memory
> + RssFile                     size of resident file mappings
> + RssShm                      size of resident shmem memory (includes SysV shm,
> +                             mapping of tmpfs and shared anonymous mappings)
>   VmData                      size of data, stack, and text segments
>   VmStk                       size of data, stack, and text segments
>   VmExe                       size of text segment
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 9b9708e..7332afd 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -23,9 +23,13 @@
>  
>  void task_mem(struct seq_file *m, struct mm_struct *mm)
>  {
> -	unsigned long data, text, lib, swap, ptes, pmds;
> +	unsigned long data, text, lib, swap, ptes, pmds, anon, file, shmem;
>  	unsigned long hiwater_vm, total_vm, hiwater_rss, total_rss;
>  
> +	anon = get_mm_counter(mm, MM_ANONPAGES);
> +	file = get_mm_counter(mm, MM_FILEPAGES);
> +	shmem = get_mm_counter(mm, MM_SHMEMPAGES);
> +
>  	/*
>  	 * Note: to minimize their overhead, mm maintains hiwater_vm and
>  	 * hiwater_rss only when about to *lower* total_vm or rss.  Any
> @@ -36,7 +40,7 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  	hiwater_vm = total_vm = mm->total_vm;
>  	if (hiwater_vm < mm->hiwater_vm)
>  		hiwater_vm = mm->hiwater_vm;
> -	hiwater_rss = total_rss = get_mm_rss(mm);
> +	hiwater_rss = total_rss = anon + file + shmem;
>  	if (hiwater_rss < mm->hiwater_rss)
>  		hiwater_rss = mm->hiwater_rss;
>  
> @@ -53,6 +57,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		"VmPin:\t%8lu kB\n"
>  		"VmHWM:\t%8lu kB\n"
>  		"VmRSS:\t%8lu kB\n"
> +		"RssAnon:\t%8lu kB\n"
> +		"RssFile:\t%8lu kB\n"
> +		"RssShm:\t%8lu kB\n"

... but on my terminal that comes out as

VmPeak:     4584 kB
VmSize:     4584 kB
VmLck:         0 kB
VmPin:         0 kB
VmHWM:      1264 kB
VmRSS:      1264 kB
RssAnon:              84 kB
RssFile:            1180 kB
RssShm:        0 kB
VmData:      184 kB
VmStk:       136 kB
VmExe:        48 kB
VmLib:      1808 kB
VmPTE:        32 kB
VmPMD:        12 kB
VmSwap:        0 kB
HugetlbPages:          0 kB

Notice anything ugly about that?  Of course, what's really wrong was
the years-ago choice of absurdly short names, with a tab after them.
Ugh.  The HugetlbPages line probably can't be helped (even HugeTLB:
would be too long).  But your three, I hope we can do better: I can
understand why Rss instead of Vm, sure, Vm on the front contributes
nothing but incorrectness, and it wasn't a bad idea to group them as
contributors to VmRSS.

I suggest either indenting them with spaces to keep the alignment,

"  Anon:\t%8lu kB\n"
"  File:\t%8lu kB\n"
" Shmem:\t%8lu kB\n"

or keeping your Rss prefix but misaligning the three together,

"RssAnon:\t%8lu kB\n"
"RssFile:\t%8lu kB\n"
"RssShmem:\t%8lu kB\n"

I somewhat prefer "Shmem" to "Shm" because "Shmem" is what
/proc/meminfo already says, and "Shm" makes me think of SysV SHM only.
But I'd happily settle for Shm if it helped in the alignment.

I realize that /proc/<pid>/status is not universally loved for its
aesthetic charm, and I may be the only one who feels this way...

Hugh

>  		"VmData:\t%8lu kB\n"
>  		"VmStk:\t%8lu kB\n"
>  		"VmExe:\t%8lu kB\n"
> @@ -66,6 +73,9 @@ void task_mem(struct seq_file *m, struct mm_struct *mm)
>  		mm->pinned_vm << (PAGE_SHIFT-10),
>  		hiwater_rss << (PAGE_SHIFT-10),
>  		total_rss << (PAGE_SHIFT-10),
> +		anon << (PAGE_SHIFT-10),
> +		file << (PAGE_SHIFT-10),
> +		shmem << (PAGE_SHIFT-10),
>  		data << (PAGE_SHIFT-10),
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
>  		ptes >> 10,
> -- 
> 2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
