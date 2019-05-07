Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53013C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 11:51:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 01F2B206A3
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 11:51:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 01F2B206A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A994F6B0005; Tue,  7 May 2019 07:51:36 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A70B86B0006; Tue,  7 May 2019 07:51:36 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 985926B0007; Tue,  7 May 2019 07:51:36 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 760356B0005
	for <linux-mm@kvack.org>; Tue,  7 May 2019 07:51:36 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t5so17676053qkt.23
        for <linux-mm@kvack.org>; Tue, 07 May 2019 04:51:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:message-id:in-reply-to:references:subject:mime-version
         :content-transfer-encoding:thread-topic:thread-index;
        bh=d9AjF2kRLaWCgHWYH5t0YRLRyl3knCMHwYhBP23qWY0=;
        b=KpEXRVHpMIL/C3W1tpiMI/KepEbY5d2o+3CKRajOvFysVNDGUZh5rcEoL8CZ5HkrdX
         wjwRO+CtgddX+gpgz8H03IGYCvEX04YR8eTAh3ypV6O8HeCdW8lhlqvr8nCHQW3YqwIS
         S4mXRP/NHfV8lRSfxLjBVdYVCHnBXneZK8VRD17vQv1HLAB0pqQu4yjNbeHS1smpJTpb
         66ZXDfKXAU7adFs5AKXaTq6e31JbHLQLBc/xVrcdIWWxudkV78Ujk+CENfIJ6RhURPu1
         zwef6EZ8J63Kng+el0Ow2WelWuHPyEGW/f+9ousyhAkChgkiNtpiZLZOF2+cEf9VKRvd
         3tIg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAU+bHwbo7rw/Fg8IfAUEyAXF6r0vcsliXY2DMyxAqu6s+DLQJyH
	7isAO9OCTYG7nHdmlnPpTjlFiws4PX6ypl+bp4/pDtCswnuOAiRMWe2iRkoa2nN2kMHPyk3kpAW
	wsUtmqagpkYKbnaBbjmpHNcDxGmVm+956w7wagIlFYp3MSpQvtI2Lg/Xlig6RBSd7yg==
X-Received: by 2002:a37:ad14:: with SMTP id f20mr24833108qkm.147.1557229896138;
        Tue, 07 May 2019 04:51:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGMMhfftvC8FNbq2//rLACv55yVxmsTzLyps7X0IteZh1vlIYfjhuqAIvX09OTLPuRtSna
X-Received: by 2002:a37:ad14:: with SMTP id f20mr24833062qkm.147.1557229895039;
        Tue, 07 May 2019 04:51:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557229895; cv=none;
        d=google.com; s=arc-20160816;
        b=GbIqt1lKeKCmRMh+fwE+bnyoWC6klZfKGFJNaNOvbf6Xbv4Gn+KQ6gP6seZwJWTVTr
         rZdjmP+rdrvJUqdPCls/B1GEZAueqdq/1b4nRcr76z8LnyuWZLPayn2Lt7YYlaInBYBw
         qL6ZXt1sP/qqj6tcKDff4TKxBSJqrjeNiLuSDIR+xs4ACOP3O1WZd7kxjpE3/EvRKH49
         S9ZF9zXe4h6WFfeqPDCP7WI6q/fv8yZ45g1uNe+ssBj+Uc0nzGhj24e5cWMQajix1Sdd
         pRFI01e/U4RIGYiZlWf9R0hG70cEQicn3prJ05I8kRzO2yrWdOtgmV+qHM/qzInUbM8Y
         N/Yg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=thread-index:thread-topic:content-transfer-encoding:mime-version
         :subject:references:in-reply-to:message-id:cc:to:from:date;
        bh=d9AjF2kRLaWCgHWYH5t0YRLRyl3knCMHwYhBP23qWY0=;
        b=nNOOnE+AwR7YnP6U4c9Ox7d0crEk/Q5GaQb2o6LLS+iza7rQRM3sAFNoi9YyEvrmEd
         rihoX8M6yoX43G06/AXhV7SAq7OwSetCTiJ/wvwuQTxZLZOtqmcjApxYSgzhaxYmTDRI
         MmbQSK3TRzxQ2I2MMhRedITkG0OgfGuEAsvRLc4+3dKt52g9lGKFArPDJ1Ra+iiqqxHY
         hJL0Tch5v/i5mQdyn0vQs2IFUqLvK0UavXg8k1qgL+NJ7QuRIfoMBpEQeQuOztlxnBPK
         AhkkbU5MmbgM13f8QYQtZgP8BQRntBVkn8cYjtM8u285fl4JVk67GL96Kd36g2XY9HZ4
         tp5A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j1si2111855qvn.142.2019.05.07.04.51.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 May 2019 04:51:35 -0700 (PDT)
