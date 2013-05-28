Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id 764906B0032
	for <linux-mm@kvack.org>; Tue, 28 May 2013 03:11:40 -0400 (EDT)
Received: by mail-lb0-f174.google.com with SMTP id u10so7271953lbi.5
        for <linux-mm@kvack.org>; Tue, 28 May 2013 00:11:38 -0700 (PDT)
Message-ID: <51A45861.1010008@gmail.com>
Date: Tue, 28 May 2013 11:10:25 +0400
From: Max Filippov <jcmvbkbc@gmail.com>
MIME-Version: 1.0
Subject: Re: TLB and PTE coherency during munmap
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com> <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
In-Reply-To: <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org
Cc: Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>

On Sun, May 26, 2013 at 6:50 AM, Max Filippov <jcmvbkbc@gmail.com> wrote:
> Hello arch and mm people.
>
> Is it intentional that threads of a process that invoked munmap syscall
> can see TLB entries pointing to already freed pages, or it is a bug?
>
> I'm talking about zap_pmd_range and zap_pte_range:
>
>       zap_pmd_range
>         zap_pte_range
>           arch_enter_lazy_mmu_mode
>             ptep_get_and_clear_full
>             tlb_remove_tlb_entry
>             __tlb_remove_page
>           arch_leave_lazy_mmu_mode
>         cond_resched
>
> With the default arch_{enter,leave}_lazy_mmu_mode, tlb_remove_tlb_entry
> and __tlb_remove_page there is a loop in the zap_pte_range that clears
> PTEs and frees corresponding pages, but doesn't flush TLB, and
> surrounding loop in the zap_pmd_range that calls cond_resched. If a thread
> of the same process gets scheduled then it is able to see TLB entries
> pointing to already freed physical pages.
>
> I've noticed that with xtensa arch when I added a test before returning to
> userspace checking that TLB contents agrees with page tables of the
> current mm. This check reliably fires with the LTP test mtest05 that
> maps, unmaps and accesses memory from multiple threads.
>
> Is there anything wrong in my description, maybe something specific to
> my arch, or this issue really exists?

Hi,

I've made similar checking function for MIPS (because qemu is my only choice
and it simulates MIPS TLB) and ran my tests on mips-malta machine in qemu.
With MIPS I can also see this issue. I hope I did it right, the patch at the
bottom is for the reference. The test I run and the diagnostic output are as
follows:

# ./runltp -p -q -T 100 -s mtest05
...
mmstress    0  TINFO  :  test2: Test case tests the race condition between simultaneous write faults in the same address space.
[  439.010000] 14: 70d68000: 03178000/00000000
mmstress    2  TPASS  :  TEST 2 Passed
...
mmstress    0  TINFO  :  test2: Test case tests the race condition between simultaneous write faults in the same address space.
[  947.390000] 10: 6f9d2000: 03639000/00000000
[  947.390000] 10: 6f9d3000: 03638000/00000000
mmstress    2  TPASS  :  TEST 2 Passed
...
mmstress    0  TINFO  :  test1: Test case tests the race condition between simultaneous read faults in the same address space.
[ 1922.680000] 10: 68e12000: 03b59000/00000000
[ 1922.680000] 10: 68e13000: 03b58000/00000000
mmstress    1  TPASS  :  TEST 1 Passed
...

To me it looks like the cond_resched in the zap_pmd_range is the root cause
of this issue (let alone SMP case for now). It was introduced in the commit

commit 97a894136f29802da19a15541de3c019e1ca147e
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Tue May 24 17:12:04 2011 -0700

    mm: Remove i_mmap_lock lockbreak

Peter, Kamezawa, other reviewers of that commit, could you please comment?


------8<------
