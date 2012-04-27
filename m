Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 398BA6B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 06:37:01 -0400 (EDT)
Received: by yenm8 with SMTP id m8so349300yen.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 03:37:00 -0700 (PDT)
Date: Fri, 27 Apr 2012 03:36:57 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC] vmalloc: add warning in __vmalloc
In-Reply-To: <1335516144-3486-1-git-send-email-minchan@kernel.org>
Message-ID: <alpine.DEB.2.00.1204270323000.11866@chino.kir.corp.google.com>
References: <1335516144-3486-1-git-send-email-minchan@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, npiggin@gmail.com, kamezawa.hiroyu@jp.fujitsu.com, kosaki.motohiro@gmail.com, Neil Brown <neilb@suse.de>, Artem Bityutskiy <dedekind1@gmail.com>, David Woodhouse <dwmw2@infradead.org>, Theodore Ts'o <tytso@mit.edu>, Adrian Hunter <adrian.hunter@intel.com>, Steven Whitehouse <swhiteho@redhat.com>, "David S. Miller" <davem@davemloft.net>, James Morris <jmorris@namei.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@newdream.net>

On Fri, 27 Apr 2012, Minchan Kim wrote:

> Now there are several places to use __vmalloc with GFP_ATOMIC,
> GFP_NOIO, GFP_NOFS but unfortunately __vmalloc calls map_vm_area
> which calls alloc_pages with GFP_KERNEL to allocate page tables.
> It means it's possible to happen deadlock.
> I don't know why it doesn't have reported until now.
> 
> Firstly, I tried passing gfp_t to lower functions to support __vmalloc
> with such flags but other mm guys don't want and decided that
> all of caller should be fixed.
> 
> http://marc.info/?l=linux-kernel&m=133517143616544&w=2
> 
> To begin with, let's listen other's opinion whether they can fix it
> by other approach without calling __vmalloc with such flags.
> 
> So this patch adds warning to detect and to be fixed hopely.
> I Cced related maintainers.
> If I miss someone, please Cced them.
> 
> side-note:
>   I added WARN_ON instead of WARN_ONCE to detect all of callers
>   and each WARN_ON for each flag to detect to use any flag easily.
>   After we fix all of caller or reduce such caller, we can merge
>   a warning with WARN_ONCE.
> 

I disagree with this approach since it's going to violently spam an 
innocent kernel user's log with no ratelimiting and for a situation that 
actually may not be problematic.

Passing any of these bits (the difference between GFP_KERNEL and 
GFP_ATOMIC) only means anything when we're going to do reclaim.  And I'm 
suspecting we would have seen problems with this already since 
pte_alloc_kernel() does __GFP_REPEAT on most architectures meaning that it 
will loop infinitely in the page allocator until at least one page is 
freed (since its an order-0 allocation) which would hardly ever happen if 
__GFP_FS or __GFP_IO actually meant something in this context.

In other words, we would already have seen these deadlocks and it would 
have been diagnosed as a vmalloc(GFP_ATOMIC) problem.  Where are those bug 
reports?

At best, you'd need _some_ sort of ratelimiting like a static variable and 
only allowing 100 WARN_ON()s which could output dozens of lines for each 
call to vmalloc().

But the page allocator already has a might_sleep_if(gfp_mask & GFP_WAIT) 
which will dump the stack for CONFIG_DEBUG_ATOMIC_SLEEP.  So for this 
effect, just enable that config option and check your kernel log.

So I'm afraid this is complete overkill for something that we can't prove 
is a problem in the first place and will potentially fill the kernel logs 
for warnings where the allocation succeeds immediately.  If you want the 
bug reports, ask people to enable CONFIG_DEBUG_ATOMIC_SLEEP.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
