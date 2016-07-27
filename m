Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id C6F426B0253
	for <linux-mm@kvack.org>; Wed, 27 Jul 2016 13:30:12 -0400 (EDT)
Received: by mail-it0-f71.google.com with SMTP id c126so6177859ith.3
        for <linux-mm@kvack.org>; Wed, 27 Jul 2016 10:30:12 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0098.hostedemail.com. [216.40.44.98])
        by mx.google.com with ESMTPS id c2si8333332itb.48.2016.07.27.10.30.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jul 2016 10:30:12 -0700 (PDT)
Date: Wed, 27 Jul 2016 13:30:08 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 1/2] mm: page_alloc.c: Add tracepoints for slowpath
Message-ID: <20160727133008.74e52024@gandalf.local.home>
In-Reply-To: <5798ED5C.1020300@intel.com>
References: <cover.1469629027.git.janani.rvchndrn@gmail.com>
	<6b12aed89ad75cb2b3525a24265fa1d622409b42.1469629027.git.janani.rvchndrn@gmail.com>
	<20160727112303.11409a4e@gandalf.local.home>
	<5798ED5C.1020300@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Janani Ravichandran <janani.rvchndrn@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@surriel.com, akpm@linux-foundation.org, hannes@compxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

On Wed, 27 Jul 2016 10:20:28 -0700
Dave Hansen <dave.hansen@intel.com> wrote:

> On 07/27/2016 08:23 AM, Steven Rostedt wrote:
> >> > +
> >> > +	trace_mm_slowpath_end(page);
> >> > +  
> > I'm thinking you only need one tracepoint, and use function_graph
> > tracer for the length of the function call.
> > 
> >  # cd /sys/kernel/debug/tracing
> >  # echo __alloc_pages_nodemask > set_ftrace_filter
> >  # echo function_graph > current_tracer
> >  # echo 1 > events/kmem/trace_mm_slowpath/enable  
> 
> I hesitate to endorse using the function_graph tracer for this kind of
> stuff.  Tracepoints offer some level of stability in naming, and the
> compiler won't ever make them go away.   While __alloc_pages_nodemask is
> probably more stable than most things, there's no guarantee that it will
> be there.

Well, then you are also advocating in a userspace ABI interface that
will have to be maintained forever. Just be warned.

> 
> BTW, what's the overhead of the function graph tracer if the filter is
> set up to be really restrictive like above?  Is the overhead really just
> limited to that one function?

Yes, if DYNAMIC_FTRACE is defined. Which it should be, because static
ftrace has a huge overhead without enabling the tracer.

It will enable only that function to be traced. I've recommend before
that if one wants to have a good idea of how long a function lasts,
they should filter to a single function. Anything else will include
overhead of the tracer itself.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
