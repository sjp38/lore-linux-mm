Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 3AD316B005A
	for <linux-mm@kvack.org>; Sun, 25 Nov 2012 21:11:21 -0500 (EST)
Received: by mail-oa0-f41.google.com with SMTP id k14so13219196oag.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2012 18:11:20 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20121123133138.GA28058@gmail.com>
References: <20121119162909.GL8218@suse.de>
	<20121119191339.GA11701@gmail.com>
	<20121119211804.GM8218@suse.de>
	<20121119223604.GA13470@gmail.com>
	<CA+55aFzQYH4qW_Cw3aHPT0bxsiC_Q_ggy4YtfvapiMG7bR=FsA@mail.gmail.com>
	<20121120071704.GA14199@gmail.com>
	<20121120152933.GA17996@gmail.com>
	<20121120175647.GA23532@gmail.com>
	<CAGjg+kHKaQLcrnEftB+2mjeCjGUBiisSOpNCe+_9-4LDho9LpA@mail.gmail.com>
	<20121122012122.GA7938@gmail.com>
	<20121123133138.GA28058@gmail.com>
Date: Mon, 26 Nov 2012 10:11:20 +0800
Message-ID: <CAGjg+kE8=cp=NyHrviyRWAZ=id6sZM1Gtb0N1_+SZ2TuBHE5cw@mail.gmail.com>
Subject: Re: numa/core regressions fixed - more testers wanted
From: Alex Shi <lkml.alex@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Alex Shi <alex.shi@intel.com>

On Fri, Nov 23, 2012 at 9:31 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> * Ingo Molnar <mingo@kernel.org> wrote:
>
>> * Alex Shi <lkml.alex@gmail.com> wrote:
>>
>> > >
>> > > Those of you who would like to test all the latest patches are
>> > > welcome to pick up latest bits at tip:master:
>> > >
>> > >    git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
>> > >
>> >
>> > I am wondering if it is a problem, but it still exists on HEAD: c418de93e39891
>> > http://article.gmane.org/gmane.linux.kernel.mm/90131/match=compiled+with+name+pl+and+start+it+on+my
>> >
>> > like when just start 4 pl tasks, often 3 were running on node
>> > 0, and 1 was running on node 1. The old balance will average
>> > assign tasks to different node, different core.
>>
>> This is "normal" in the sense that the current mainline
>> scheduler is (supposed to be) doing something similar: if the
>> node is still within capacity, then there's no reason to move
>> those threads.
>>
>> OTOH, I think with NUMA balancing we indeed want to spread
>> them better, if those tasks do not share memory with each
>> other but use their own memory. If they share memory then they
>> should remain on the same node if possible.

I rewrite the little test case by assemble:
==
.text

    .global _start

_start:

do_nop:
        nop
        nop
        jmp do_nop
==
It reproduced the problem on latest tip/master, HEAD: 7cb989d0159a6f43104992f18
like for 4 above tasks running, 3 of them running on node 0, one
running on node 1.

If kernel can detect the LLC of CPU is allowed for tasks aggregate, it's a nice
feature. if not, the aggregate may cause more cache missing.


>
> Could you please check tip:master with -v17:
>
>   git://git.kernel.org/pub/scm/linux/kernel/git/tip/tip.git master
>
> ?
>
> It should place your workload better than v16 did.
>
> Note, you might be able to find other combinations of tasks that
> are not scheduled NUMA-perfectly yet, as task group placement is
> not exhaustive yet.
>
> You might want to check which combination looks the weirdest to
> you and report it, so I can fix any remaining placement
> inefficiencies in order of importance.
>
> Thanks,
>
>         Ingo



-- 
Thanks
    Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
