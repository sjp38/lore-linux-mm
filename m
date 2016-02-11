Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CBD296B0005
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 16:18:05 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id ho8so34884505pac.2
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 13:18:05 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id k81si14801138pfj.154.2016.02.11.13.18.04
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 13:18:05 -0800 (PST)
Message-ID: <1455225484.715.93.camel@schen9-desk2.jf.intel.com>
Subject: Re: [RFC PATCH 3/3] mm: increase scalability of global memory
 commitment accounting
From: Tim Chen <tim.c.chen@linux.intel.com>
Date: Thu, 11 Feb 2016 13:18:04 -0800
In-Reply-To: <20160211125103.8a4fb0ffed593938321755d2@linux-foundation.org>
References: <1455115941-8261-1-git-send-email-aryabinin@virtuozzo.com>
	 <1455115941-8261-3-git-send-email-aryabinin@virtuozzo.com>
	 <1455127253.715.36.camel@schen9-desk2.jf.intel.com>
	 <20160210132818.589451dbb5eafae3fdb4a7ec@linux-foundation.org>
	 <1455150256.715.60.camel@schen9-desk2.jf.intel.com>
	 <20160211125103.8a4fb0ffed593938321755d2@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>

On Thu, 2016-02-11 at 12:51 -0800, Andrew Morton wrote:
> On Wed, 10 Feb 2016 16:24:16 -0800 Tim Chen <tim.c.chen@linux.intel.com> wrote:
> 
> > On Wed, 2016-02-10 at 13:28 -0800, Andrew Morton wrote:
> > 
> > > 
> > > If a process is unmapping 4MB then it's pretty crazy for us to be
> > > hitting the percpu_counter 32 separate times for that single operation.
> > > 
> > > Is there some way in which we can batch up the modifications within the
> > > caller and update the counter less frequently?  Perhaps even in a
> > > single hit?
> > 
> > I think the problem is the batch size is too small and we overflow
> > the local counter into the global counter for 4M allocations.
> 
> That's one way of looking at the issue.  The other way (which I point
> out above) is that we're calling vm_[un]_acct_memory too frequently
> when mapping/unmapping 4M segments.
> 
> Exactly which mmap.c callsite is causing this issue?

I suspect it is __vm_enough_memory called from do_brk or mmap_region in
Andrey's test case.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
