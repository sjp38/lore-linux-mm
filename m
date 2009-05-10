Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 758DD6B003D
	for <linux-mm@kvack.org>; Sun, 10 May 2009 17:25:21 -0400 (EDT)
Date: Sun, 10 May 2009 14:23:22 -0700
From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first
 class  citizen
Message-ID: <20090510142322.690186a4@infradead.org>
In-Reply-To: <4A073B0D.4090604@redhat.com>
References: <20090430181340.6f07421d.akpm@linux-foundation.org>
	<1241432635.7620.4732.camel@twins>
	<20090507121101.GB20934@localhost>
	<20090507151039.GA2413@cmpxchg.org>
	<20090507134410.0618b308.akpm@linux-foundation.org>
	<20090508081608.GA25117@localhost>
	<20090508125859.210a2a25.akpm@linux-foundation.org>
	<20090508230045.5346bd32@lxorguk.ukuu.org.uk>
	<2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>
	<1241946446.6317.42.camel@laptop>
	<2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com>
	<20090510144533.167010a9@lxorguk.ukuu.org.uk>
	<4A06EA08.1030102@redhat.com>
	<20090510211350.7aecc8de@lxorguk.ukuu.org.uk>
	<4A073B0D.4090604@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

On Sun, 10 May 2009 16:37:33 -0400
Rik van Riel <riel@redhat.com> wrote:

> Alan Cox wrote:
> 
> > Make your swap decisions depend upon I/O load on storage devices.
> > Make your paging decisions based upon writing and reading large
> > contiguous chunks (512K costs the same as 8K pretty much) - but you
> > already know that .
> 
> Even a 2MB chunk only takes 3x as much time to write to
> or read from disk as a 4kB page.

... if your disk rotates.
If instead it's a voltage level in a transistor... the opposite is
true... it starts to approach linear-with-size then ;-)
 
At least we know for the block device which of the two types it is
inside the kernel (ok, there's a few false positives towards rotating,
but those we could/should quirk away)

> 
> > Historically BSD tackled some of this by actually swapping
> > processes out once pressure got very high 
> 
> Our big problem today usually isn't throughput though,
> but latency - the time it takes to bring a previously
> inactive application back to life.

Could we do a chain? E.g. store which page we paged out next (for the
vma) as part of the first pageout, and then page them just right back
in? Or even have a (bitmap?) of pages that have been in memory for the
vma, and on a re-fault, look for other pages "nearby" that used to be
in but are now out ?

> 
> If we have any throughput related memory problems,
> they often seem to be due to TLB miss penalties.

TLB miss is cheap on x86. For most non-HPC workloads they
tend to be hidden by the out of order execution...

-- 
Arjan van de Ven 	Intel Open Source Technology Centre
For development, discussion and tips for power savings, 
visit http://www.lesswatts.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
