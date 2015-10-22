Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 1F0DD6B0255
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 10:33:57 -0400 (EDT)
Received: by pasz6 with SMTP id z6so88327120pas.2
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:33:56 -0700 (PDT)
Received: from mail-pa0-x22e.google.com (mail-pa0-x22e.google.com. [2607:f8b0:400e:c03::22e])
        by mx.google.com with ESMTPS id vz2si21512598pbc.164.2015.10.22.07.33.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 07:33:56 -0700 (PDT)
Received: by pacfv9 with SMTP id fv9so92475631pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 07:33:56 -0700 (PDT)
Date: Thu, 22 Oct 2015 23:33:49 +0900
From: Tejun Heo <htejun@gmail.com>
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable()
 checks
Message-ID: <20151022143349.GD30579@mtj.duckdns.org>
References: <alpine.DEB.2.20.1510210948460.6898@east.gentwo.org>
 <20151021145505.GE8805@dhcp22.suse.cz>
 <alpine.DEB.2.20.1510211214480.10364@east.gentwo.org>
 <201510222037.ACH86458.OFOLFtQFOHJSVM@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.20.1510220836430.18486@east.gentwo.org>
 <20151022140944.GA30579@mtj.duckdns.org>
 <20151022142155.GB30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220923130.23591@east.gentwo.org>
 <20151022142429.GC30579@mtj.duckdns.org>
 <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1510220925160.23638@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, mhocko@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, David Rientjes <rientjes@google.com>, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

On Thu, Oct 22, 2015 at 09:25:49AM -0500, Christoph Lameter wrote:
> On Thu, 22 Oct 2015, Tejun Heo wrote:
> 
> > On Thu, Oct 22, 2015 at 09:23:54AM -0500, Christoph Lameter wrote:
> > > I guess we need that otherwise vm statistics are not updated while worker
> > > threads are blocking on memory reclaim.
> >
> > And the blocking one is just constantly running?
> 
> I was told that there is just one task struct so additional work queue
> items cannot be processed while waiting?

lol, no, what it tries to do is trying to keep the number of RUNNING
workers at minimum so that minimum number of workers can be used and
work items are executed back-to-back on the same workers.  The moment
a work item blocks, the next worker kicks in and starts executing the
next work item in line.

The only way to hang the execution for a work item w/ WQ_MEM_RECLAIM
is to create a cyclic dependency on another work item and keep that
work item busy wait.  Workqueue thinks that work item is making
progress as it's running and doesn't schedule the next one.

(I was misremembering here) HIGHPRI originally was implemented
head-queueing on the same pool followed by immediate execution, so
could get around cases where this could happen, but that got lost
while converting it to a separate pool.  I can introduce another flag
to bypass concurrency management if necessary (it's kinda trivial) but
busy-waiting cyclic dependency is a pretty unusual thing.

If this is actually a legit busy-waiting cyclic dependency, just let
me know.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
