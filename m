Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 019516B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 00:30:21 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp08.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0E5FENx028793
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 10:45:14 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0E5UHFr2920702
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 11:00:18 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0E5UCBc001326
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 16:30:13 +1100
Date: Wed, 14 Jan 2009 11:00:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 1/4] Memory controller soft limit documentation
Message-ID: <20090114053015.GK27129@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090107184110.18062.41459.sendpatchset@localhost.localdomain> <20090107184116.18062.8379.sendpatchset@localhost.localdomain> <6599ad830901131745t704428dav6fbf69aa315285b1@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <6599ad830901131745t704428dav6fbf69aa315285b1@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* Paul Menage <menage@google.com> [2009-01-13 17:45:54]:

> On Wed, Jan 7, 2009 at 10:41 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > -7. TODO
> > +7. Soft limits
> > +
> > +Soft limits allow for greater sharing of memory. The idea behind soft limits
> > +is to allow control groups to use as much of the memory as needed, provided
> > +
> > +a. There is no memory contention
> > +b. They do not exceed their hard limit
> > +
> > +When the system detects memory contention (through do_try_to_free_pages(),
> > +while allocating), control groups are pushed back to their soft limits if
> > +possible. If the soft limit of each control group is very high, they are
> > +pushed back as much as possible to make sure that one control group does not
> > +starve the others.
> 
> Can you give an example here of how to implement the following setup:
> 
> - we have a high-priority latency-sensitive server job A and a bunch
> of low-priority batch jobs B, C and D
> 
> - each job *may* need up to 2GB of memory, but generally each tends to
> use <1GB of memory
> 
> - we want to run all four jobs on a 4GB machine
> 
> - we don't want A to ever have to wait for memory to be reclaimed (as
> it's serving latency-sensitive queries), so the kernel should be
> squashing B/C/D down *before* memory actually runs out.
> 
> Is this possible with the proposed hard/soft limit setup? Or do we
> need some additional support for keeping a pool of pre-reserved free
> memory available?

This is a more complex scenario, It sounds like B/C and D should be
hard limited to 2G or another value, depending on how much you want to
pre-reserve for A (all B/C and D should be in the same cgroup). Then
you want to use soft limits within the B/C/D cgroup. You don't want to
hard limit A, but just setup a 2G soft limit for it.

The notion of prioritized jobs and reservation does not exist yet, but
once we support soft limits and overcommit via soft limits, we could
consider looking at what design aspects would help with it.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
