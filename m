Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id DA5676B007D
	for <linux-mm@kvack.org>; Tue, 16 Feb 2010 02:03:49 -0500 (EST)
Date: Tue, 16 Feb 2010 18:03:44 +1100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/7 -mm] oom: filter tasks not sharing the same cpuset
Message-ID: <20100216070344.GF5723@laptop>
References: <20100215115154.727B.A69D9226@jp.fujitsu.com>
 <alpine.DEB.2.00.1002151401280.26927@chino.kir.corp.google.com>
 <20100216110859.72C6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100216110859.72C6.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Lubos Lunak <l.lunak@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 16, 2010 at 01:52:02PM +0900, KOSAKI Motohiro wrote:
> But this explanation is irrelevant and meaningless. CPUSET can change
> restricted node dynamically. So, the tsk->mempolicy at oom time doesn't
> represent the place of task's usage memory. plus, OOM_DISABLE can 
> always makes undesirable result. it's not special in this case.
> 
> The fact is, both current and your heuristics have a corner case. it's
> obvious. (I haven't seen corner caseless heuristics). then talking your
> patch's merit doesn't help to merge the patch. The most important thing
> is, we keep no regression. personally, I incline your one. but It doesn't
> mean we can ignore its demerit.

Yes we do need to explain the downside of the patch. It is a
heuristic and we can't call either approach perfect.

The fact is that even if 2 tasks are on completely disjoint
memory policies and never _allocate_ from one another's nodes,
you can still have one task pinning memory of the other task's
node.

Most shared and userspace-pinnable resources (pagecache, vfs
caches and fds files sockes etc) are allocated by first-touch
basically.

I don't see much usage of cpusets and oom killer first hand in
my experience, so I am happy to defer to others when it comes
to heuristics. Just so long as we are all aware of the full
story :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
