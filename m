Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 605BA6B004D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 10:01:25 -0500 (EST)
Received: by fxm9 with SMTP id 9so1470090fxm.10
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 07:01:06 -0800 (PST)
Subject: Re: Improving OOM killer
From: Minchan Kim <minchan.kim@gmail.com>
In-Reply-To: <20100203122526.GG19641@balbir.in.ibm.com>
References: <201002012302.37380.l.lunak@suse.cz>
	 <20100203085711.GF19641@balbir.in.ibm.com>
	 <201002031310.28271.l.lunak@suse.cz>
	 <20100203122526.GG19641@balbir.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 04 Feb 2010 00:00:54 +0900
Message-ID: <1265209254.1052.24.camel@barrios-desktop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Lubos Lunak <l.lunak@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Jiri Kosina <jkosina@suse.cz>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-02-03 at 17:55 +0530, Balbir Singh wrote:
> * Lubos Lunak <l.lunak@suse.cz> [2010-02-03 13:10:27]:
> 
> > On Wednesday 03 of February 2010, Balbir Singh wrote:
> > > * Lubos Lunak <l.lunak@suse.cz> [2010-02-01 23:02:37]:
> > > >  In other words, use VmRSS for measuring memory usage instead of VmSize,
> > > > and remove child accumulating.
> > >
> > > I am not sure of the impact of changing to RSS, although I've
> > > personally believed that RSS based accounting is where we should go,
> > > but we need to consider the following
> > >
> > > 1. Total VM provides data about potentially swapped pages,
> > 
> >  Yes, I've already updated my proposal in another mail to switch from VmSize 
> > to VmRSS+InSwap. I don't know how to find out the second item in code, but at 
> > this point of discussion that's just details.
> > 

We have swap count with mm-count-swap-usage.patch by Kame in mmtom.

> I am yet to catch up with the rest of the thread. Thanks for heads up.
> 
> > > overcommit, 
> > 
> >  I don't understand how this matters. Overcommit is memory for which address 
> > space has been allocated but not actual memory, right? Then that's exactly 
> > what I'm claiming is wrong and am trying to reverse. Currently OOM killer 
> > takes this into account because it uses VmSize, but IMO it shouldn't - if a 
> > process does malloc(400M) but then it uses only a tiny fraction of that, in 
> > the case of memory shortage killing that process does not solve anything in 
> > practice.
> 
> We have a way of tracking commmitted address space, which is more
> sensible than just allocating memory and is used for tracking
> overcommit. I was suggesting that, that might be a better approach.

Yes. It does make sense. At least total_vm doesn't care about
MAP_NORESERVE case. But unfortunately, it's a per CPU not per Process.

> 
> > 
> > > etc.
> > > 2. RSS alone is not sufficient, RSS does not account for shared pages,
> > > so we ideally need something like PSS.
> > 
> >  Just to make sure I understand what you mean with "RSS does not account for 
> > shared pages" - you say that if a page is shared by 4 processes, then when 
> > calculating badness for them, only 1/4 of the page should be counted for 
> > each? Yes, I suppose so, that makes sense.
> 
> Yes, that is what I am speaking of

I agree. If we want to make RSS with base of badness, it's one of things
we have to solve.


-- 
Kind regards,
Minchan Kim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
