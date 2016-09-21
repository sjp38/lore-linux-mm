Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3961328024E
	for <linux-mm@kvack.org>; Wed, 21 Sep 2016 11:12:21 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id n185so125315419qke.2
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:12:21 -0700 (PDT)
Received: from mail-yb0-x232.google.com (mail-yb0-x232.google.com. [2607:f8b0:4002:c09::232])
        by mx.google.com with ESMTPS id q190si14624752ywf.417.2016.09.21.08.12.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Sep 2016 08:12:20 -0700 (PDT)
Received: by mail-yb0-x232.google.com with SMTP id u125so33719135ybg.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 08:12:20 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160406220202.GA2998@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com> <1459974829.28435.6.camel@redhat.com>
 <20160406220202.GA2998@redhat.com>
From: Gavin Guo <gavin.guo@canonical.com>
Date: Wed, 21 Sep 2016 23:12:19 +0800
Message-ID: <CA+eFSM0e1XqnPweeLeYJJz=4zS6ixWzFRSeH6UaChey+o+FWPA@mail.gmail.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

Hi Andrea,

On Thu, Apr 7, 2016 at 6:02 AM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello Rik,
>
> On Wed, Apr 06, 2016 at 04:33:49PM -0400, Rik van Riel wrote:
>> On Tue, 2015-11-10 at 19:44 +0100, Andrea Arcangeli wrote:
>> > Without a max deduplication limit for each KSM page, the list of the
>> > rmap_items associated to each stable_node can grow infinitely
>> > large.
>> >
>> > During the rmap walk each entry can take up to ~10usec to process
>> > because of IPIs for the TLB flushing (both for the primary MMU and
>> > the
>> > secondary MMUs with the MMU notifier). With only 16GB of address
>> > space
>> > shared in the same KSM page, that would amount to dozens of seconds
>> > of
>> > kernel runtime.
>>
>> Silly question, but could we fix this problem
>> by building up a bitmask of all CPUs that have
>> a page-with-high-mapcount mapped, and simply
>> send out a global TLB flush to those CPUs once
>> we have changed the page tables, instead of
>> sending out IPIs at every page table change?
>
> That's great idea indeed, but it's an orthogonal optimization. Hugh
> already posted a patch adding TTU_BATCH_FLUSH to try_to_unmap in
> migrate and then call try_to_unmap_flush() at the end which is on the
> same lines of you're suggesting. Problem is we still got millions of
> entries potentially present in those lists with the current code, even
> a list walk without IPI is prohibitive.
>
> The only alternative is to make rmap_walk non atomic, i.e. break it in
> the middle, because it's not just the cost of IPIs that is
> excessive. However doing that breaks all sort of assumptions in the VM
> and overall it will make it weaker, as when we're OOM we're not sure
> anymore if we have been aggressive enough in clearing referenced bits
> if tons of KSM pages are slightly above the atomic-walk-limit. Even
> ignoring the VM behavior, page migration and in turn compaction and
> memory offlining require scanning all entries in the list before we
> can return to userland and remove the DIMM or succeed the increase of
> echo > nr_hugepages, so all those features would become unreliable and
> they could incur in enormous latencies.
>
> Like Arjan mentioned, there's no significant downside in limiting the
> "compression ratio" to x256 or x1024 or x2048 (depending on the sysctl
> value) because the higher the limit the more we're hitting diminishing
> returns.
>
> On the design side I believe there's no other black and white possible
> solution than this one that solves all problems with no downside at
> all for the VM fast paths we care about the most.
>
> On the implementation side if somebody can implement it better than I
> did while still as optimal, so that the memory footprint of the KSM
> metadata is unchanged (on 64bit), that would be welcome.
>
> One thing that could be improved is adding proper defrag to increase
> the average density to nearly match the sysctl value at all times, but
> the heuristic I added (that tries to achieve the same objective by
> picking the busiest stable_node_dup and putting it in the head of the
> chain for the next merges) is working well too. There will be at least
> 2 entries for each stable_node_dup so the worst case density is still
> x2. Real defrag that modifies pagetables would be as costly as page
> migration, while this costs almost nothing as it's run once in a
> while.
>
> Thanks,
> Andrea
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Recently, a similar bug can also be observed under the numad process
with the v4.4 Ubuntu kernel or the latest upstream kernel. However, I
think the patch should be useful to mitigate the symptom. I tried to
search the mailing list and found the patch finally didn't be merged
into the upstream kernel. If there are any problems which drop the
patch?

