Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 64F2A6B0069
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:01:57 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id 3so49994627pgd.3
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 13:01:57 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id g129si65952100pfc.132.2016.11.30.13.01.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 13:01:56 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAUKwiSs090875
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:01:56 -0500
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2721hkfqas-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 16:01:55 -0500
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 30 Nov 2016 14:01:55 -0700
Date: Wed, 30 Nov 2016 13:01:52 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: next: Commit 'mm: Prevent __alloc_pages_nodemask() RCU CPU stall
 ...' causing hang on sparc32 qemu
Reply-To: paulmck@linux.vnet.ibm.com
References: <20161129212308.GA12447@roeck-us.net>
 <20161130012817.GH3924@linux.vnet.ibm.com>
 <b96c1560-3f06-bb6d-717a-7a0f0c6e869a@roeck-us.net>
 <20161130070212.GM3924@linux.vnet.ibm.com>
 <929f6b29-461a-6e94-fcfd-710c3da789e9@roeck-us.net>
 <20161130120333.GQ3924@linux.vnet.ibm.com>
 <20161130192159.GB22216@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161130192159.GB22216@roeck-us.net>
Message-Id: <20161130210152.GL3924@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, sparclinux@vger.kernel.org, davem@davemloft.net

On Wed, Nov 30, 2016 at 11:21:59AM -0800, Guenter Roeck wrote:
> On Wed, Nov 30, 2016 at 04:03:33AM -0800, Paul E. McKenney wrote:
> > On Wed, Nov 30, 2016 at 02:52:11AM -0800, Guenter Roeck wrote:
> > > On 11/29/2016 11:02 PM, Paul E. McKenney wrote:
> > > >On Tue, Nov 29, 2016 at 08:32:51PM -0800, Guenter Roeck wrote:
> > > >>On 11/29/2016 05:28 PM, Paul E. McKenney wrote:
> > > >>>On Tue, Nov 29, 2016 at 01:23:08PM -0800, Guenter Roeck wrote:
> > > >>>>Hi Paul,
> > > >>>>
> > > >>>>most of my qemu tests for sparc32 targets started to fail in next-20161129.
> > > >>>>The problem is only seen in SMP builds; non-SMP builds are fine.
> > > >>>>Bisect points to commit 2d66cccd73436 ("mm: Prevent __alloc_pages_nodemask()
> > > >>>>RCU CPU stall warnings"); reverting that commit fixes the problem.
> > 
> > And I have dropped this patch.  Michal Hocko showed me the error of
> > my ways with this patch.
> > 
> 
> :-)
> 
> On another note, I still get RCU tracebacks in the s390 tests.
> 
> BUG: sleeping function called from invalid context at mm/page_alloc.c:3775
> 
> That is caused by 'rcu: Maintain special bits at bottom of ->dynticks counter';
> if I recall correctly we had discussed that earlier.

Indeed, I had missed a dyntick counter update back on Nov 11, which meant
that some of the code was still looking at the low-order bit instead of
the next bit up.  This is now fixed.

So to get to the error message you call out above, I need to have improperly
left the system in bh state or left irqs disabled, while the system was
running normally without an oops.  I am having a hard time seeing how this
patch can do that.

I would be more suspicious of f2a471ffc8a8 ("rcu: Allow boot-time use
of cond_resched_rcu_qs()").

So you bisected or did a revert to work out which was the offending commit?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
