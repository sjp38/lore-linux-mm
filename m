Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 96E716B0253
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 05:33:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so87815015wmf.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 02:33:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t82si5880132wmg.164.2017.01.05.02.33.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 02:33:06 -0800 (PST)
Date: Thu, 5 Jan 2017 11:33:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [patch] mm, thp: add new background defrag option
Message-ID: <20170105103303.GI21618@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1701041532040.67903@chino.kir.corp.google.com>
 <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170105101330.bvhuglbbeudubgqb@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 05-01-17 10:13:30, Mel Gorman wrote:
> On Wed, Jan 04, 2017 at 03:41:59PM -0800, David Rientjes wrote:
> > There is no thp defrag option that currently allows MADV_HUGEPAGE regions 
> > to do direct compaction and reclaim while all other thp allocations simply 
> > trigger kswapd and kcompactd in the background and fail immediately.
> > 
> > The "defer" setting simply triggers background reclaim and compaction for 
> > all regions, regardless of MADV_HUGEPAGE, which makes it unusable for our 
> > userspace where MADV_HUGEPAGE is being used to indicate the application is 
> > willing to wait for work for thp memory to be available.
> > 
> > The "madvise" setting will do direct compaction and reclaim for these
> > MADV_HUGEPAGE regions, but does not trigger kswapd and kcompactd in the 
> > background for anybody else.
> > 
> > For reasonable usage, there needs to be a mesh between the two options.  
> > This patch introduces a fifth mode, "background", that will do direct 
> > reclaim and compaction for MADV_HUGEPAGE regions and trigger background 
> > reclaim and compaction for everybody else so that hugepages may be 
> > available in the near future.
> > 
> > A proposal to allow direct reclaim and compaction for MADV_HUGEPAGE 
> > regions as part of the "defer" mode, making it a very powerful setting and 
> > avoids breaking userspace, was offered: 
> > http://marc.info/?t=148236612700003.  This additional mode is a 
> > compromise.
> > 
> > This patch also cleans up the helper function for storing to "enabled" 
> > and "defrag" since the former supports three modes while the latter 
> > supports five and triple_flag_store() was getting unnecessarily messy.
> > 
> > Signed-off-by: David Rientjes <rientjes@google.com>
> > ---
> >  I don't understand Mel's suggestion of "defer-fault" as option naming.
> > 
> 
> defer-fault was intended to reflect "defer faults but not anything else"
> with the only sensible alternative being madvise requests. While not a
> major fan of the background name, I don't have a better suggestion either
> other than defer-fault.
> 
> There are likely to be objections based on how this should be specified
> and investigating alternative proposals such as fine-grained control of
> how background compaction should be done but I hadn't proposed them and
> hadn't intended to work on such patches. This patch appears to give the
> semantics you want and I said I would ack such a configuration option so;

Yes, I would really like to see that we have exhausted all the proposed
options before we go with a new tunable value. I personally do not have
strong objection to this patch as long as all other options are
considered not viable. The naming is really confusing because defer and
background sonds just too similar and background suggests that no
expensive operation will happen in the direct (fault) context. From that
POV, Mel's defer-fault was more clear to me. I would even like to see
madvise in the name. Something like madvise-with-defer?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