The numad process tried to migrate a qemu process of 33GB memory.
Finally, it stuck in the csd_lock_wait function which causes the qemu
process hung and the virtual machine has high CPU usage and hung also.
With KSM disabled, the symptom disappeared.

>From the following backtrace, The RIP: smp_call_function_single+219 is
actually in the csd_lock_wait function mentioned above, but the
compiler has optimized that call and it does not appear in the stack.

What happens here is that do_migrate_pages (frame #10) acquires the
mmap_sem semaphore that everything else is waiting for (and that
eventually produce the hang warnings), and it holds that semaphore for
the duration of the page migration.

crash> bt 2950
PID: 2950   TASK: ffff885f97745280  CPU: 49  COMMAND: "numad"
    [exception RIP: smp_call_function_single+219]
    RIP: ffffffff81103a0b  RSP: ffff885f8fb4fb28  RFLAGS: 00000202
    RAX: 0000000000000000  RBX: 0000000000000013  RCX: 0000000000000000
    RDX: 0000000000000003  RSI: 0000000000000100  RDI: 0000000000000286
    RBP: ffff885f8fb4fb70   R8: 0000000000000000   R9: 0000000000080000
    R10: 0000000000000000  R11: ffff883faf917c88  R12: ffffffff810725f0
    R13: 0000000000000013  R14: ffffffff810725f0  R15: ffff885f8fb4fbc8
    CS: 0010  SS: 0018
 #0 [ffff885f8fb4fb30] kvm_unmap_rmapp at ffffffffc01f1c3e [kvm]
 #1 [ffff885f8fb4fb78] smp_call_function_many at ffffffff81103db3
 #2 [ffff885f8fb4fbc0] native_flush_tlb_others at ffffffff8107279d
 #3 [ffff885f8fb4fc08] flush_tlb_page at ffffffff81072a95
 #4 [ffff885f8fb4fc30] ptep_clear_flush at ffffffff811d048e
 #5 [ffff885f8fb4fc60] try_to_unmap_one at ffffffff811cb1c7
 #6 [ffff885f8fb4fcd0] rmap_walk_ksm at ffffffff811e6f91
 #7 [ffff885f8fb4fd28] rmap_walk at ffffffff811cc1bf
 #8 [ffff885f8fb4fd80] try_to_unmap at ffffffff811cc46b
 #9 [ffff885f8fb4fdc8] migrate_pages at ffffffff811f26d8
#10 [ffff885f8fb4fe80] do_migrate_pages at ffffffff811e15f7
#11 [ffff885f8fb4fef8] sys_migrate_pages at ffffffff811e187d
#12 [ffff885f8fb4ff50] entry_SYSCALL_64_fastpath at ffffffff818244f2

After some investigations, I've tried to disassemble the coredump and
finally find the stable_node->hlist is as long as 2306920 entries.

rmap_item list(stable_node->hlist):
stable_node: 0xffff881f836ba000 stable_node->hlist->first =
0xffff883f3e5746b0

struct hlist_head {
[0] struct hlist_node *first;
}
struct hlist_node {
[0] struct hlist_node *next;
[8] struct hlist_node **pprev;
}

crash> list hlist_node.next 0xffff883f3e5746b0 > rmap_item.lst

$ wc -l rmap_item.lst
2306920 rmap_item.lst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
