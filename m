Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 547D46008F0
	for <linux-mm@kvack.org>; Wed, 19 May 2010 12:38:13 -0400 (EDT)
Date: Thu, 20 May 2010 01:17:26 +1000
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Unexpected splice "always copy" behavior observed
Message-ID: <20100519151726.GB2516@laptop>
References: <20100518153440.GB7748@Krystal>
 <1274197993.26328.755.camel@gandalf.stny.rr.com>
 <1274199039.26328.758.camel@gandalf.stny.rr.com>
 <alpine.LFD.2.00.1005180918300.4195@i5.linux-foundation.org>
 <20100519063116.GR2516@laptop>
 <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1005190736370.23538@i5.linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Pierre Tardy <tardyp@gmail.com>, Ingo Molnar <mingo@elte.hu>, Arnaldo Carvalho de Melo <acme@redhat.com>, Tom Zanussi <tzanussi@gmail.com>, Paul Mackerras <paulus@samba.org>, linux-kernel@vger.kernel.org, arjan@infradead.org, ziga.mahkovec@gmail.com, davem <davem@davemloft.net>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Jens Axboe <jens.axboe@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 19, 2010 at 07:39:11AM -0700, Linus Torvalds wrote:
> 
> 
> On Wed, 19 May 2010, Nick Piggin wrote:
> > 
> > We can possibly do an attempt to invalidate existing pagecache and
> > then try to install the new page.
> 
> Yes, but that's going to be rather hairier. We need to make sure that the 
> filesystem doesn't have some kind of dirty pointers to the old page etc. 
> Although I guess that should always show up in the page counters, so I 
> guess we can always handle the case of page_count() being 1 (only page 
> cache) and the page being unlocked.

Well I mean a full invalidate -- invalidate_mapping_pages -- so there is
literally no pagecache there at all.

Then we just need to ensure that the filesystem doesn't do anything
funny with the page in write_begin (I don't know, such as zero out holes
or something strange). I don't think any do except maybe for something
obscure like jffs2, but obviously it needs to be looked at.

Error handling may need to be looked at too, but shouldn't be much
issue I'd think.
 
Even so, it's all going to add branches and complexity to an important
fast path, so we'd want to see numbers.


> So I'd much rather just handle the "append to the end".
> 
> The real limitation is likely always going to be the fact that it has to 
> be page-aligned and a full page. For a lot of splice inputs, that simply 
> won't be the case, and you'll end up copying for alignment reasons anyway.

That's true.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
