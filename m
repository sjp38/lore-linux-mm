Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9E2F36B0168
	for <linux-mm@kvack.org>; Wed, 13 May 2009 22:57:07 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4E2tJcn024095
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:55:19 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4E2w0Pm220282
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:58:00 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4E2vxJm023566
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:58:00 -0600
Date: Thu, 14 May 2009 07:18:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH] memcg: fix deadlock between
	lock_page_cgroupand mapping tree_lock
Message-ID: <20090514014801.GS13394@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090513133031.f4be15a8.nishimura@mxp.nes.nec.co.jp> <20090513115626.57844f28.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090513115626.57844f28.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-05-13 11:56:26]:

> On Wed, 13 May 2009 13:30:31 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > mapping->tree_lock can be aquired from interrupt context.
> > Then, following dead lock can occur.
> > 
> > Assume "A" as a page.
> > 
> >  CPU0:
> >        lock_page_cgroup(A)
> > 		interrupted
> > 			-> take mapping->tree_lock.
> >  CPU1:
> >        take mapping->tree_lock
> > 		-> lock_page_cgroup(A)
> 
> And we didn't find out about this because lock_page_cgroup() uses
> bit_spin_lock(), and lockdep doesn't handle bit_spin_lock().
> 
> It would perhaps be useful if one of you guys were to add a spinlock to
> struct page, convert lock_page_cgroup() to use that spinlock then run a
> full set of tests under lockdep, see if it can shake out any other bugs.
>

May be under DEBUG_VM we could do that. Good suggestion! 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
