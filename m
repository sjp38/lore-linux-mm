Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS,
	UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DDED6C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:05:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0AF2220830
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 19:05:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0AF2220830
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=linux.alibaba.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 54D8D6B026C; Mon,  6 May 2019 15:05:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4FFC96B026D; Mon,  6 May 2019 15:05:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3EDB16B026F; Mon,  6 May 2019 15:05:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 08D2B6B026C
	for <linux-mm@kvack.org>; Mon,  6 May 2019 15:05:12 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id s19so7672165plp.6
        for <linux-mm@kvack.org>; Mon, 06 May 2019 12:05:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-transfer-encoding:content-language;
        bh=nDDOjS/FRz7WvoetKmH147+0M+0Xk9mQRKqNTo7WzKY=;
        b=mB+fdUFh56bUSXxobyilEn9N/Iqat22g69lxpTuR3q1cAONZUfABYiqCyo+ikoF7X1
         UPCfD/fkp30rcHbhB8MknnxgugBhdNPgYnL1JjRATojAxsjpDITcfMkPNLlwx0aMo6f6
         f0jMpdhYUiWP0SBpla8jMdY82vXzFGhcqV0DCb9Q/aHXyyro8QlWEvEu4dWQGaEDXaAm
         rp8v7Z7PAWeHh3DtBBzLsrFrXzOR9i4Kw0C6Lk52zxm//tPCaRBKGM1skUn8jeO4Rc5p
         r19hmKsoQZiv5yy4PlqKlcVc8fjipqKAQuSfB3bNTwokcLSkxUk3M42U5IvInaanA3DN
         LwWA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Gm-Message-State: APjAAAX+Pcs/UlUC4si2nRQwMIsTCXtpQBIuTtWeH2cU9tt9FKDIdUOg
	ydxxyjlzKriZphZGp5nvrMh90RqKaOl3SsP3qRx1PTtJFR3yUC6ERMwTz4+BGoSDRqdAnqwRH4X
	3mntIg3X455IKBdO7B5jC5xJdT6m85XVeIt38x6KWYK3cLLb2QlNLtCDDD+R0cjB8PA==
X-Received: by 2002:a63:191b:: with SMTP id z27mr34402610pgl.327.1557169511544;
        Mon, 06 May 2019 12:05:11 -0700 (PDT)
X-Google-Smtp-Source: APXvYqysEe4+YDcY38uuSa8qoTXckMIYQNWMdxIEGdWlPv4Wh2PomnHoLJWZws8t0dcmHysTN8Rv
X-Received: by 2002:a63:191b:: with SMTP id z27mr34402440pgl.327.1557169510266;
        Mon, 06 May 2019 12:05:10 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557169510; cv=none;
        d=google.com; s=arc-20160816;
        b=AcMsWNbNnltQAy48YWW+UP35oYQ438saSLQpCIeC4mNJ//Gjp/lBZ+hnrhYfkzXqYJ
         vhClSKOnK8nYYMvxG3QKQmWX+meHQ9K5tOir4jAGxK64mSYrtgo/JQbBanUaZ25qoM0s
         OoqAfOPbPsrOPJcDcciIwN8dnBWIa/pr/3b8DHUISS3dJTFFImJGxQi874A7ZKSZbDC7
         1ZUgXNz4j0L41wIq7MJcDxxkDyzecYuC74QDnLmTXBht3RDElkvDkJA6B1qYp3Kqb/2W
         bZfaT1nzw12xr2esd2ZQZ7QWgZIGY9Arkd+4KJ92OyMshkJZlr0vMFZGppArSPigDHiW
         LhvA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:content-transfer-encoding:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=nDDOjS/FRz7WvoetKmH147+0M+0Xk9mQRKqNTo7WzKY=;
        b=R2BYkpg5rRHbtv065Qw1ArGI79Qg455m3sN2wXXQiYTW7ezLDfcEdRiivJtfSANVcR
         MY/10bYZmO6PMBvpdmbXLx6TS3KjG4grfGxtfWv2bQ5X4UWP56qOVbWfgo4X1sW7OfS+
         xJqm5gy/sxAzlzpxxOnDqtlZpoV5RXv2x6afjQahkh/yb/mCNJSE+XTugnsxbQ+u9I4X
         t9Jms7zzy6yjk4czlBa3iCglERPK7YF3od4SQm3zhpHqpt3r3GI34ZqfaaYI/EtToown
         LdEQ7EnFBMhGnjCDqyEbvctFFFUWp++5MXjn6F7WxcKRt/deYVGXrtNT1EDU8WAH9Khc
         iLuw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
