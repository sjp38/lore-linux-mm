Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 5C9CE6B0036
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 18:30:44 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 4 Apr 2013 16:30:41 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2FB261FF0039
	for <linux-mm@kvack.org>; Thu,  4 Apr 2013 16:25:40 -0600 (MDT)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r34MUc0N268038
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 16:30:38 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r34MXN14026145
	for <linux-mm@kvack.org>; Thu, 4 Apr 2013 16:33:23 -0600
Date: Thu, 4 Apr 2013 15:30:34 -0700
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] mm: prevent mmap_cache race in find_vma()
Message-ID: <20130404223034.GQ28522@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <alpine.LNX.2.00.1304041120510.26822@eggly.anvils>
 <CA+55aFwCG2h1ijWTCJ38LVcUyczDAfk72c4MVSU+_-BiLoMOOw@mail.gmail.com>
 <alpine.LNX.2.00.1304041149030.29847@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1304041149030.29847@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jan Stancek <jstancek@redhat.com>, Jakub Jelinek <jakub@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Ian Lance Taylor <iant@google.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Thu, Apr 04, 2013 at 12:01:52PM -0700, Hugh Dickins wrote:
> On Thu, 4 Apr 2013, Linus Torvalds wrote:
> > On Thu, Apr 4, 2013 at 11:35 AM, Hugh Dickins <hughd@google.com> wrote:
> > >
> > > find_vma() can be called by multiple threads with read lock
> > > held on mm->mmap_sem and any of them can update mm->mmap_cache.
> > > Prevent compiler from re-fetching mm->mmap_cache, because other
> > > readers could update it in the meantime:
> > 
> > Ack. I do wonder if we should mark the unlocked update too some way
> > (also in find_vma()), although it's probably not a problem in practice
> > since there's no way the compiler can reasonably really do anything
> > odd with it. We *could* make that an ACCESS_ONCE() write too just to
> > highlight the fact that it's an unlocked write to this optimistic data
> > structure.
> 
> Hah, you beat me to it.
> 
> I wanted to get Jan's patch in first, seeing as it actually fixes his
> observed issue; and it is very nice to have such a good description of
> one of those, when ACCESS_ONCE() is usually just an insurance policy.
> 
> But then I was researching the much rarer "ACCESS_ONCE(x) = y" usage
> (popular in drivers/net/wireless/ath/ath9k and kernel/rcutree* and
> sound/firewire, but few places else).
> 
> When Paul reminded us of it yesterday, I came to wonder if actually
> every use of ACCESS_ONCE in the read form should strictly be matched
> by ACCESS_ONCE whenever modifying the location.

>From a hygiene/insurance/documentation point of view, I agree.  Of course,
it is OK to use things like cmpxchg() in place of ACCESS_ONCE().

The possible exceptions that come to mind are (1) if the access in
question is done holding a lock that excludes all other accesses to that
location, (2) if the access in question happens during initialization
before any other CPU has access to that location, and (3) if the access
in question happens during cleanup after all other CPUs have lost access
to that location.  Any others?

/me goes to look to see if the RCU code follows this good advice...

							Thanx, Paul

> My uneducated guess is that strictly it ought to, in the sense of
> insurance policy; but that (apart from that strange split writing
> issue which came up a couple of months ago) in practice our compilers
> have not "advanced" to the point of making this an issue yet.
> 
> > 
> > Anyway, applied.
> 
> Thanks,
> Hugh
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
