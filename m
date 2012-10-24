Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id D65516B0068
	for <linux-mm@kvack.org>; Wed, 24 Oct 2012 19:45:28 -0400 (EDT)
Received: by mail-ie0-f169.google.com with SMTP id 10so1898027ied.14
        for <linux-mm@kvack.org>; Wed, 24 Oct 2012 16:45:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1210241633290.22819@chino.kir.corp.google.com>
References: <20121008150949.GA15130@redhat.com> <CAHGf_=pr1AYeWZhaC2MKN-XjiWB7=hs92V0sH-zVw3i00X-e=A@mail.gmail.com>
 <alpine.DEB.2.00.1210152055150.5400@chino.kir.corp.google.com>
 <CAHGf_=rLjQbtWQLDcbsaq5=zcZgjdveaOVdGtBgBwZFt78py4Q@mail.gmail.com>
 <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com>
 <CAHGf_=pemT6rcbu=dBVSJE7GuGWwVFP+Wn-mwkcsZ_gBGfaOsg@mail.gmail.com>
 <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com>
 <20121017040515.GA13505@redhat.com> <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com>
 <CA+1xoqe74R6DX8Yx2dsp1MkaWkC1u6yAEd8eWEdiwi88pYdPaw@mail.gmail.com> <alpine.DEB.2.00.1210241633290.22819@chino.kir.corp.google.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Wed, 24 Oct 2012 19:37:08 -0400
Message-ID: <CA+1xoqd6MEFP-eWdnWOrcz2EmE6tpd7UhgJyS8HjQ8qrGaMMMw@mail.gmail.com>
Subject: Re: [patch for-3.7] mm, mempolicy: fix printing stack contents in numa_maps
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 24, 2012 at 7:34 PM, David Rientjes <rientjes@google.com> wrote:
> On Wed, 24 Oct 2012, Sasha Levin wrote:
>
>> I'm not sure about the status of the patch, but it doesn't apply on
>> top of -next, and I still
>> see the warnings when fuzzing on -next.
>>
>
> This should be fixed by 9e7814404b77 ("hold task->mempolicy while
> numa_maps scans.") in 3.7-rc2, can you reproduce any issues reading
> /proc/pid/numa_maps on that kernel?

I was actually referring to the warnings Dave Jones saw when fuzzing
with trinity after the
original patch was applied.

I still see the following when fuzzing:

[  338.467156] BUG: sleeping function called from invalid context at
kernel/mutex.c:269
[  338.473719] in_atomic(): 1, irqs_disabled(): 0, pid: 6361, name: trinity-main
[  338.481199] 2 locks held by trinity-main/6361:
[  338.486629]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810aa314>]
__do_page_fault+0x1e4/0x4f0
[  338.498783]  #1:  (&(&mm->page_table_lock)->rlock){+.+...}, at:
[<ffffffff8122f017>] handle_pte_fault+0x3f7/0x6a0
[  338.511409] Pid: 6361, comm: trinity-main Tainted: G        W
3.7.0-rc2-next-20121024-sasha-00001-gd95ef01-dirty #74
[  338.530318] Call Trace:
[  338.534088]  [<ffffffff8114e393>] __might_sleep+0x1c3/0x1e0
[  338.539358]  [<ffffffff83ae5209>] mutex_lock_nested+0x29/0x50
[  338.545253]  [<ffffffff8124fc3e>] mpol_shared_policy_lookup+0x2e/0x90
[  338.545258]  [<ffffffff81219ebe>] shmem_get_policy+0x2e/0x30
[  338.545264]  [<ffffffff8124e99a>] get_vma_policy+0x5a/0xa0
[  338.545267]  [<ffffffff8124fce1>] mpol_misplaced+0x41/0x1d0
[  338.545272]  [<ffffffff8122f085>] handle_pte_fault+0x465/0x6a0
[  338.545278]  [<ffffffff81131e04>] ? __rcu_read_unlock+0x44/0xb0
[  338.545282]  [<ffffffff81230baa>] handle_mm_fault+0x32a/0x360
[  338.545286]  [<ffffffff810aa5b0>] __do_page_fault+0x480/0x4f0
[  338.545293]  [<ffffffff8111a706>] ? del_timer+0x26/0x80
[  338.545298]  [<ffffffff811c7313>] ? rcu_cleanup_after_idle+0x23/0x170
[  338.545302]  [<ffffffff811ca9a4>] ? rcu_eqs_exit_common+0x64/0x3a0
[  338.545305]  [<ffffffff811c8c66>] ? rcu_eqs_enter_common+0x7c6/0x970
[  338.545309]  [<ffffffff811cafdc>] ? rcu_eqs_exit+0x9c/0xb0
[  338.545312]  [<ffffffff810aa666>] do_page_fault+0x26/0x40
[  338.545317]  [<ffffffff810a3a40>] do_async_page_fault+0x30/0xa0
[  338.545321]  [<ffffffff83ae9268>] async_page_fault+0x28/0x30

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
