Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id F35C76B0038
	for <linux-mm@kvack.org>; Mon, 23 Nov 2015 09:26:07 -0500 (EST)
Received: by igl9 with SMTP id 9so51877783igl.0
        for <linux-mm@kvack.org>; Mon, 23 Nov 2015 06:26:07 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0188.hostedemail.com. [216.40.44.188])
        by mx.google.com with ESMTP id g2si9526985igc.14.2015.11.23.06.26.07
        for <linux-mm@kvack.org>;
        Mon, 23 Nov 2015 06:26:07 -0800 (PST)
Date: Mon, 23 Nov 2015 09:26:04 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 2/2] mm/page_ref: add tracepoint to track down page
 reference manipulation
Message-ID: <20151123092604.7ec1397d@gandalf.local.home>
In-Reply-To: <20151123082805.GB29397@js1304-P5Q-DELUXE>
References: <1447053784-27811-1-git-send-email-iamjoonsoo.kim@lge.com>
	<1447053784-27811-2-git-send-email-iamjoonsoo.kim@lge.com>
	<564C9A86.1090906@suse.cz>
	<20151120063325.GB13061@js1304-P5Q-DELUXE>
	<20151120114225.7efeeafe@grimm.local.home>
	<20151123082805.GB29397@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@suse.de>, "Kirill A.
 Shutemov" <kirill.shutemov@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Mon, 23 Nov 2015 17:28:05 +0900
Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Fri, Nov 20, 2015 at 11:42:25AM -0500, Steven Rostedt wrote:
> > On Fri, 20 Nov 2015 15:33:25 +0900
> > Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > 
> >   
> > > Steven, is it possible to add tracepoint to inlined fucntion such as
> > > get_page() in include/linux/mm.h?  
> > 
> > I highly recommend against it. The tracepoint code adds a bit of bloat,
> > and if you inline it, you add that bloat to every use case. Also, it  
> 
> Is it worse than adding function call to my own stub function into
> inlined function such as get_page(). I implemented it as following.
> 
> get_page()
> {
>         atomic_inc()
>         stub_get_page()
> }
> 
> stub_get_page() in foo.c
> {
>         trace_page_ref_get_page()
> }

Now you just slowed down the fast path. But what you could do is:

get_page()
{
	atomic_inc();
	if (trace_page_ref_get_page_enabled())
		stub_get_page();
}

Now that "trace_page_ref_get_page_enabled()" will turn into:

	if (static_key_false(&__tracepoint_page_ref_get_page.key)) {

which is a jump label (nop when disabled, a jmp when enabled). That's
less bloat but doesn't solve the include problem. You still need to add
the include of that will cause havoc with other tracepoints.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
