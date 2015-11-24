Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 99A3E6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 20:59:43 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so3845686pac.3
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 17:59:43 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id j6si23976457pbq.165.2015.11.23.17.59.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 17:59:42 -0800 (PST)
Date: Tue, 24 Nov 2015 10:56:04 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151124015604.GB32335@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
 <564C9A86.1090906@suse.cz>
 <20151120063325.GB13061@js1304-P5Q-DELUXE>
 <20151120114225.7efeeafe@grimm.local.home>
 <20151123082805.GB29397@js1304-P5Q-DELUXE>
 <20151123092604.7ec1397d@gandalf.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151123092604.7ec1397d@gandalf.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, Nov 23, 2015 at 09:26:04AM -0500, Steven Rostedt wrote:
> On Mon, 23 Nov 2015 17:28:05 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> > On Fri, Nov 20, 2015 at 11:42:25AM -0500, Steven Rostedt wrote:
> > > On Fri, 20 Nov 2015 15:33:25 +0900
> > > Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > > 
> > >   
> > > > Steven, is it possible to add tracepoint to inlined fucntion such as
> > > > get_page() in include/linux/mm.h?  
> > > 
> > > I highly recommend against it. The tracepoint code adds a bit of bloat,
> > > and if you inline it, you add that bloat to every use case. Also, it  
> > 
> > Is it worse than adding function call to my own stub function into
> > inlined function such as get_page(). I implemented it as following.
> > 
> > get_page()
> > {
> >         atomic_inc()
> >         stub_get_page()
> > }
> > 
> > stub_get_page() in foo.c
> > {
> >         trace_page_ref_get_page()
> > }
> 
> Now you just slowed down the fast path. But what you could do is:
> 
> get_page()
> {
> 	atomic_inc();
> 	if (trace_page_ref_get_page_enabled())
> 		stub_get_page();
> }
> 
> Now that "trace_page_ref_get_page_enabled()" will turn into:
> 
> 	if (static_key_false(&__tracepoint_page_ref_get_page.key)) {
> 
> which is a jump label (nop when disabled, a jmp when enabled). That's
> less bloat but doesn't solve the include problem. You still need to add
> the include of that will cause havoc with other tracepoints.

Yes, it also has include dependency problem so I can't use
trace_page_ref_get_page_enabled() in mm.h.

BTW, I try to open code trace_page_ref_get_page_enabled() in
get_page() as following and it works fine.

extern struct tracepoint __tracepoint_page_ref_get_page;

get_page()
{
        atomic_inc()
        if (static_key_false(&__tracepoint_page_ref_get_page.key))
                stub_get_page()
}

I know that it's not good coding practice to use raw data structure,
but, page reference management functions has complex dependency
so I'm not sure I can solve it completely. For this special case, can
I use it?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
