Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E70D36B0072
	for <linux-mm@kvack.org>; Sat, 17 Nov 2012 10:25:11 -0500 (EST)
Message-ID: <50A7AC33.5060308@redhat.com>
Date: Sat, 17 Nov 2012 10:24:35 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] x86,mm: drop TLB flush from ptep_set_access_flags
References: <CA+55aFx2fSdDcFxYmu00JP9rHiZ1BjH3tO4CfYXOhf_rjRP_Eg@mail.gmail.com> <CANN689EHj2inp+wjJGcqMHZQUV3Xm+3dAkLPOsnV4RZU+Kq5nA@mail.gmail.com> <m2pq45qu0s.fsf@firstfloor.org> <508A8D31.9000106@redhat.com> <20121026132601.GC9886@gmail.com> <20121026144502.6e94643e@dull> <20121026221254.7d32c8bf@pyramind.ukuu.org.uk> <508BE459.2080406@redhat.com> <20121029165705.GA4693@x1.osrc.amd.com> <CA+55aFzbwaHxWPkJ-t-TEh9hUwmA+D-unHGuJ7FPx7ULmrwKMg@mail.gmail.com> <20121117145015.GF16441@x1.osrc.amd.com> <CA+55aFxunZ94QkhxUKB0iJ0p1mFuWGzr0mR8icM=XJZadcSuRw@mail.gmail.com>
In-Reply-To: <CA+55aFxunZ94QkhxUKB0iJ0p1mFuWGzr0mR8icM=XJZadcSuRw@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Borislav Petkov <bp@alien8.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>, Ingo Molnar <mingo@kernel.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Thomas Gleixner <tglx@linutronix.de>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Florian Fainelli <florian@openwrt.org>, Borislav Petkov <borislav.petkov@amd.com>

On 11/17/2012 09:56 AM, Linus Torvalds wrote:
> On Sat, Nov 17, 2012 at 6:50 AM, Borislav Petkov <bp@alien8.de> wrote:
>> I don't know, however, whether it would be prudent to have some sort of
>> a cheap assertion in the code (cheaper than INVLPG %ADDR, although on
>> older cpus we do MOV CR3) just in case. This should be enabled only with
>> DEBUG_VM on, of course...
>
> I wonder how we could actually test for it. We'd have to have some
> per-cpu page-fault address check (along with a generation count on the
> mm or similar). I doubt we'd figure out anything that works reliably
> and efficiently and would actually show any problems

Would it be enough to simply print out a warning if we fault
on the same address twice (or three times) in a row, and then
flush the local TLB?

I realize this would not just trigger on CPUs that fail to
invalidate TLB entries that cause faults, but also on kernel
paths that cause a page fault to be re-taken...

... but then again, don't we want to find those paths and
fix them, anyway? :)

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
