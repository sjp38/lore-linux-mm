Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk1-f197.google.com (mail-vk1-f197.google.com [209.85.221.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6A648E0001
	for <linux-mm@kvack.org>; Thu, 10 Jan 2019 18:13:20 -0500 (EST)
Received: by mail-vk1-f197.google.com with SMTP id p73so2574499vka.21
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:13:20 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e24sor44339535uah.50.2019.01.10.15.13.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 Jan 2019 15:13:18 -0800 (PST)
Received: from mail-vs1-f42.google.com (mail-vs1-f42.google.com. [209.85.217.42])
        by smtp.gmail.com with ESMTPSA id k200sm30916778vke.9.2019.01.10.15.13.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 10 Jan 2019 15:13:16 -0800 (PST)
Received: by mail-vs1-f42.google.com with SMTP id v205so8114304vsc.3
        for <linux-mm@kvack.org>; Thu, 10 Jan 2019 15:13:16 -0800 (PST)
MIME-Version: 1.0
References: <cover.1547153058.git.khalid.aziz@oracle.com>
In-Reply-To: <cover.1547153058.git.khalid.aziz@oracle.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 10 Jan 2019 15:07:38 -0800
Message-ID: <CAGXu5jKS8XSw7nByaeXqgPbmRRw01E_zUYxLCk7zFepAVSw_aQ@mail.gmail.com>
Subject: Re: [RFC PATCH v7 00/16] Add support for eXclusive Page Frame Ownership
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Juerg Haefliger <juergh@gmail.com>, Tycho Andersen <tycho@tycho.ws>, jsteckli@amazon.de, Andi Kleen <ak@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, liran.alon@oracle.com, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, deepa.srinivasan@oracle.com, chris hyser <chris.hyser@oracle.com>, Tyler Hicks <tyhicks@canonical.com>, "Woodhouse, David" <dwmw@amazon.co.uk>, Andrew Cooper <andrew.cooper3@citrix.com>, Jon Masters <jcm@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, kanth.ghatraju@oracle.com, joao.m.martins@oracle.com, Jim Mattson <jmattson@google.com>, pradeep.vincent@oracle.com, John Haxby <john.haxby@oracle.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Hellwig <hch@lst.de>, steven.sistare@oracle.com, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>

On Thu, Jan 10, 2019 at 1:10 PM Khalid Aziz <khalid.aziz@oracle.com> wrote:
> I implemented a solution to reduce performance penalty and
> that has had large impact. When XPFO code flushes stale TLB entries,
> it does so for all CPUs on the system which may include CPUs that
> may not have any matching TLB entries or may never be scheduled to
> run the userspace task causing TLB flush. Problem is made worse by
> the fact that if number of entries being flushed exceeds
> tlb_single_page_flush_ceiling, it results in a full TLB flush on
> every CPU. A rogue process can launch a ret2dir attack only from a
> CPU that has dual mapping for its pages in physmap in its TLB. We
> can hence defer TLB flush on a CPU until a process that would have
> caused a TLB flush is scheduled on that CPU. I have added a cpumask
> to task_struct which is then used to post pending TLB flush on CPUs
> other than the one a process is running on. This cpumask is checked
> when a process migrates to a new CPU and TLB is flushed at that
> time. I measured system time for parallel make with unmodified 4.20
> kernel, 4.20 with XPFO patches before this optimization and then
> again after applying this optimization. Here are the results:
>
> Hardware: 96-core Intel Xeon Platinum 8160 CPU @ 2.10GHz, 768 GB RAM
> make -j60 all
>
> 4.20                            915.183s
> 4.20+XPFO                       24129.354s      26.366x
> 4.20+XPFO+Deferred flush        1216.987s        1.330xx
>
>
> Hardware: 4-core Intel Core i5-3550 CPU @ 3.30GHz, 8G RAM
> make -j4 all
>
> 4.20                            607.671s
> 4.20+XPFO                       1588.646s       2.614x
> 4.20+XPFO+Deferred flush        794.473s        1.307xx

Well that's an impressive improvement! Nice work. :)

(Are the cpumask improvements possible to be extended to other TLB
flushing needs? i.e. could there be other performance gains with that
code even for a non-XPFO system?)

> 30+% overhead is still very high and there is room for improvement.
> Dave Hansen had suggested batch updating TLB entries and Tycho had
> created an initial implementation but I have not been able to get
> that to work correctly. I am still working on it and I suspect we
> will see a noticeable improvement in performance with that. In the
> code I added, I post a pending full TLB flush to all other CPUs even
> when number of TLB entries being flushed on current CPU does not
> exceed tlb_single_page_flush_ceiling. There has to be a better way
> to do this. I just haven't found an efficient way to implemented
> delayed limited TLB flush on other CPUs.
>
> I am not entirely sure if switch_mm_irqs_off() is indeed the right
> place to perform the pending TLB flush for a CPU. Any feedback on
> that will be very helpful. Delaying full TLB flushes on other CPUs
> seems to help tremendously, so if there is a better way to implement
> the same thing than what I have done in patch 16, I am open to
> ideas.

Dave, Andy, Ingo, Thomas, does anyone have time to look this over?

> Performance with this patch set is good enough to use these as
> starting point for further refinement before we merge it into main
> kernel, hence RFC.
>
> Since not flushing stale TLB entries creates a false sense of
> security, I would recommend making TLB flush mandatory and eliminate
> the "xpfotlbflush" kernel parameter (patch "mm, x86: omit TLB
> flushing by default for XPFO page table modifications").

At this point, yes, that does seem to make sense.

> What remains to be done beyond this patch series:
>
> 1. Performance improvements
> 2. Remove xpfotlbflush parameter
> 3. Re-evaluate the patch "arm64/mm: Add support for XPFO to swiotlb"
>    from Juerg. I dropped it for now since swiotlb code for ARM has
>    changed a lot in 4.20.
> 4. Extend the patch "xpfo, mm: Defer TLB flushes for non-current
>    CPUs" to other architectures besides x86.

This seems like a good plan.

I've put this series in one of my tree so that 0day will find it and
grind tests...
https://git.kernel.org/pub/scm/linux/kernel/git/kees/linux.git/log/?h=kspp/xpfo/v7

Thanks!

-- 
Kees Cook
