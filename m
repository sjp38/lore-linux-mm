Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 496736B003D
	for <linux-mm@kvack.org>; Sun, 10 May 2009 16:37:25 -0400 (EDT)
Message-ID: <4A073B0D.4090604@redhat.com>
Date: Sun, 10 May 2009 16:37:33 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -mm] vmscan: make mapped executable pages the first class
  citizen
References: <20090430181340.6f07421d.akpm@linux-foundation.org>	<1241432635.7620.4732.camel@twins>	<20090507121101.GB20934@localhost>	<20090507151039.GA2413@cmpxchg.org>	<20090507134410.0618b308.akpm@linux-foundation.org>	<20090508081608.GA25117@localhost>	<20090508125859.210a2a25.akpm@linux-foundation.org>	<20090508230045.5346bd32@lxorguk.ukuu.org.uk>	<2f11576a0905100159m32c36a9ep9fb7cc5604c60b2@mail.gmail.com>	<1241946446.6317.42.camel@laptop>	<2f11576a0905100236u15d45f7fm32d470776659cfec@mail.gmail.com>	<20090510144533.167010a9@lxorguk.ukuu.org.uk>	<4A06EA08.1030102@redhat.com> <20090510211350.7aecc8de@lxorguk.ukuu.org.uk>
In-Reply-To: <20090510211350.7aecc8de@lxorguk.ukuu.org.uk>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tytso@mit.edu, linux-mm@kvack.org, elladan@eskimo.com, npiggin@suse.de, cl@linux-foundation.org, minchan.kim@gmail.com
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:

> Make your swap decisions depend upon I/O load on storage devices. Make
> your paging decisions based upon writing and reading large contiguous
> chunks (512K costs the same as 8K pretty much) - but you already know
> that .

Even a 2MB chunk only takes 3x as much time to write to
or read from disk as a 4kB page.

> Historically BSD tackled some of this by actually swapping processes out
> once pressure got very high 

Our big problem today usually isn't throughput though,
but latency - the time it takes to bring a previously
inactive application back to life.

If we have any throughput related memory problems,
they often seem to be due to TLB miss penalties.

I believe it is time to start looking into transparent
use of 2MB superpages for anonymous memory (and tmpfs?)
in Linux on x86-64.

I realize the utter horror of all the different corner
cases one can have with those. However, with a careful
design the problems should be manageable and the
advantages are many.

With a reservation based system, populating a 2MB area
4kB at a time until most of the area is in use by one
process (or not), waste can be kept to a minimum.

I guess I'll start with this the same way I started
with the split LRU code - think of all the ways things
could possibly go wrong and come up with a design that
seems mostly impervious to the downsides.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
