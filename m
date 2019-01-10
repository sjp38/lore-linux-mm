Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id DDE6E8E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:40:07 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id a9so7151878pla.2
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:40:07 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id b60si25380382plc.95.2019.01.10.15.40.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:40:06 -0800 (PST)
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
References: <cover.1547153058.git.khalid.aziz@oracle.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
Date: Thu, 10 Jan 2019 15:40:04 -0800
MIME-Version: 1.0
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com
Cc: deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>

First of all, thanks for picking this back up.  It looks to be going in
a very positive direction!

On 1/10/19 1:09 PM, Khalid Aziz wrote:
> I implemented a solution to reduce performance penalty and
> that has had large impact. When XPFO code flushes stale TLB entries,
> it does so for all CPUs on the system which may include CPUs that
> may not have any matching TLB entries or may never be scheduled to
> run the userspace task causing TLB flush.
...
> A rogue process can launch a ret2dir attack only from a CPU that has 
> dual mapping for its pages in physmap in its TLB. We can hence defer 
> TLB flush on a CPU until a process that would have caused a TLB
> flush is scheduled on that CPU.

This logic is a bit suspect to me.  Imagine a situation where we have
two attacker processes: one which is causing page to go from
kernel->user (and be unmapped from the kernel) and a second process that
*was* accessing that page.

The second process could easily have the page's old TLB entry.  It could
abuse that entry as long as that CPU doesn't context switch
(switch_mm_irqs_off()) or otherwise flush the TLB entry.

As for where to flush the TLB...  As you know, using synchronous IPIs is
obviously the most bulletproof from a mitigation perspective.  If you
can batch the IPIs, you can get the overhead down, but you need to do
the flushes for a bunch of pages at once, which I think is what you were
exploring but haven't gotten working yet.

Anything else you do will have *some* reduced mitigation value, which
isn't a deal-breaker (to me at least).  Some ideas:

Take a look at the SWITCH_TO_KERNEL_CR3 in head_64.S.  Every time that
gets called, we've (potentially) just done a user->kernel transition and
might benefit from flushing the TLB.  We're always doing a CR3 write (on
Meltdown-vulnerable hardware) and it can do a full TLB flush based on if
X86_CR3_PCID_NOFLUSH_BIT is set.  So, when you need a TLB flush, you
would set a bit that ADJUST_KERNEL_CR3 would see on the next
user->kernel transition on *each* CPU.  Potentially, multiple TLB
flushes could be coalesced this way.  The downside of this is that
you're exposed to the old TLB entries if a flush is needed while you are
already *in* the kernel.

You could also potentially do this from C code, like in the syscall
entry code, or in sensitive places, like when you're returning from a
guest after a VMEXIT in the kvm code.
