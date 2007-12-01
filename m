Date: Sat, 1 Dec 2007 13:36:52 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: What can we do to get ready for memory controller merge in
 2.6.25
Message-ID: <20071201133652.6888a717@bree.surriel.com>
In-Reply-To: <47512E65.9030803@linux.vnet.ibm.com>
References: <474ED005.7060300@linux.vnet.ibm.com>
	<200711301311.48291.nickpiggin@yahoo.com.au>
	<6599ad830711302339v1f92af40v85e89484a8a6575e@mail.gmail.com>
	<47512E65.9030803@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelianov <xemul@sw.ru>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Christoph Lameter <clameter@sgi.com>, "Martin J. Bligh" <mbligh@google.com>, Andy Whitcroft <andyw@uk.ibm.com>, Srivatsa Vaddagiri <vatsa@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Sat, 01 Dec 2007 15:20:29 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > In our experience, users are not good at figuring out how much memory
> > they really need. In general they tend to massively over-estimate
> > their requirements. So we want some way to determine how much of its
> > allocated memory a job is actively using, and how much could be thrown
> > away or swapped out without bothering the job too much.
> 
> One would prefer the kernel provides the mechanism and user space
> provides the policy. The algorithms to assign limits can exist in user
> space and be supported by a good set of statistics.

With the /proc/refaults info, we can measure how much extra
memory each process group needs, if any.

As for how much memory a process group needs, at pageout time
we can check the fraction of pages that are accessed.  If 60%
of the pages were recently accessed at pageout time and this
process group is spending little or no time waiting for refaults,
40% of the pages are *not* recently accessed and we can probably
reduce the amount of memory assigned to this group.

Page cache that has only been accessed once can also be
counted as "not recently accessed", since streaming file
IO should not increase the working set of the process group.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
