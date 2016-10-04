Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CBB2E6B0038
	for <linux-mm@kvack.org>; Tue,  4 Oct 2016 16:32:38 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id s30so125214981ioi.0
        for <linux-mm@kvack.org>; Tue, 04 Oct 2016 13:32:38 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id l30si7693534iod.131.2016.10.04.13.32.37
        for <linux-mm@kvack.org>;
        Tue, 04 Oct 2016 13:32:38 -0700 (PDT)
Date: Wed, 5 Oct 2016 07:32:02 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161004203202.GY9806@dastard>
References: <20161004081215.5563-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004081215.5563-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Oct 04, 2016 at 10:12:15AM +0200, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> direct compact when a high-order allocation fails"). The main reason
> is that the migration of page cache pages might recurse back to fs/io
> layer and we could potentially deadlock. This is overly conservative
> because all the anonymous memory is migrateable in the GFP_NOFS context
> just fine.  This might be a large portion of the memory in many/most
> workkloads.
> 
> Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> (those with a mapping) while isolating pages to be migrated. We cannot
> consider clean fs pages because they might need a metadata update so
> only isolate pages without any mapping for nofs requests.
> 
> The effect of this patch will be probably very limited in many/most
> workloads because higher order GFP_NOFS requests are quite rare,

You say they are rare only because you don't know how to trigger
them easily.  :/

Try this:

# mkfs.xfs -f -n size=64k <dev>
# mount <dev> /mnt/scratch
# time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  32 \
        -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
        -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
        -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
        -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
        -d  /mnt/scratch/8  -d  /mnt/scratch/9 \
        -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
        -d  /mnt/scratch/12  -d  /mnt/scratch/13 \
        -d  /mnt/scratch/14  -d  /mnt/scratch/15

As soon as tail pushing on the journal starts (a few seconds in,
most likely), you'll start to see lots of 65kB allocations being
requested in GFP_NOFS context by the xfs-cil-worker context doing
journal checkpoint formatting....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
