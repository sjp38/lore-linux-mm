Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id DAAA26B0005
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 10:37:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so302218861pad.2
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 07:37:58 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id 190si3335065pfg.255.2016.08.02.07.37.57
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 07:37:58 -0700 (PDT)
Subject: Re: [PATCH 09/10] x86, pkeys: allow configuration of init_pkru
References: <20160729163009.5EC1D38C@viggo.jf.intel.com>
 <20160729163023.407672D2@viggo.jf.intel.com>
 <2cd6331c-7fa7-b358-6892-580bef430755@suse.cz>
From: Dave Hansen <dave@sr71.net>
Message-ID: <57A0B044.1010405@sr71.net>
Date: Tue, 2 Aug 2016 07:37:56 -0700
MIME-Version: 1.0
In-Reply-To: <2cd6331c-7fa7-b358-6892-580bef430755@suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, luto@kernel.org, mgorman@techsingularity.net, dave.hansen@linux.intel.com, arnd@arndb.de

On 08/02/2016 01:28 AM, Vlastimil Babka wrote:
> On 07/29/2016 06:30 PM, Dave Hansen wrote:
>> From: Dave Hansen <dave.hansen@linux.intel.com>
>> But, having PKRU be 0 (its init value) provides some nonzero
>> amount of optimization potential to the hardware.  It can, for
>> instance, skip writes to the XSAVE buffer when it knows that PKRU
>> is in its init state.
> 
> I'm not very happy with tuning options that need the admin to make
> choice between reliability and performance. Is there no way to to
> optimize similarly for a non-zero init state?

The init state is architecturally defined and the overhead comes from
hardware cost when the register is not in its 'init state'.  There's
nothing I can think of that we can do in software to work around this.

I did try a few things with our XSAVE/XRSTOR code to optimize this since
most tasks will have the same PKRU value, but they didn't pan out and
added more overhead than they removed.

>> The cost of losing this optimization is approximately 100 cycles
>> per context switch for a workload which lightly using XSAVE
>> state (something not using AVX much).  The overhead comes from a
>> combinaation of actually manipulating PKRU and the overhead of
>> pullin in an extra cacheline.
> 
> So the cost is in extra steps in software, not in hardware as you
> mentioned above?

There are two sources of overhead: a RDPKRU/WRPKRU pair of instructions
at fpu__clear() time (mostly called via execve()) and overhead in the
XSAVE and XRSTOR instructions that occurs at context-switch time.

Taking the PKRU state out of the 'init state' makes us read at least one
additional cacheline during XRSTOR, plus some additional work inside the
instruction that the processor has to do to shuffle registers in/out of
memory.  This, I consider hardware overhead.

>> This overhead is not huge, but it's also not something that I
>> think we should unconditionally inflict on everyone.
> 
> Here, everyone means really all processes on system, that never heard of
> PKEs, and pay the cost just because the kernel was configured for it?

Yes, all processes on all systems that have memory protection keys
enabled in hardware.  In a normal workload that's context switching 1000
times a second is about 3/100,000 cycles on a 3GHz processor, which I
haven't been able to measure other than instrumenting the XSAVE/XRSTOR
paths themselves.

I also expect the relative overhead to decrease as more pervasive AVX
use increases the overall overhead of XSAVE. (AVX state is ~1k and PKU's
64b of space pales in comparison).

> But in that case, all PTEs use the key 0 anyway, so the non-zero default
> actually provides no extra reliability/security?

Correct.  It provides no additional security or reliability for
processes not using protection keys.

> Seems suboptimal that
> admins of such system have to recognize such situation themselves and
> change the default?

To be honest, I don't think anyone will notice.  Most folks will run a
kernel with PKU support on the new hardware that contains this feature
from day one and they'll never know about the 0.003% performance penalty
that I *think* this might cause.  Say that the processor with protection
keys is 5% faster than its predecessor (made up number), it will now
appear to be 4.996% faster.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
