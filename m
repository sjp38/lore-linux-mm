Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 682E46B04EB
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 05:28:04 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id s195-v6so1715577itc.6
        for <linux-mm@kvack.org>; Wed, 07 Nov 2018 02:28:04 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id m25si403101itn.134.2018.11.07.02.28.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Nov 2018 02:28:03 -0800 (PST)
Date: Wed, 7 Nov 2018 11:27:52 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181107102752.GK9781@hirez.programming.kicks-ass.net>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
 <20181106084911.GA22504@hirez.programming.kicks-ass.net>
 <20181106203411.pdce6tgs7dncwflh@ca-dmjordan1.us.oracle.com>
 <20181106205146.GB30490@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181106205146.GB30490@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@mellanox.com>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, "rjw@rjwysocki.net" <rjw@rjwysocki.net>, "linux-pm@vger.kernel.org" <linux-pm@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kvm@vger.kernel.org" <kvm@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "aarcange@redhat.com" <aarcange@redhat.com>, "aaron.lu@intel.com" <aaron.lu@intel.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "alex.williamson@redhat.com" <alex.williamson@redhat.com>, "bsd@redhat.com" <bsd@redhat.com>, "darrick.wong@oracle.com" <darrick.wong@oracle.com>, "dave.hansen@linux.intel.com" <dave.hansen@linux.intel.com>, "jwadams@google.com" <jwadams@google.com>, "jiangshanlai@gmail.com" <jiangshanlai@gmail.com>, "mhocko@kernel.org" <mhocko@kernel.org>, "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>, "Pavel.Tatashin@microsoft.com" <Pavel.Tatashin@microsoft.com>, "prasad.singamsetty@oracle.com" <prasad.singamsetty@oracle.com>, "rdunlap@infradead.org" <rdunlap@infradead.org>, "steven.sistare@oracle.com" <steven.sistare@oracle.com>, "tim.c.chen@intel.com" <tim.c.chen@intel.com>, "tj@kernel.org" <tj@kernel.org>, "vbabka@suse.cz" <vbabka@suse.cz>

On Tue, Nov 06, 2018 at 08:51:54PM +0000, Jason Gunthorpe wrote:
> On Tue, Nov 06, 2018 at 12:34:11PM -0800, Daniel Jordan wrote:
> 
> > > What isn't clear is if this calling thread is waiting or not. Only do
> > > this inheritance trick if it is actually waiting on the work. If it is
> > > not, nobody cares.
> > 
> > The calling thread waits.  Even if it didn't though, the inheritance trick
> > would still be desirable for timely completion of the job.
> 
> Can you make lockdep aware that this is synchronous?
> 
> ie if I do
> 
>   mutex_lock()
>   ktask_run()
>   mutex_lock()
> 
> Can lockdep know that all the workers are running under that lock?
> 
> I'm thinking particularly about rtnl_lock as a possible case, but
> there could also make some sense to hold the read side of the mm_sem
> or similar like the above.

Yes, the normal trick is adding a fake lock to ktask_run and holding
that over the actual job. See lock_map* in flush_workqueue() vs
process_one_work().
