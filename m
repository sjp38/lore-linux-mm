Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A3550C04A6B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 21:35:57 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3601B2053B
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 21:35:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3601B2053B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 94A8A6B000C; Mon,  6 May 2019 17:35:56 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FDE56B026A; Mon,  6 May 2019 17:35:56 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7C3276B026B; Mon,  6 May 2019 17:35:56 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9526B000C
	for <linux-mm@kvack.org>; Mon,  6 May 2019 17:35:56 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id u15so15835025qkj.12
        for <linux-mm@kvack.org>; Mon, 06 May 2019 14:35:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=JRPdQmhQPVbgYYQ9zDvEH1pqyYoDjSkcprpKERB6T0g=;
        b=JwegQO8U88SwUL6ST6J4WYqBGp1c5wlGQzreI+Sn++514PO7nMFLeeYw7MO2ymAuLd
         7qVuZ/wyss8rYJM+4g8NtSlifLQYMXvlI5uh6O+gS4XOJ7FMm2MjrCZEhfP6WDVnE5Fa
         DjIS1rOTpoEioC6buqvh74GxqZAiXJd6gUClh9QKN+rJ7HWe5VVNtK0Pv9OfjeZ7VqZp
         wIbTg7/0xbCTquE1B/hhwX4mRdhDraHd7DMYG93w9hO3lNkoMkVKgm6x94JNrO9eQWpQ
         H1xgzd1LYVjiqVcbaFKBvrYbd6H2drjlImqO99sdV7wFqll+yUGvaCCFbI4AsE9lVcAm
         18Gg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAUXyV1pC/XpGGie2u47985/pF7lOL4UNtZ3XmwdTfehjV2smg1S
	nJ5yu9ggXEkL50jVgMkvQhLG05iC4G2Fmnt7/wHBvVmbUMXA9fJSo1PrSRBKODdrzB5rkHZkgEL
	Bg2RKluHj/79pwGy00cFe4bAzMjs+vTY/p9WOhkqELa0fksxcNQrQZqgBt+y0tPyXkQ==
X-Received: by 2002:aed:24a3:: with SMTP id t32mr23349861qtc.206.1557178556065;
        Mon, 06 May 2019 14:35:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpaLTIGhwtXlBs2FF8lToM1xNhoGYUU4A3sJENQE6iHoIoaEI35DOYxvOt/mwVJo039S8y
X-Received: by 2002:aed:24a3:: with SMTP id t32mr23349785qtc.206.1557178554984;
        Mon, 06 May 2019 14:35:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557178554; cv=none;
        d=google.com; s=arc-20160816;
        b=tjJwVcxuXlqhiaGpXYZvTsfgPdtBENeyp0gPBzpde4r6caBOLY7UqNebTR+QZLRoms
         rwARr7K8QQFzb5ysGOv/rGufl4SkZvPKBSP9F0yo9wfFhGn6BIkkcuTLQejDRw6GsVCA
         Cvgaz5I+P6jSk4y7B6iiKSAlBx+njqDyEkfyGncHSzWbARcRidX73b01dDsP88ZDe42I
         S46ctVmXLUAr0fNmYHWJj8JvCIBWJ37Bs90TzoGQRIIApjWztIrapTAxcA37hz5a0YaU
         NCWbTcTKI/MJHc/LtxnNw29E+H5lNtoxzY1oEcc7FdZwMqYQOkbU3KWyky7pIs0Vv/l1
         KZfw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=JRPdQmhQPVbgYYQ9zDvEH1pqyYoDjSkcprpKERB6T0g=;
        b=YDeVjt8z+ndzDldcVjpWhD6E4mn05LhzcMVbeeKPi0j7FMQNBEB4F+n4mh9WHCzUmZ
         VxcpHq6DhboZgOi0qAgicgM5ss+quGhQd5CYPyyG1jov2B7ip31Eg7iFr3GE1Fkmd9OY
         5XJ2XMBnVnyUencgXWTx7nUvnuK9bqCc0EtGlpbwkwlsMU5EkHCLbmrRdOEXUOuBf2PY
         bOO8o/CuLkwRgVW2nPuerjjTVF2Tdp/TVGMx/fOeZZIkW4K2PEYWb8wV5s4qMqgtcHjG
         1e71cTkxu6e7Nss5bXXcYOxJkAefVsmSfgxFdd8uZOmmw5SU4HCtV2mWlavIsu1WX2L0
         fNCA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 2si7428297qtv.11.2019.05.06.14.35.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 May 2019 14:35:54 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id C1A02308FEE2;
	Mon,  6 May 2019 21:35:53 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.21])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id A58325C1B5;
	Mon,  6 May 2019 21:35:52 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id 74EE641F3C;
	Mon,  6 May 2019 21:35:51 +0000 (UTC)
