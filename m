Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2018760023A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 07:54:38 -0400 (EDT)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp03.au.ibm.com (8.14.3/8.13.1) with ESMTP id o2HBpNtZ002788
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:51:23 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2HBme1T1581280
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:48:40 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2HBsUk8005039
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 22:54:31 +1100
Date: Wed, 17 Mar 2010 17:24:28 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v7)
Message-ID: <20100317115427.GR18054@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1268609202-15581-1-git-send-email-arighi@develer.com>
 <20100315171209.GI21127@redhat.com>
 <20100315171921.GJ21127@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100315171921.GJ21127@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Andrea Righi <arighi@develer.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Peter Zijlstra <peterz@infradead.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Suleiman Souhlal <suleiman@google.com>, Greg Thelen <gthelen@google.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andrew Morton <akpm@linux-foundation.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Vivek Goyal <vgoyal@redhat.com> [2010-03-15 13:19:21]:

> On Mon, Mar 15, 2010 at 01:12:09PM -0400, Vivek Goyal wrote:
> > On Mon, Mar 15, 2010 at 12:26:37AM +0100, Andrea Righi wrote:
> > > Control the maximum amount of dirty pages a cgroup can have at any given time.
> > > 
> > > Per cgroup dirty limit is like fixing the max amount of dirty (hard to reclaim)
> > > page cache used by any cgroup. So, in case of multiple cgroup writers, they
> > > will not be able to consume more than their designated share of dirty pages and
> > > will be forced to perform write-out if they cross that limit.
> > > 
> > 
> > For me even with this version I see that group with 100M limit is getting
> > much more BW.
> > 
> > root cgroup
> > ==========
> > #time dd if=/dev/zero of=/root/zerofile bs=4K count=1M
> > 4294967296 bytes (4.3 GB) copied, 55.7979 s, 77.0 MB/s
> > 
> > real	0m56.209s
> > 
> > test1 cgroup with memory limit of 100M
> > ======================================
> > # time dd if=/dev/zero of=/root/zerofile1 bs=4K count=1M
> > 4294967296 bytes (4.3 GB) copied, 20.9252 s, 205 MB/s
> > 
> > real	0m21.096s
> > 
> > Note, these two jobs are not running in parallel. These are running one
> > after the other.
> > 
> 
> Ok, here is the strange part. I am seeing similar behavior even without
> your patches applied.
> 
> root cgroup
> ==========
> #time dd if=/dev/zero of=/root/zerofile bs=4K count=1M
> 4294967296 bytes (4.3 GB) copied, 56.098 s, 76.6 MB/s
> 
> real	0m56.614s
> 
> test1 cgroup with memory limit 100M
> ===================================
> # time dd if=/dev/zero of=/root/zerofile1 bs=4K count=1M
> 4294967296 bytes (4.3 GB) copied, 19.8097 s, 217 MB/s
> 
> real	0m19.992s
> 

This is strange, did you flish the cache between the two runs?
NOTE: Since the files are same, we reuse page cache from the
other cgroup.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
