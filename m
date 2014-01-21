Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 9B1E76B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 06:52:27 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so3705860eak.11
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 03:52:27 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k3si3655916eep.246.2014.01.21.03.52.26
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 03:52:26 -0800 (PST)
Date: Tue, 21 Jan 2014 11:52:23 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 1/6] numa,sched,mm: remove p->numa_migrate_deferred
Message-ID: <20140121115223.GF4963@suse.de>
References: <1390245667-24193-1-git-send-email-riel@redhat.com>
 <1390245667-24193-2-git-send-email-riel@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1390245667-24193-2-git-send-email-riel@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: riel@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, mingo@redhat.com, chegu_vinod@hp.com

On Mon, Jan 20, 2014 at 02:21:02PM -0500, riel@redhat.com wrote:
> From: Rik van Riel <riel@redhat.com>
> 
> Excessive migration of pages can hurt the performance of workloads
> that span multiple NUMA nodes.  However, it turns out that the
> p->numa_migrate_deferred knob is a really big hammer, which does
> reduce migration rates, but does not actually help performance.
> 
> Now that the second stage of the automatic numa balancing code
> has stabilized, it is time to replace the simplistic migration
> deferral code with something smarter.
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Mel Gorman <mgorman@suse.de>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Chegu Vinod <chegu_vinod@hp.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>

When I added a tracepoint to track deferred migration I was surprised how
often it triggered for some workloads. I agree that we want to do something
better because it was a crutch albeit a necessary one at the time.

Note that the knob was not about performance as such, it was about avoiding
worst-case behaviour. We should keep an eye out for bugs that look like
excessive migration on workloads that are not converging.  Reintroducing this
hammer would be a last resort for working around the problem.

Finally, the sysctl is documented in Documentation/sysctl/kernel.txt and
this patch should also remove it.

Functionally, the patch looks fine and it's time to reinvestigate if
it's necessary so assuming the documentation gets removed;

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
