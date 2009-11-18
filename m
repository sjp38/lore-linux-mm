Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 36D466B004D
	for <linux-mm@kvack.org>; Wed, 18 Nov 2009 04:56:30 -0500 (EST)
Subject: Re: [PATCH 2/7] mmc: Don't use PF_MEMALLOC
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <28c262360911171601u618ca555o1dd51ea19168575e@mail.gmail.com>
References: <20091117161711.3DDA.A69D9226@jp.fujitsu.com>
	 <20091117102903.7cb45ff3@lxorguk.ukuu.org.uk>
	 <20091117200618.3DFF.A69D9226@jp.fujitsu.com> <4B029C40.2020803@gmail.com>
	 <1258490826.3918.29.camel@laptop>
	 <28c262360911171601u618ca555o1dd51ea19168575e@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 Nov 2009 10:56:21 +0100
Message-ID: <1258538181.3918.138.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alan Cox <alan@lxorguk.ukuu.org.uk>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mmc@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-11-18 at 09:01 +0900, Minchan Kim wrote:
> Hi, Peter.
> 
> First of all, Thanks for the commenting.
> 
> On Wed, Nov 18, 2009 at 5:47 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> > On Tue, 2009-11-17 at 21:51 +0900, Minchan Kim wrote:
> >> I think it's because mempool reserves memory.
> >> (# of I/O issue\0 is hard to be expected.
> >> How do we determine mempool size of each block driver?
> >> For example,  maybe, server use few I/O for nand.
> >> but embedded system uses a lot of I/O.
> >
> > No, you scale the mempool to the minimum amount required to make
> > progress -- this includes limiting the 'concurrency' when handing out
> > mempool objects.
> >
> > If you run into such tight corners often enough to notice it, there's
> > something else wrong.
> >
> > I fully agree with ripping out PF_MEMALLOC from pretty much everything,
> > including the VM, getting rid of the various abuse outside of the VM
> > seems like a very good start.
> >
> 
> I am not against removing PF_MEMALLOC.
> Totally, I agree to prevent abusing of PF_MEMALLOC.
> 
> What I have a concern is per-block mempool.
> Although it's minimum amount of mempool, it can be increased
> by adding new block driver. I am not sure how many we will have block driver.
> 
> And, person who develop new driver always have to use mempool and consider
> what is minimum of mempool.
> I think this is a problem of mempool, now.
> 
> How about this?
> According to system memory, kernel have just one mempool for I/O which
> is one shared by several block driver.
> 
> And we make new API block driver can use.
> Of course, as usual It can use dynamic memoy. Only it can use mempool if
> system don't have much dynamic memory.
> 
> In this case, we can control read/write path. read I/O can't help
> memory reclaiming.
> So I think read I/O don't use mempool, I am not sure. :)

Sure some generic blocklevel infrastructure might work, _but_ you cannot
take away the responsibility of determining the amount of memory needed,
nor does any of this have any merit if you do not limit yourself to that
amount.

Current PF_MEMALLOC usage in the VM is utterly broken in that we can
have a basically unlimited amount of tasks hit direct reclaim and all of
them will then consume PF_MEMALLOC, which mean we can easily run out of
memory.

( unless I missed the direct reclaim throttle patches going in, which
isn't at all impossible )



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
