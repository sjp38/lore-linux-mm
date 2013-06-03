Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id C05B76B006C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 06:02:00 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id v10so422433pde.4
        for <linux-mm@kvack.org>; Mon, 03 Jun 2013 03:01:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20130603091621.GA23320@gmail.com>
References: <CAMo8BfL4QfJrfejNKmBDhAVdmE=_Ys6MVUH5Xa3w_mU41hwx0A@mail.gmail.com>
 <CAMo8BfJie1Y49QeSJ+JTQb9WsYJkMMkb1BkKz2Gzy3T7V6ogHA@mail.gmail.com>
 <51A45861.1010008@gmail.com> <20130529122728.GA27176@twins.programming.kicks-ass.net>
 <51A5F7A7.5020604@synopsys.com> <20130529175125.GJ12193@twins.programming.kicks-ass.net>
 <CAMo8BfJtkEtf9RKsGRnOnZ5zbJQz5tW4HeDfydFq_ZnrFr8opw@mail.gmail.com>
 <20130603090501.GI5910@twins.programming.kicks-ass.net> <20130603091621.GA23320@gmail.com>
From: Catalin Marinas <catalin.marinas@arm.com>
Date: Mon, 3 Jun 2013 11:01:39 +0100
Message-ID: <CAHkRjk7D=PAMgaqjGQ0t3e5Ftob2Z248uexvKGb0tWpycEMK6Q@mail.gmail.com>
Subject: Re: TLB and PTE coherency during munmap
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Max Filippov <jcmvbkbc@gmail.com>, Vineet Gupta <Vineet.Gupta1@synopsys.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>, Chris Zankel <chris@zankel.net>, Marc Gauthier <Marc.Gauthier@tensilica.com>, linux-xtensa@linux-xtensa.org, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On 3 June 2013 10:16, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Peter Zijlstra <peterz@infradead.org> wrote:
>
>> On Fri, May 31, 2013 at 08:09:17AM +0400, Max Filippov wrote:
>> > Hi Peter,
>> >
>> > On Wed, May 29, 2013 at 9:51 PM, Peter Zijlstra <peterz@infradead.org> wrote:
>> > > What about something like this?
>> >
>> > With that patch I still get mtest05 firing my TLB/PTE incoherency
>> > check in the UP PREEMPT_VOLUNTARY configuration. This happens after
>> > zap_pte_range completion in the end of unmap_region because of
>> > rescheduling called in the following call chain:
>>
>> OK, so there two options; completely kill off fast-mode or something
>> like the below where we add magic to the scheduler :/
>>
>> I'm aware people might object to something like the below -- but since
>> its a possibility I thought we ought to at least mention it.
>>
>> For those new to the thread; the problem is that since the introduction
>> of preemptible mmu_gather the traditional UP fast-mode is broken.
>> Fast-mode is where we free the pages first and flush TLBs later. This is
>> not a problem if there's no concurrency, but obviously if you can
>> preempt there now is.
>>
>> I think I prefer completely killing off fast-mode esp. since UP seems to
>> go the way of the Dodo and it does away with an exception in the
>> mmu_gather code.
>>
>> Anyway; opinions? Linus, Thomas, Ingo?
>
> Since UP kernels have not been packaged up by major distros for years, and
> since the live-patching of SMP kernels (the SMP alternative-instructions
> patching machinery) does away with a big chunk of the SMP cost, I guess UP
> kernels are slowly becoming like TINY_RCU: interesting but not really a
> primary design goal?
>
> ( Another reason for reducing SMP vs. UP complexity in this area would be
>   the fact that we had a few bad regressions lately - the TLB code is not
>   getting simpler, and bugs are getting discovered and fixed slower. )
>
> At least that's the x86 perspective. ARM might still see it differently?

On ARM there is a lot of ongoing work on single zImage for multiple
SoCs and this implies SMP kernels. There is an SMP_ON_UP feature which
does run-time code patching to optimise the UP case in a few places.

Regarding tlb_fast_mode(), the ARM-specific implementation is always 0
on ARMv7 even if UP because of speculative TLB loads (the MMU could
pretty much act as a separate processor).

Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