Received: from out30-45.freemail.mail.aliyun.com (out30-45.freemail.mail.aliyun.com. [115.124.30.45])
        by mx.google.com with ESMTPS id u12si5725042pgj.145.2019.05.06.12.05.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 12:05:10 -0700 (PDT)
Received-SPF: pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) client-ip=115.124.30.45;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of yang.shi@linux.alibaba.com designates 115.124.30.45 as permitted sender) smtp.mailfrom=yang.shi@linux.alibaba.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=alibaba.com
X-Alimail-AntiSpam:AC=PASS;BC=-1|-1;BR=01201311R171e4;CH=green;DM=||false|;FP=0|-1|-1|-1|0|-1|-1|-1;HT=e01e01422;MF=yang.shi@linux.alibaba.com;NM=1;PH=DS;RN=10;SR=0;TI=SMTPD_---0TR3YQ05_1557169494;
Received: from US-143344MP.local(mailfrom:yang.shi@linux.alibaba.com fp:SMTPD_---0TR3YQ05_1557169494)
          by smtp.aliyun-inc.com(127.0.0.1);
          Tue, 07 May 2019 03:05:07 +0800
Subject: Re: [bug] aarch64: userspace stalls on page fault after dd2283f2605e
 ("mm: mmap: zap pages with read mmap_sem in munmap")
To: Jan Stancek <jstancek@redhat.com>, linux-mm@kvack.org,
 linux-arm-kernel@lists.infradead.org
Cc: kirill@shutemov.name, willy@infradead.org,
 kirill shutemov <kirill.shutemov@linux.intel.com>, vbabka@suse.cz,
 Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org,
 Waiman Long <longman@redhat.com>
References: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com>
From: Yang Shi <yang.shi@linux.alibaba.com>
Message-ID: <a9d5efea-6088-67c5-8711-f0657a852813@linux.alibaba.com>
Date: Mon, 6 May 2019 12:04:53 -0700
User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.12; rv:52.0)
 Gecko/20100101 Thunderbird/52.7.0
MIME-Version: 1.0
In-Reply-To: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



On 5/5/19 7:10 AM, Jan Stancek wrote:
> Hi,
>
> I'm seeing userspace program getting stuck on aarch64, on kernels 4.20 and newer.
> It stalls from seconds to hours.
>
> I have simplified it to following scenario (reproducer linked below [1]):
>    while (1):
>      spawn Thread 1: mmap, write, munmap
>      spawn Thread 2: <nothing>
>
> Thread 1 is sporadically getting stuck on write to mapped area. User-space is not
> moving forward - stdout output stops. Observed CPU usage is however 100%.
>
> At this time, kernel appears to be busy handling page faults (~700k per second):
>
> # perf top -a -g
> -   98.97%     8.30%  a.out                     [.] map_write_unmap
>     - 23.52% map_write_unmap
>        - 24.29% el0_sync
>           - 10.42% do_mem_abort
>              - 17.81% do_translation_fault
>                 - 33.01% do_page_fault
>                    - 56.18% handle_mm_fault
>                         40.26% __handle_mm_fault
>                         2.19% __ll_sc___cmpxchg_case_acq_4
>                         0.87% mem_cgroup_from_task
>                    - 6.18% find_vma
>                         5.38% vmacache_find
>                      1.35% __ll_sc___cmpxchg_case_acq_8
>                      1.23% __ll_sc_atomic64_sub_return_release
>                      0.78% down_read_trylock
>             0.93% do_translation_fault
>     + 8.30% thread_start
>
> #  perf stat -p 8189 -d
> ^C
>   Performance counter stats for process id '8189':
>
>          984.311350      task-clock (msec)         #    1.000 CPUs utilized
>                   0      context-switches          #    0.000 K/sec
>                   0      cpu-migrations            #    0.000 K/sec
>             723,641      page-faults               #    0.735 M/sec
>       2,559,199,434      cycles                    #    2.600 GHz
>         711,933,112      instructions              #    0.28  insn per cycle
>     <not supported>      branches
>             757,658      branch-misses
>         205,840,557      L1-dcache-loads           #  209.121 M/sec
>          40,561,529      L1-dcache-load-misses     #   19.71% of all L1-dcache hits
>     <not supported>      LLC-loads
>     <not supported>      LLC-load-misses
>
>         0.984454892 seconds time elapsed
>
> With some extra traces, it appears looping in page fault for same address, over and over:
>    do_page_fault // mm_flags: 0x55
>      __do_page_fault
>        __handle_mm_fault
>          handle_pte_fault
>            ptep_set_access_flags
>              if (pte_same(pte, entry))  // pte: e8000805060f53, entry: e8000805060f53
>
> I had traces in mmap() and munmap() as well, they don't get hit when reproducer
> hits the bad state.
>
> Notes:
> - I'm not able to reproduce this on x86.
> - Attaching GDB or strace immediatelly recovers application from stall.
> - It also seems to recover faster when system is busy with other tasks.
> - MAP_SHARED vs. MAP_PRIVATE makes no difference.
> - Turning off THP makes no difference.
> - Reproducer [1] usually hits it within ~minute on HW described below.
> - Longman mentioned that "When the rwsem becomes reader-owned, it causes
>    all the spinning writers to go to sleep adding wakeup latency to
>    the time required to finish the critical sections", but this looks
>    like busy loop, so I'm not sure if it's related to rwsem issues identified
>    in: https://lore.kernel.org/lkml/20190428212557.13482-2-longman@redhat.com/

