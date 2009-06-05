Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0D9556B004D
	for <linux-mm@kvack.org>; Thu,  4 Jun 2009 20:40:30 -0400 (EDT)
Date: Fri, 5 Jun 2009 09:34:20 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] remove memory.limit v.s. memsw.limit comparison.
Message-Id: <20090605093420.0b208c33.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <0921392c77890fc84fa69653ae4f31d9.squirrel@webmail-b.css.fujitsu.com>
References: <20090604141043.9a1064fd.kamezawa.hiroyu@jp.fujitsu.com>
	<20090604123625.GE7504@balbir.in.ibm.com>
	<0921392c77890fc84fa69653ae4f31d9.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009 00:45:03 +0900 (JST), "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
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
I agree.

> ...maybe give all jobs to user-land and keep the kernel as it is now
> is a good choice.
> 
> BTW, I'd like to avoid useless swap-out in memory.limit == memsw.limit case.
> If someone has good idea, please :(
> 
I think so too.

>From my simple thoughts, how about changing __mem_cgroup_try_charge() like:

1. initialize "noswap" as "bool noswap = !!(mem->res.limit == mem->memsw.limit)".
2. add check "if (mem->res.limit == mem->memsw.limit)" on charge failure to mem->res
   and set "noswap" to true if needed. 
3. charge mem->memsw before mem->res.

There would be other ideas, but I prefer 1 among these choices.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
