Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 985D86B025E
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 03:53:41 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id p2so16399464pfk.0
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 00:53:41 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id p5si6104050plk.185.2017.10.09.00.53.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Oct 2017 00:53:40 -0700 (PDT)
Date: Mon, 9 Oct 2017 15:53:38 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH] page_alloc.c: inline __rmqueue()
Message-ID: <20171009075338.GC1798@intel.com>
References: <20171009054434.GA1798@intel.com>
 <c1e5a3d4-c5ac-d6ee-88ab-d9e2aa433b16@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <c1e5a3d4-c5ac-d6ee-88ab-d9e2aa433b16@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Huang Ying <ying.huang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>

On Mon, Oct 09, 2017 at 01:07:36PM +0530, Anshuman Khandual wrote:
> On 10/09/2017 11:14 AM, Aaron Lu wrote:
> > __rmqueue() is called by rmqueue_bulk() and rmqueue() under zone->lock
> > and that lock can be heavily contended with memory intensive applications.
> > 
> > Since __rmqueue() is a small function, inline it can save us some time.
> > With the will-it-scale/page_fault1/process benchmark, when using nr_cpu
> > processes to stress buddy:
> > 
> > On a 2 sockets Intel-Skylake machine:
> >       base          %change       head
> >      77342            +6.3%      82203        will-it-scale.per_process_ops
> > 
> > On a 4 sockets Intel-Skylake machine:
> >       base          %change       head
> >      75746            +4.6%      79248        will-it-scale.per_process_ops
> > 
> > This patch adds inline to __rmqueue().
> > 
> > Signed-off-by: Aaron Lu <aaron.lu@intel.com>
> 
> Ran it through kernel bench and ebizzy micro benchmarks. Results
> were comparable with and without the patch. May be these are not
> the appropriate tests for this inlining improvement. Anyways it

I think so.

The benefit only appears when the lock contention is huge enough, e.g.
perf-profile.self.cycles-pp.native_queued_spin_lock_slowpath is as high
as 80% with the workload I have used.

> does not have any performance degradation either.
> 
> Reviewed-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>
> Tested-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
