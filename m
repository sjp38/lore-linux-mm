Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 648048D0039
	for <linux-mm@kvack.org>; Thu,  3 Mar 2011 12:22:41 -0500 (EST)
Message-ID: <4D6FCE5D.4030904@tilera.com>
Date: Thu, 3 Mar 2011 12:22:37 -0500
From: Chris Metcalf <cmetcalf@tilera.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 2/6] mm: Change flush_tlb_range() to take an mm_struct
References: <20110302180258.956518392@chello.nl>	<AANLkTimhWKhHojZ-9XZGSh3OzfPhvo__Dib9VfeMWoBQ@mail.gmail.com>	<1299102027.1310.39.camel@laptop> <20110302.134735.260066220.davem@davemloft.net>
In-Reply-To: <20110302.134735.260066220.davem@davemloft.net>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, torvalds@linux-foundation.org, aarcange@redhat.com, tglx@linutronix.de, riel@redhat.com, mingo@elte.hu, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, benh@kernel.crashing.org, hugh.dickins@tiscali.co.uk, mel@csn.ul.ie, npiggin@kernel.dk, rmk@arm.linux.org.uk, schwidefsky@de.ibm.com

On 3/2/2011 4:47 PM, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Wed, 02 Mar 2011 22:40:27 +0100
>
>> On Wed, 2011-03-02 at 11:19 -0800, Linus Torvalds wrote:
>>> On Wed, Mar 2, 2011 at 9:59 AM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>>>> In order to be able to properly support architecture that want/need to
>>>> support TLB range invalidation, we need to change the
>>>> flush_tlb_range() argument from a vm_area_struct to an mm_struct
>>>> because the range might very well extend past one VMA, or not have a
>>>> VMA at all.
>>> I really don't think this is right. The whole "drop the icache
>>> information" thing is a total anti-optimization, since for some
>>> architectures, the icache flush is the _big_ deal. 
>> Right, so Tile has the I-cache flush from flush_tlb_range(), I'm not
>> sure if that's the right thing to do, Documentation/cachetlb.txt seems
>> to suggest doing it from update_mmu_cache() like things.
> Sparc32 chips that require a valid TLB entry for I-cache flushes do
> the flush from flush_cache_range() and similar.
>
> Sparc64 does not have the "present TLB entry" requirement (since I-cache
> is physical), and we handle it in update_mmu_cache() but only as an
> optimization.  This scheme works in concert with flush_dcache_page().
>
> Either scheme is valid, the former is best when flushing is based upon
> virtual addresses.
>
> But I'll be the first to admit that the interfaces we have for doing
> this stuff is basically nothing more than a set of hooks, with
> assurances that the hooks will be called in specific situations.  Like
> anything else, it's evolved over time based upon architectural needs.

I'm finding it hard to understand how the Sparc code handles icache
coherence.  It seems that the Spitfire MMU is the interesting one, but the
hard case seems to be when a process migrates around to various cores
during execution (thus leaving incoherent icache lines everywhere), and the
page is then freed and re-used for different executable code.  I'd think
that there would have to be xcall IPIs to flush all the cpus' icaches, or
to flush every core in the cpu_vm_mask plus do something at context switch,
but I don't see any of that.  No doubt I'm missing something :-)

Currently on Tile I assume that we flush icaches in cpu_vm_mask at TLB
flush time, and flush the icache on context-switch, since I'm confident I
can reason correctly about that and prove that with this model you can
never have stale icache data.  But the "every context-switch" is a
nuisance, only somewhat mitigated by the fact that with 64 cores we don't
do a lot of context-switching.

To give some more specificity to my thinking, here's one optimization we
could do on Tile, that would both address Peter Zijlstra's generic
architecture in an obvious way, and also improve context switch time:

- Add a "free time" field to struct page.  The free time field could be a
64-bit cycle counter value, or maybe some kind of 32-bit counter that just
increments every time we free, etc., though then we'd need to worry about
handling wraparound.  We'd record the free time when we freed the page back
to the buddy allocator.  Since we only care about executable page frees,
we'd want to use a page bit to track if a given page was ever associated
with an executable PTE, and if it wasn't, we could just record the "free
time" as zero, for book-keeping purposes.

- Keep a per-cpu "icache flush time", with the same timekeeping system as
the page free time.  Every time we flush the whole icache on a cpu, we
update its per-cpu timestamp.

- When writing an executable PTE into the page table, we'd check the
cpu_vm_mask, and any cpu that hadn't done a full icache flush since the
page in question was previously freed would be IPI'ed and would do the
icache flush, making it safe to start running code on the page with its new
code.  We'd also update a per-mm "latest free" timestamp to hold the most
recent "free time" of all the pages faulted in for that mm.

- When context-switching, we'd check the per-mm "latest free" timestamp,
and if the mm held a page that was freed more recently than that cpu's
timestamp, we'd do a full icache flush and update the per-cpu timestamp.

This has several good properties:

- We are unlikely to do much icache flushing, since we only do it when an
executable page is freed back to the buddy allocator and then reused as
executable again.

- If two processes share a cpu, they don't end up having to icache flush at
every context switch.

- We never need to IPI a cpu that isn't actively involved with the process
that is faulting in a new executable page.  (This is particularly important
since we want to avoid disturbing "dataplane" cpus that are running
latency-sensitive tasks.)

- We don't need to worry about vma's at flush_tlb_range() time, thus making
Peter happy :-)

I'm not worrying about kernel module executable pages, since I'm happy to
do much more heavy-weight operations for them, i.e. flush all the icaches
on all the cores.

So: does this general approach seem appropriate, or am I missing a key
subtlety of the Sparc approach that makes this all unnecessary?

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
