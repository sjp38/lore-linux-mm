Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 280D36B004D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 14:24:36 -0400 (EDT)
Date: Tue, 24 Mar 2009 19:39:40 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [patch 8/9] LTTng instrumentation - filemap
Message-ID: <20090324183940.GI31117@elte.hu>
References: <20090324155625.420966314@polymtl.ca> <20090324160149.029092843@polymtl.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090324160149.029092843@polymtl.ca>
Sender: owner-linux-mm@kvack.org
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ltt-dev@lists.casi.polymtl.ca, linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>, Masami Hiramatsu <mhiramat@redhat.com>, Peter Zijlstra <peterz@infradead.org>, "Frank Ch. Eigler" <fche@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Hideo AOKI <haoki@redhat.com>, Takashi Nishiie <t-nishiie@np.css.fujitsu.com>, Steven Rostedt <rostedt@goodmis.org>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>


* Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:

> Index: linux-2.6-lttng/mm/filemap.c

> +DEFINE_TRACE(wait_on_page_start);
> +DEFINE_TRACE(wait_on_page_end);

These are extremely incomplete - to the level of being useless.

To understand the lifetime of the pagecache, the following basic 
events have to be observed and instrumented:

 - create a new page
 - fill in a new page
 - dirty a page [when we know this]
 - request writeout of a page
 - clean a page / complete writeout
 - free a page due to MM pressure
 - free a page due to truncation/delete

The following additional events are useful as well:

 - mmap a page to a user-space address
 - copy a page to a user-space address (read)
 - write to a page from a user-space address (write)
 - unmap a page from a user-space address
 - fault in a user-space mapped pagecache page

optional:
   - shmem attach/detach events
   - shmem map/unmap events
   - hugetlb map/unmap events

I'm sure i havent listed them all. Have a look at the function-graph 
tracer output to see what kind of basic events can happen to a 
pagecache page.

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
