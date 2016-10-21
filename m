Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6217E6B0069
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 03:08:37 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id b81so21087989lfe.1
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 00:08:37 -0700 (PDT)
Received: from mail-lf0-f66.google.com (mail-lf0-f66.google.com. [209.85.215.66])
        by mx.google.com with ESMTPS id n8si590509lfd.166.2016.10.21.00.08.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Oct 2016 00:08:35 -0700 (PDT)
Received: by mail-lf0-f66.google.com with SMTP id x23so4035425lfi.1
        for <linux-mm@kvack.org>; Fri, 21 Oct 2016 00:08:35 -0700 (PDT)
Date: Fri, 21 Oct 2016 09:08:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] scripts: Include postprocessing script for memory
 allocation tracing
Message-ID: <20161021070832.GE6045@dhcp22.suse.cz>
References: <20160919094224.GH10785@dhcp22.suse.cz>
 <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com>
 <20160923080709.GB4478@dhcp22.suse.cz>
 <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com>
 <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com>
 <20161016073340.GA15839@dhcp22.suse.cz>
 <CANnt6X=RpSnuxGXZfF6Qa5mJpzC8gL3wkKJi3tQMZJBZJVWF3w@mail.gmail.com>
 <A6E7231A-54FF-4D5C-90F5-0A8C4126CFEA@gmail.com>
 <20161018131343.GJ12092@dhcp22.suse.cz>
 <4F0F918D-B98A-48EC-82ED-EE7D32F222EA@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F0F918D-B98A-48EC-82ED-EE7D32F222EA@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu 20-10-16 18:10:37, Janani Ravichandran wrote:
> Michal,
> 
> > On Oct 18, 2016, at 8:13 AM, Michal Hocko <mhocko@kernel.org> wrote:
> > 
> >> 
> > 
> > yes, function_graph tracer will give you _some_ information but it will
> > not have the context you are looking for, right? See the following
> > example
> > 
> > ------------------------------------------
> > 0) x-www-b-22756  =>  x-termi-4083 
> > ------------------------------------------
> > 
> > 0)               |  __alloc_pages_nodemask() {
> > 0)               |  /* mm_page_alloc: page=ffffea000411b380 pfn=1066702 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
> > 0)   3.328 us    |  }
> > 3)               |  __alloc_pages_nodemask() {
> > 3)               |  /* mm_page_alloc: page=ffffea0008f1f6c0 pfn=2344923 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
> > 3)   1.011 us    |  }
> > 0)               |  __alloc_pages_nodemask() {
> > 0)               |  /* mm_page_alloc: page=ffffea000411b380 pfn=1066702 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
> > 0)   0.587 us    |  }
> > 3)               |  __alloc_pages_nodemask() {
> > 3)               |  /* mm_page_alloc: page=ffffea0008f1f6c0 pfn=2344923 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
> > 3)   1.125 us    |  }
> > 
> > How do I know which process has performed those allocations? I know that
> > CPU0 should be running x-termi-4083 but what is running on other CPUs?
> > 
> > Let me explain my usecase I am very interested in. Say I that a usespace
> > application is not performing well. I would like to see some statistics
> > about memory allocations performed for that app - are there few outliers
> > or the allocation stalls increase gradually? Where do we spend time during
> > that allocation? Reclaim LRU pages? Compaction or the slab shrinkers?
> > 
> > To answer those questions I need to track particular events (alocation,
> > reclaim, compaction) to the process and know how long each step
> > took. Maybe we can reconstruct something from the above output but it is
> > a major PITA.  If we either hard start/stop pairs for each step (which
> > we already do have for reclaim, compaction AFAIR) then this is an easy
> > scripting. Another option would be to have only a single tracepoint for
> > each step with a timing information.
> > 
> > See my point?
> 
> Yes, if we want to know what processes are running on what CPUs,
> echo funcgraph-proc > trace_options in the tracing directory should give us
> what we want.

Interesting.
$ cat /debug/tracing/available_tracers 
function_graph preemptirqsoff preemptoff irqsoff function nop

Do I have to configure anything specially? And if I do why isn't it any
better to simply add a start tracepoint and make this available also to
older kernels?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
