Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 84E656B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 21:10:24 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5516j6p022660
	for <linux-mm@kvack.org>; Thu, 4 Jun 2009 19:06:45 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n551ANJu024798
	for <linux-mm@kvack.org>; Thu, 4 Jun 2009 19:10:23 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n551AM8t020705
	for <linux-mm@kvack.org>; Thu, 4 Jun 2009 19:10:23 -0600
Date: Fri, 5 Jun 2009 09:10:19 +0800
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] remove memory.limit v.s. memsw.limit comparison.
Message-ID: <20090605011019.GG7504@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com> <20090604123625.GE7504@balbir.in.ibm.com> <0921392c77890fc84fa69653ae4f31d9.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <0921392c77890fc84fa69653ae4f31d9.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-05 00:45:03]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-04
> > 14:10:43]:
> >
> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> Removes memory.limit < memsw.limit at setting limit check completely.
> >>
> >> The limitation "memory.limit <= memsw.limit" was added just because
> >> it seems sane ...if memory.limit > memsw.limit, only memsw.limit works.
> >>
> >> But To implement this limitation, we needed to use private mutex and
> >> make
> >> the code a bit complated.
> >> As Nishimura pointed out, in real world, there are people who only want
> >> to use memsw.limit.
> >>
> >> Then, this patch removes the check. user-land library or middleware can
> >> check
> >> this in userland easily if this really concerns.
> >>
> >> And this is a good change to charge-and-reclaim.
> >>
> >> Now, memory.limit is always checked before memsw.limit
> >> and it may do swap-out. But, if memory.limit == memsw.limit, swap-out is
> >> finally no help and hits memsw.limit again. So, let's allow the
> >> condition
> >> memory.limit > memsw.limit. Then we can skip unnecesary swap-out.
> >>
> >> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >> ---
> >
> > There is one other option, we could set memory.limit_in_bytes ==
> > memory.memsw.limit_in_bytes provided it is set to LONG_LONG_MAX. I am
> > not convinced that we should allow memsw.limit_in_bytes to be less
> > that limit_in_bytes, it will create confusion and the API is already
> > exposed.
> >
> Ahhhh, I get your point.
>  if memory.memsw.limit_in_bytes < memory.limit_in_bytes, no swap will
>  be used bacause currnet try_to_free_pages() for memcg skips swap-out.
>  Then, only global-LRU will use swap.
>  This behavior is not easy to understand.
> 
> Sorry, I don't push this patch as this is. But adding documentation about
> "What happens when you set memory.limit == memsw.limit" will be necessary.
> 
> ...maybe give all jobs to user-land and keep the kernel as it is now
> is a good choice.

Yes, probably and with libcgroup and configuration, defaults should
not be hard to setup. Worst case we can use a script to setup both the
values.

> 
> BTW, I'd like to avoid useless swap-out in memory.limit == memsw.limit case.
> If someone has good idea, please :(
>

Are you seeing swap even with memory.limit == memory.memsw.limit? Only
global pressure should cause swapout, no? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
