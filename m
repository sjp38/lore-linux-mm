Message-ID: <46ABEE87.5090907@redhat.com>
Date: Sat, 28 Jul 2007 21:33:59 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>	<46A57068.3070701@yahoo.com.au>	<2c0942db0707232153j3670ef31kae3907dff1a24cb7@mail.gmail.com>	<46A58B49.3050508@yahoo.com.au>	<2c0942db0707240915h56e007e3l9110e24a065f2e73@mail.gmail.com>	<46A6CC56.6040307@yahoo.com.au>	<p73abtkrz37.fsf@bingen.suse.de>	<46A85D95.509@kingswood-consulting.co.uk>	<20070726092025.GA9157@elte.hu>	<20070726023401.f6a2fbdf.akpm@linux-foundation.org>	<20070726094024.GA15583@elte.hu>	<20070726030902.02f5eab0.akpm@linux-foundation.org>	<1185454019.6449.12.camel@Homer.simpson.net>	<20070726110549.da3a7a0d.akpm@linux-foundation.org>	<1185513177.6295.21.camel@Homer.simpson.net>	<1185521021.6295.50.camel@Homer.simpson.net> <20070727014749.85370e77.akpm@linux-foundation.org>
In-Reply-To: <20070727014749.85370e77.akpm@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Galbraith <efault@gmx.de>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:

> What I think is killing us here is the blockdev pagecache: the pagecache
> which backs those directory entries and inodes.  These pages get read
> multiple times because they hold multiple directory entries and multiple
> inodes.  These multiple touches will put those pages onto the active list
> so they stick around for a long time and everything else gets evicted.
> 
> I've never been very sure about this policy for the metadata pagecache.  We
> read the filesystem objects into the dcache and icache and then we won't
> read from that page again for a long time (I expect).  But the page will
> still hang around for a long time.
> 
> It could be that we should leave those pages inactive.

Good idea for updatedb.

However, it may be a bad idea for files that are often
written to.  Turning an inode write into a read plus a
write does not sound like such a hot idea, we really
want to keep those in the cache.

I think what you need is to ignore multiple references
to the same page when they all happen in one time
interval, counting them only if they happen in multiple
time intervals.

The use-once cleanup (which takes a page flag for PG_new,
I know...) would solve that problem.

However, it would introduce the problem of having to scan
all the pages on the list before a page becomes freeable.
We would have to add some background scanning (or a separate
list for PG_new pages) to make the initial pageout run use
an acceptable amount of CPU time.

Not sure that complexity will be worth it...

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
