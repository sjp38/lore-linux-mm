Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7A35E280250
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 06:48:51 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id f187so32182614qkd.3
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:48:51 -0700 (PDT)
Received: from mail-yw0-x22b.google.com (mail-yw0-x22b.google.com. [2607:f8b0:4002:c05::22b])
        by mx.google.com with ESMTPS id l14si362407ybl.75.2016.09.22.03.48.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Sep 2016 03:48:50 -0700 (PDT)
Received: by mail-yw0-x22b.google.com with SMTP id u82so87595757ywc.2
        for <linux-mm@kvack.org>; Thu, 22 Sep 2016 03:48:50 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160921153421.GA4716@redhat.com>
References: <1447181081-30056-1-git-send-email-aarcange@redhat.com>
 <1447181081-30056-2-git-send-email-aarcange@redhat.com> <1459974829.28435.6.camel@redhat.com>
 <20160406220202.GA2998@redhat.com> <CA+eFSM0e1XqnPweeLeYJJz=4zS6ixWzFRSeH6UaChey+o+FWPA@mail.gmail.com>
 <20160921153421.GA4716@redhat.com>
From: Gavin Guo <gavin.guo@canonical.com>
Date: Thu, 22 Sep 2016 18:48:49 +0800
Message-ID: <CA+eFSM33iAS98t5QU_+iOGH7F2VvMErwRvuuHnQU2JowZ8cMHg@mail.gmail.com>
Subject: Re: [PATCH 1/1] ksm: introduce ksm_max_page_sharing per page
 deduplication limit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Arjan van de Ven <arjan@linux.intel.com>

Hi Andrea,

On Wed, Sep 21, 2016 at 11:34 PM, Andrea Arcangeli <aarcange@redhat.com> wrote:
> Hello Gavin,
>
> On Wed, Sep 21, 2016 at 11:12:19PM +0800, Gavin Guo wrote:
>> Recently, a similar bug can also be observed under the numad process
>> with the v4.4 Ubuntu kernel or the latest upstream kernel. However, I
>> think the patch should be useful to mitigate the symptom. I tried to
>> search the mailing list and found the patch finally didn't be merged
>> into the upstream kernel. If there are any problems which drop the
>> patch?
>
> Zero known problems, in fact it's running in production in both RHEL7
> and RHEL6 for a while. The RHEL customers are not affected anymore for
> a while now.
>
> It's a critical computational complexity fix, if using KSM in
> enterprise production. Hugh already Acked it as well.
>
> It's included in -mm and Andrew submitted it once upstream, but it
> bounced probably perhaps it was not the right time in the merge window
> cycle.
>
> Or perhaps because it's complex but I wouldn't know how to simplify it
> but there's no bug at all in the code.
>
> I would suggest Andrew to send it once again when he feels it's a good
> time to do so.
>
>> The numad process tried to migrate a qemu process of 33GB memory.
>> Finally, it stuck in the csd_lock_wait function which causes the qemu
>> process hung and the virtual machine has high CPU usage and hung also.
>> With KSM disabled, the symptom disappeared.
>
> Until it's merged upstream you can cherrypick from my aa.git tree
> these three commits:
>
> https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=9384142e4ce830898abcefc4f0479c4533fa5bbc
> https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=4b293be7e20c8e8731a4fdc3c3bf6047304d0cc8
> https://git.kernel.org/cgit/linux/kernel/git/andrea/aa.git/commit/?id=44c0d79c2c223c54ffe3fabc893963fc5963d611
>
> They're in -mm too.
>
>> What happens here is that do_migrate_pages (frame #10) acquires the
>> mmap_sem semaphore that everything else is waiting for (and that
>> eventually produce the hang warnings), and it holds that semaphore for
>> the duration of the page migration.
>>
>> crash> bt 2950
>> PID: 2950   TASK: ffff885f97745280  CPU: 49  COMMAND: "numad"
>>     [exception RIP: smp_call_function_single+219]
>>     RIP: ffffffff81103a0b  RSP: ffff885f8fb4fb28  RFLAGS: 00000202
>>     RAX: 0000000000000000  RBX: 0000000000000013  RCX: 0000000000000000
>>     RDX: 0000000000000003  RSI: 0000000000000100  RDI: 0000000000000286
>>     RBP: ffff885f8fb4fb70   R8: 0000000000000000   R9: 0000000000080000
>>     R10: 0000000000000000  R11: ffff883faf917c88  R12: ffffffff810725f0
>>     R13: 0000000000000013  R14: ffffffff810725f0  R15: ffff885f8fb4fbc8
>>     CS: 0010  SS: 0018
>>  #0 [ffff885f8fb4fb30] kvm_unmap_rmapp at ffffffffc01f1c3e [kvm]
>>  #1 [ffff885f8fb4fb78] smp_call_function_many at ffffffff81103db3
>>  #2 [ffff885f8fb4fbc0] native_flush_tlb_others at ffffffff8107279d
>>  #3 [ffff885f8fb4fc08] flush_tlb_page at ffffffff81072a95
>>  #4 [ffff885f8fb4fc30] ptep_clear_flush at ffffffff811d048e
>>  #5 [ffff885f8fb4fc60] try_to_unmap_one at ffffffff811cb1c7
>>  #6 [ffff885f8fb4fcd0] rmap_walk_ksm at ffffffff811e6f91
>>  #7 [ffff885f8fb4fd28] rmap_walk at ffffffff811cc1bf
>>  #8 [ffff885f8fb4fd80] try_to_unmap at ffffffff811cc46b
>>  #9 [ffff885f8fb4fdc8] migrate_pages at ffffffff811f26d8
>> #10 [ffff885f8fb4fe80] do_migrate_pages at ffffffff811e15f7
>> #11 [ffff885f8fb4fef8] sys_migrate_pages at ffffffff811e187d
>> #12 [ffff885f8fb4ff50] entry_SYSCALL_64_fastpath at ffffffff818244f2
>>
>> After some investigations, I've tried to disassemble the coredump and
>> finally find the stable_node->hlist is as long as 2306920 entries.
>
> Yep, this is definitely getting fixed by the three commits above and
> the problem is in rmap_walk_ksm like you found above. With that
> applied you can't ever run into hangs anymore with KSM enabled, no
> matter the workload and the amount of memory in guest and host.
>
> numad isn't required to reproduce it, some swapping is enough.
>
> It limits the de-duplication factor to 256 times, like a x256 times
> compression, a x256 compression factor is clearly more than enough. So
> effectively the list you found that was too long, gets hard-limited to
> 256 entries with my patch applied. The limit is configurable at runtime:
>
> /* Maximum number of page slots sharing a stable node */
> static int ksm_max_page_sharing = 256;
>
> If you want to increase the limit (careful: that will increase
> the rmap_walk_ksm computation time) you can echo $newsharinglimit >
> /sys/kernel/mm/ksm/max_page_sharing.
>
> Hope this helps,
> Andrea

Thank you for the detail explanation. I've cherry-picked these patches
and now doing the verification. I'll get back to you if there is any
problem. Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
