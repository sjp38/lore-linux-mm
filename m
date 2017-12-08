Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 81A2D6B0033
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 07:43:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id w141so941978wme.1
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 04:43:38 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id q124si1094086wma.132.2017.12.08.04.43.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Dec 2017 04:43:36 -0800 (PST)
Date: Fri, 8 Dec 2017 13:43:33 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH v3 1/7] ktask: add documentation
Message-ID: <20171208124333.GV20234@dhcp22.suse.cz>
References: <20171205195220.28208-1-daniel.m.jordan@oracle.com>
 <20171205195220.28208-2-daniel.m.jordan@oracle.com>
 <20171206143509.GG7515@dhcp22.suse.cz>
 <d8323ee9-eb99-7f55-50c6-c71f4986cf06@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d8323ee9-eb99-7f55-50c6-c71f4986cf06@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Jordan <daniel.m.jordan@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, aaron.lu@intel.com, akpm@linux-foundation.org, dave.hansen@linux.intel.com, mgorman@techsingularity.net, mike.kravetz@oracle.com, pasha.tatashin@oracle.com, steven.sistare@oracle.com, tim.c.chen@intel.com

On Wed 06-12-17 15:32:48, Daniel Jordan wrote:
> On 12/06/2017 09:35 AM, Michal Hocko wrote:
[...]
> > There is also no mention about other
> > characteristics (e.g. power management), resource isloataion etc. So > let me ask again. How do you control that the parallelized operation
> > doesn't run outside of the limit imposed to the calling context?
> 
> The current code doesn't do this, and the answer is the same for the rest of
> your questions.

I really believe this should be addressed before this can be considered
for merging. While what you have might be sufficient for early boot
initialization stuff I am not sure the amount of code is really
justified by that usecase alone. Any runtime enabled parallelized work
really have to care about the rest of the system. The last thing you
really want to see is to make a highly utilized system overloaded just
because of some optimization. And I do not see how can you achive that
with a limit on the number of paralelization threads.

> For resource isolation, I'll experiment with moving ktask threads into and
> out of the cgroup of the calling thread.
> 
> Do any resources not covered by cgroup come to mind?  I'm trying to think if
> I've left anything out.

This is mostly about cpu so dealing with the cpu cgroup controller
should do the work.

[...]

> Anyway, I think scalability bottlenecks should be weighed with the rest of
> this.  It seems wrong that the kernel should always assume that one thread
> is enough to free all of a process's memory or evict all the pages of a file
> system no matter how much work there is to do.

Well, this will be always a double edge sword. Sure if you have spare
cycles (whatever that means) than using them is really nice. But the
last thing you really want is to turn an optimization into an
utilization nightmare where few processes dominant the whole machine
even though they could be easily contained normally inside a single
execution context.

Your work targets larger machines and I understand that you are mainly
focused on a single large workload running on that machine but there are
many others running with many smaller workloads which would like to be
independent. Not everything is a large DB running on a large HW.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
