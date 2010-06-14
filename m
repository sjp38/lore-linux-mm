Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA4676B01B9
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 04:48:20 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e38.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5E8fY9A013931
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 02:41:34 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5E8mE59136108
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 02:48:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5E8mEmS003974
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 02:48:14 -0600
Date: Mon, 14 Jun 2010 14:18:10 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100614084810.GT5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
 <4C10B3AF.7020908@redhat.com>
 <20100610142512.GB5191@balbir.in.ibm.com>
 <1276214852.6437.1427.camel@nimitz>
 <20100611045600.GE5191@balbir.in.ibm.com>
 <4C15E3C8.20407@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C15E3C8.20407@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-14 11:09:44]:

> On 06/11/2010 07:56 AM, Balbir Singh wrote:
> >
> >>Just to be clear, let's say we have a mapped page (say of /sbin/init)
> >>that's been unreferenced since _just_ after the system booted.  We also
> >>have an unmapped page cache page of a file often used at runtime, say
> >>one from /etc/resolv.conf or /etc/passwd.
> >>
> >>Which page will be preferred for eviction with this patch set?
> >>
> >In this case the order is as follows
> >
> >1. First we pick free pages if any
> >2. If we don't have free pages, we go after unmapped page cache and
> >slab cache
> >3. If that fails as well, we go after regularly memory
> >
> >In the scenario that you describe, we'll not be able to easily free up
> >the frequently referenced page from /etc/*. The code will move on to
> >step 3 and do its regular reclaim.
> 
> Still it seems to me you are subverting the normal order of reclaim.
> I don't see why an unmapped page cache or slab cache item should be
> evicted before a mapped page.  Certainly the cost of rebuilding a
> dentry compared to the gain from evicting it, is much higher than
> that of reestablishing a mapped page.
>

Subverting to aviod memory duplication, the word subverting is
overloaded, let me try to reason a bit. First let me explain the
problem

Memory is a precious resource in a consolidated environment.
We don't want to waste memory via page cache duplication
(cache=writethrough and cache=writeback mode).

Now here is what we are trying to do

1. A slab page will not be freed until the entire page is free (all
slabs have been kfree'd so to speak). Normal reclaim will definitely
free this page, but a lot of it depends on how frequently we are
scanning the LRU list and when this page got added.
2. In the case of page cache (specifically unmapped page cache), there
is duplication already, so why not go after unmapped page caches when
the system is under memory pressure?

In the case of 1, we don't force a dentry to be freed, but rather a
freed page in the slab cache to be reclaimed ahead of forcing reclaim
of mapped pages.

Does the problem statement make sense? If so, do you agree with 1 and
2? Is there major concern about subverting regular reclaim? Does
subverting it make sense in the duplicated scenario?

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
