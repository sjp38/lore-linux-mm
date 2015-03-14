Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f46.google.com (mail-la0-f46.google.com [209.85.215.46])
	by kanga.kvack.org (Postfix) with ESMTP id 34C9C6B0080
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 13:14:26 -0400 (EDT)
Received: by ladw1 with SMTP id w1so11476321lad.0
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:14:25 -0700 (PDT)
Received: from mail-la0-x22f.google.com (mail-la0-x22f.google.com. [2a00:1450:4010:c03::22f])
        by mx.google.com with ESMTPS id ay11si3890554lab.50.2015.03.14.10.14.23
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Mar 2015 10:14:24 -0700 (PDT)
Received: by ladw1 with SMTP id w1so11476048lad.0
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:14:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc>
References: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Sat, 14 Mar 2015 20:14:02 +0300
Message-ID: <CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com>
Subject: Re: High system load and 3TB of memory.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jesper@krogh.cc
Cc: linux-mm@kvack.org

On Sat, Mar 14, 2015 at 8:05 PM,  <jesper@krogh.cc> wrote:
> Hi.
>
> I have a 3.13 (ubuntu LTS) server with 3TB of memory and under certain load
> conditions it can spiral off to 80+% system load. Per recommendation on IRC
> yesterday I have captured 2 perf reports (I'm new to perf, so I'm not
> sure they tell precisely whats needed.
>
> Bad situation (high sysload 80%+)
>
> Samples: 381K of event 'cycles', Event count (approx.): 1228296411165
> +  27.84%         postgres  [kernel.kallsyms]     [k] isolate_freepages_block
> +  21.08%             psql  [kernel.kallsyms]     [k] isolate_freepages_block
> +  20.72%       pg_restore  [kernel.kallsyms]     [k] isolate_freepages_block
> +   3.94%         postgres  postgres              [.] pglz_compress
> +   2.86%         postgres  [kernel.kallsyms]     [k]
> set_pageblock_flags_mask
> +   2.35%        bacula-fd  [kernel.kallsyms]     [k] isolate_freepages_block
> +   2.07%       pg_restore  [kernel.kallsyms]     [k]
> set_pageblock_flags_mask
> +   2.06%             psql  [kernel.kallsyms]     [k]
> set_pageblock_flags_mask
> +   1.56%         postgres  libc-2.15.so          [.] 0x000000000003c95f
> +   0.93%       irqbalance  [kernel.kallsyms]     [k] isolate_freepages_block
> +   0.88%       pg_restore  [kernel.kallsyms]     [k] isolate_freepages
> +   0.87%             psql  [kernel.kallsyms]     [k] isolate_freepages
> +   0.86%         postgres  [kernel.kallsyms]     [k] isolate_freepages
> +   0.81%         postgres  postgres              [.] 0x000000000027ff5b
> +   0.60%         postgres  [kernel.kallsyms]     [k]
> get_pageblock_flags_mask
> +   0.44%         proc_pri  [kernel.kallsyms]     [k] isolate_freepages_block
>
> Good situation .. sysload < 5%
>
> Samples: 509K of event 'cycles', Event count (approx.): 1635259826919
> +  21.14%         postgres  postgres                  [.] pglz_compress
> +  14.46%         postgres  postgres                  [.] 0x000000000016b643
> +  10.11%         postgres  libc-2.15.so              [.] 0x0000000000092f69
> +   5.74%         postgres  postgres                  [.] s_lock
> +   2.86%         postgres  postgres                  [.] LWLockAcquire
> +   2.51%       pg_restore  [kernel.kallsyms]         [k]
> isolate_freepages_block
> +   2.33%         postgres  postgres                  [.]
> NextCopyFromRawFields
> +   2.15%         postgres  postgres                  [.] LWLockRelease
> +   2.10%         postgres  postgres                  [.] _start
> +   1.93%         postgres  [kernel.kallsyms]         [k]
> copy_user_enhanced_fast_string
> +   1.70%         postgres  [kernel.kallsyms]         [k] change_pte_range
> +   1.61%         postgres  postgres                  [.] pg_verify_mbstr_len
> +   1.31%         postgres  postgres                  [.]
> hash_search_with_hash_value
> +   1.21%         postgres  libc-2.15.so              [.] __strcoll_l
> +   0.86%          kswapd0  [kernel.kallsyms]         [k]
> __mem_cgroup_uncharge_common
> +   0.72%         postgres  postgres                  [.] heap_fill_tuple
> +   0.68%        bacula-fd  [kernel.kallsyms]         [k]
> isolate_freepages_block
> +   0.66%         postgres  [kernel.kallsyms]         [k] clear_page_c_e
> +   0.63%       pg_restore  [kernel.kallsyms]         [k]
> copy_user_enhanced_fast_string
>
>
> Hugepages are disabled. All suggestions for configuration changes, etc are
> welcome?
>
> IO subsystem is not particulary busy in any of the situations. A sar
> output can be seen here:
> http://thread.gmane.org/gmane.linux.kernel/1908263
>
> Jesper

Hi Jesper, please take a look on
http://marc.info/?l=linux-mm&m=141605213522925&w=2, there is a long
and unfinished discussion as it seems very problematic to make a
deterministic reproduction of the bug in our environments. If you can
observe same lockups with more ease, it`ll help a lot in the issue
pinning and fixing.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
