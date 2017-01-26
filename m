Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f199.google.com (mail-wj0-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF0DA6B0033
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 05:47:34 -0500 (EST)
Received: by mail-wj0-f199.google.com with SMTP id ez4so38797763wjd.2
        for <linux-mm@kvack.org>; Thu, 26 Jan 2017 02:47:34 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id s45si1488378wrc.179.2017.01.26.02.47.33
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 26 Jan 2017 02:47:33 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 3B55998FF2
	for <linux-mm@kvack.org>; Thu, 26 Jan 2017 10:47:33 +0000 (UTC)
Date: Thu, 26 Jan 2017 10:47:32 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: Use static global work_struct for
 draining per-cpu pages
Message-ID: <20170126104732.meri27v5lf3or22j@techsingularity.net>
References: <20170125083038.rzb5f43nptmk7aed@techsingularity.net>
 <20170125160802.67172878e6692e45fa035f37@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170125160802.67172878e6692e45fa035f37@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Jan 25, 2017 at 04:08:02PM -0800, Andrew Morton wrote:
> > +	for_each_cpu(cpu, &cpus_with_pcps) {
> > +		struct work_struct *work = per_cpu_ptr(&pcpu_drain, cpu);
> > +		INIT_WORK(work, drain_local_pages_wq);
> 
> It's strange to repeatedly run INIT_WORK() in this fashion. 
> Overwriting an atomic_t which should already be zero, initializing a
> list_head which should already be in the initialized state...
> 
> Can we instead do this a single time in init code?
> 

INIT_WORK does different things depending on whether LOCKDEP is enabled or
not and also whether object debugging is enabled. I'd worry that it's not
functionally equivalent or some future change would break the assumptions
about what INIT_WORK does internally. The init cost is there, but it's
insignicant in comparison to the whole workqueue operation or the old
cost of sending IPIs for that matter.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
