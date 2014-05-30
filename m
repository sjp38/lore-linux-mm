Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id D7EF06B0035
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:50:09 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1097251pbb.33
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:50:09 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id bv2si3139716pbb.63.2014.05.29.17.50.07
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 17:50:08 -0700 (PDT)
Date: Fri, 30 May 2014 09:50:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] x86_64: expand kernel stack to 16K
Message-ID: <20140530005042.GO10092@bbox>
References: <1401260039-18189-2-git-send-email-minchan@kernel.org>
 <CA+55aFxXdc22dirnE49UbQP_2s2vLQpjQFL+NptuyK7Xry6c=g@mail.gmail.com>
 <20140528223142.GO8554@dastard>
 <CA+55aFyRk6_v6COPGVvu6hvt=i2A8-dPcs1X3Ydn1g24AxbPkg@mail.gmail.com>
 <20140529013007.GF6677@dastard>
 <20140529015830.GG6677@dastard>
 <20140529233638.GJ10092@bbox>
 <CA+55aFyvn_fTnWEmTCSGgfM18c21-YDU_s=FJP=grDDLQe+aDA@mail.gmail.com>
 <20140530002021.GM10092@bbox>
 <CA+55aFxjXf5xLKGFBjUWimn8-=rj0=g3pku9O1MvGSoDUcEQAw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxjXf5xLKGFBjUWimn8-=rj0=g3pku9O1MvGSoDUcEQAw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Chinner <david@fromorbit.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Steven Rostedt <rostedt@goodmis.org>

On Thu, May 29, 2014 at 05:31:42PM -0700, Linus Torvalds wrote:
> On Thu, May 29, 2014 at 5:20 PM, Minchan Kim <minchan@kernel.org> wrote:
> >
> > I guess this part which avoid swapout in direct reclaim would be key
> > if this patch were successful. But it could make anon pages rotate back
> > into inactive's head from tail in direct reclaim path until kswapd can
> > catch up. And kswapd kswapd can swap out anon pages from tail of inactive
> > LRU so I suspect it could make side-effect LRU churning.
> 
> Oh, it could make bad things happen, no question about that.
> 
> That said, those bad things are what happens to shared mapped pages
> today, so in that sense it's not new. But large dirty shared mmap's
> have traditionally been a great way to really hurt out VM, so "it
> should work as well as shared mapping pages" is definitely not a
> ringing endorsement!

True.

> 
> (Of course, *if* we can improve kswapd behavior for both swap-out and
> shared dirty pages, that would then be a double win, so there is
> _some_ argument for saying that we should aim to handle both kinds of
> pages equally).

Just an idea for preventing LRU churn.
We can return back the pages to tail of inactive instead of head if it's
not proper pages in this context and reclaimer uses the cursor as list_head
instead of LRU head to scan victim page and record the cursor in somewhere
like lruvec after shrinking is done. It makes VM code more complicated but
is worthy to try if we approach that way.

> 
> > Anyway, I will queue it into testing machine since Rusty's test is done.
> 
> You could also try Dave's patch, and _not_ do my mm/vmscan.c part.

Sure. While I write this, Rusty's test was crached so I will try Dave's patch,
them yours except vmscan.c part.

Thanks.

> 
>             Linus
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