Received-SPF: pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jstancek@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jstancek@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id A7A4C307E04E;
	Tue,  7 May 2019 11:51:33 +0000 (UTC)
Received: from colo-mx.corp.redhat.com (colo-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.20])
	by smtp.corp.redhat.com (Postfix) with ESMTPS id 8E46B1001E99;
	Tue,  7 May 2019 11:51:33 +0000 (UTC)
Received: from zmail17.collab.prod.int.phx2.redhat.com (zmail17.collab.prod.int.phx2.redhat.com [10.5.83.19])
	by colo-mx.corp.redhat.com (Postfix) with ESMTP id B24FE18089CA;
	Tue,  7 May 2019 11:51:32 +0000 (UTC)
Date: Tue, 7 May 2019 07:51:29 -0400 (EDT)
From: Jan Stancek <jstancek@redhat.com>
To: Yang Shi <yang.shi@linux.alibaba.com>, will deacon <will.deacon@arm.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
Cc: kirill@shutemov.name, willy@infradead.org, 
	kirill shutemov <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, 
	Andrea Arcangeli <aarcange@redhat.com>, akpm@linux-foundation.org, 
	Waiman Long <longman@redhat.com>, 
	Mel Gorman <mgorman@techsingularity.net>, 
	Rik van Riel <riel@surriel.com>, 
	catalin marinas <catalin.marinas@arm.com>, 
	Jan Stancek <jstancek@redhat.com>
Message-ID: <756571293.21386229.1557229889545.JavaMail.zimbra@redhat.com>
In-Reply-To: <2b2006bf-753b-c4b8-e9a2-fd27ae65fe14@linux.alibaba.com>
References: <1817839533.20996552.1557065445233.JavaMail.zimbra@redhat.com> <a9d5efea-6088-67c5-8711-f0657a852813@linux.alibaba.com> <1928544225.21255545.1557178548494.JavaMail.zimbra@redhat.com> <2b2006bf-753b-c4b8-e9a2-fd27ae65fe14@linux.alibaba.com>
Subject: Re: [bug] aarch64: userspace stalls on page fault after
 dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
X-Originating-IP: [10.40.204.177, 10.4.195.24]
Thread-Topic: aarch64: userspace stalls on page fault after dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
Thread-Index: 0C22kbfcoytv/kDLi1w85tmBvAuqfA==
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.42]); Tue, 07 May 2019 11:51:34 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