It sounds possible to me. What the optimization done by the commit ("mm: 
mmap: zap pages with read mmap_sem in munmap") is to downgrade write 
rwsem to read when zapping pages and page table in munmap() after the 
vmas have been detached from the rbtree.

So the mmap(), which is writer, in your test may steal the lock and 
execute with the munmap(), which is the reader after the downgrade, in 
parallel to break the mutual exclusion.

In this case, the parallel mmap() may map to the same area since vmas 
have been detached by munmap(), then mmap() may create the complete same 
vmas, and page fault happens on the same vma at the same address.

I'm not sure why gdb or strace could recover this, but they use ptrace 
which may acquire mmap_sem to break the parallel inadvertently.

May you please try Waiman's patch to see if it makes any difference?

> - I tried 2 different aarch64 systems so far: APM X-Gene CPU Potenza A3 and
>    Qualcomm 65-LA-115-151.
>    I can reproduce it on both with v5.1-rc7. It's easier to reproduce
>    on latter one (for longer periods of time), which has 46 CPUs.
> - Sample output of reproducer on otherwise idle system:
>    # ./a.out
>    [00000314] map_write_unmap took: 26305 ms
>    [00000867] map_write_unmap took: 13642 ms
>    [00002200] map_write_unmap took: 44237 ms
>    [00002851] map_write_unmap took: 992 ms
>    [00004725] map_write_unmap took: 542 ms
>    [00006443] map_write_unmap took: 5333 ms
>    [00006593] map_write_unmap took: 21162 ms
>    [00007435] map_write_unmap took: 16982 ms
>    [00007488] map_write unmap took: 13 ms^C
>
> I ran a bisect, which identified following commit as first bad one:
>    dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
>
> I can also make the issue go away with following change:
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 330f12c17fa1..13ce465740e2 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2844,7 +2844,7 @@ EXPORT_SYMBOL(vm_munmap);
>   SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
>   {
>          profile_munmap(addr);
> -       return __vm_munmap(addr, len, true);
> +       return __vm_munmap(addr, len, false);
>   }
>
> # cat /proc/cpuinfo  | head
> processor       : 0
> BogoMIPS        : 40.00
> Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid asimdrdm
> CPU implementer : 0x51
> CPU architecture: 8
> CPU variant     : 0x0
> CPU part        : 0xc00
> CPU revision    : 1
>
> # numactl -H
> available: 1 nodes (0)
> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
> node 0 size: 97938 MB
> node 0 free: 95732 MB
> node distances:
> node   0
>    0:  10
>
> Regards,
> Jan
>
> [1] https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/mmap5.c
> [2] https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/config

