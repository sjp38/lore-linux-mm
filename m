Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f176.google.com (mail-ob0-f176.google.com [209.85.214.176])
	by kanga.kvack.org (Postfix) with ESMTP id D61136B0009
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 12:35:42 -0500 (EST)
Received: by mail-ob0-f176.google.com with SMTP id ba1so68947014obb.3
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:35:42 -0800 (PST)
Received: from mail-ob0-x22a.google.com (mail-ob0-x22a.google.com. [2607:f8b0:4003:c01::22a])
        by mx.google.com with ESMTPS id i64si15736445oif.58.2016.01.29.09.35.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 09:35:41 -0800 (PST)
Received: by mail-ob0-x22a.google.com with SMTP id ny8so47196363obc.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 09:35:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20160129142625.GH10187@pd.tnic>
References: <cover.1453746505.git.luto@kernel.org> <e3e4f31df42ea5d5e190a6d1e300e01d55e09d79.1453746505.git.luto@kernel.org>
 <20160129142625.GH10187@pd.tnic>
From: Andy Lutomirski <luto@amacapital.net>
Date: Fri, 29 Jan 2016 09:35:22 -0800
Message-ID: <CALCETrWhUWjfdDS6eyB6PfrJLU8YvvrfkeeKFTo8moxq7L5t6A@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] x86/mm: If INVPCID is available, use it to flush
 global mappings
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>, X86 ML <x86@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Brian Gerst <brgerst@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Fri, Jan 29, 2016 at 6:26 AM, Borislav Petkov <bp@alien8.de> wrote:
> On Mon, Jan 25, 2016 at 10:37:44AM -0800, Andy Lutomirski wrote:
>> On my Skylake laptop, INVPCID function 2 (flush absolutely
>> everything) takes about 376ns, whereas saving flags, twiddling
>> CR4.PGE to flush global mappings, and restoring flags takes about
>> 539ns.
>
> FWIW, I ran your microbenchmark on the IVB laptop I have here 3 times
> and some of the numbers from each run are pretty unstable. Not that it
> means a whole lot - the thing doesn't have INVPCID support.
>
> I'm just questioning the microbenchmark and whether we should be rather
> doing those measurements with a real benchmark, whatever that means. My
> limited experience says that measuring TLB performance is hard.
>
>  ./context_switch_latency 0 thread same
>  use_xstate = 0
>  Using threads
> 1: 100000 iters at 2676.2 ns/switch
> 2: 100000 iters at 2700.2 ns/switch
> 3: 100000 iters at 2656.1 ns/switch
>
>  ./context_switch_latency 0 thread different
>  use_xstate = 0
>  Using threads
> 1: 100000 iters at 5174.8 ns/switch
> 2: 100000 iters at 5140.5 ns/switch
> 3: 100000 iters at 5292.9 ns/switch
>
>  ./context_switch_latency 0 process same
>  use_xstate = 0
>  Using a subprocess
> 1: 100000 iters at 2361.2 ns/switch
> 2: 100000 iters at 2332.2 ns/switch
> 3: 100000 iters at 3436.9 ns/switch
>
>  ./context_switch_latency 0 process different
>  use_xstate = 0
>  Using a subprocess
> 1: 100000 iters at 4713.6 ns/switch
> 2: 100000 iters at 4957.5 ns/switch
> 3: 100000 iters at 5012.2 ns/switch
>
>  ./context_switch_latency 1 thread same
>  use_xstate = 1
>  Using threads
> 1: 100000 iters at 2505.6 ns/switch
> 2: 100000 iters at 2483.1 ns/switch
> 3: 100000 iters at 2479.7 ns/switch
>
>  ./context_switch_latency 1 thread different
>  use_xstate = 1
>  Using threads
> 1: 100000 iters at 5245.9 ns/switch
> 2: 100000 iters at 5241.1 ns/switch
> 3: 100000 iters at 5220.3 ns/switch
>
>  ./context_switch_latency 1 process same
>  use_xstate = 1
>  Using a subprocess
> 1: 100000 iters at 2329.8 ns/switch
> 2: 100000 iters at 2350.2 ns/switch
> 3: 100000 iters at 2500.9 ns/switch
>
>  ./context_switch_latency 1 process different
>  use_xstate = 1
>  Using a subprocess
> 1: 100000 iters at 4970.7 ns/switch
> 2: 100000 iters at 5034.0 ns/switch
> 3: 100000 iters at 4991.6 ns/switch
>

I'll fiddle with that benchmark a little bit.  Maybe I can make it
suck less.  If anyone knows a good non-micro benchmark for this, let
me know.  I refuse to use dbus as my benchmark :)

FWIW, I benchmarked cr4 vs invpcid by adding a prctl and calling it in
a loop.  If Ingo's fpu benchmark thing ever lands, I'll gladly send a
patch to add TLB flushes to it.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
