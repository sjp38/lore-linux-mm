Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 934B06B0037
	for <linux-mm@kvack.org>; Thu, 29 May 2014 21:59:40 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so1129245pad.16
        for <linux-mm@kvack.org>; Thu, 29 May 2014 18:59:40 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:6])
        by mx.google.com with ESMTP id pq10si3248953pbb.233.2014.05.29.18.59.38
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 18:59:39 -0700 (PDT)
Date: Fri, 30 May 2014 11:58:52 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530015852.GG14410@dastard>
References: <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
 <20140529233638.GJ10092@bbox>
 <CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
 <20140530002021.GM10092@bbox>
 <CA+55aFxjXf5xLKGFBjUWimn8-=rj0=g3pku9O1MvGSoDUcEQAw@mail.gmail.com>
 <20140530005042.GO10092@bbox>
 <CA+55aFz84toJOqnuphA99c0av1nLzxcxfjiTwhBbxzaNs3J6NQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFz84toJOqnuphA99c0av1nLzxcxfjiTwhBbxzaNs3J6NQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 06:24:02PM -0700, Linus Torvalds wrote:
> On Thu, May 29, 2014 at 5:50 PM, Minchan Kim <minchan@kernel.org> wrote:
> >>
> >> You could also try Dave's patch, and _not_ do my mm/vmscan.c part.
> >
> > Sure. While I write this, Rusty's test was crached so I will try Dave's patch,
> > them yours except vmscan.c part.
> 
> Looking more at Dave's patch (well, description), I don't think there
> is any way in hell we can ever apply it. If I read it right, it will
> cause all IO that overflows the max request count to go through the
> scheduler to get it flushed. Maybe I misread it, but that's definitely
> not acceptable. Maybe it's not noticeable with a slow rotational
> device, but modern ssd hardware? No way.
> 
> I'd *much* rather slow down the swap side. Not "real IO". So I think
> my mm/vmscan.c patch is preferable (but yes, it might require some
> work to make kswapd do better).
> 
> So you can try Dave's patch just to see what it does for stack depth,
> but other than that it looks unacceptable unless I misread things.

Yeah, it's a hack, not intended as a potential solution.

I'm thinking, though, that plug flushing behaviour is actually
dependent on plugger context and there is no one "correct"
behaviour. If we are doing process driven IO, then we want to do
immediate dispatch, but for IO where stack is an issue or is for
bulk throughput (e.g. background writeback) async dispatch through
kblockd is desirable.

If the patch I sent solves the swap stack usage issue, then perhaps
we should look towards adding "blk_plug_start_async()" to pass such
hints to the plug flushing. I'd want to use the same behaviour in
__xfs_buf_delwri_submit() for bulk metadata writeback in XFS, and
probably also in mpage_writepages() for bulk data writeback in
WB_SYNC_NONE context....

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
