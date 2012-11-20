Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 0FAD66B004D
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 18:01:36 -0500 (EST)
Received: by mail-lb0-f169.google.com with SMTP id gk1so6116590lbb.14
        for <linux-mm@kvack.org>; Tue, 20 Nov 2012 15:01:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121120094132.GA15156@gmail.com>
References: <1353291284-2998-1-git-send-email-mingo@kernel.org>
 <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com>
 <20121120060014.GA14065@gmail.com> <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com> <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com>
 <20121120090637.GA14873@gmail.com> <20121120094132.GA15156@gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 20 Nov 2012 15:01:13 -0800
Message-ID: <CALCETrVVQXbHvWaT9HLHgk6cbMT9EHGrsGJptVS+66OMDmnGYA@mail.gmail.com>
Subject: Re: [patch] x86/vsyscall: Add Kconfig option to use native vsyscalls,
 switch to it
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Tue, Nov 20, 2012 at 1:41 AM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>> >      0.10%  [kernel]          [k] __do_page_fault
>> >      0.08%  [kernel]          [k] handle_mm_fault
>> >      0.08%  libjvm.so         [.] os::javaTimeMillis()
>> >      0.08%  [kernel]          [k] emulate_vsyscall
>>
>> Oh, finally a clue: you seem to have vsyscall emulation
>> overhead!
>>
>> Vsyscall emulation is fundamentally page fault driven - which
>> might explain why you are seeing page fault overhead. It might
>> also interact with other sources of faults - such as
>> numa/core's working set probing ...
>>
>> Many JVMs try to be smart with the vsyscall. As a test, does
>> the vsyscall=native boot option change the results/behavior in
>> any way?
>
> As a blind shot into the dark, does the attached patch help?
>
> If that's the root cause then it should measurably help mainline
> SPECjbb performance as well. It could turn numa/core from a
> regression into a win on your system.
>
> Thanks,
>
>         Ingo
>
> ----------------->
> Subject: x86/vsyscall: Add Kconfig option to use native vsyscalls, switch to it
> From: Ingo Molnar <mingo@kernel.org>
>
> Apparently there's still plenty of systems out there triggering
> the vsyscall emulation page faults - causing hard to track down
> performance regressions on page fault intense workloads...
>
> Some people seem to have run into that with threading-intense
> Java workloads.
>
> So until there's a better solution to this, add a Kconfig switch
> to make the vsyscall mode configurable and turn native vsyscall
> support back on by default.
>

I'm not sure the default should be changed.  Presumably only a
smallish minority of users are affected, and all of their code still
*works* -- it's just a little bit slower.

>
> +config X86_VSYSCALL_COMPAT
> +       bool "vsyscall compatibility"
> +       default y
> +       help

This is IMO misleading.  Perhaps the option should be
X86_VSYSCALL_EMULATION.  A description like "compatibility" makes
turning it on sound like a no-brainer.

Perhaps the vsyscall emulation code should be tweaked to warn if it's
getting called more than, say, 1k times per second.  The kernel could
log something like "Detected large numbers of emulated vsyscalls.
Consider upgading, setting vsyscall=native, or adjusting
CONFIG_X86_WHATEVER."


> +         vsyscalls, as global executable pages, can be a security hole
> +         escallation helper by exposing an easy shell code target with

escalation?

> +         a predictable address.
> +
> +         Many versions of glibc rely on the vsyscall page though, so it
> +         cannot be eliminated unconditionally. If you disable this
> +         option these systems will still work but might incur the overhead
> +         of vsyscall emulation page faults.
> +
> +         The vsyscall=none, vsyscall=emulate, vsyscall=native kernel boot
> +         option can be used to override this mode as well.
> +
> +         Keeping this option enabled leaves the vsyscall page enabled,
> +         i.e. vsyscall=native. Disabling this option means vsyscall=emulate.
> +
> +         If unsure, say Y.
> +

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
