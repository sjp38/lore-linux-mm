Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 141EC6B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 19:30:50 -0400 (EDT)
Received: by mail-ia0-f169.google.com with SMTP id h37so1068672iak.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:30:49 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Wed, 24 Oct 2012 19:30:29 -0400
Message-ID: <CA+1xoqe74R6DX8Yx2dsp1MkaWkC1u6yAEd8eWEdiwi88pYdPaw@mail.gmail.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 17, 2012 at 1:24 AM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 17 Oct 2012, Dave Jones wrote:
>
>> BUG: sleeping function called from invalid context at kernel/mutex.c:269
>> in_atomic(): 1, irqs_disabled(): 0, pid: 8558, name: trinity-child2
>> 3 locks on stack by trinity-child2/8558:
>>  #0: held:     (&p->lock){+.+.+.}, instance: ffff88010c9a00b0, at: [<ffffffff8120cd1f>] seq_lseek+0x3f/0x120
>>  #1: held:     (&mm->mmap_sem){++++++}, instance: ffff88013956f7c8, at: [<ffffffff81254437>] m_start+0xa7/0x190
>>  #2: held:     (&(&p->alloc_lock)->rlock){+.+...}, instance: ffff88011fc64f30, at: [<ffffffff81254f8f>] show_numa_map+0x14f/0x610
>> Pid: 8558, comm: trinity-child2 Not tainted 3.7.0-rc1+ #32
>> Call Trace:
>>  [<ffffffff810ae4ec>] __might_sleep+0x14c/0x200
>>  [<ffffffff816bdf4e>] mutex_lock_nested+0x2e/0x50
>>  [<ffffffff811c43a3>] mpol_shared_policy_lookup+0x33/0x90
>>  [<ffffffff8118d5c3>] shmem_get_policy+0x33/0x40
>>  [<ffffffff811c31fa>] get_vma_policy+0x3a/0x90
>>  [<ffffffff81254fa3>] show_numa_map+0x163/0x610
>>  [<ffffffff81255b10>] ? pid_maps_open+0x20/0x20
>>  [<ffffffff81255980>] ? pagemap_hugetlb_range+0xf0/0xf0
>>  [<ffffffff81255483>] show_pid_numa_map+0x13/0x20
>>  [<ffffffff8120c902>] traverse+0xf2/0x230
>>  [<ffffffff8120cd8b>] seq_lseek+0xab/0x120
>>  [<ffffffff811e6c0b>] sys_lseek+0x7b/0xb0
>>  [<ffffffff816ca088>] tracesys+0xe1/0xe6
>>
>
> Hmm, looks like we need to change the refcount semantics entirely.  We'll
> need to make get_vma_policy() always take a reference and then drop it
> accordingly.  This work sif get_vma_policy() can grab a reference while
> holding task_lock() for the task policy fallback case.
>
> Comments on this approach?
> ---
[snip]

I'm not sure about the status of the patch, but it doesn't apply on
top of -next, and I still
see the warnings when fuzzing on -next.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
