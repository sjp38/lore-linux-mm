Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id D0AFF6B4DFC
	for <linux-mm@kvack.org>; Wed, 28 Nov 2018 11:56:40 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id k133so3766229ite.4
        for <linux-mm@kvack.org>; Wed, 28 Nov 2018 08:56:40 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id o8si2335511ite.100.2018.11.28.08.56.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Nov 2018 08:56:39 -0800 (PST)
Date: Wed, 28 Nov 2018 08:56:18 -0800
From: Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [RFC PATCH v4 01/13] ktask: add documentation
Message-ID: <20181128165618.7ttzgzh2axl62ajd@ca-dmjordan1.us.oracle.com>
References: <20181105165558.11698-1-daniel.m.jordan@oracle.com>
 <20181105165558.11698-2-daniel.m.jordan@oracle.com>
 <20181127195008.GA20692@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181127195008.GA20692@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: Daniel Jordan <daniel.m.jordan@oracle.com>, linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, aarcange@redhat.com, aaron.lu@intel.com, akpm@linux-foundation.org, alex.williamson@redhat.com, bsd@redhat.com, darrick.wong@oracle.com, dave.hansen@linux.intel.com, jgg@mellanox.com, jwadams@google.com, jiangshanlai@gmail.com, mhocko@kernel.org, mike.kravetz@oracle.com, Pavel.Tatashin@microsoft.com, prasad.singamsetty@oracle.com, rdunlap@infradead.org, steven.sistare@oracle.com, tim.c.chen@intel.com, tj@kernel.org, vbabka@suse.cz, peterz@infradead.org, dhaval.giani@oracle.com

On Tue, Nov 27, 2018 at 08:50:08PM +0100, Pavel Machek wrote:
> Hi!

Hi, Pavel.

> > +============================================
> > +ktask: parallelize CPU-intensive kernel work
> > +============================================
> > +
> > +:Date: November, 2018
> > +:Author: Daniel Jordan <daniel.m.jordan@oracle.com>
> 
> 
> > +For example, consider the task of clearing a gigantic page.  This used to be
> > +done in a single thread with a for loop that calls a page clearing function for
> > +each constituent base page.  To parallelize with ktask, the client first moves
> > +the for loop to the thread function, adapting it to operate on the range passed
> > +to the function.  In this simple case, the thread function's start and end
> > +arguments are just addresses delimiting the portion of the gigantic page to
> > +clear.  Then, where the for loop used to be, the client calls into ktask with
> > +the start address of the gigantic page, the total size of the gigantic page,
> > +and the thread function.  Internally, ktask will divide the address range into
> > +an appropriate number of chunks and start an appropriate number of threads to
> > +complete these chunks.
> 
> Great, so my little task is bound to CPUs 1-4 and uses gigantic
> pages. Kernel clears them for me.
> 
> a) Do all the CPUs work for me, or just CPUs I was assigned to?

In ktask's current form, all the CPUs.  This is an existing limitation of
workqueues, which ktask is built on: unbound workqueue workers don't honor the
cpumask of the queueing task (...absent a wq user applying a cpumask wq attr
beforehand, which nobody in-tree does...).

But good point, the helper threads should only run on the CPUs the task is
bound to.  I'm working on cgroup-aware workqueues but hadn't considered a
task's cpumask outside of cgroup/cpuset, so I'll try adding support for this
too.

> b) Will my time my_little_task show the system time including the
> worker threads?

No, system time of kworkers isn't accounted to the user tasks they're working
on behalf of.  This time is already visible to userland in kworkers, and it
would be confusing to account it to a userland task instead.

Thanks for the questions.

Daniel
