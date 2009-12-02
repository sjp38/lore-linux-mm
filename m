Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 29532600762
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 07:55:09 -0500 (EST)
Date: Wed, 2 Dec 2009 13:55:01 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
Message-ID: <20091202125501.GD28697@random.random>
References: <20091201181633.5C31.A69D9226@jp.fujitsu.com>
 <20091201093738.GL30235@random.random>
 <20091201184535.5C37.A69D9226@jp.fujitsu.com>
 <20091201095947.GM30235@random.random>
 <4B15F642.1080308@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B15F642.1080308@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 02, 2009 at 12:08:18AM -0500, Rik van Riel wrote:
> The VM needs to touch a few (but only a few) PTEs in
> that situation, to make sure that anonymous pages get
> moved to the inactive anon list and get to a real chance
> at being referenced before we try to evict anonymous
> pages.
> 
> Without a small amount of pre-aging, we would end up
> essentially doing FIFO replacement of anonymous memory,
> which has been known to be disastrous to performance
> for over 40 years now.

So far the only kernel that hangs in fork is the newer one...

In general I cannot care less about FIFO, I care about no CPU waste on
100% of my systems were swap is not needed. All my unmapped cache is
100% garbage collectable, and there is never any reason to flush any
tlb and walk the rmap chain. Give me a knob to disable the CPU waste
given I know what is going on, on my systems. I am totally ok with
slightly slower swap performance and fifo replacement in case I
eventually hit swap for a little while, then over time if memory
pressure stays high swap behavior will improve regardless of
flooding ipis to clear young bit when there are hundred gigabytes of
freeaeble cache unmapped and clean.

> Having said that - it may be beneficial to keep very heavily
> shared pages on the active list, without ever trying to scan
> the ptes associated with them.

Just mapped pages in general, not heavily... The other thing that is
beneficial likely is to stop page_referenced after 64 young bit clear,
that is referenced enough, you can enable this under my knob so that
it won't screw your algorithm. I don't have 1 terabyte of memory, so
you don't have to worry for me, I just want every cycle out of my cpu
without having to use O_DIRECT all the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
