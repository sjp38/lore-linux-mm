Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7E5556B0038
	for <linux-mm@kvack.org>; Tue, 18 Oct 2016 09:13:47 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id b81so11484664lfe.1
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:13:47 -0700 (PDT)
Received: from mail-lf0-f68.google.com (mail-lf0-f68.google.com. [209.85.215.68])
        by mx.google.com with ESMTPS id o198si680321lfe.216.2016.10.18.06.13.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Oct 2016 06:13:46 -0700 (PDT)
Received: by mail-lf0-f68.google.com with SMTP id b75so32341891lfg.3
        for <linux-mm@kvack.org>; Tue, 18 Oct 2016 06:13:45 -0700 (PDT)
Date: Tue, 18 Oct 2016 15:13:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] scripts: Include postprocessing script for memory
 allocation tracing
Message-ID: <20161018131343.GJ12092@dhcp22.suse.cz>
References: <20160912121635.GL14524@dhcp22.suse.cz>
 <0ACE5927-A6E5-4B49-891D-F990527A9F50@gmail.com>
 <20160919094224.GH10785@dhcp22.suse.cz>
 <BFAF8DCA-F4A6-41C6-9AA0-C694D33035A3@gmail.com>
 <20160923080709.GB4478@dhcp22.suse.cz>
 <E8FAA4EF-DAA1-4E18-B48F-6677E6AFE76E@gmail.com>
 <2D27EF16-B63B-4516-A156-5E2FB675A1BB@gmail.com>
 <20161016073340.GA15839@dhcp22.suse.cz>
 <CANnt6X=RpSnuxGXZfF6Qa5mJpzC8gL3wkKJi3tQMZJBZJVWF3w@mail.gmail.com>
 <A6E7231A-54FF-4D5C-90F5-0A8C4126CFEA@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <A6E7231A-54FF-4D5C-90F5-0A8C4126CFEA@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Janani Ravichandran <janani.rvchndrn@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 17-10-16 13:31:57, Janani Ravichandran wrote:
> 
> > On Oct 17, 2016, at 1:24 PM, Janani Ravichandran <janani.rvchndrn@gmail.com> wrote:
> > 
> > 
> > On Sun, Oct 16, 2016 at 3:33 AM, Michal Hocko <mhocko@kernel.org <mailto:mhocko@kernel.org>> wrote:
> > 
> > trace_mm_page_alloc will tell you details about the allocation, like
> > gfp mask, order but it doesn't tell you how long the allocation took at
> > its current form. So either you have to note jiffies at the allocation
> > start and then add the end-start in the trace point or we really need
> > another trace point to note the start. The later has an advantage that
> > we do not add unnecessary load for jiffies when the tracepoint is
> > disabled.
> 
> The function graph tracer can tell us how long alloc_pages_nodemask() took.
> Cana??t that, combined with the context information given by trace_mm_page_alloc
> give us what we want? Correct me if I am wrong.

yes, function_graph tracer will give you _some_ information but it will
not have the context you are looking for, right? See the following
example

 ------------------------------------------
 0) x-www-b-22756  =>  x-termi-4083 
 ------------------------------------------

 0)               |  __alloc_pages_nodemask() {
 0)               |  /* mm_page_alloc: page=ffffea000411b380 pfn=1066702 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
 0)   3.328 us    |  }
 3)               |  __alloc_pages_nodemask() {
 3)               |  /* mm_page_alloc: page=ffffea0008f1f6c0 pfn=2344923 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
 3)   1.011 us    |  }
 0)               |  __alloc_pages_nodemask() {
 0)               |  /* mm_page_alloc: page=ffffea000411b380 pfn=1066702 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
 0)   0.587 us    |  }
 3)               |  __alloc_pages_nodemask() {
 3)               |  /* mm_page_alloc: page=ffffea0008f1f6c0 pfn=2344923 order=0 migratetype=0 gfp_flags=GFP_KERNEL */
 3)   1.125 us    |  }

How do I know which process has performed those allocations? I know that
CPU0 should be running x-termi-4083 but what is running on other CPUs?

Let me explain my usecase I am very interested in. Say I that a usespace
application is not performing well. I would like to see some statistics
about memory allocations performed for that app - are there few outliers
or the allocation stalls increase gradually? Where do we spend time during
that allocation? Reclaim LRU pages? Compaction or the slab shrinkers?

To answer those questions I need to track particular events (alocation,
reclaim, compaction) to the process and know how long each step
took. Maybe we can reconstruct something from the above output but it is
a major PITA.  If we either hard start/stop pairs for each step (which
we already do have for reclaim, compaction AFAIR) then this is an easy
scripting. Another option would be to have only a single tracepoint for
each step with a timing information.

See my point?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
