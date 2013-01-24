Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id E5D5F6B0008
	for <linux-mm@kvack.org>; Thu, 24 Jan 2013 00:50:44 -0500 (EST)
Date: Thu, 24 Jan 2013 14:50:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC/PATCH] scripts/tracing: Add trace_analyze.py tool
Message-ID: <20130124055042.GE22654@blaptop>
References: <1358848018-3679-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <20130123042714.GD2723@blaptop>
 <CALF0-+V6D1Ka9SNyrgRAgTSGLUTp_9y4vYwauSx1qCfU-JOwjA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALF0-+V6D1Ka9SNyrgRAgTSGLUTp_9y4vYwauSx1qCfU-JOwjA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tim Bird <tim.bird@am.sony.com>, Pekka Enberg <penberg@kernel.org>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>

On Wed, Jan 23, 2013 at 06:37:56PM -0300, Ezequiel Garcia wrote:
> Hi Minchan,
> 
> On Wed, Jan 23, 2013 at 1:27 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Hi Ezequiel,
> >
> > On Tue, Jan 22, 2013 at 06:46:58AM -0300, Ezequiel Garcia wrote:
> >> From: Ezequiel Garcia <elezegarcia@gmail.com>
> >>
> >> The purpose of trace_analyze.py tool is to perform static
> >> and dynamic memory analysis using a kmem ftrace
> >> log file and a built kernel tree.
> >>
> >> This script and related work has been done on the CEWG/2012 project:
> >> "Kernel dynamic memory allocation tracking and reduction"
> >> (More info here [1])
> >>
> >> It produces mainly two kinds of outputs:
> >>  * an account-like output, similar to the one given by Perf, example below.
> >>  * a ring-char output, examples here [2].
> >>
> >> $ ./scripts/tracing/trace_analyze.py -k linux -f kmem.log --account-file account.txt
> >> $ ./scripts/tracing/trace_analyze.py -k linux -f kmem.log -c account.txt
> >>
> >> This will produce an account file like this:
> >>
> >>     current bytes allocated:     669696
> >>     current bytes requested:     618823
> >>     current wasted bytes:         50873
> >>     number of allocs:              7649
> >>     number of frees:               2563
> >>     number of callers:              115
> >>
> >>      total    waste      net alloc/free  caller
> >>     ---------------------------------------------
> >>     299200        0   298928  1100/1     alloc_inode+0x4fL
> >>     189824        0   140544  1483/385   __d_alloc+0x22L
> >>      51904        0    47552   811/68    sysfs_new_dirent+0x4eL
> >>     [...]
> >>
> >> [1] http://elinux.org/Kernel_dynamic_memory_analysis
> >> [2] http://elinux.org/Kernel_dynamic_memory_analysis#Current_dynamic_footprint
> >
> > First of all, Thanks for nice work! It could be very useful for
> > embedded side.
> >
> > Questions.
> >
> > 1. Can we detect different call path but same function?
> >    I mean
> >
> >         A       C
> >          \     /
> >           B   D
> >            \ /
> >             E
> >             |
> >          kmalloc
> >
> > In this case, E could be called by A or C. I would like to know the call path.
> > It could point out exact culprit of memory hogger.
> >
> 
> I'm sorry, I'm not following you:
> How can I know which caller in the call path is the 'real' responsible
> for the allocation?
> 
> The only way I can think of achieving something like this is by using
> kmalloc_track_caller() instead of kmalloc().
> This is done in cases where an allocer is known to alloc memory on
> behalf of its caller.

I mean following as.

It's a example from page_owner about alloc_pages.
I'm not sure it's good example but it could give my intent.

358 times:
Page allocated via order 1, mask 0x2852d0
 [<ffffffff811654f5>] new_slab+0x2d5/0x370
 [<ffffffff815705a8>] __slab_alloc+0x2bb/0x41c
 [<ffffffff811682ac>] kmem_cache_alloc+0x18c/0x1a0
 [<ffffffff8118ac07>] __d_alloc+0x27/0x180
 [<ffffffff8118b038>] d_alloc+0x28/0x80
 [<ffffffff8117d313>] lookup_dcache+0xa3/0xd0
 [<ffffffff8117d363>] __lookup_hash+0x23/0x50
 [<ffffffff8157076a>] lookup_slow+0x49/0xad

..
..

1 times:
Page allocated via order 1, mask 0x2852d0
 [<ffffffff811654f5>] new_slab+0x2d5/0x370
 [<ffffffff815705a8>] __slab_alloc+0x2bb/0x41c
 [<ffffffff811682ac>] kmem_cache_alloc+0x18c/0x1a0
 [<ffffffff8118ac07>] __d_alloc+0x27/0x180
 [<ffffffff8118b038>] d_alloc+0x28/0x80
 [<ffffffff8117d313>] lookup_dcache+0xa3/0xd0
 [<ffffffff8117d363>] __lookup_hash+0x23/0x50
 [<ffffffff81181126>] lookup_one_len+0xd6/0x130

>From above example, alloc_pages could be called from several path
The one path is lookup_slow and another is lookup_one_len so
I can investigate who asks lookup_slow frequently.

> 
> > 2. Does it support alloc_pages family?
> >    kmem event trace already supports it. If it supports, maybe we can replace
> >    CONFIG_PAGE_OWNER hack.
> >
> 
> Mmm.. no, it doesn't support alloc_pages and friends, for we found
> no reason to do it.
> However, it sounds like a nice idea, on a first thought.
> 
> I'll review CONFIG_PAGE_OWNER patches and see if I can come up with something.

Thanks!

> 
> Meantime, and given this is just a script submission, is there anything
> preventing to merge this? We can move it to perf, and/or add it
> features, etc. later,
> on top of this. Does this make sense?
> 
> -- 
>     Ezequiel
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
