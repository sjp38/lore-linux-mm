Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0CA946B009F
	for <linux-mm@kvack.org>; Wed, 26 Feb 2014 05:30:43 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id y20so483968ier.29
        for <linux-mm@kvack.org>; Wed, 26 Feb 2014 02:30:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id x4si960170icy.65.2014.02.26.02.30.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Feb 2014 02:30:42 -0800 (PST)
Date: Wed, 26 Feb 2014 11:30:33 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: mm: OS boot failed when set command-line kmemcheck=1
Message-ID: <20140226103033.GI18404@twins.programming.kicks-ass.net>
References: <5304558F.9050605@huawei.com>
 <alpine.DEB.2.02.1402182344001.3551@chino.kir.corp.google.com>
 <53047AE6.4060403@huawei.com>
 <alpine.DEB.2.02.1402191422240.31921@chino.kir.corp.google.com>
 <20140226084304.GD18404@twins.programming.kicks-ass.net>
 <CAOMGZ=F66ysRvvPKiCNDRtjDjgAZUV+KBcgjS+G0Yho5quBFPw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOMGZ=F66ysRvvPKiCNDRtjDjgAZUV+KBcgjS+G0Yho5quBFPw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vegard Nossum <vegard.nossum@gmail.com>
Cc: David Rientjes <rientjes@google.com>, Xishi Qiu <qiuxishi@huawei.com>, Robert Richter <rric@kernel.org>, Stephane Eranian <eranian@google.com>, Pekka Enberg <penberg@kernel.org>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 26, 2014 at 11:14:41AM +0100, Vegard Nossum wrote:
> On 26 February 2014 09:43, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Wed, Feb 19, 2014 at 02:24:41PM -0800, David Rientjes wrote:
> >> On Wed, 19 Feb 2014, Xishi Qiu wrote:
> >>
> >> > Here is a warning, I don't whether it is relative to my hardware.
> >> > If set "kmemcheck=1 nowatchdog", it can boot.
> >> >
> >> > code:
> >> >     ...
> >> >     pte = kmemcheck_pte_lookup(address);
> >> >     if (!pte)
> >> >             return false;
> >> >
> >> >     WARN_ON_ONCE(in_nmi());
> >> >
> >> >     if (error_code & 2)
> >> >     ...
> >
> > That code seems to assume NMI context cannot fault; this is false since
> > a while back (v3.9 or thereabouts).
> >
> >> > [   10.920757]  [<ffffffff810452c1>] kmemcheck_fault+0xb1/0xc0
> >> > [   10.920760]  [<ffffffff814d262b>] __do_page_fault+0x39b/0x4c0
> >> > [   10.920763]  [<ffffffff814d2829>] do_page_fault+0x9/0x10
> >> > [   10.920765]  [<ffffffff814cf222>] page_fault+0x22/0x30
> >> > [   10.920774]  [<ffffffff8101eb02>] intel_pmu_handle_irq+0x142/0x3a0
> >> > [   10.920777]  [<ffffffff814d0655>] perf_event_nmi_handler+0x35/0x60
> >> > [   10.920779]  [<ffffffff814cfe83>] nmi_handle+0x63/0x150
> >> > [   10.920782]  [<ffffffff814cffd3>] default_do_nmi+0x63/0x290
> >> > [   10.920784]  [<ffffffff814d02a8>] do_nmi+0xa8/0xe0
> >> > [   10.920786]  [<ffffffff814cf527>] end_repeat_nmi+0x1e/0x2e
> >
> > And this does indeed show a fault from NMI context; which is totally
> > expected.
> >
> > kmemcheck needs to be fixed; but I've no clue how any of that works.
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

That's what perf and ftrace do. We keep a 4 layer stack using things
like:

static inline int get_recursion_context(int *recursion)
{
	int rctx;

	if (in_nmi())
		rctx = 3;
	else if (in_irq())
		rctx = 2;
	else if (in_softirq())
		rctx = 1;
	else
		rctx = 0;

	if (recursion[rctx])
		return -1;

	recursion[rctx]++;
	barrier();

	return rctx;
}

>  - try to figure out why intel_pmu_handle_irq() faults and add a
> (kmemcheck-specific) workaround for it

Well, that's easy, we access user memory, which might or might not be
there.

We do this for a number of reasons; one is to read the code and decode
the current basic block to find the previous instruction; see
intel_pmu_pebs_fixup_ip() another is to try and walk the userspace
framepointers, see perf_callchain_user().

In all cases we use 'atomic' accesses which return short copies in case
of failure; we take the fault handler exception path, and we abort the
operation.

> Incidentally, do you remember what exactly changed wrt page faults in
> NMI context?

Sure; commit 3f3c8b8c4b2a34776c3470142a7c8baafcda6eb0 and a fair number
of 'fixes', in particular: 7fbb98c5cb07563d3ee08714073a8e5452a96be2.

These patches made it possible to take faults from NMI context.
Previously this was not possible because we return from the fault using
IRET and IRET unconditionally re-enables NMIs, which is a bit of a
problem when you're still running the NMI handler.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
