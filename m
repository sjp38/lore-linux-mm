Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 723626B0033
	for <linux-mm@kvack.org>; Mon, 11 Dec 2017 02:01:50 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id x24so12276445pgv.5
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 23:01:50 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id s4si9442015pgo.278.2017.12.10.23.01.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Dec 2017 23:01:48 -0800 (PST)
From: Vinayak Menon <vinmenon@codeaurora.org>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
 <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com>
 <20171205121614.ek45btdgrpbmvf45@armageddon.cambridge.arm.com>
Message-ID: <b33f9452-112f-873b-e41e-dee2bf2f4be8@codeaurora.org>
Date: Mon, 11 Dec 2017 12:31:39 +0530
MIME-Version: 1.0
In-Reply-To: <20171205121614.ek45btdgrpbmvf45@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: riel@redhat.com, jack@suse.cz, minchan@kernel.org, dave.hansen@linux.intel.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ying.huang@intel.com, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, mgorman@suse.de


On 12/5/2017 5:46 PM, Catalin Marinas wrote:
> On Tue, Nov 28, 2017 at 11:45:27AM -0800, Linus Torvalds wrote:
>> On Mon, Nov 27, 2017 at 9:07 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
>>> Making the faultaround ptes old results in a unixbench regression for some
>>> architectures [3][4]. But on some architectures it is not found to cause
>>> any regression. So by default produce young ptes and provide an option for
>>> architectures to make the ptes old.
>> Ugh. This hidden random behavior difference annoys me.
>>
>> It should also be better documented in the code if we end up doing it.
>>
>> The reason x86 seems to prefer young pte's is simply that a TLB lookup
>> of an old entry basically causes a micro-fault that then sets the
>> accessed bit (using a locked cycle) and then a restart.
>>
>> Those microfaults are not visible to software, but they are pretty
>> expensive in hardware, probably because they basically serialize
>> execution as if a real page fault had happened.
> In principle it's not that different for ARMv8.1+ but it highly depends
> on the microarchitecture details (and we have a lot of variation on
> ARM). From a programmer's perspective, old ptes (access flag cleared)
> are not allowed to be cached in the TLB, otherwise ptep_clear_flush()
> would break. Marking fault-around ptes as young allows the hardware to
> speculatively populate the TLB but, again, it's highly microarchitecture
> specific and I'm not sure we have a general answer covering the ARM
> architecture. Of course, faulting on old ptes is much slower without
> hardware AF.
>
>> HOWEVER - and this is the part that annoys me most about the hidden
>> behavior - I suspect it ends up being very dependent on
>> microarchitectural details in addition to the actual load. So it might
>> be more true on some cores than others, and it might be very
>> load-dependent. So hiding it as some architectural helper function
>> really feels wrong to me. It would likely be better off as a real
>> flag, and then maybe we could make the default behavior be set by
>> architecture (or even dynamically by the architecture bootup code if
>> it turns out to be enough of an issue).
> It looks to me like we are trying to work around a vmscan behaviour
> visible under memory pressure [1]. The original report doesn't state
> whether hardware AF is available (it seems to be tested on a 3.18
> Android kernel; hardware AF on arm64 went in 4.6).
Sorry for the delayed response.
The original report was based on a target without HW AF support.
The issue can be seen even on a 8GB machine with multibuild test. Yes, I agree that the problem
is triggered with reclaim, but looks like it doesn't need a very low memory condition for the issue
to be visible.
IIUC, vmscan is doing the right thing in trying to keep the hot pages. But by making the faultaround
pages young, we are saying that they are referenced which may not be true. When the speculation
that faultaround pages are hot goes wrong, vmscan ends up evicting more hot anon and file pages.
Multibuild and apps launch test on android showing a regression I think means that this speculation
is going wrong often.
Even on non-HW-AF targets, where making ptes old can result in more minor faults, performance is
better with faultaorund disabled (or making ptes old), with the above mentioned tests.
I think making faultaround pages young was not intentionally done by the original faultaround code [1],
and the original idea was to gain benefit of reduced minor faults.

> In this case there is a trade-off between swapping out potentially hot
> pages vs page table walk (either in hardware or via software fault) for
> fault-around ptes. This trade-off further depends on whether the
> architecture can do hardware access flag or not.
>
> I would be more in favour of some heuristics to dynamically reduce the
> fault-around bytes based on the memory pressure rather than choosing
> between young or old ptes. 

Even with minimal or moderateA  memory pressure, if the speculation that faultaround pages are hot is
wrong, it can result in wrong evictions. I am not sure, but it could be similar reason why we skip VM_SEQ_READ
pages in page_referenced_one.
Since the arm64 tests doesn't show any visible impact of page table walk, there doesn't seem to be a case of
trade-off. I agree that this may not be a case for all arm64 cores, but it would be advantageous to make
faultaround ptes old on targets which doesn't show page table access issues. And shouldn't faultaround ptes
logically be old until they are really accessed ?
Also, even during memory pressure, it can be beneficial to have faultaround pages which reduces the page
faults (even if a quarter of the pages are actually accessed), but the issue is only that they are made young
which confuses vmscan. So I think faultaround bytes may not be related to memory pressure.

> Or, if we are to go with old vs young ptes,
> make this choice dependent on the memory pressure regardless of whether
> the CPU supports hardware accessed bit.

Will it be okay then to make this flag part of /proc/sys/vm and let the vmpressure clients take care of
setting it based on the vmpressure values ? Those who always want faultaround ptes to be old can do
that too with this interface.

[1] https://lkml.org/lkml/2016/4/22/568

Thanks,
Vinayak

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