----- Original Message -----
>=20
>=20
> On 5/6/19 2:35 PM, Jan Stancek wrote:
> >
> > ----- Original Message -----
> >>
> >> On 5/5/19 7:10 AM, Jan Stancek wrote:
> >>> Hi,
> >>>
> >>> I'm seeing userspace program getting stuck on aarch64, on kernels 4.2=
0
> >>> and
> >>> newer.
> >>> It stalls from seconds to hours.
> >>>
> >>> I have simplified it to following scenario (reproducer linked below [=
1]):
> >>>     while (1):
> >>>       spawn Thread 1: mmap, write, munmap
> >>>       spawn Thread 2: <nothing>
> >>>
> >>> Thread 1 is sporadically getting stuck on write to mapped area.
> >>> User-space
> >>> is not
> >>> moving forward - stdout output stops. Observed CPU usage is however 1=
00%.
> >>>
> >>> At this time, kernel appears to be busy handling page faults (~700k p=
er
> >>> second):
> >>>
> >>> # perf top -a -g
> >>> -   98.97%     8.30%  a.out                     [.] map_write_unmap
> >>>      - 23.52% map_write_unmap
> >>>         - 24.29% el0_sync
> >>>            - 10.42% do_mem_abort
> >>>               - 17.81% do_translation_fault
> >>>                  - 33.01% do_page_fault
> >>>                     - 56.18% handle_mm_fault
> >>>                          40.26% __handle_mm_fault
> >>>                          2.19% __ll_sc___cmpxchg_case_acq_4
> >>>                          0.87% mem_cgroup_from_task
> >>>                     - 6.18% find_vma
> >>>                          5.38% vmacache_find
> >>>                       1.35% __ll_sc___cmpxchg_case_acq_8
> >>>                       1.23% __ll_sc_atomic64_sub_return_release
> >>>                       0.78% down_read_trylock
> >>>              0.93% do_translation_fault
> >>>      + 8.30% thread_start
> >>>
> >>> #  perf stat -p 8189 -d
> >>> ^C
> >>>    Performance counter stats for process id '8189':
> >>>
> >>>           984.311350      task-clock (msec)         #    1.000 CPUs
> >>>           utilized
> >>>                    0      context-switches          #    0.000 K/sec
> >>>                    0      cpu-migrations            #    0.000 K/sec
> >>>              723,641      page-faults               #    0.735 M/sec
> >>>        2,559,199,434      cycles                    #    2.600 GHz
> >>>          711,933,112      instructions              #    0.28  insn p=
er
> >>>          cycle
> >>>      <not supported>      branches
> >>>              757,658      branch-misses
> >>>          205,840,557      L1-dcache-loads           #  209.121 M/sec
> >>>           40,561,529      L1-dcache-load-misses     #   19.71% of all
> >>>           L1-dcache hits
> >>>      <not supported>      LLC-loads
> >>>      <not supported>      LLC-load-misses
> >>>
> >>>          0.984454892 seconds time elapsed
> >>>
> >>> With some extra traces, it appears looping in page fault for same
> >>> address,
> >>> over and over:
> >>>     do_page_fault // mm_flags: 0x55
> >>>       __do_page_fault
> >>>         __handle_mm_fault
> >>>           handle_pte_fault
> >>>             ptep_set_access_flags
> >>>               if (pte_same(pte, entry))  // pte: e8000805060f53, entr=
y:
> >>>               e8000805060f53
> >>>
> >>> I had traces in mmap() and munmap() as well, they don't get hit when
> >>> reproducer
> >>> hits the bad state.
> >>>
> >>> Notes:
> >>> - I'm not able to reproduce this on x86.
> >>> - Attaching GDB or strace immediatelly recovers application from stal=
l.
> >>> - It also seems to recover faster when system is busy with other task=
s.
> >>> - MAP_SHARED vs. MAP_PRIVATE makes no difference.
> >>> - Turning off THP makes no difference.
> >>> - Reproducer [1] usually hits it within ~minute on HW described below=
.
> >>> - Longman mentioned that "When the rwsem becomes reader-owned, it cau=
ses
> >>>     all the spinning writers to go to sleep adding wakeup latency to
> >>>     the time required to finish the critical sections", but this look=
s
> >>>     like busy loop, so I'm not sure if it's related to rwsem issues
> >>>     identified
> >>>     in:
> >>>     https://lore.kernel.org/lkml/20190428212557.13482-2-longman@redha=
t.com/
> >> It sounds possible to me. What the optimization done by the commit ("m=
m:
> >> mmap: zap pages with read mmap_sem in munmap") is to downgrade write
> >> rwsem to read when zapping pages and page table in munmap() after the
> >> vmas have been detached from the rbtree.
> >>
> >> So the mmap(), which is writer, in your test may steal the lock and
> >> execute with the munmap(), which is the reader after the downgrade, in
> >> parallel to break the mutual exclusion.
> >>
> >> In this case, the parallel mmap() may map to the same area since vmas
> >> have been detached by munmap(), then mmap() may create the complete sa=
me
> >> vmas, and page fault happens on the same vma at the same address.
> >>
> >> I'm not sure why gdb or strace could recover this, but they use ptrace
> >> which may acquire mmap_sem to break the parallel inadvertently.
> >>
> >> May you please try Waiman's patch to see if it makes any difference?
> > I don't see any difference in behaviour after applying:
> >    [PATCH-tip v7 01/20] locking/rwsem: Prevent decrement of reader coun=
t
> >    before increment
> > Issue is still easily reproducible for me.
> >
> > I'm including output of mem_abort_decode() / show_pte() for sample PTE,
> > that
> > I see in page fault loop. (I went through all bits, but couldn't find
> > anything invalid about it)
> >
> >    mem_abort_decode: Mem abort info:
> >    mem_abort_decode:   ESR =3D 0x92000047
> >    mem_abort_decode:   Exception class =3D DABT (lower EL), IL =3D 32 b=
its
> >    mem_abort_decode:   SET =3D 0, FnV =3D 0
> >    mem_abort_decode:   EA =3D 0, S1PTW =3D 0
> >    mem_abort_decode: Data abort info:
> >    mem_abort_decode:   ISV =3D 0, ISS =3D 0x00000047
> >    mem_abort_decode:   CM =3D 0, WnR =3D 1
> >    show_pte: user pgtable: 64k pages, 48-bit VAs, pgdp =3D 000000006702=
7567
> >    show_pte: [0000ffff6dff0000] pgd=3D000000176bae0003
> >    show_pte: , pud=3D000000176bae0003
> >    show_pte: , pmd=3D000000174ad60003
> >    show_pte: , pte=3D00e80008023a0f53
> >    show_pte: , pte_pfn: 8023a
> >
> >    >>> print bin(0x47)
> >    0b1000111
> >
> >    Per D12-2779 (ARM Architecture Reference Manual),
> >        ISS encoding for an exception from an Instruction Abort:
> >      IFSC, bits [5:0], Instruction Fault Status Code
> >      0b000111 Translation fault, level 3
> >
> > ---
> >
> > My theory is that TLB is getting broken.

Theory continued:

unmap_region() is batching updates to TLB (for vmas and page tables).
And at the same time another thread handles page fault for same mm,
which increases "tlb_flush_pending".

tlb_finish_mmu() called from unmap_region() will thus set 'force =3D 1'.
And arch_tlb_finish_mmu() will in turn reset TLB range, presumably making
it smaller then it would be if force =3D=3D 0.

Change below appears to fix it:

diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index f2f03c655807..a4cef21bd62b 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -93,7 +93,7 @@ void arch_tlb_finish_mmu(struct mmu_gather *tlb,
        struct mmu_gather_batch *batch, *next;
=20
        if (force) {
-               __tlb_reset_range(tlb);
                __tlb_adjust_range(tlb, start, end - start);
        }

> >
> > I made a dummy kernel module that exports debugfs file, which on read
> > triggers:
> >    flush_tlb_all();
> >
> > Any time reproducer stalls and I read debugfs file, it recovers
> > immediately and resumes printing to stdout.
>=20
> That commit doesn't change anything about TLB flush, just move zapping
> pages under read mmap_sem as what MADV_DONTNEED does.
>=20
> I don't have aarch64 board to reproduce and debug it. And, I'm not
> familiar with aarch64 architecture either. But, some history told me the
> parallel zapping page may run into stale TLB and defer a flush meaning
> that this call may observe pte_none and fails to flush the TLB. But,
> this has been solved by commit 56236a59556c ("mm: refactor TLB gathering
> API") and 99baac21e458 ("mm: fix MADV_[FREE|DONTNEED] TLB flush miss
> problem").
>=20
> For more detail, please refer to commit 4647706ebeee ("mm: always flush
> VMA ranges affected by zap_page_range"). Copied Mel and Rik in this
> thread. Also added Will Deacon and Catalin Marinas, who are aarch64
> maintainers, in this loop

Thanks

>=20
> But, your test (triggering TLB flush) does demonstrate TLB flush is
> *not* done properly at some point as expected for aarch64. Could you
> please give the below patch a try?

Your patch also fixes my reproducer.

>=20
> diff --git a/mm/memory.c b/mm/memory.c
> index ab650c2..ef41ad5 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1336,8 +1336,10 @@ void unmap_vmas(struct mmu_gather *tlb,
>=20
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mmu_notifier_range_init(&rang=
e, vma->vm_mm, start_addr, end_addr);
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mmu_notifier_invalidate_range=
_start(&range);
> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for ( ; vma && vma->vm_start < end_=
addr; vma =3D vma->vm_next)
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 for ( ; vma && vma->vm_start < end_=
addr; vma =3D vma->vm_next) {
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 unmap_single_vma(tlb, vma, start_addr, end_addr, NULL);
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 flush_tlb_range(vma, start_addr, end_addr);
> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>  =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 mmu_notifier_invalidate_range=
_end(&range);
>  =C2=A0}
>=20
> >
> >>> - I tried 2 different aarch64 systems so far: APM X-Gene CPU Potenza =
A3
> >>> and
> >>>     Qualcomm 65-LA-115-151.
> >>>     I can reproduce it on both with v5.1-rc7. It's easier to reproduc=
e
> >>>     on latter one (for longer periods of time), which has 46 CPUs.
> >>> - Sample output of reproducer on otherwise idle system:
> >>>     # ./a.out
> >>>     [00000314] map_write_unmap took: 26305 ms
> >>>     [00000867] map_write_unmap took: 13642 ms
> >>>     [00002200] map_write_unmap took: 44237 ms
> >>>     [00002851] map_write_unmap took: 992 ms
> >>>     [00004725] map_write_unmap took: 542 ms
> >>>     [00006443] map_write_unmap took: 5333 ms
> >>>     [00006593] map_write_unmap took: 21162 ms
> >>>     [00007435] map_write_unmap took: 16982 ms
> >>>     [00007488] map_write unmap took: 13 ms^C
> >>>
> >>> I ran a bisect, which identified following commit as first bad one:
> >>>     dd2283f2605e ("mm: mmap: zap pages with read mmap_sem in munmap")
> >>>
> >>> I can also make the issue go away with following change:
> >>> diff --git a/mm/mmap.c b/mm/mmap.c
> >>> index 330f12c17fa1..13ce465740e2 100644
> >>> --- a/mm/mmap.c
> >>> +++ b/mm/mmap.c
> >>> @@ -2844,7 +2844,7 @@ EXPORT_SYMBOL(vm_munmap);
> >>>    SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
> >>>    {
> >>>           profile_munmap(addr);
> >>> -       return __vm_munmap(addr, len, true);
> >>> +       return __vm_munmap(addr, len, false);
> >>>    }
> >>>
> >>> # cat /proc/cpuinfo  | head
> >>> processor       : 0
> >>> BogoMIPS        : 40.00
> >>> Features        : fp asimd evtstrm aes pmull sha1 sha2 crc32 cpuid
> >>> asimdrdm
> >>> CPU implementer : 0x51
> >>> CPU architecture: 8
> >>> CPU variant     : 0x0
> >>> CPU part        : 0xc00
> >>> CPU revision    : 1
> >>>
> >>> # numactl -H
> >>> available: 1 nodes (0)
> >>> node 0 cpus: 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 =
22
> >>> 23
> >>> 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45
> >>> node 0 size: 97938 MB
> >>> node 0 free: 95732 MB
> >>> node distances:
> >>> node   0
> >>>     0:  10
> >>>
> >>> Regards,
> >>> Jan
> >>>
> >>> [1]
> >>> https://github.com/jstancek/reproducers/blob/master/kernel/page_fault=
_stall/mmap5.c
> >>> [2]
> >>> https://github.com/jstancek/reproducers/blob/master/kernel/page_fault=
_stall/config
> >>
>=20
>=20

