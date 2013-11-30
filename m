Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f50.google.com (mail-yh0-f50.google.com [209.85.213.50])
	by kanga.kvack.org (Postfix) with ESMTP id D7D436B0035
	for <linux-mm@kvack.org>; Sat, 30 Nov 2013 05:25:45 -0500 (EST)
Received: by mail-yh0-f50.google.com with SMTP id b6so7262127yha.23
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 02:25:45 -0800 (PST)
Received: from mail-yh0-x235.google.com (mail-yh0-x235.google.com [2607:f8b0:4002:c01::235])
        by mx.google.com with ESMTPS id k26si39345117yha.229.2013.11.30.02.25.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 30 Nov 2013 02:25:45 -0800 (PST)
Received: by mail-yh0-f53.google.com with SMTP id b20so7239962yha.26
        for <linux-mm@kvack.org>; Sat, 30 Nov 2013 02:25:44 -0800 (PST)
Date: Sat, 30 Nov 2013 02:25:41 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [merged] mm-memcg-handle-non-error-oom-situations-more-gracefully.patch
 removed from -mm tree
In-Reply-To: <20131130005100.GA8387@kroah.com>
Message-ID: <alpine.DEB.2.02.1311300153310.29602@chino.kir.corp.google.com>
References: <526028bd.k5qPj2+MDOK1o6ii%akpm@linux-foundation.org> <alpine.DEB.2.02.1311271453270.13682@chino.kir.corp.google.com> <20131127233353.GH3556@cmpxchg.org> <alpine.DEB.2.02.1311271622330.10617@chino.kir.corp.google.com> <20131128021809.GI3556@cmpxchg.org>
 <alpine.DEB.2.02.1311271826001.5120@chino.kir.corp.google.com> <20131128031313.GK3556@cmpxchg.org> <alpine.DEB.2.02.1311271914460.5120@chino.kir.corp.google.com> <20131128035218.GM3556@cmpxchg.org> <alpine.DEB.2.02.1311291546370.22413@chino.kir.corp.google.com>
 <20131130005100.GA8387@kroah.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg KH <gregkh@linuxfoundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, azurit@pobox.sk, mm-commits@vger.kernel.org, stable@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 29 Nov 2013, Greg KH wrote:

> > > > None that I am currently aware of, I'll continue to try them out.  I'd 
> > > > suggest just dropping the stable@kernel.org from the whole series though 
> > > > unless there is another report of such a problem that people are running 
> > > > into.
> > > 
> > > The series has long been merged, how do we drop stable@kernel.org from
> > > it?
> > > 
> > 
> > You said you have informed stable to not merge these patches until further 
> > notice, I'd suggest simply avoid ever merging the whole series into a 
> > stable kernel since the problem isn't serious enough.  Marking changes 
> > that do "goto nomem" seem fine to mark for stable, though.
> 
> I'm lost.  These patches are in 3.12, so how can they not be "in
> stable"?
> 
> What exactly do you want me to do here?
> 

Sorry, I sympathize with your confusion since the handling of this patch 
series has been strange and confusing from the beginning.

I'm referring to the comment in this thread from Johannes: "[t]his patch 
series was not supposed to go into the last merge window, I already told 
stable to hold off on these until further notice" from 
http://marc.info/?l=linux-mm&m=138559524422298 and his intention to send 
the entire series to stable in 
http://marc.info/?l=linux-kernel&m=138539243412073.

>From that, I had thought you were already aware of this series and were 
waiting to merge it into previous stable kernels; I'm suggesting that 
stable doesn't touch this series with a ten-foot pole and only backport 
the fixes that have gone into 3.12.

That series is:

759496ba640c ("arch: mm: pass userspace fault flag to generic fault handler")
3a13c4d761b4 ("x86: finish user fault error path with fatal signal")
519e52473ebe ("mm: memcg: enable memcg OOM killer only for user faults")
fb2a6fc56be6 ("mm: memcg: rework and document OOM waiting and wakeup")
3812c8c8f395 ("mm: memcg: do not trap chargers with full callstack on OOM")

And then there's the mystery of 4942642080ea ("mm: memcg: handle non-error 
OOM situations more gracefully").  This patch went into 3.12-rc6 and is 
marked for stable@vger.kernel.org.  Its changelog indicates it fixes the 
last patch in the above series, but that patch isn't marked for 
stable@vger.kernel.org.

And then you have 84235de394d9 ("fs: buffer: move allocation failure loop 
into the allocator") which is marked for stable@vger.kernel.org, but 
3168ecbe1c04 ("mm: memcg: use proper memcg in limit bypass") which fixes 
the memory corruption in that commit isn't marked for stable.

I disagreed with the entire series being marked for stable in 
http://marc.info/?l=linux-kernel&m=137107020216528 since it violates the 
rules in Documentation/stable_kernel_rules.txt when it was originally 
proposed for stable.  The memcg oom waitqueue that this series avoids has 
been in memcg for 3 1/2 years since 2.6.34 and to date one user, cc'd, has 
reported any issues with it.

And then Johannes commented that he is asking stable to hold off on the 
series until further notice.  I'm suggesting the series not be merged into 
stable at all, and that's what's in the email you're responding to.

Further, since this is confusing enough as it is, I suggest if you do take 
84235de394d9 ("fs: buffer: move allocation failure loop into the 
allocator") that you certainly must also consider 3168ecbe1c04 ("mm: 
memcg: use proper memcg in limit bypass").  The former was backported to 
3.5 and they required an emergency release of 3.5.7.25 to take it back 
out.

There's also another patch that Johannes will shortly be sending to fix 
the leakage to the root memcg in oom conditions that can trivially cause 
large amounts of memory to be charged to the root memcg when it should 
have been isolated to the oom memcg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
