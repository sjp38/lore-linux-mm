Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA139003C7
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 17:17:21 -0400 (EDT)
Received: by pdbnt7 with SMTP id nt7so48386153pdb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:17:21 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id ti5si12880743pab.152.2015.07.31.14.17.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 14:17:20 -0700 (PDT)
Received: by pdbnt7 with SMTP id nt7so48385979pdb.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 14:17:19 -0700 (PDT)
Date: Fri, 31 Jul 2015 14:17:18 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC 1/4] mm, compaction: introduce kcompactd
In-Reply-To: <20150730105732.GJ19352@techsingularity.net>
Message-ID: <alpine.DEB.2.10.1507311412200.5910@chino.kir.corp.google.com>
References: <1435826795-13777-1-git-send-email-vbabka@suse.cz> <1435826795-13777-2-git-send-email-vbabka@suse.cz> <20150730105732.GJ19352@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On Thu, 30 Jul 2015, Mel Gorman wrote:

> There will be different opinions on periodic compaction but to be honest,
> periodic compaction also could be implemented from userspace using the
> compact_node sysfs files. The risk with periodic compaction is that it
> can cause stalls in applications that do not care if they fault the pages
> being migrated. This may happen even though there are zero requirements
> for high-order pages from anybody.
> 

When thp is enabled, I think there is always a non-zero requirement for 
high-order pages.  That's why we've shown an increase of 1.4% in cpu 
utilization over all our machines by doing periodic memory compaction.  
It's essential when thp is enabled and no amount of background compaction 
kicked off with a trigger similar to kswapd (which I have agreed with in 
this thread) is going to assist when a very large process is exec'd.

That's why my proposal was for background compaction through kcompactd 
kicked off in the allocator slowpath and for periodic compaction on, at 
the minimum, thp configurations to keep fragmentation low.  Dave Chinner 
seems to also have a usecase absent thp for high-order page cache 
allocation.

I think it would depend on how aggressive you are proposing background 
compaction to be, whether it will ever be MIGRATE_SYNC over all memory, or 
whether it will only terminate when a fragmentation index meets a 
threshold.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
