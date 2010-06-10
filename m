Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 694776B01B4
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 10:25:19 -0400 (EDT)
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by e31.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5AEEuA4004609
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 08:14:56 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5AEPHSW017888
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 08:25:22 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5AEPHnG016104
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 08:25:17 -0600
Date: Thu, 10 Jun 2010 19:55:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC/T/D][PATCH 2/2] Linux/Guest cooperative unmapped page cache
 control
Message-ID: <20100610142512.GB5191@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100608155140.3749.74418.sendpatchset@L34Z31A.ibm.com>
 <20100608155153.3749.31669.sendpatchset@L34Z31A.ibm.com>
 <4C10B3AF.7020908@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <4C10B3AF.7020908@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: kvm <kvm@vger.kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* Avi Kivity <avi@redhat.com> [2010-06-10 12:43:11]:

> On 06/08/2010 06:51 PM, Balbir Singh wrote:
> >Balloon unmapped page cache pages first
> >
> >From: Balbir Singh<balbir@linux.vnet.ibm.com>
> >
> >This patch builds on the ballooning infrastructure by ballooning unmapped
> >page cache pages first. It looks for low hanging fruit first and tries
> >to reclaim clean unmapped pages first.
> 
> I'm not sure victimizing unmapped cache pages is a good idea.
> Shouldn't page selection use the LRU for recency information instead
> of the cost of guest reclaim?  Dropping a frequently used unmapped
> cache page can be more expensive than dropping an unused text page
> that was loaded as part of some executable's initialization and
> forgotten.
>

We victimize the unmapped cache only if it is unused (in LRU order).
We don't force the issue too much. We also have free slab cache to go
after.

> Many workloads have many unmapped cache pages, for example static
> web serving and the all-important kernel build.
> 

I've tested kernbench, you can see the results in the original posting
and there is no observable overhead as a result of the patch in my
run.

> >The key advantage was that it resulted in lesser RSS usage in the host and
> >more cached usage, indicating that the caching had been pushed towards
> >the host. The guest cached memory usage was lower and free memory in
> >the guest was also higher.
> 
> Caching in the host is only helpful if the cache can be shared,
> otherwise it's better to cache in the guest.
>

Hmm.. so we would need a ballon cache hint from the monitor, so that
it is not unconditional? Overall my results show the following

1. No drastic reduction of guest unmapped cache, just sufficient to
show lesser RSS in the host. More freeable memory (as in cached
memory + free memory) visible on the host.
2. No significant impact on the benchmark (numbers) running in the
guest.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
