Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f199.google.com (mail-it1-f199.google.com [209.85.166.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5308F8E0001
	for <linux-mm@kvack.org>; Fri, 11 Jan 2019 04:59:56 -0500 (EST)
Received: by mail-it1-f199.google.com with SMTP id v3so978884itf.4
        for <linux-mm@kvack.org>; Fri, 11 Jan 2019 01:59:56 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id 25si792052jar.92.2019.01.11.01.59.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 11 Jan 2019 01:59:55 -0800 (PST)
Date: Fri, 11 Jan 2019 10:59:32 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame
 Ownership
Message-ID: <20190111095932.GN30894@hirez.programming.kicks-ass.net>
References: <cover.1547153058.git.khalid.aziz@oracle.com>
 <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <31fe7522-0a59-94c8-663e-049e9ad2bff6@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Khalid Aziz <khalid.aziz@oracle.com>, juergh@gmail.com, tycho@tycho.ws, jsteckli@amazon.de, ak@linux.intel.com, torvalds@linux-foundation.org, liran.alon@oracle.com, keescook@google.com, konrad.wilk@oracle.com, deepa.srinivasan@oracle.com, chris.hyser@oracle.com, tyhicks@canonical.com, dwmw@amazon.co.uk, andrew.cooper3@citrix.com, jcm@redhat.com, boris.ostrovsky@oracle.com, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, jmattson@google.com, pradeep.vincent@oracle.com, john.haxby@oracle.com, tglx@linutronix.de, kirill.shutemov@linux.intel.com, hch@lst.de, steven.sistare@oracle.com, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andy Lutomirski <luto@kernel.org>

On Thu, Jan 10, 2019 at 03:40:04PM -0800, Dave Hansen wrote:
> Anything else you do will have *some* reduced mitigation value, which
> isn't a deal-breaker (to me at least).  Some ideas:
> 
> Take a look at the SWITCH_TO_KERNEL_CR3 in head_64.S.  Every time that
> gets called, we've (potentially) just done a user->kernel transition and
> might benefit from flushing the TLB.  We're always doing a CR3 write (on
> Meltdown-vulnerable hardware) and it can do a full TLB flush based on if
> X86_CR3_PCID_NOFLUSH_BIT is set.  So, when you need a TLB flush, you
> would set a bit that ADJUST_KERNEL_CR3 would see on the next
> user->kernel transition on *each* CPU.  Potentially, multiple TLB
> flushes could be coalesced this way.  The downside of this is that
> you're exposed to the old TLB entries if a flush is needed while you are
> already *in* the kernel.

I would really prefer not to depend on the PTI crud for new stuff. We
really want to get rid of that code on unaffected CPUs.
