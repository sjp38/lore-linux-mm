Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id DC7EC6B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 03:27:47 -0500 (EST)
Received: by padhx2 with SMTP id hx2so184400433pad.1
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 00:27:47 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTPS id w74si17839838pfi.93.2015.11.23.00.27.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 23 Nov 2015 00:27:47 -0800 (PST)
Date: Mon, 23 Nov 2015 17:28:05 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151123082805.GB29397@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
 <564C9A86.1090906@suse.cz>
 <20151120063325.GB13061@js1304-P5Q-DELUXE>
 <20151120114225.7efeeafe@grimm.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151120114225.7efeeafe@grimm.local.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Fri, Nov 20, 2015 at 11:42:25AM -0500, Steven Rostedt wrote:
> On Fri, 20 Nov 2015 15:33:25 +0900
> Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> 
> 
> > Steven, is it possible to add tracepoint to inlined fucntion such as
> > get_page() in include/linux/mm.h?
> 
> I highly recommend against it. The tracepoint code adds a bit of bloat,
> and if you inline it, you add that bloat to every use case. Also, it

Is it worse than adding function call to my own stub function into
inlined function such as get_page(). I implemented it as following.

get_page()
{
        atomic_inc()
        stub_get_page()
}

stub_get_page() in foo.c
{
        trace_page_ref_get_page()
}

> makes things difficult if this file is included in other files that
> create tracepoints, which I could easily imagine would be the case.
> That is, if a tracepoint file in include/trace/events/foo.h needs to
> include include/linux/mm.h, when you do CREATE_TRACEPOINTS for foo.h,
> it will create tracepoints for mm.h as to use tracepoints there you
> would need to include the include/trace/events/mm.h (or whatever its
> name is), and that has caused issues in the past.
> 
> Now, if you still want to have these tracepoints in the inlined
> function, it would be best to add a new file mm_trace.h? or something
> that would include it, and then have only the .c files include that
> directly. Do not put it into mm.h as that would definitely cause
> tracepoint include troubles.

Okay. If I choose this way, I have to change too many places and churn
the code. If bloat of my implementation is similar with this suggestion,
I prefer my implementation.

Thanks for good advice.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
