Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 00BD36B0038
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 04:46:17 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id u144so82923425wmu.1
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 01:46:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cg2si57493325wjc.103.2017.01.04.01.46.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Jan 2017 01:46:15 -0800 (PST)
Date: Wed, 4 Jan 2017 10:46:11 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: always direct reclaim for MADV_HUGEPAGE even
 when deferred
Message-ID: <20170104094611.GB25427@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1612211621210.100462@chino.kir.corp.google.com>
 <bba4c707-c470-296c-edbe-b8a6d21152ad@suse.cz>
 <alpine.DEB.2.10.1701031431120.139238@chino.kir.corp.google.com>
 <75bf7af0-76e8-2d8e-cb00-745fd06c42ef@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <75bf7af0-76e8-2d8e-cb00-745fd06c42ef@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@techsingularity.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 04-01-17 09:32:55, Vlastimil Babka wrote:
> On 01/03/2017 11:44 PM, David Rientjes wrote:
> > On Mon, 2 Jan 2017, Vlastimil Babka wrote:
[...]
> >>> echo "defer madvise" > /sys/kernel/mm/transparent_hugepage/defrag
> >>> cat /sys/kernel/mm/transparent_hugepage/defrag
> >> always [defer] [madvise] never
> >>
> >> I'm not sure about the analogous kernel boot option though, I guess
> >> those can't use spaces, so maybe comma-separated?
> 
> No opinion on the above? I think it could be somewhat more elegant than
> a fifth-option that Mel said he would prefer, and deliver the same
> flexibility.

I am not sure we have considered the kcompactd watermark option
throughly as well. In case the relation is not clear because I admit
that the propsal was scattered in more emails. So let me summarize it
here.

Let's add a system configuration whih would control the pro-active
background compaction which would
	- wake up kcompactd pro-actively even when there is no immediate
	  memory pressure - based on the timeout
	- keep compacting as long as the requested order is under the
	  configured watermark and the compaction makes further
	  progress.

Admin can set up this tunable to reflect demand for the THP in the
particular workload. Now how it would play with the THP specific defrag
options?
	- never - THP allocations will be tried without any feedback to
	  kcopactd - no stalls in the page fault path
	- defer -  THP allocations will be tried and kcompactd woken up
	  outside of its wmark setting to catch with the workload - no
	  stalls in the page fault path
	- madvise - do the direct compaction for madvised VMAs and rely
	  on kcompactd watermarks setting to do the background
	  compaction
	- always - do the direct compaction for all VMAs

We won't have to add or modify any new THP specific option and we will
have a generic user independent tunable to tell that the system should
try to generate high order pages which is something that is demand for.
Such a solution would be more flexible as well because the configuration
could reflect the demand much better.

Is there any reason, except for not being implemented yet, that would
make it inappropriate for the described usecase?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
