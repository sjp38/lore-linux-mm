Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0CB87C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B6037216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B6037216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 839566B0006; Mon, 20 May 2019 10:00:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DAFF6B0008; Mon, 20 May 2019 10:00:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6C9936B000A; Mon, 20 May 2019 10:00:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0559D6B0006
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:21 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id 17so2628767lfr.14
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state
         :content-transfer-encoding:subject:from:to:date:message-id
         :user-agent:mime-version;
        bh=EMjV+tlHAXESqbWvGNp2RQ3d/yIclAx6Yis6R3laKyU=;
        b=i5RrHNVsCPYBuTKNFgcRvUh8YpIIy/NM+9q6fgPd9qtd1vVv4x0vJEKQdqJlbppbOZ
         tx0OqAvk+kd0UN0vEbLTcRQqShseqBb9941Msa7BE3amQ6uz3suUqDrpp2+IJHPrMoNJ
         rAc7H/m+EnJDiSKcYfpFISu6+Cyd6z4y69CPEY0LMqjZB3AnA/POhWj1W/8zinZziB1z
         X+S2z28B+6ZH89IpMywsHpMK3+QBnPp+btpHcFQuvou7X6fbeEmPlvHh4E4mN1e48tdn
         r3cDvgMLLoAfM1rFrarW1Et4j1JENCrZ1gpuFonxeKwchh08ZdT7qUKICldF5mGI1JLS
         iSIQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAV9tOjg2WK+fqV+wWcnpl2ZYAgE148Ju64XPoqfRguOfqHmjbTX
	8Pe2C9tzshmHboOSR6/Yq5WywPvQhEWP1GD2BlajcTLdLLK/q4U9EU2SRkCZXJwJwcWUTP80ZI8
	pg3a0SLZStiyIDSuSfre8pUrM83MrHJdkMRFhuDf1Sy7R+xgxUTdnDvZzuvaBWscdWQ==
X-Received: by 2002:a2e:9b0b:: with SMTP id u11mr23277896lji.57.1558360820335;
        Mon, 20 May 2019 07:00:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzZ3/ApKc5zTEQRfvh80KCZrBcZTWCyNpaM9OGk4V+jH6sN+TajSjHGw9N7wl1offF2DoiD
X-Received: by 2002:a2e:9b0b:: with SMTP id u11mr23277810lji.57.1558360818880;
        Mon, 20 May 2019 07:00:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360818; cv=none;
        d=google.com; s=arc-20160816;
        b=l3W3s+wA+3tEPtdIA0yLW6gJvclXEcS2yvGKJGzXqKtX8JgtuV+5t3/PnzjFe1xnSN
         OkLZ3cuuOtbsHgZt/qCk25xpb8yNs6GkgBz/TdwpzGXwU2W9agZaicAYqIk/IlEVZ+Jo
         FraKagHdcqC1qbe5Euuo4wrPAr1qTqZI1UlKtjSdKehNTugoZ5jwh6ANMwMt4Q2EPPsp
         S29tskO1i9UIOIpPGT98WsWt3BHsBe61R4v9bpIg743NkwUZJuZ1kNeJTd6knZ2Te543
         U47pEEO5EiKiNZ7CJ8bDRXRBBaKpabLLGnn3UYoA6/cTmni4urbtSfJ877TxRrxlt+zI
         RkGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:date:to:from:subject
         :content-transfer-encoding;
        bh=EMjV+tlHAXESqbWvGNp2RQ3d/yIclAx6Yis6R3laKyU=;
        b=SvcYST1dJsvAJCDU5CO0+vIuM5yOyYo8o2GtNjsEruljfEDNYuFaLjJF4cG/yqRPu9
         GsyAZKJ12zSwrGtsvRPHrtoKSmAgRlPFG8GLA8/T4O6oa5Znpc5GJ17iDrc1XgGBG24e
         JnBAoWFn5ywnCxn1t1pnI4TadDTnLpHH1wiVJ60+PnhuplFCP16rkqxtTN0d4UlEeC+h
         2diL5XLv+I/AJHEJaLcgb1WpwqdUPU5+6tjbt1CJ6+75lLdsmwYSrmReB0dd93uGXv8a
         jRBv+cQKy488ZptaglBD0DrLvBsHLiVdGRJDTpiTW+9PA+DKjR0dp3yaWhkafa3Zngkj
         WeOg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id r1si15618276lji.171.2019.05.20.07.00.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSipd-00082V-Un; Mon, 20 May 2019 17:00:02 +0300
Content-Transfer-Encoding: 7bit
Subject: [PATCH v2 0/7] mm: process_vm_mmap() -- syscall for duplication a
 process mapping
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:01 +0300
Message-ID: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

v2: Add PVMMAP_FIXED_NOREPLACE flag.
    Use find_vma_without_flags() and may_mmap_overlapped_region() helpers,
    so even more code became reused.
    Syscall number is changed.
    Fix whitespaces.

    Prohibited a cloning from local to remote process. Only mapping
    to local process mm is allowed, since I missed initially, that
    get_unmapped_area() can't be used for remote process. This may
    be very simply solved by passing @mm argument to all .get_unmapped_area
    handlers. In this patchset I don't do this, since this gives a lot
    of cleanup patches, which hides main logic away. I'm going to
    send them later, as another series, after we finish with this.

[Summary]

New syscall, which allows to clone a remote process VMA
into local process VM. The remote process's page table
entries related to the VMA are cloned into local process's
page table (in any desired address, which makes this different
from that happens during fork()). Huge pages are handled
appropriately.

