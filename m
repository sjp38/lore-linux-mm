Message-ID: <4684415D.1060700@redhat.com>
Date: Thu, 28 Jun 2007 19:16:45 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
References: <8e38f7656968417dfee0.1181332979@v2.random>	<466C36AE.3000101@redhat.com>	<20070610181700.GC7443@v2.random>	<46814829.8090808@redhat.com>	<20070626105541.cd82c940.akpm@linux-foundation.org>	<468439E8.4040606@redhat.com>	<20070628155715.49d051c9.akpm@linux-foundation.org>	<46843E65.3020008@redhat.com> <20070628161350.5ce20202.akpm@linux-foundation.org>
In-Reply-To: <20070628161350.5ce20202.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 28 Jun 2007 19:04:05 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
>>> Sigh.  We had a workload (forget which, still unfixed) in which things
>>> would basically melt down in that linear anon_vma walk, walking 10,000 or
>>> more vma's.  I wonder if that's what's happening here?
>> That would be a large multi-threaded application that fills up
>> memory.  Customers are reproducing this with JVMs on some very
>> large systems.
> 
> So.... does that mean "yes, it's scanning a lot of vmas"?

Not necessarily.

The problem can also be reproduced if you have many
threads, from "enough" CPUs, all scanning pages in
the same huge VMA.

> If so, I expect there will still be failure modes, whatever we do outside
> of this.  A locked, linear walk of a list whose length is
> application-controlled is going to be a problem.  Could be that we'll need
> an O(n) -> O(log(n)) conversion, which will be tricky in there.

Scanning fewer pages in the pageout path is probably
the way to go.

No matter how efficient we make the scanning of one
individual page, we simply cannot scan through 1TB
worth of anonymous pages (which are all referenced
because they've been there for a week) in order to
deactivate something.

Systems that big are only a year or two away from
general purpose use.

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
