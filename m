Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C009F6B0038
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 07:38:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l138so155008802wmg.3
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 04:38:48 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id io8si10598047wjb.284.2016.10.05.04.38.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Oct 2016 04:38:47 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id p138so24124881wmb.0
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 04:38:47 -0700 (PDT)
Date: Wed, 5 Oct 2016 13:38:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161005113839.GC7138@dhcp22.suse.cz>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <20161004203202.GY9806@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161004203202.GY9806@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 05-10-16 07:32:02, Dave Chinner wrote:
> On Tue, Oct 04, 2016 at 10:12:15AM +0200, Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> > the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> > direct compact when a high-order allocation fails"). The main reason
> > is that the migration of page cache pages might recurse back to fs/io
> > layer and we could potentially deadlock. This is overly conservative
> > because all the anonymous memory is migrateable in the GFP_NOFS context
> > just fine.  This might be a large portion of the memory in many/most
> > workkloads.
> > 
> > Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> > (those with a mapping) while isolating pages to be migrated. We cannot
> > consider clean fs pages because they might need a metadata update so
> > only isolate pages without any mapping for nofs requests.
> > 
> > The effect of this patch will be probably very limited in many/most
> > workloads because higher order GFP_NOFS requests are quite rare,
> 
> You say they are rare only because you don't know how to trigger
> them easily.  :/

true

> Try this:
> 
> # mkfs.xfs -f -n size=64k <dev>
> # mount <dev> /mnt/scratch
> # time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  32 \
>         -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
>         -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
>         -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
>         -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
>         -d  /mnt/scratch/8  -d  /mnt/scratch/9 \
>         -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
>         -d  /mnt/scratch/12  -d  /mnt/scratch/13 \
>         -d  /mnt/scratch/14  -d  /mnt/scratch/15

Does this simulate a standard or usual fs workload/configuration?  I am
not questioning that higher order NOFS allocations are non-existent -
that's why I came with the patch in the first place ;). My observation
was that they are so rare that the visible effect of this patch might be
quite low or even hard to notice.

Anyway, thanks for a _useful_ testcase to play with! Let's see what
numbers I get from this.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
