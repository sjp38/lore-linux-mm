Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6FE8F6B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:18:50 -0500 (EST)
Received: by mail-io0-f198.google.com with SMTP id j65so42505972iof.1
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 15:18:50 -0800 (PST)
Received: from bh-25.webhostbox.net (bh-25.webhostbox.net. [208.91.199.152])
        by mx.google.com with ESMTPS id e64si32083463otb.19.2016.11.30.15.18.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 30 Nov 2016 15:18:49 -0800 (PST)
Date: Wed, 30 Nov 2016 15:18:46 -0800
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
Message-ID: <20161130231846.GB17244@roeck-us.net>
References: <20161129212308.GA12447@roeck-us.net>
 <20161130012817.GH3924@linux.vnet.ibm.com>
 <b96c1560-3f06-bb6d-717a-7a0f0c6e869a@roeck-us.net>
 <20161130070212.GM3924@linux.vnet.ibm.com>
 <929f6b29-461a-6e94-fcfd-710c3da789e9@roeck-us.net>
 <20161130120333.GQ3924@linux.vnet.ibm.com>
 <20161130192159.GB22216@roeck-us.net>
 <20161130210152.GL3924@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130210152.GL3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

On Wed, Nov 30, 2016 at 01:01:52PM -0800, Paul E. McKenney wrote:
> On Wed, Nov 30, 2016 at 11:21:59AM -0800, Guenter Roeck wrote:
> > On Wed, Nov 30, 2016 at 04:03:33AM -0800, Paul E. McKenney wrote:
> > > On Wed, Nov 30, 2016 at 02:52:11AM -0800, Guenter Roeck wrote:
> > > > On 11/29/2016 11:02 PM, Paul E. McKenney wrote:
> > > > >On Tue, Nov 29, 2016 at 08:32:51PM -0800, Guenter Roeck wrote:
> > > > >>On 11/29/2016 05:28 PM, Paul E. McKenney wrote:
> > > > >>>On Tue, Nov 29, 2016 at 01:23:08PM -0800, Guenter Roeck wrote:
> > > > >>>>Hi Paul,
> > > > >>>>
> > > > >>>>most of my qemu tests for sparc32 targets started to fail in next-20161129.
> > > > >>>>The problem is only seen in SMP builds; non-SMP builds are fine.
> > > > >>>>Bisect points to commit 2d66cccd73436 ("mm: Prevent __alloc_pages_nodemask()
> > > > >>>>RCU CPU stall warnings"); reverting that commit fixes the problem.
> > > 
> > > And I have dropped this patch.  Michal Hocko showed me the error of
> > > my ways with this patch.
> > > 
> > 
> > :-)
> > 
> > On another note, I still get RCU tracebacks in the s390 tests.
> > 
> > BUG: sleeping function called from invalid context at mm/page_alloc.c:3775
> > 
> > That is caused by 'rcu: Maintain special bits at bottom of ->dynticks counter';
> > if I recall correctly we had discussed that earlier.
> 
> Indeed, I had missed a dyntick counter update back on Nov 11, which meant
> that some of the code was still looking at the low-order bit instead of
> the next bit up.  This is now fixed.
> 
> So to get to the error message you call out above, I need to have improperly
> left the system in bh state or left irqs disabled, while the system was
> running normally without an oops.  I am having a hard time seeing how this
> patch can do that.
> 
> I would be more suspicious of f2a471ffc8a8 ("rcu: Allow boot-time use
> of cond_resched_rcu_qs()").
> 
> So you bisected or did a revert to work out which was the offending commit?
> 

My most recent bisect was with the November 10 image, so that would have missed
any later fix. Comparing the log messages, the current message is indeed
different. Sorry, I mixed that up; I just assumed that the problem would be
the same without really checking. My bad.

Bisect would be tricky, since the s390 image was broken for some time after
November 10. The first time I have seen the above BUG: was with next-20161128
(which is the first build after the crash was fixed). That version did not
include f2a471ffc8a8, so that can not be the cause.

I'll try to set up a bisect tonight, working around the crash problem.
I'll let you know how it goes.

Guenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
