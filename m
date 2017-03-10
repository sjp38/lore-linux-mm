Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0E60B280910
	for <linux-mm@kvack.org>; Fri, 10 Mar 2017 08:05:31 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id n11so3307898wma.5
        for <linux-mm@kvack.org>; Fri, 10 Mar 2017 05:05:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l78si2788658wmg.72.2017.03.10.05.05.29
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 10 Mar 2017 05:05:29 -0800 (PST)
Date: Fri, 10 Mar 2017 14:05:26 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 0/6] Enable parallel page migration
Message-ID: <20170310130525.GG3753@dhcp22.suse.cz>
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
 <20170309150904.pnk6ejeug4mktxjv@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170309150904.pnk6ejeug4mktxjv@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, vbabka@suse.cz, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On Thu 09-03-17 15:09:04, Mel Gorman wrote:
> On Wed, Mar 08, 2017 at 09:34:27PM +0530, Anshuman Khandual wrote:
> > > Any comments, suggestions are welcome.
> > 
> > Hello Vlastimil/Michal/Minchan/Mel/Dave,
> > 
> > Apart from the comments from Naoya on a different thread posted by Zi
> > Yan, I did not get any more review comments on this series. Could you
> > please kindly have a look on the over all design and its benefits from
> > page migration performance point of view and let me know your views.
> > Thank you.
> > 
> 
> I didn't look into the patches in detail except to get a general feel
> for how it works and I'm not convinced that it's a good idea at all.
> 
> I accept that memory bandwidth utilisation may be higher as a result but
> consider the impact. THP migrations are relatively rare and when they
> occur, it's in the context of a single thread. To parallelise the copy,
> an allocation, kmap and workqueue invocation are required. There may be a
> long delay before the workqueue item can start which may exceed the time
> to do a single copy if the CPUs on a node are saturated. Furthermore, a
> single thread can preempt operations of other unrelated threads and incur
> CPU cache pollution and future misses on unrelated CPUs. It's compounded by
> the fact that a high priority system workqueue is used to do the operation,
> one that is used for CPU hotplug operations and rolling back when a netdevice
> fails to be registered. It treats a hugepage copy as an essential operation
> that can preempt all other work which is very questionable.
> 
> The series leader has no details on a workload that is bottlenecked by
> THP migrations and even if it is, the primary question should be *why*
> THP migrations are so frequent and alleviating that instead of
> preempting multiple CPUs to do the work.

FWIW I very much agree here and the follow up reply. Making migration
itself parallel is a hard task. You should start simple and optimize the
current code first and each step accompany with numbers. Parallel
migration should be the very last step - if it is needed at all of
course. I am quite skeptical that a reasonable parallel load balancing
is achievable without a large maintenance cost and/or predictable
behavior. 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