This allows to improve performance in significant way like
it's shows in the example below.

[Description] 

This patchset adds a new syscall, which makes possible
to clone a VMA from a process to current process.
The syscall supplements the functionality provided
by process_vm_writev() and process_vm_readv() syscalls,
and it may be useful in many situation.

For example, it allows to make a zero copy of data,
when process_vm_writev() was previously used:

	struct iovec local_iov, remote_iov;
	void *buf;

	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
	recv(sock, buf, n * PAGE_SIZE, 0);

	local_iov->iov_base = buf;
	local_iov->iov_len = n * PAGE_SIZE;
	remove_iov = ...;

	process_vm_writev(pid, &local_iov, 1, &remote_iov, 1 0);
	munmap(buf, n * PAGE_SIZE);

	(Note, that above completely ignores error handling)

There are several problems with process_vm_writev() in this example:

1)it causes pagefault on remote process memory, and it forces
  allocation of a new page (if was not preallocated);

2)amount of memory for this example is doubled in a moment --
  n pages in current and n pages in remote tasks are occupied
  at the same time;

3)received data has no a chance to be properly swapped for
  a long time.

The third is the most critical in case of remote process touches
the data pages some time after process_vm_writev() was made.
Imagine, node is under memory pressure:

a)kernel moves @buf pages into swap right after recv();
b)process_vm_writev() reads the data back from swap to pages;
c)process_vm_writev() allocates duplicate pages in remote
  process and populates them;
d)munmap() unmaps @buf;
e)5 minutes later remote task touches data.

In stages "a" and "b" kernel submits unneeded IO and makes
system IO throughput worse. To make "b" and "c", kernel
reclaims memory, and moves pages of some other processes
to swap, so they have to read pages from swap back. Also,
unneeded copying of pages is occured, while zero-copy is
more preferred.

We observe similar problem during online migration of big enough
containers, when after doubling of container's size, the time
increases 100 times. The system resides under high IO and
throwing out of useful cashes.

The proposed syscall aims to introduce an interface, which
supplements currently existing process_vm_writev() and
process_vm_readv(), and allows to solve the problem with
anonymous memory transfer. The above example may be rewritten as:

[Task 1]
	void *buf;

	buf = mmap(NULL, n * PAGE_SIZE, PROT_READ|PROT_WRITE,
		   MAP_PRIVATE|MAP_ANONYMOUS, ...);
	recv(sock, buf, n * PAGE_SIZE, 0);

[Task 2]
	buf2 = process_vm_mmap(pid_of_task1, buf, n * PAGE_SIZE, NULL, 0);

This creates a copy of VMA related to buf from task1 in task2's VM.
Task1's page table entries are copied into corresponding page table
entries of VM of task2.

It is swap-friendly: in case of memory is swapped right after recv(),
the syscall just copies pagetable entries like we do on fork(),
so real access to pages does not occurs, and no IO is needed.
No excess pages are reclaimed, and number of pages is not doubled.
Also, zero-copy takes a place, and this also reduces overhead.

The patchset does not introduce much new code, since we simply
reuse existing copy_page_range() and copy_vma() functions.
We extend copy_vma() to be able merge VMAs in remote task [2/7],
and teach copy_page_range() to work with different local and
remote addresses [3/7]. Patch [7/7] introduces the syscall logic,
which mostly consists of sanity checks. The rest of patches
are preparations.

This syscall may be used for page servers like in example
above, for migration (I assume, even virtual machines may
want something like this), for zero-copy desiring users
of process_vm_writev() and process_vm_readv(), for debug
purposes, etc. It requires the same permittions like
existing proc_vm_xxx() syscalls have.

The tests I used may be obtained here (UPDATED):

[1]https://gist.github.com/tkhai/ce46502fc53580372da35e8c3b7818b9
[2]https://gist.github.com/tkhai/40bda78e304d2fe0d90863214b9ac5b5

Previous version (RFC):
[3]https://lore.kernel.org/lkml/CAG48ez0itiEE1x=SXeMbjKvMGkrj7wxjM6c+ZB00LpXAAhqmiw@mail.gmail.com/T/

---

Kirill Tkhai (7):
      mm: Add process_vm_mmap() syscall declaration
      mm: Extend copy_vma()
      mm: Extend copy_page_range()
      mm: Export round_hint_to_min()
      mm: Introduce may_mmap_overlapped_region() helper
      mm: Introduce find_vma_filter_flags() helper
      mm: Add process_vm_mmap()


 arch/x86/entry/syscalls/syscall_32.tbl |    1 
 arch/x86/entry/syscalls/syscall_64.tbl |    2 
 include/linux/huge_mm.h                |    6 +
 include/linux/mm.h                     |   14 ++
 include/linux/mm_types.h               |    2 
 include/linux/mman.h                   |   14 ++
 include/linux/syscalls.h               |    5 +
 include/uapi/asm-generic/mman-common.h |    6 +
 include/uapi/asm-generic/unistd.h      |    5 +
 init/Kconfig                           |    9 +-
 kernel/fork.c                          |    5 +
 kernel/sys_ni.c                        |    2 
 mm/huge_memory.c                       |   30 ++++-
 mm/memory.c                            |  165 +++++++++++++++++++---------
 mm/mmap.c                              |  186 ++++++++++++++++++++++++++------
 mm/mremap.c                            |   43 +++++--
 mm/process_vm_access.c                 |   69 ++++++++++++
 17 files changed, 439 insertions(+), 125 deletions(-)

--
Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>

