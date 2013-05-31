Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 5BD7A6B0033
	for <linux-mm@kvack.org>; Thu, 30 May 2013 21:40:30 -0400 (EDT)
Received: by mail-vb0-f52.google.com with SMTP id p12so652085vbe.39
        for <linux-mm@kvack.org>; Thu, 30 May 2013 18:40:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130529122728.GA27176@twins.programming.kicks-ass.net>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
	<CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
	<51A45861.1010008@gmail.com>
	<20130529122728.GA27176@twins.programming.kicks-ass.net>
Date: Fri, 31 May 2013 05:40:29 +0400
Message-ID: <CAMo8BfLO21hORMPoYofyibVeioAw=vzXjjD9EPnjdn2Duvb+WQ@mail.gmail.com>
Subject: Re: TLB and PTE coherency during munmap
From: Max Filippov <jcmvbkbc@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>

On Wed, May 29, 2013 at 4:27 PM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, May 28, 2013 at 11:10:25AM +0400, Max Filippov wrote:
>> On Sun, May 26, 2013 at 6:50 AM, Max Filippov <jcmvbkbc@gmail.com> wrote:
>> > Hello arch and mm people.
>> >
>> > Is it intentional that threads of a process that invoked munmap syscall
>> > can see TLB entries pointing to already freed pages, or it is a bug?
>> >
>> > I'm talking about zap_pmd_range and zap_pte_range:
>> >
>> >       zap_pmd_range
>> >         zap_pte_range
>> >           arch_enter_lazy_mmu_mode
>> >             ptep_get_and_clear_full
>> >             tlb_remove_tlb_entry
>> >             __tlb_remove_page
>> >           arch_leave_lazy_mmu_mode
>> >         cond_resched
>> >
>> > With the default arch_{enter,leave}_lazy_mmu_mode, tlb_remove_tlb_entry
>> > and __tlb_remove_page there is a loop in the zap_pte_range that clears
>> > PTEs and frees corresponding pages, but doesn't flush TLB, and
>> > surrounding loop in the zap_pmd_range that calls cond_resched. If a thread
>> > of the same process gets scheduled then it is able to see TLB entries
>> > pointing to already freed physical pages.
>> >
>> > I've noticed that with xtensa arch when I added a test before returning to
>> > userspace checking that TLB contents agrees with page tables of the
>> > current mm. This check reliably fires with the LTP test mtest05 that
>> > maps, unmaps and accesses memory from multiple threads.
>> >
>> > Is there anything wrong in my description, maybe something specific to
>> > my arch, or this issue really exists?
>>
>> Hi,
>>
>> I've made similar checking function for MIPS (because qemu is my only choice
>> and it simulates MIPS TLB) and ran my tests on mips-malta machine in qemu.
>> With MIPS I can also see this issue. I hope I did it right, the patch at the
>> bottom is for the reference. The test I run and the diagnostic output are as
>> follows:
>>
>> To me it looks like the cond_resched in the zap_pmd_range is the root cause
>> of this issue (let alone SMP case for now). It was introduced in the commit
>>
>> commit 97a894136f29802da19a15541de3c019e1ca147e
>> Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
>> Date:   Tue May 24 17:12:04 2011 -0700
>>
>>     mm: Remove i_mmap_lock lockbreak
>>
>> Peter, Kamezawa, other reviewers of that commit, could you please comment?
>
> Are you all running UP systems? I suppose the preemptible muck

Yes, xtensa SMP support is in the middle of forward porting/cleanup process.

> invalidated the assumption that UP systems are 'easy'.
>
> If you make tlb_fast_mode() return an unconditional false, does it all
> work again?

Actually the only thing that was visibly broken is the test for
TLB/PTE coherency,
but that incoherency appears to be intentional (and the test is too
simple for that).
Unconditionally returning false from tlb_fast_mode() doesn't fix that test, but
AFAICS it fixes underlying page freeing.

-- 
Thanks.
-- Max

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
