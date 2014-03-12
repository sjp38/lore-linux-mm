Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id 899266B0092
	for <linux-mm@kvack.org>; Wed, 12 Mar 2014 05:19:35 -0400 (EDT)
Received: by mail-we0-f176.google.com with SMTP id x48so11140753wes.35
        for <linux-mm@kvack.org>; Wed, 12 Mar 2014 02:19:34 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [119.145.14.64])
        by mx.google.com with ESMTPS id pd8si3452582wic.87.2014.03.12.02.19.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 12 Mar 2014 02:19:34 -0700 (PDT)
Message-ID: <53202598.8010402@huawei.com>
Date: Wed, 12 Mar 2014 17:15:04 +0800
From: Xishi Qiu <qiuxishi@huawei.com>
MIME-Version: 1.0
Subject: Re: mm: OS boot failed when set command-line kmemcheck=1
References: <5304558F.9050605@huawei.com> <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com> <53047AE6.4060403@huawei.com> <alpine.DEB.2.02.1402191422240.31921@chino.kir.corp.google.com> <20140226084304.GD18404@twins.programming.kicks-ass.net> <CAOMGZ=F66ysRvvPKiCNDRtjDjgAZUV+KBcgjS+G0Yho5quBFPw@mail.gmail.com>
In-Reply-To: <CAOMGZ=F66ysRvvPKiCNDRtjDjgAZUV+KBcgjS+G0Yho5quBFPw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, David Rientjes <rientjes@google.com>, Robert Richter <rric@kernel.org>, Stephane Eranian <eranian@google.com>, Pekka Enberg <penberg@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2014/2/26 18:14, Vegard Nossum wrote:

> On 26 February 2014 09:43, Peter Zijlstra <peterz@infradead.org> wrote:
>> On Wed, Feb 19, 2014 at 02:24:41PM -0800, David Rientjes wrote:
>>> On Wed, 19 Feb 2014, Xishi Qiu wrote:
>>>
>>>> Here is a warning, I don't whether it is relative to my hardware.
>>>> If set "kmemcheck=1 nowatchdog", it can boot.
>>>>
>>>> code:
>>>>     ...
>>>>     pte = kmemcheck_pte_lookup(address);
>>>>     if (!pte)
>>>>             return false;
>>>>
>>>>     WARN_ON_ONCE(in_nmi());
>>>>
>>>>     if (error_code & 2)
>>>>     ...
>>
>> That code seems to assume NMI context cannot fault; this is false since
>> a while back (v3.9 or thereabouts).
>>
>>>> [   10.920757]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
>>>> [   10.920760]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
>>>> [   10.920763]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
>>>> [   10.920765]  [<ffffffff814cf222>] page_fault+0x22/0x30
>>>> [   10.920774]  [<ffffffff8101eb02>] intel_pmu_handle_irq+0x142/0x3a0
>>>> [   10.920777]  [<ffffffff814d0655>] perf_event_nmi_handler+0x35/0x60
>>>> [   10.920779]  [<ffffffff814cfe83>] nmi_handle+0x63/0x150
>>>> [   10.920782]  [<ffffffff814cffd3>] default_do_nmi+0x63/0x290
>>>> [   10.920784]  [<ffffffff814d02a8>] do_nmi+0xa8/0xe0
>>>> [   10.920786]  [<ffffffff814cf527>] end_repeat_nmi+0x1e/0x2e
>>
>> And this does indeed show a fault from NMI context; which is totally
>> expected.
>>
>> kmemcheck needs to be fixed; but I've no clue how any of that works.
> 
> IIRC the reason we don't support page faults in NMI context is that we
> may already be handling an existing fault (or trap) when the NMI hits.
> So that would mess up kmemcheck's working state. I don't really see
> that anything has changed in this respect lately, so it could always
> have been broken.
> 
> I think the way we dealt with this before was just to make sure than
> NMI handlers don't access any kmemcheck-tracked memory (i.e. to make
> sure that all memory touched by NMI handlers has been marked NOTRACK).
> And the purpose of this warning is just to tell us that something
> inside an NMI triggered a page fault (in this specific case, it seems
> to be intel_pmu_handle_irq).
> 
> I guess there are two ways forward:
> 
>  - create a stack of things that kmemcheck is working on, so that we
> handle recursive page faults
>  - try to figure out why intel_pmu_handle_irq() faults and add a
> (kmemcheck-specific) workaround for it
> 
> Incidentally, do you remember what exactly changed wrt page faults in
> NMI context?
> 
> 
> Vegard
> 
> .
> 

Hi Vegardi 1/4 ?

I use PERF_COUNT_HW_CACHE_MISSES instead of PERF_COUNT_HW_CPU_CYCLESi 1/4 ?
and change watchdog_thresh to a large value, then OS boot successfully. 
I don't know why.

static struct perf_event_attr wd_hw_attr = {
	.type		= PERF_TYPE_HARDWARE,
	.config		= PERF_COUNT_HW_CPU_CYCLES, -> change to PERF_COUNT_HW_CACHE_MISSES
	.size		= sizeof(struct perf_event_attr),
	.pinned		= 1,
	.disabled	= 1,
};

Thanks,
Xishi Qiu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
