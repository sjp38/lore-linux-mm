Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id F0CF26B0069
	for <linux-mm@kvack.org>; Wed,  5 Oct 2016 22:12:18 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id 190so11322390pfv.3
        for <linux-mm@kvack.org>; Wed, 05 Oct 2016 19:12:18 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id k10si10343523pak.66.2016.10.05.19.11.58
        for <linux-mm@kvack.org>;
        Wed, 05 Oct 2016 19:11:59 -0700 (PDT)
Date: Thu, 6 Oct 2016 13:11:42 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [RFC PATCH] mm, compaction: allow compaction for GFP_NOFS
 requests
Message-ID: <20161006021142.GC9806@dastard>
References: <20161004081215.5563-1-mhocko@kernel.org>
 <20161004203202.GY9806@dastard>
 <20161005113839.GC7138@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161005113839.GC7138@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <js1304@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, Oct 05, 2016 at 01:38:45PM +0200, Michal Hocko wrote:
> On Wed 05-10-16 07:32:02, Dave Chinner wrote:
> > On Tue, Oct 04, 2016 at 10:12:15AM +0200, Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > compaction has been disabled for GFP_NOFS and GFP_NOIO requests since
> > > the direct compaction was introduced by 56de7263fcf3 ("mm: compaction:
> > > direct compact when a high-order allocation fails"). The main reason
> > > is that the migration of page cache pages might recurse back to fs/io
> > > layer and we could potentially deadlock. This is overly conservative
> > > because all the anonymous memory is migrateable in the GFP_NOFS context
> > > just fine.  This might be a large portion of the memory in many/most
> > > workkloads.
> > > 
> > > Remove the GFP_NOFS restriction and make sure that we skip all fs pages
> > > (those with a mapping) while isolating pages to be migrated. We cannot
> > > consider clean fs pages because they might need a metadata update so
> > > only isolate pages without any mapping for nofs requests.
> > > 
> > > The effect of this patch will be probably very limited in many/most
> > > workloads because higher order GFP_NOFS requests are quite rare,
> > 
> > You say they are rare only because you don't know how to trigger
> > them easily.  :/
> 
> true
> 
> > Try this:
> > 
> > # mkfs.xfs -f -n size=64k <dev>
> > # mount <dev> /mnt/scratch
> > # time ./fs_mark  -D  10000  -S0  -n  100000  -s  0  -L  32 \
> >         -d  /mnt/scratch/0  -d  /mnt/scratch/1 \
> >         -d  /mnt/scratch/2  -d  /mnt/scratch/3 \
> >         -d  /mnt/scratch/4  -d  /mnt/scratch/5 \
> >         -d  /mnt/scratch/6  -d  /mnt/scratch/7 \
> >         -d  /mnt/scratch/8  -d  /mnt/scratch/9 \
> >         -d  /mnt/scratch/10  -d  /mnt/scratch/11 \
> >         -d  /mnt/scratch/12  -d  /mnt/scratch/13 \
> >         -d  /mnt/scratch/14  -d  /mnt/scratch/15
> 
> Does this simulate a standard or usual fs workload/configuration?  I am

Unfortunately, there was an era of cargo cult configuration tweaks
in the Ceph community that has resulted in a large number of
production machines with XFS filesystems configured this way. And a
lot of them store large numbers of small files and run under
significant sustained memory pressure.

I slowly working towards getting rid of these high order allocations
and replacing them with the equivalent number of single page
allocations, but I haven't got that (complex) change working yet.

> not questioning that higher order NOFS allocations are non-existent -
> that's why I came with the patch in the first place ;). My observation
> was that they are so rare that the visible effect of this patch might be
> quite low or even hard to notice.

Yup, it's a valid observation that would hold true for the majority
of users.

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
