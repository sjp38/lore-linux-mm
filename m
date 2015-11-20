Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f170.google.com (mail-qk0-f170.google.com [209.85.220.170])
	by kanga.kvack.org (Postfix) with ESMTP id 708C06B0038
	for <linux-mm@kvack.org>; Fri, 20 Nov 2015 11:42:32 -0500 (EST)
Received: by qkda6 with SMTP id a6so38514260qkd.3
        for <linux-mm@kvack.org>; Fri, 20 Nov 2015 08:42:32 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.230])
        by mx.google.com with ESMTP id m82si349944qki.10.2015.11.20.08.42.31
        for <linux-mm@kvack.org>;
        Fri, 20 Nov 2015 08:42:31 -0800 (PST)
Date: Fri, 20 Nov 2015 11:42:25 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151120114225.7efeeafe@grimm.local.home>
In-Reply-To: <20151120063325.GB13061@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
	<564C9A86.1090906@suse.cz>
	<20151120063325.GB13061@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Fri, 20 Nov 2015 15:33:25 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:


> Steven, is it possible to add tracepoint to inlined fucntion such as
> get_page() in include/linux/mm.h?

I highly recommend against it. The tracepoint code adds a bit of bloat,
and if you inline it, you add that bloat to every use case. Also, it
makes things difficult if this file is included in other files that
create tracepoints, which I could easily imagine would be the case.
That is, if a tracepoint file in include/trace/events/foo.h needs to
include include/linux/mm.h, when you do CREATE_TRACEPOINTS for foo.h,
it will create tracepoints for mm.h as to use tracepoints there you
would need to include the include/trace/events/mm.h (or whatever its
name is), and that has caused issues in the past.

Now, if you still want to have these tracepoints in the inlined
function, it would be best to add a new file mm_trace.h? or something
that would include it, and then have only the .c files include that
directly. Do not put it into mm.h as that would definitely cause
tracepoint include troubles.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
