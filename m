Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate4.de.ibm.com (8.13.6/8.13.6) with ESMTP id k3PCIZmt124882
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 12:18:35 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k3PCJeKp117778
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 14:19:40 +0200
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11/8.13.3) with ESMTP id k3PCIYYT013127
	for <linux-mm@kvack.org>; Tue, 25 Apr 2006 14:18:34 +0200
Subject: Re: Page host virtual assist patches.
From: Martin Schwidefsky <schwidefsky@de.ibm.com>
Reply-To: schwidefsky@de.ibm.com
In-Reply-To: <444DFF4D.8050108@yahoo.com.au>
References: <20060424123412.GA15817@skybase>
	 <20060424180138.52e54e5c.akpm@osdl.org> <1145952628.5282.8.camel@localhost>
		  <444DDD1B.4010202@yahoo.com.au> <1145961386.5282.37.camel@localhost>
	  <444DFF4D.8050108@yahoo.com.au>
Content-Type: text/plain
Date: Tue, 25 Apr 2006 14:18:39 +0200
Message-Id: <1145967519.5282.81.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-25 at 20:51 +1000, Nick Piggin wrote:
> > Beauty lies in the eye of the beholder. From my point of view there is
> > benefit to the method.
> 
> That's 'cause you have an s390.

And everbody else do not have to use the code. It configuratable.

> > First some assumptions about the environment. We are talking about a
> > paging hypervisor that runs several hundreds of guest Linux images. The
> > memory is overcommited, the sum of the guest memory sizes is larger than
> > the host memory by a factor of 2-3. Usually a large percentage of the
> > guests memory is paged out by the hypervisor.
> > 
> > Both the host and the guest follow an LRU strategy. That means that the
> > host will pick the oldest page from the idlest guest. Almost the same
> > would happen if you call into the idlest guest to let the guest free its
> > oldest page. But the catch is that the guest will touch a lot of page
> > doing its vmscan operation, if that causes a single additional host i/o
> > because a guest page needs to be retrieved from the host swap device,
> > you are already in negative territory.
> 
> Why would most guest memory be paged out if the host reclaims by first
> asking guests to reclaim, *then* paging them out?

Because memory for guests running under z/VM is overcommitted. Even with
the ballooner that reduces the guest memory size to the >guests< working
set size, the host will still do paging on the remaining guest pages.

> I can understand that you observe most guest memory to be paged out
> under pressure with the present scheme, but the dynamics will completely
> change I think... You'll be left with shrunk guests, which you could
> then mark as unreclaimable, stop asking them to reclaim, then page the
> rest of their memory out from the host.

Yes I think that this works. With 5 guest images. With 1000 images? I
doubt it, the overhead just adds up.

>  > It does attempt to keep some memory free. But lets say 1000 guest images
>  > generate a lot of memory pressure. You will run out of memory, and
>  > anything that speeds up the host reclaim will improve the situation. And
> 
> I believe that, and I'm sure there are lots of really invasive things you
> could do to make it even faster...

With enough images you have a lot of dynamics in the shift of memory
between guests. With the ballooner you can do the low-frequency shifts
to get the guests roughly to their working set size. The high-frequency
shifts between guests are better done with hva.

-- 
blue skies,
  Martin.

Martin Schwidefsky
Linux for zSeries Development & Services
IBM Deutschland Entwicklung GmbH

"Reality continues to ruin my life." - Calvin.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
