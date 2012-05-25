Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 5F34C6B00F6
	for <linux-mm@kvack.org>; Fri, 25 May 2012 16:46:29 -0400 (EDT)
Date: Fri, 25 May 2012 15:46:27 -0500
From: Nathan Zimmer <nzimmer@sgi.com>
Subject: Re: [PATCH] tmpfs not interleaving properly
Message-ID: <20120525204626.GA16178@gulag1.americas.sgi.com>
References: <74F10842A85F514CA8D8C487E74474BB2C1597@P-EXMB1-DC21.corp.sgi.com> <20120523152011.3b581761.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120523152011.3b581761.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Hugh Dickins <hughd@google.com>, Nick Piggin <npiggin@gmail.com>, Christoph Lameter <cl@linux.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "stable@vger.kernel.org" <stable@vger.kernel.org>

On Wed, May 23, 2012 at 03:20:11PM -0700, Andrew Morton wrote:
> On Wed, 23 May 2012 13:28:21 +0000
> Nathan Zimmer <nzimmer@sgi.com> wrote:
> 
> > 
> > When tmpfs has the memory policy interleaved it always starts allocating at each file at node 0.
> > When there are many small files the lower nodes fill up disproportionately.
> > My proposed solution is to start a file at a randomly chosen node.
> > 
> > ...
> >
> > --- a/include/linux/shmem_fs.h
> > +++ b/include/linux/shmem_fs.h
> > @@ -17,6 +17,7 @@ struct shmem_inode_info {
> >  		char		*symlink;	/* unswappable short symlink */
> >  	};
> >  	struct shared_policy	policy;		/* NUMA memory alloc policy */
> > +	int			node_offset;	/* bias for interleaved nodes */
> >  	struct list_head	swaplist;	/* chain of maybes on swap */
> >  	struct list_head	xattr_list;	/* list of shmem_xattr */
> >  	struct inode		vfs_inode;
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index f99ff3e..58ef512 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -819,7 +819,7 @@ static struct page *shmem_alloc_page(gfp_t gfp,
> >  
> >  	/* Create a pseudo vma that just contains the policy */
> >  	pvma.vm_start = 0;
> > -	pvma.vm_pgoff = index;
> > +	pvma.vm_pgoff = index + info->node_offset;
> >  	pvma.vm_ops = NULL;
> >  	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, index);
> >  
> > @@ -1153,6 +1153,7 @@ static struct inode *shmem_get_inode(struct super_block *sb, const struct inode
> >  			inode->i_fop = &shmem_file_operations;
> >  			mpol_shared_policy_init(&info->policy,
> >  						 shmem_get_sbmpol(sbinfo));
> > +			info->node_offset = node_random(&node_online_map);
> >  			break;
> >  		case S_IFDIR:
> >  			inc_nlink(inode);
> 
> The patch seems a bit arbitrary and hacky.  It would have helped if you
> had fully described how it works, and why this implementation was
> chosen.
> 
The patch attempt to spread out the node usage by starting files at nodes other
then 0.  node_offset is set to a random node when the inode is allocated.  

> - Why alter (actually, lie about!) the offset-into-file?  Could we
>   have similarly perturbed the address arg to alloc_page_vma() to do
>   the spreading?
> 
Using the address arg would be better.  It also makes clear that we should
still be using the index for looking up the memory policy.

> - The patch is dependent upon MPOL_INTERLEAVE being in effect, isn't
>   it?  How do we guarantee that it is in force here?
> 
The node_offset is only used when MPOL_INTERLEAVE is in effect. However
node_offset is set unconditionally.  It would be quite easy to only generate
the offset when the policy is set to interleave. 

> - We look up the policy via mpol_shared_policy_lookup() using the
>   unperturbed index.  Why?  Should we be using index+info->node_offset
>   there?
> 
This concern should be obviated using the address arg instead of 'altering' the
vm_pgoff.

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
