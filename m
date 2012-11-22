Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id BB47B6B0062
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 23:31:15 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id bj3so1612469pad.14
        for <linux-mm@kvack.org>; Wed, 21 Nov 2012 20:31:15 -0800 (PST)
Date: Wed, 21 Nov 2012 20:31:12 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 00/27] Latest numa/core release, v16
In-Reply-To: <20121121172046.GA28975@gmail.com>
Message-ID: <alpine.DEB.2.00.1211212021030.12667@chino.kir.corp.google.com>
References: <20121119162909.GL8218@suse.de> <alpine.DEB.2.00.1211191644340.24618@chino.kir.corp.google.com> <alpine.DEB.2.00.1211191703270.24618@chino.kir.corp.google.com> <20121120060014.GA14065@gmail.com> <alpine.DEB.2.00.1211192213420.5498@chino.kir.corp.google.com>
 <20121120074445.GA14539@gmail.com> <alpine.DEB.2.00.1211200001420.16449@chino.kir.corp.google.com> <20121120090637.GA14873@gmail.com> <CA+55aFyR9FsGYWSKkgsnZB7JhheDMjEQgbzb0gsqawSTpetPvA@mail.gmail.com> <20121121171047.GA28875@gmail.com>
 <20121121172046.GA28975@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>

On Wed, 21 Nov 2012, Ingo Molnar wrote:

> Btw., what I did was to simply look at David's profile on the 
> regressing system and I compared it to the profile I got on a 
> pretty similar (but unfortunately not identical and not 
> regressing) system. I saw 3 differences:
> 
>  - the numa emulation faults
>  - the higher TLB miss cost
>  - numa/core's failure to handle 4K pages properly
> 
> And addressed those, in the hope of one of them making a
> difference.
> 

I agree that it's worth a try and if it's helpful to your debugging then 
I'll always commit to trying things out.  I've pulled tip#master at 
9f7b91a96bb6 ("Merge branch 'x86/urgent'") and performance improves 0.3% 
with 16 warehouses with vsyscall=emulate, i.e. a revert of 01e9c2441eee 
("x86/vsyscall: Add Kconfig option to use native vsyscalls and switch to 
it") so I'd recommend that gets dropped based on my results and Andy's 
feedback unless anybody can demonstrate it's better (which very well may 
be the case on some systems, but then again that's why its configurable 
from the command line).

You're also completely right about the old glibc, mine is seven years old; 
I can upgrade that since I need to install libnuma as well on this box 
since you asked for the autonuma topology information that I haven't 
forgotten about but will definitely get around to doing.

> There's a fourth line of inquiry I'm pursuing as well: the node 
> assymetry that David and Paul mentioned could have a performance 
> effect as well - resulting from non-ideal placement under 
> numa/core.
> 
> That is not easy to cure - I have written a patch to take the 
> node assymetry into consideration, I'm still testing it with 
> David's topology simulated on a testbox:
> 
>    numa=fake=4:10,20,20,30,20,10,20,20,20,20,10,20,30,20,20,10
> 

This very much may be the case and that characteristic of this box is why 
I picked it to test with first.  Just curious what types of topologies 
you've benchmarked on for your results if you have that available?  An 
early version of sched/numa used to panic on this machine and Peter was 
interested in its topology (see https://lkml.org/lkml/2012/5/25/89) so 
perhaps I'm the only one testing with such a thing thus far?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
