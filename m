Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id E340A600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 07:46:25 -0500 (EST)
Date: Tue, 1 Dec 2009 13:46:19 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] high system time & lock contention running large mixed
 workload
Message-ID: <20091201124619.GO30235@random.random>
References: <1259618429.2345.3.camel@dhcp-100-19-198.bos.redhat.com>
 <20091201100444.GN30235@random.random>
 <20091201212357.5C3A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091201212357.5C3A.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Larry Woodman <lwoodman@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 01, 2009 at 09:31:09PM +0900, KOSAKI Motohiro wrote:
> Ummm. I can't agree this. 7 is too small priority. if large system have prio==7,
> the system have unacceptable big latency trouble.
> if only prio==DEF_PRIOTIRY or something, I can agree you probably.

I taken number 7 purely as mentioned by Larry about old code, but I
don't mind what is the actual breakpoint level where we start to send
the ipi flood to destroy all userland tlbs mapping the page so the
young bit can be set by the cpu on the old pte. If you agree with me
at the lowest priority we shouldn't flood ipi and destroy tlb when
there's plenty of clean unmapped clean cache, we already agree ;). If
that's 7 or DEV_PRIORITY-1, that's ok. All I care is that it escalates
gradually, first clean cache and re-activate mapped pages, then when
we're low on clean cache we start to check ptes and unmap whatever is
not found referenced.

> Avoiding lock contention on light VM pressure is important than
> strict lru order. I guess we don't need knob.

Hope so indeed. It's not just lock contention, that is exacerbated by
certain workloads, but even in total absence of any lock contention I
generally dislike the cpu waste itself of the pte loop to clear the
young bit, and the interruption of userland as well when it receives a
tlb flush for no good reason because 99% of the time plenty of
unmapped clean cache is available. I know this performs best, even if
there will be always someone that will want mapped and unmapped cache
to be threat totally equal in lru terms (which then make me wonder why
there are still & VM_EXEC magics in vmscan.c if all pages shall be
threaded equal in the lru... especially given VM_EXEC is often
meaningless [because potentially randomly set] unlike page_mapcount
[which is never randomly set]), which is the reason I mentioned the
knob.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
