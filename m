Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 333416B0071
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 17:10:56 -0500 (EST)
Date: Thu, 11 Nov 2010 09:10:38 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Propagating GFP_NOFS inside __vmalloc()
Message-ID: <20101110221038.GX2715@dastard>
References: <1289421759.11149.59.camel@oralap>
 <1289424955.11149.73.camel@oralap>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1289424955.11149.73.camel@oralap>
Sender: owner-linux-mm@kvack.org
To: "Ricardo M. Correia" <ricardo.correia@oracle.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Brian Behlendorf <behlendorf1@llnl.gov>, Andreas Dilger <andreas.dilger@oracle.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 10, 2010 at 10:35:55PM +0100, Ricardo M. Correia wrote:
> On Wed, 2010-11-10 at 21:42 +0100, Ricardo M. Correia wrote:
> > Hi,
> > 
> > As part of Lustre filesystem development, we are running into a
> > situation where we (sporadically) need to call into __vmalloc() from a
> > thread that processes I/Os to disk (it's a long story).
> > 
> > In general, this would be fine as long as we pass GFP_NOFS to
> > __vmalloc(), but the problem is that even if we pass this flag, vmalloc
> > itself sometimes allocates memory with GFP_KERNEL.
> 
> By the way, it seems that existing users in Linus' tree may be
> vulnerable to the same bug that we experienced:
> 
> In GFS:
>     8   1253  fs/gfs2/dir.c <<gfs2_alloc_sort_buffer>>
>              ptr = __vmalloc(size, GFP_NOFS, PAGE_KERNEL);
> 
> The Ceph filesystem:
>   20     22  net/ceph/buffer.c <<ceph_buffer_new>>
>              b->vec.iov_base = __vmalloc(len, gfp, PAGE_KERNEL);
> .. which can be called from:
>    3    560  fs/ceph/inode.c <<fill_inode>>
>              xattr_blob = ceph_buffer_new(iinfo->xattr_len, GFP_NOFS);
> 
> In the MM code:
>   18   5184  mm/page_alloc.c <<alloc_large_system_hash>>
>              table = __vmalloc(size, GFP_ATOMIC, PAGE_KERNEL);
> 
> All of these seem to be vulnerable to GFP_KERNEL allocations from within
> __vmalloc(), at least on x86-64 (as I've detailed below).

Hmmm. I'd say there's a definite possibility that vm_map_ram() as
called from in fs/xfs/linux-2.6/xfs_buf.c needs to use GFP_NOFS
allocation, too. Currently vm_map_ram() just uses GFP_KERNEL
internally, but is certainly being called in contexts where we don't
allow recursion (e.g. in a transaction) so probably should allow a
gfp mask to be passed in....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
