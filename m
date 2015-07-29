Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id CBECA6B0253
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 18:14:32 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so12060869pac.3
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 15:14:32 -0700 (PDT)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id do1si64562508pdb.32.2015.07.29.15.14.30
        for <linux-mm@kvack.org>;
        Wed, 29 Jul 2015 15:14:32 -0700 (PDT)
Date: Thu, 30 Jul 2015 08:13:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [regression 4.2-rc3] loop: xfstests xfs/073 deadlocked in low
 memory conditions
Message-ID: <20150729221356.GC16638@dastard>
References: <20150721015934.GY7943@dastard>
 <20150721085859.GG11967@dhcp22.suse.cz>
 <20150729115411.GF15801@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150729115411.GF15801@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Ming Lei <ming.lei@canonical.com>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <andreas.dilger@intel.com>, Oleg Drokin <oleg.drokin@intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@lst.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, xfs@oss.sgi.com, linux-nfs@vger.kernel.org, linux-cifs@vger.kernel.org

On Wed, Jul 29, 2015 at 01:54:12PM +0200, Michal Hocko wrote:
> On Tue 21-07-15 10:58:59, Michal Hocko wrote:
> > [CCing more people from a potentially affected fs - the reference to the 
> >  email thread is: http://marc.info/?l=linux-mm&m=143744398020147&w=2]
...
> > > The didn't used to happen, because the loop device used to issue
> > > reads through the splice path and that does:
> > > 
> > > 	error = add_to_page_cache_lru(page, mapping, index,
> > > 			GFP_KERNEL & mapping_gfp_mask(mapping));
> > > 
> > > i.e. it pays attention to the allocation context placed on the
> > > inode and so is doing GFP_NOFS allocations here and avoiding the
> > > recursion problem.
> > > 
> > > [ CC'd Michal Hocko and the mm list because it's a clear exaple of
> > > why ignoring the mapping gfp mask on any page cache allocation is
> > > a landmine waiting to be tripped over. ]
> > 
> > Thank you for CCing me. I haven't noticed this one when checking for
> > other similar hardcoded GFP_KERNEL users (6afdb859b710 ("mm: do not
> > ignore mapping_gfp_mask in page cache allocation paths")). And there
> > seem to be more of them now that I am looking closer.
> > 
> > I am not sure what to do about fs/nfs/dir.c:nfs_symlink which doesn't
> > require GFP_NOFS or mapping gfp mask for other allocations in the same
> > context.
> > 
> > What do you think about this preliminary (and untested) patch?
> 
> Dave, did you have chance to test the patch in your environment? Is the
> patch good to go or we want a larger refactoring?

No, I haven't had a chance to test it yet. I'll try to get somethign
done by the end of the week, but I'm not able to reliably
reproduce the hang I saw (i.e. the analysis I did was from the first
deadlock and I've only seen it once since) so testing is likely to
be inconclusive, anyway....

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
