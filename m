Date: Sat, 1 Dec 2007 14:26:50 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: What can we do to get ready for memory controller merge in
 2.6.25
Message-ID: <20071201142650.6ee71d43@bree.surriel.com>
In-Reply-To: <6599ad830712011102h3bbfd7e6lc5c448cd8efa3158@mail.gmail.com>
References: <474ED005.7060300@linux.vnet.ibm.com>
	<200711301311.48291.nickpiggin@yahoo.com.au>
	<6599ad830711302339v1f92af40v85e89484a8a6575e@mail.gmail.com>
	<47512E65.9030803@linux.vnet.ibm.com>
	<20071201133652.6888a717@bree.surriel.com>
	<6599ad830712011102h3bbfd7e6lc5c448cd8efa3158@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: balbir@linux.vnet.ibm.com, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 1 Dec 2007 11:02:32 -0800
"Paul Menage" <menage@google.com> wrote:

> On Dec 1, 2007 10:36 AM, Rik van Riel <riel@redhat.com> wrote:
> >
> > With the /proc/refaults info, we can measure how much extra
> > memory each process group needs, if any.
> 
> What's the status of that? It looks as though it would be better than
> the "accessed in the last N seconds" metric that we've been playing
> with, although it's possibly more intrusive?
> 
> Would it be practical to keep a non-resident set for each cgroup?

I have an implementation with a global array, but will have to
change it over to a per-radix tree implementation (not that
hard, with the slab reclaiming code) and per-cgroup reclaiming
information.

That way we can figure out per mapping, per cgroup or system
wide reclaim info (though not all at the same time).

> > As for how much memory a process group needs, at pageout time
> > we can check the fraction of pages that are accessed.  If 60%
> > of the pages were recently accessed at pageout time and this
> > process group is spending little or no time waiting for refaults,
> > 40% of the pages are *not* recently accessed and we can probably
> > reduce the amount of memory assigned to this group.
> 
> It would probably be better to reduce its background-reclaim high
> watermark than to reduce its limit. If you do the latter, you risk
> triggering an OOM in the cgroup if it turns out that it did need all
> that memory after all.

I did mean the RSS limit, not a virtual memory limit.

What exactly are all the terminologies you use that
I need to be aware of? :)

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
