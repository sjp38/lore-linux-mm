Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id F405128089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 19:10:44 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id q124so908299wmg.2
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 16:10:44 -0800 (PST)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id i44si10892244wra.237.2017.02.08.16.10.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 08 Feb 2017 16:10:43 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 2721298EDF
	for <linux-mm@kvack.org>; Thu,  9 Feb 2017 00:10:43 +0000 (UTC)
Date: Thu, 9 Feb 2017 00:10:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: PCID review?
Message-ID: <20170209001042.ahxmoqegr6h74mle@techsingularity.net>
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CALCETrVfah6AFG5mZDjVcRrdXKL=07+WC9ES9ZKU90XqVpWCOg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Nadav Amit <nadav.amit@gmail.com>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, Feb 08, 2017 at 12:51:24PM -0800, Andy Lutomirski wrote:
> On Tue, Feb 7, 2017 at 10:56 AM, Andy Lutomirski <luto@kernel.org> wrote:
> > Quite a few people have expressed interest in enabling PCID on (x86)
> > Linux.  Here's the code:
> >
> > https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
> >
> > The main hold-up is that the code needs to be reviewed very carefully.
> > It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
> > entries using PCID" ought to be looked at carefully to make sure the
> > locking is right, but there are plenty of other ways this this could
> > all break.
> >
> > Anyone want to take a look or maybe scare up some other reviewers?
> > (Kees, you seemed *really* excited about getting this in.)
> 
> Nadav pointed out that this doesn't work right with
> ARCH_WANT_BATCHED_UNMAP_TLB_FLUSH.  Mel, here's the issue:
> 

I confess I didn't read the thread or patch, I'm only looking at this
question.

> I want to add ASID (Intel calls it PCID) support to x86.  This means
> that "flush the TLB on a given CPU" will no longer be a particularly
> well defined operation because it's not clear which ASID tag to flush.
> Instead there's "flush the TLB for a given mm on a given CPU".
> 

Understood.

> If I'm understanding the batched flush code, all it's trying to do is
> to flush more than one mm at a time. 

More or less. It would be more accurate to say it's flushing any CPU TLB
that potentially accessed a list of pages recently.  It's not flushing
"multiple MMs at a time" as such, it's flushing "only CPUs that accessed
pages mapped by a mm recently". The distinction may not matter.

The requirements do matter though.

mm/vmscan.c is where TTU_BATCH_FLUSH is set and that is processing a list
of pages that can be mapped by multiple MMs.

The TLBs must be flushed before either IO starts (try_to_unmap_flush_dirty)
or they are freed to the page allocator (try_to_unmap_flush).

To do this, all it has to track is a simple mask of CPUs, whether a flush
is necessary and whether any of the PTEs were dirty. This is trivial to
assemble during an rmap walk as it's a PTE check and a cpumask_or.

try_to_unmap_flush then flushes the entire TLB as the cost of targetted
a specific page to flush was so high (both maintaining the PFNs and the
individual flush operations).

> Would it make sense to add a new
> arch API to flush more than one mm?  Presumably it would take a linked
> list, and the batched flush code would fall back to flushing in pieces
> if it can't allocate a new linked list node when needed.
> 

Conceptually it's ok but the details are a headache.

The defer code would need to maintain a list of mm's (or ASIDs) that is
unbounded in size to match the number of IPIs sent as the current code as
opposed to a simple cpumask. There are SWAP_CLUSTER_MAX pages to consider
with each page potentially mapped by an arbitrary number of MMs. The same
mm's could exist on multiple lists for each active kswapd instance and
direct reclaimer.

As multiple reclaimers are interested in the same mm, that pretty much
rules out linking them off mm_struct unless the locking would serialise
the parallel reclaimers and prevent an mm existing on more than one list
at a time. You could try allowing multiple tasks to share the one list
(not sure how to find that list quickly) but each entry would have to
be locked and as each user can flush at any time, multiple reclaimers
potentially have to block while an IPI is being sent. It's hard to see
how this could be scaled to match the existing code.

It would be easier to track via an array stored in task_struct but the
number of MMs is unknown in advance so all you can do is guess a reasonable
size. It would have to flush if the array files resulting in more IPIs
than the current code depending on how many MMs map the list of pages.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
