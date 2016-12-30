Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8036D6B0038
	for <linux-mm@kvack.org>; Fri, 30 Dec 2016 09:06:54 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id l2so41298555wml.5
        for <linux-mm@kvack.org>; Fri, 30 Dec 2016 06:06:54 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m19si58727336wmg.153.2016.12.30.06.06.53
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 30 Dec 2016 06:06:53 -0800 (PST)
Date: Fri, 30 Dec 2016 14:06:51 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [LSF/MM TOPIC] wmark based pro-active compaction
Message-ID: <20161230140651.nud2ozpmvmziqyx4@suse.de>
References: <20161230131412.GI13301@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20161230131412.GI13301@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, David Rientjes <rientjes@google.com>

On Fri, Dec 30, 2016 at 02:14:12PM +0100, Michal Hocko wrote:
> Hi,
> I didn't originally want to send this proposal because Vlastimil is
> planning to do some work in this area so I've expected him to send
> something similar. But the recent discussion about the THP defrag
> options pushed me to send out my thoughts.
> 
> So what is the problem? The demand for high order pages is growing and
> that seems to be the general trend. The problem is that while they can
> bring performance benefit they can get be really expensive to allocate
> especially when we enter the direct compaction. So we really want to
> prevent from expensive path and defer as much as possible to the
> background. A huge step forward was kcompactd introduced by Vlastimil.
> We are still not there yet though, because it might be already quite
> late when we wakeup_kcompactd(). The memory might be already fragmented
> when we hit there. Moreover we do not have any way to actually tell
> which orders we do care about.
> 
> Therefore I believe we need a watermark based pro-active compaction
> which would keep the background compaction busy as long as we have
> less pages of the configured order. kcompactd should wake up
> periodically, I think, and check for the status so that we can catch
> the fragmentation before we get low on memory.
> The interface could look something like:
> /proc/sys/vm/compact_wmark
> time_period order count
> 
> There are many details that would have to be solved of course - e.g. do
> not burn cycles pointlessly when we know that no further progress can be
> made etc... but in principle the idea show work.

I'd be very interested in this. I'd also like to add to the list to revisit
the concept of pre-emptively moving movable pages from pageblocks stolen for
unmovable pages to reduce future events that degrade fragmentation. Before
the Christmas I was mulling over whether it would be appropriate to have a
workqueue of pageblocks that need "cleaning". This could be either instead
of or in conjunction with wmark-based compaction.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
