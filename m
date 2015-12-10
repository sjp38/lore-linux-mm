Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id 1F5EB6B0277
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 21:58:40 -0500 (EST)
Received: by igcto18 with SMTP id to18so4270512igc.0
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 18:58:39 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id k5si17410677igx.2.2015.12.09.18.58.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 09 Dec 2015 18:58:39 -0800 (PST)
Date: Thu, 10 Dec 2015 11:50:15 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151210025015.GA17967@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
 <564C9A86.1090906@suse.cz>
 <20151120063325.GB13061@js1304-P5Q-DELUXE>
 <20151120114225.7efeeafe@grimm.local.home>
 <20151123082805.GB29397@js1304-P5Q-DELUXE>
 <20151123092604.7ec1397d@gandalf.local.home>
 <20151124014527.GA32335@js1304-P5Q-DELUXE>
 <20151203041657.GB1495@js1304-P5Q-DELUXE>
 <20151209150154.31c142b9@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151209150154.31c142b9@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Wed, Dec 09, 2015 at 03:01:54PM -0500, Steven Rostedt wrote:
> On Thu, 3 Dec 2015 13:16:58 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Tue, Nov 24, 2015 at 10:45:28AM +0900, Joonsoo Kim wrote:
> > > On Mon, Nov 23, 2015 at 09:26:04AM -0500, Steven Rostedt wrote:  
> > > > On Mon, 23 Nov 2015 17:28:05 +0900
> > > > Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > >   
> > > > > On Fri, Nov 20, 2015 at 11:42:25AM -0500, Steven Rostedt wrote:  
> > > > > > On Fri, 20 Nov 2015 15:33:25 +0900
> > > > > > Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > > > > 
> > > > > >     
> > > > > > > Steven, is it possible to add tracepoint to inlined fucntion such as
> > > > > > > get_page() in include/linux/mm.h?    
> > > > > > 
> > > > > > I highly recommend against it. The tracepoint code adds a bit of bloat,
> > > > > > and if you inline it, you add that bloat to every use case. Also, it    
> > > > > 
> > > > > Is it worse than adding function call to my own stub function into
> > > > > inlined function such as get_page(). I implemented it as following.
> > > > > 
> > > > > get_page()
> > > > > {
> > > > >         atomic_inc()
> > > > >         stub_get_page()
> > > > > }
> > > > > 
> > > > > stub_get_page() in foo.c
> > > > > {
> > > > >         trace_page_ref_get_page()
> > > > > }  
> > > > 
> > > > Now you just slowed down the fast path. But what you could do is:
> > > > 
> > > > get_page()
> > > > {
> > > > 	atomic_inc();
> > > > 	if (trace_page_ref_get_page_enabled())
> > > > 		stub_get_page();
> > > > }
> > > > 
> > > > Now that "trace_page_ref_get_page_enabled()" will turn into:
> > > > 
> > > > 	if (static_key_false(&__tracepoint_page_ref_get_page.key)) {
> > > > 
> > > > which is a jump label (nop when disabled, a jmp when enabled). That's
> > > > less bloat but doesn't solve the include problem. You still need to add
> > > > the include of that will cause havoc with other tracepoints.  
> > > 
> > > Yes, It also has a include dependency problem so I can't use
> > > trace_page_ref_get_page_enabled() in mm.h. BTW, I tested following
> > > implementation and it works fine.
> > > 
> > > extern struct tracepoint __tracepoint_page_ref_get_page;
> > > 
> > > get_page()
> > > {
> > >         atomic_inc()
> > >         if (static_key_false(&__tracepoint_page_ref_get_page.key))
> > >                 stub_get_page()
> > > }
> > > 
> > > This would not slow down fast path although it can't prevent bloat.
> > > I know that it isn't good code practice, but, this page reference
> > > handling functions have complex include dependency so I'm not sure
> > > I can solve it completely. For this special case, can I use
> > > this raw data structure?
> > >   
> > 
> > Steven, any comment?
> 
> Sorry for the later reply, I was going to reply but then got called off
> to do something else, and then forgot about this message :-/

No problem. :)

> 
> I wanted you to look at what Andi has done here:
> 
> http://lkml.kernel.org/r/1449018060-1742-2-git-send-email-andi@firstfloor.org
> 
>  and here
> 
> http://lkml.kernel.org/r/1449018060-1742-3-git-send-email-andi@firstfloor.org

Wow...They look like what I'm looking for. Nice!
Thanks for the pointer!

I have one more question about trace-cmd.
'trace-cmd report' shows time-sorted output even stack trace. See
following example.

trace-cmd-6338  [003]    54.046508: page_ref_mod:    ...
trace-cmd-6583  [007]    54.046509: page_ref_mod:    ...
trace-cmd-6338  [003]    54.046515: kernel_stack:         <stack trace>
=> do_wp_page (ffffffff811a0c6f)                                                                                                                                      
=> handle_mm_fault (ffffffff811a34e2)
=> __do_page_fault (ffffffff810632da)
=> trace_do_page_fault (ffffffff81063633)
=> do_async_page_fault (ffffffff8105c3ea) 
=> async_page_fault (ffffffff817733f8)                                                                                                                                                                   
trace-cmd-6583  [007]    54.046515: kernel_stack:         <stack trace>                                                                                                                               
=> do_wp_page (ffffffff811a0c6f)
=> handle_mm_fault (ffffffff811a34e2)
...

Output of cpu 3, 7 are mixed and it's not easy to analyze it.

I think that it'd be better not to sort stack trace. How do
you think about it? Could you fix it, please?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
