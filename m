Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 873386B0044
	for <linux-mm@kvack.org>; Fri,  8 Jan 2010 11:20:14 -0500 (EST)
Date: Fri, 8 Jan 2010 14:18:28 -0200
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [PATCH v3 00/12] KVM: Add host swap event notifications for PV
	guest
Message-ID: <20100108161828.GA30404@amt.cnet>
References: <1262700774-1808-1-git-send-email-gleb@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1262700774-1808-1-git-send-email-gleb@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, avi@redhat.com, mingo@elte.hu, a.p.zijlstra@chello.nl, tglx@linutronix.de, hpa@zytor.com, riel@redhat.com, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 05, 2010 at 04:12:42PM +0200, Gleb Natapov wrote:
> KVM virtualizes guest memory by means of shadow pages or HW assistance
> like NPT/EPT. Not all memory used by a guest is mapped into the guest
> address space or even present in a host memory at any given time.
> When vcpu tries to access memory page that is not mapped into the guest
> address space KVM is notified about it. KVM maps the page into the guest
> address space and resumes vcpu execution. If the page is swapped out
> from host memory vcpu execution is suspended till the page is not swapped
> into the memory again. This is inefficient since vcpu can do other work
> (run other task or serve interrupts) while page gets swapped in.
> 
> To overcome this inefficiency this patch series implements "asynchronous
> page fault" for paravirtualized KVM guests. If a page that vcpu is
> trying to access is swapped out KVM sends an async PF to the vcpu
> and continues vcpu execution. Requested page is swapped in by another
> thread in parallel.  When vcpu gets async PF it puts faulted task to
> sleep until "wake up" interrupt is delivered. When the page is brought
> to the host memory KVM sends "wake up" interrupt and the guest's task
> resumes execution.

Some high level comments:

- cr2 used as token: better use the shared region? what if:
 
 async pf queued
 guest triple faults without a vmexit
 inject async-pf-done with token in cr2

Also, in such scenario, can't you potentially corrupt guest memory after
the triple fault by writing to the previously registered shared region
address?

- The token can overflow relatively easy. Use u64?

- Does it really inject interrupts for non-pv guests while waiting
for swapin? Can't see that. Wish it was more geared towards fv.

- Please share some perf numbers.

- Limit the number of queued async pf's per guest ?

- Unify gfn_to_pfn / gfn_to_pfn_async code in the pf handlers (easier
to review).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
