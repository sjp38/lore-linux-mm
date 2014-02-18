Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4CDC36B0031
	for <linux-mm@kvack.org>; Mon, 17 Feb 2014 20:28:54 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id un15so16083601pbc.10
        for <linux-mm@kvack.org>; Mon, 17 Feb 2014 17:28:53 -0800 (PST)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id ui8si16465302pac.61.2014.02.17.17.28.52
        for <linux-mm@kvack.org>;
        Mon, 17 Feb 2014 17:28:53 -0800 (PST)
Date: Tue, 18 Feb 2014 12:27:53 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 3.14-rc2 XFS backtrace because irqs_disabled.
Message-ID: <20140218012753.GG13997@dastard>
References: <20140212004403.GA17129@redhat.com>
 <20140212010941.GM18016@ZenIV.linux.org.uk>
 <CA+55aFwoWT-0A_KTkXMkNqOy8hc=YmouTMBgWUD_z+8qYPphjA@mail.gmail.com>
 <20140212040358.GA25327@redhat.com>
 <20140212042215.GN18016@ZenIV.linux.org.uk>
 <20140212054043.GB13997@dastard>
 <CA+55aFxy2t7bnCUc-DhhxYxsZ0+GwL9GuQXRYtE_VzqZusmB9A@mail.gmail.com>
 <20140212071829.GE13997@dastard>
 <20140214002427.GN13997@dastard>
 <CA+55aFx=i6dbzCUZ6TwCMqniyS4C=tJx9+72p=EA+dU8Vn=2jQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFx=i6dbzCUZ6TwCMqniyS4C=tJx9+72p=EA+dU8Vn=2jQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, Al Viro <viro@zeniv.linux.org.uk>, Dave Jones <davej@redhat.com>, Eric Sandeen <sandeen@sandeen.net>, Linux Kernel <linux-kernel@vger.kernel.org>, xfs@oss.sgi.com

On Sat, Feb 15, 2014 at 03:50:29PM -0800, Linus Torvalds wrote:
> [ Added linux-mm to the participants list ]
> 
> On Thu, Feb 13, 2014 at 4:24 PM, Dave Chinner <david@fromorbit.com> wrote:
> >
> > Dave, the patch below should chop off the stack usage from
> > xfs_log_force_lsn() issuing IO by deferring it to the CIL workqueue.
> > Can you given this a run?
> 
> Ok, so DaveJ confirmed that DaveC's patch fixes his issue (damn,
> people, your parents were some seriously boring people, were they not?
> We've got too many Dave's around),

It's an exclusive club - we have 'kernel hacker Dave' reunions in
bars around the world. We should get some tshirts made up....  :)

> but DaveC earlier pointed out that
> pretty much any memory allocation path can end up using 3kB of stack
> even without XFS being involved.
> 
> Which does bring up the question whether we should look (once more) at
> the VM direct-reclaim path, and try to avoid GFP_FS/IO direct
> reclaim..

We do that mostly already, but GFP_KERNEL allows swap IO and that's
where the deepest stack I saw came from.

Even if we don't allow IO at all, we're still going to see stack
usage of 2-2.5k in direct reclaim. e.g.  invalidate a page and enter
the rmap code.  The rmap is protected by a mutex, so if we fail to
get that we have about 1.2k of stack consumed from there and that is
on top of the the allocator/reclaim that has already consumes ~1k of
stack...

> Direct reclaim historically used to be an important throttling
> mechanism, and I used to not be a fan of trying to avoid direct
> reclaim. But the stack depth issue really looks to be pretty bad, and
> I think we've gotten better at throttling explicitly, so..
> 
> I *think* we already limit filesystem writeback to just kswapd (in
> shrink_page_list()), but DaveC posted a backtrace that goes through
> do_try_to_free_pages() to shrink_slab(), and through there to the
> filesystem and then IO. That looked like a disaster.

Right, that's an XFS problem, and I'm working on fixing it. The
Patch I sent to DaveJ fixes the worst case, but I need to make it
completely IO-less while still retaining the throttling the IO gives
us.

> And that's because (if I read things right) shrink_page_list() limits
> filesystem page writeback to kswapd, but not swap pages. Which I think
> probably made more sense back in the days than it does now (I
> certainly *hope* that swapping is less important today than it was,
> say, ten years ago)
> 
> So I'm wondering whether we should remove that page_is_file_cache()
> check from shrink_page_list()?

The thing is, the stack usage from the swap IO path is pretty well
bound - it's just the worst case stack of issuing IO. We know it
won't recurse into direct reclaim, so mempool allocation and
blocking is all we need to consider. Compare that to a filesystem
which may need to allocate extents and hence do transactions and
split btrees and read metadata and allocate large amounts of memory
even before it gets to the IO layers.

Hence I suspect that we could do a simple thing like only allow swap
if there's more than half the stack available in the current reclaim
context. Because, let's face it, if the submit_bio path is consuming
more than half the available stack then we're totally screwed from a
filesystem perspective....

> And then there is that whole shrink_slab() case...

I think with shrinkers we just need to be more careful. The XFS
behaviour is all my fault, and I should have known better that to
design code that requires IO in the direct reclaim path. :/

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
