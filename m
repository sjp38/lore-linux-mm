Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id D803C6B0253
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 07:16:21 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id t79so10224ota.7
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 04:16:21 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id u85si776oie.493.2017.12.05.04.16.20
        for <linux-mm@kvack.org>;
        Tue, 05 Dec 2017 04:16:20 -0800 (PST)
Date: Tue, 5 Dec 2017 12:16:14 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [PATCH 1/2] mm: make faultaround produce old ptes
Message-ID: <20171205121614.ek45btdgrpbmvf45@armageddon.cambridge.arm.com>
References: <1511845670-12133-1-git-send-email-vinmenon@codeaurora.org>
 <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAADWXX8FmAs1qB9=fsWZjt8xTEnGOAMS=eCHnuDLJrZiX6x=7w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Vinayak Menon <vinmenon@codeaurora.org>, riel@redhat.com, jack@suse.cz, minchan@kernel.org, dave.hansen@linux.intel.com, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, ying.huang@intel.com, Andrew Morton <akpm@linux-foundation.org>, kirill.shutemov@linux.intel.com, mgorman@suse.de

On Tue, Nov 28, 2017 at 11:45:27AM -0800, Linus Torvalds wrote:
> On Mon, Nov 27, 2017 at 9:07 PM, Vinayak Menon <vinmenon@codeaurora.org> wrote:
> > Making the faultaround ptes old results in a unixbench regression for some
> > architectures [3][4]. But on some architectures it is not found to cause
> > any regression. So by default produce young ptes and provide an option for
> > architectures to make the ptes old.
> 
> Ugh. This hidden random behavior difference annoys me.
> 
> It should also be better documented in the code if we end up doing it.
> 
> The reason x86 seems to prefer young pte's is simply that a TLB lookup
> of an old entry basically causes a micro-fault that then sets the
> accessed bit (using a locked cycle) and then a restart.
> 
> Those microfaults are not visible to software, but they are pretty
> expensive in hardware, probably because they basically serialize
> execution as if a real page fault had happened.

In principle it's not that different for ARMv8.1+ but it highly depends
on the microarchitecture details (and we have a lot of variation on
ARM). From a programmer's perspective, old ptes (access flag cleared)
are not allowed to be cached in the TLB, otherwise ptep_clear_flush()
would break. Marking fault-around ptes as young allows the hardware to
speculatively populate the TLB but, again, it's highly microarchitecture
specific and I'm not sure we have a general answer covering the ARM
architecture. Of course, faulting on old ptes is much slower without
hardware AF.

> HOWEVER - and this is the part that annoys me most about the hidden
> behavior - I suspect it ends up being very dependent on
> microarchitectural details in addition to the actual load. So it might
> be more true on some cores than others, and it might be very
> load-dependent. So hiding it as some architectural helper function
> really feels wrong to me. It would likely be better off as a real
> flag, and then maybe we could make the default behavior be set by
> architecture (or even dynamically by the architecture bootup code if
> it turns out to be enough of an issue).

It looks to me like we are trying to work around a vmscan behaviour
visible under memory pressure [1]. The original report doesn't state
whether hardware AF is available (it seems to be tested on a 3.18
Android kernel; hardware AF on arm64 went in 4.6).

In this case there is a trade-off between swapping out potentially hot
pages vs page table walk (either in hardware or via software fault) for
fault-around ptes. This trade-off further depends on whether the
architecture can do hardware access flag or not.

I would be more in favour of some heuristics to dynamically reduce the
fault-around bytes based on the memory pressure rather than choosing
between young or old ptes. Or, if we are to go with old vs young ptes,
make this choice dependent on the memory pressure regardless of whether
the CPU supports hardware accessed bit.

[1] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
