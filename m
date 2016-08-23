Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 32E1B6B0038
	for <linux-mm@kvack.org>; Tue, 23 Aug 2016 11:14:08 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so87464559wmz.2
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:14:08 -0700 (PDT)
Received: from mail-wm0-f67.google.com (mail-wm0-f67.google.com. [74.125.82.67])
        by mx.google.com with ESMTPS id k6si3508129wjy.153.2016.08.23.08.14.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 Aug 2016 08:14:06 -0700 (PDT)
Received: by mail-wm0-f67.google.com with SMTP id o80so18597136wme.0
        for <linux-mm@kvack.org>; Tue, 23 Aug 2016 08:14:05 -0700 (PDT)
Date: Tue, 23 Aug 2016 17:14:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] proc, smaps: reduce printing overhead
Message-ID: <20160823151404.GM23577@dhcp22.suse.cz>
References: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1471519888-13829-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Jann Horn <jann@thejh.net>

On Thu 18-08-16 13:31:28, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> seq_printf (used by show_smap) can be pretty expensive when dumping a
> lot of numbers.  Say we would like to get Rss and Pss from a particular
> process.  In order to measure a pathological case let's generate as many
> mappings as possible:
> 
> $ cat max_mmap.c
> int main()
> {
> 	while (mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_ANON|MAP_SHARED|MAP_POPULATE, -1, 0) != MAP_FAILED)
> 		;
> 
> 	printf("pid:%d\n", getpid());
> 	pause();
> 	return 0;
> }
> 
> $ awk '/^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss}' /proc/$pid/smaps
> 
> would do a trick. The whole runtime is in the kernel space which is not
> that that unexpected because smaps is not the cheapest one (we have to
> do rmap walk etc.).
> 
>         Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3050/smaps"
>         User time (seconds): 0.01
>         System time (seconds): 0.44
>         Percent of CPU this job got: 99%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.47
> 
> But the perf says:
>     22.55%  awk      [kernel.kallsyms]  [k] format_decode
>     14.65%  awk      [kernel.kallsyms]  [k] vsnprintf
>      6.40%  awk      [kernel.kallsyms]  [k] number
>      2.53%  awk      [kernel.kallsyms]  [k] shmem_mapping
>      2.53%  awk      [kernel.kallsyms]  [k] show_smap
>      1.81%  awk      [kernel.kallsyms]  [k] lock_acquire
> 
> we are spending most of the time actually generating the output which is
> quite lame. Let's replace seq_printf by seq_puts and seq_put_decimal_ull.
> This will give us:
>         Command being timed: "awk /^Rss/{rss+=$2} /^Pss/{pss+=$2} END {printf "rss:%d pss:%d\n", rss, pss} /proc/3067/smaps"
>         User time (seconds): 0.00
>         System time (seconds): 0.41
>         Percent of CPU this job got: 99%
>         Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.42
> 
> which will give us ~7% improvement. Perf says:
>     28.87%  awk      [kernel.kallsyms]  [k] seq_puts
>      5.30%  awk      [kernel.kallsyms]  [k] vsnprintf
>      4.54%  awk      [kernel.kallsyms]  [k] format_decode
>      3.73%  awk      [kernel.kallsyms]  [k] show_smap
>      2.56%  awk      [kernel.kallsyms]  [k] shmem_mapping
>      1.92%  awk      [kernel.kallsyms]  [k] number
>      1.80%  awk      [kernel.kallsyms]  [k] lock_acquire
>      1.75%  awk      [kernel.kallsyms]  [k] print_name_value_kb

OK, so it turned out that I was fooled by VIRT_CPU_ACCOUNTING_GEN
accounting [1]. So I have replaced it by TICK_CPU_ACCOUNTING and the
numbers the seq_printf -> seq_write doesn't seem to be all that much of
a win.
Before
        User time (seconds): 0.14
        System time (seconds): 0.30
        Percent of CPU this job got: 98%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.45

    19.66%  awk      [kernel.kallsyms]  [k] format_decode
    14.25%  awk      [kernel.kallsyms]  [k] vsnprintf
     6.42%  awk      [kernel.kallsyms]  [k] number
     2.88%  awk      mawk               [.] 0x0000000000006910
     2.58%  awk      [kernel.kallsyms]  [k] shmem_mapping
     2.12%  awk      mawk               [.] 0x0000000000006918
     2.02%  awk      [kernel.kallsyms]  [k] show_smap

after:
        User time (seconds): 0.13
        System time (seconds): 0.31
        Percent of CPU this job got: 99%
        Elapsed (wall clock) time (h:mm:ss or m:ss): 0:00.45

    23.89%  awk      [kernel.kallsyms]  [k] seq_write
     5.84%  awk      [kernel.kallsyms]  [k] vsnprintf
     5.08%  awk      [kernel.kallsyms]  [k] format_decode
     4.00%  awk      [kernel.kallsyms]  [k] show_val_kb
     3.84%  awk      [kernel.kallsyms]  [k] show_smap
     2.16%  awk      [kernel.kallsyms]  [k] number
     2.05%  awk      [kernel.kallsyms]  [k] shmem_mapping

so it is basically in noise.

[1] http://lkml.kernel.org/r/20160823143330.GL23577@dhcp22.suse.cz
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