Date: Mon, 6 May 2019 17:35:48 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Yang Shi <yang.shi@linux.alibaba.com>, linux-mm@kvack.org, 
	linux-arm-kernel@lists.infradead.org
Cc: kirill@shutemov.name, willy@infradead.org, 
	kirill shutemov <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, 
	Waiman Long <longman@redhat.com>, Jan Stancek <jstancek@redhat.com>
Message-ID: <1928544225.21255545.1557178548494.JavaMail.zimbra@redhat.com>
In-Reply-To: <a9d5efea-6088-67c5-8711-f0657a852813@linux.alibaba.com>
References: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com> <a9d5efea-6088-67c5-8711-f0657a852813@linux.alibaba.com>
Subject: Re: [bug] aarch64: userspace stalls on page fault after
 dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
X-Originating-IP: [10.40.204.21, 10.4.195.14]
Thread-Topic: aarch64: userspace stalls on page fault after dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Thread-Index: Hqz3G0R+UjL/FIWX5jRPpgcdI4xikA==
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Mon, 06 May 2019 21:35:54 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



----- Original Message -----
> 
> 
> On 5/5/19 7:10 AM, Jan Stancek wrote:
> > Hi,
> >
> > I'm seeing userspace program getting stuck on aarch64, on kernels 4.20 and
> > newer.
> > It stalls from seconds to hours.
> >
> > I have simplified it to following scenario (reproducer linked below [1]):
> >    while (1):
> >      spawn Thread 1: mmap, write, munmap
> >      spawn Thread 2: <nothing>
> >
> > Thread 1 is sporadically getting stuck on write to mapped area. User-space
> > is not
> > moving forward - stdout output stops. Observed CPU usage is however 100%.
> >
> > At this time, kernel appears to be busy handling page faults (~700k per
> > second):
> >
> > # perf top -a -g
> > -   98.97%     8.30%  a.out                     [.] map_write_unmap
> >     - 23.52% map_write_unmap
> >        - 24.29% el0_sync
> >           - 10.42% do_mem_abort
> >              - 17.81% do_translation_fault
> >                 - 33.01% do_page_fault
> >                    - 56.18% handle_mm_fault
> >                         40.26% __handle_mm_fault
> >                         2.19% __ll_sc___cmpxchg_case_acq_4
> >                         0.87% mem_cgroup_from_task
> >                    - 6.18% find_vma
> >                         5.38% vmacache_find
> >                      1.35% __ll_sc___cmpxchg_case_acq_8
> >                      1.23% __ll_sc_atomic64_sub_return_release
> >                      0.78% down_read_trylock
> >             0.93% do_translation_fault
> >     + 8.30% thread_start
> >
> > #  perf stat -p 8189 -d
> > ^C
> >   Performance counter stats for process id '8189':
> >
> >          984.311350      task-clock (msec)         #    1.000 CPUs utilized
> >                   0      context-switches          #    0.000 K/sec
> >                   0      cpu-migrations            #    0.000 K/sec
> >             723,641      page-faults               #    0.735 M/sec
> >       2,559,199,434      cycles                    #    2.600 GHz
> >         711,933,112      instructions              #    0.28  insn per
> >         cycle
> >     <not supported>      branches
> >             757,658      branch-misses
> >         205,840,557      L1-dcache-loads           #  209.121 M/sec
> >          40,561,529      L1-dcache-load-misses     #   19.71% of all
> >          L1-dcache hits
> >     <not supported>      LLC-loads
> >     <not supported>      LLC-load-misses
> >
> >         0.984454892 seconds time elapsed
> >
> > With some extra traces, it appears looping in page fault for same address,
> > over and over:
> >    do_page_fault // mm_flags: 0x55
> >      __do_page_fault
> >        __handle_mm_fault
> >          handle_pte_fault
> >            ptep_set_access_flags
> >              if (pte_same(pte, entry))  // pte: e8000805060f53, entry:
> >              e8000805060f53
> >
> > I had traces in mmap() and munmap() as well, they don't get hit when
> > reproducer
> > hits the bad state.
> >
> > Notes:
> > - I'm not able to reproduce this on x86.
> > - Attaching GDB or strace immediatelly recovers application from stall.
> > - It also seems to recover faster when system is busy with other tasks.
> > - MAP_SHARED vs. MAP_PRIVATE makes no difference.
> > - Turning off THP makes no difference.
> > - Reproducer [1] usually hits it within ~minute on HW described below.
> > - Longman mentioned that "When the rwsem becomes reader-owned, it causes
> >    all the spinning writers to go to sleep adding wakeup latency to
> >    the time required to finish the critical sections", but this looks
> >    like busy loop, so I'm not sure if it's related to rwsem issues
> >    identified
> >    in:
> >    https://lore.kernel.org/lkml/20190428212557.13482-2-longman@redhat.com/
> 
> It sounds possible to me. What the optimization done by the commit ("mm:
> mmap: zap pages with read mmap_sem in munmap") is to downgrade write
> rwsem to read when zapping pages and page table in munmap() after the
> vmas have been detached from the rbtree.
> 
> So the mmap(), which is writer, in your test may steal the lock and
> execute with the munmap(), which is the reader after the downgrade, in
> parallel to break the mutual exclusion.
> 
> In this case, the parallel mmap() may map to the same area since vmas
> have been detached by munmap(), then mmap() may create the complete same
> vmas, and page fault happens on the same vma at the same address.
> 
> I'm not sure why gdb or strace could recover this, but they use ptrace
> which may acquire mmap_sem to break the parallel inadvertently.
> 
> May you please try Waiman's patch to see if it makes any difference?

I don't see any difference in behaviour after applying:
  [PATCH-tip v7 01/20] locking/rwsem: Prevent decrement of reader count before increment
Issue is still easily reproducible for me.

I'm including output of mem_abort_decode() / show_pte() for sample PTE, that
I see in page fault loop. (I went through all bits, but couldn't find anything invalid about it)

  mem_abort_decode: Mem abort info:
  mem_abort_decode:   ESR = 0x92000047
  mem_abort_decode:   Exception class = DABT (lower EL), IL = 32 bits
  mem_abort_decode:   SET = 0, FnV = 0
  mem_abort_decode:   EA = 0, S1PTW = 0
  mem_abort_decode: Data abort info:
  mem_abort_decode:   ISV = 0, ISS = 0x00000047
  mem_abort_decode:   CM = 0, WnR = 1
  show_pte: user pgtable: 64k pages, 48-bit VAs, pgdp = 0000000067027567
  show_pte: [0000ffff6dff0000] pgd=000000176bae0003
  show_pte: , pud=000000176bae0003
  show_pte: , pmd=000000174ad60003
  show_pte: , pte=00e80008023a0f53
  show_pte: , pte_pfn: 8023a

  >>> print bin(0x47)
  0b1000111

  Per D12-2779 (ARM Architecture Reference Manual),
      ISS encoding for an exception from an Instruction Abort:
    IFSC, bits [5:0], Instruction Fault Status Code
    0b000111 Translation fault, level 3

---

My theory is that TLB is getting broken.

I made a dummy kernel module that exports debugfs file, which on read triggers:
  flush_tlb_all();

Any time reproducer stalls and I read debugfs file, it recovers
immediately and resumes printing to stdout.

> 
> > - I tried 2 different aarch64 systems so far: APM X-Gene CPU Potenza A3 and
> >    Qualcomm 65-LA-115-151.
> >    I can reproduce it on both with v5.1-rc7. It's easier to reproduce
> >    on latter one (for longer periods of time), which has 46 CPUs.
> > - Sample output of reproducer on otherwise idle system:
> >    # ./a.out
> >    [00000314] map_write_unmap took: 26305 ms
> >    [00000867] map_write_unmap took: 13642 ms
> >    [00002200] map_write_unmap took: 44237 ms
> >    [00002851] map_write_unmap took: 992 ms
> >    [00004725] map_write_unmap took: 542 ms
> >    [00006443] map_write_unmap took: 5333 ms
> >    [00006593] map_write_unmap took: 21162 ms
> >    [00007435] map_write_unmap took: 16982 ms
> >    [00007488] map_write unmap took: 13 ms^C
> >
> > I ran a bisect, which identified following commit as first bad one:
> >    dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
> >
> > I can also make the issue go away with following change:
> > diff --git a/mm/mmap.c b/mm/mmap.c
> > index 330f12c17fa1..13ce465740e2 100644
> > --- a/mm/mmap.c
> > +++ b/mm/mmap.c
> > @@ -2844,7 +2844,7 @@ EXPORT_SYMBOL(vm_munmap);
> >   SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
> >   {
> >          profile_munmap(addr);
> > -       return __vm_munmap(addr, len, true);
> > +       return __vm_munmap(addr, len, false);
> >   }
> >
> > # cat /proc/cpuinfo  | head
> > processor       : 0
> > BogoMIPS        : 40.00
> > Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid asimdrdm
> > CPU implementer : 0x51
> > CPU architecture: 8
> > CPU variant     : 0x0
> > CPU part        : 0xc00
> > CPU revision    : 1
> >
> > # numactl -H
> > available: 1 nodes (0)
> > node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23
> > 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
> > node 0 size: 97938 MB
> > node 0 free: 95732 MB
> > node distances:
> > node   0
> >    0:  10
> >
> > Regards,
> > Jan
> >
> > [1]
> > https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/mmap5.c
> > [2]
> > https://github.com/jstancek/reproducers/blob/master/kernel/page_fault_stall/config
> 
> 

