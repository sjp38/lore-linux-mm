Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id EB9142808E6
	for <linux-mm@kvack.org>; Thu,  9 Mar 2017 10:09:09 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w37so22570154wrc.2
        for <linux-mm@kvack.org>; Thu, 09 Mar 2017 07:09:09 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b207si4692645wme.143.2017.03.09.07.09.08
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Mar 2017 07:09:08 -0800 (PST)
Date: Thu, 9 Mar 2017 15:09:04 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] Enable parallel page migration
Message-ID: <20170309150904.pnk6ejeug4mktxjv@suse.de>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Wed, Mar 08, 2017 at 09:34:27PM +0530, Anshuman Khandual wrote:
> > Any comments, suggestions are welcome.
> 
> Hello Vlastimil/Michal/Minchan/Mel/Dave,
> 
> Apart from the comments from Naoya on a different thread posted by Zi
> Yan, I did not get any more review comments on this series. Could you
> please kindly have a look on the over all design and its benefits from
> page migration performance point of view and let me know your views.
> Thank you.
> 

I didn't look into the patches in detail except to get a general feel
for how it works and I'm not convinced that it's a good idea at all.

I accept that memory bandwidth utilisation may be higher as a result but
consider the impact. THP migrations are relatively rare and when they
occur, it's in the context of a single thread. To parallelise the copy,
an allocation, kmap and workqueue invocation are required. There may be a
long delay before the workqueue item can start which may exceed the time
to do a single copy if the CPUs on a node are saturated. Furthermore, a
single thread can preempt operations of other unrelated threads and incur
CPU cache pollution and future misses on unrelated CPUs. It's compounded by
the fact that a high priority system workqueue is used to do the operation,
one that is used for CPU hotplug operations and rolling back when a netdevice
fails to be registered. It treats a hugepage copy as an essential operation
that can preempt all other work which is very questionable.

The series leader has no details on a workload that is bottlenecked by
THP migrations and even if it is, the primary question should be *why*
THP migrations are so frequent and alleviating that instead of
preempting multiple CPUs to do the work.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
