Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 16FC36B003D
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 00:15:15 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nB35FB0u013295
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 3 Dec 2009 14:15:11 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 99C3345DE4E
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:15:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6AAD045DE50
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:15:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3493A1DB803E
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:15:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D4DDEE38002
	for <linux-mm@kvack.org>; Thu,  3 Dec 2009 14:15:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/9] ksm: let shared pages be swappable
In-Reply-To: <20091202125501.GD28697@random.random>
References: <4B15F642.1080308@redhat.com> <20091202125501.GD28697@random.random>
Message-Id: <20091203134610.586E.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  3 Dec 2009 14:15:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Wed, Dec 02, 2009 at 12:08:18AM -0500, Rik van Riel wrote:
> > The VM needs to touch a few (but only a few) PTEs in
> > that situation, to make sure that anonymous pages get
> > moved to the inactive anon list and get to a real chance
> > at being referenced before we try to evict anonymous
> > pages.
> > 
> > Without a small amount of pre-aging, we would end up
> > essentially doing FIFO replacement of anonymous memory,
> > which has been known to be disastrous to performance
> > for over 40 years now.
> 
> So far the only kernel that hangs in fork is the newer one...
> 
> In general I cannot care less about FIFO, I care about no CPU waste on
> 100% of my systems were swap is not needed. All my unmapped cache is
> 100% garbage collectable, and there is never any reason to flush any
> tlb and walk the rmap chain. Give me a knob to disable the CPU waste
> given I know what is going on, on my systems. I am totally ok with
> slightly slower swap performance and fifo replacement in case I
> eventually hit swap for a little while, then over time if memory
> pressure stays high swap behavior will improve regardless of
> flooding ipis to clear young bit when there are hundred gigabytes of
> freeaeble cache unmapped and clean.
> 
> > Having said that - it may be beneficial to keep very heavily
> > shared pages on the active list, without ever trying to scan
> > the ptes associated with them.
> 
> Just mapped pages in general, not heavily... The other thing that is
> beneficial likely is to stop page_referenced after 64 young bit clear,
> that is referenced enough, you can enable this under my knob so that
> it won't screw your algorithm. I don't have 1 terabyte of memory, so
> you don't have to worry for me, I just want every cycle out of my cpu
> without having to use O_DIRECT all the time.

Umm?? Personally I don't like knob. If you have problematic workload,
please tell it us. I will try to make reproduce environment on my box.
If current code doesn't works on KVM or something-else, I really want
to fix it.

I think Larry's trylock idea and your 64 young bit idea can be combinate.
I only oppose the page move to inactive list without clear young bit. IOW,
if VM pressure is very low and the page have lots young bit, the page should
go back active list although trylock(ptelock) isn't contended.

But unfortunatelly I don't have problem workload as you mentioned. Anyway
we need evaluate way to your idea. We obviouslly more info.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
