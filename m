Subject: Re: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem
	Policy
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0710151226330.26753@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
	 <20071012154918.8157.26655.sendpatchset@localhost>
	 <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
	 <Pine.LNX.4.64.0710151226330.26753@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 23 Oct 2007 12:15:05 -0400
Message-Id: <1193156105.5859.28.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Mon, 2007-10-15 at 12:34 -0700, Christoph Lameter wrote:
> On Fri, 12 Oct 2007, Christoph Lameter wrote:
> 
> > > Index: Linux/mm/mempolicy.c
> > > ===================================================================
> > > --- Linux.orig/mm/mempolicy.c	2007-10-12 10:50:05.000000000 -0400
> > > +++ Linux/mm/mempolicy.c	2007-10-12 10:52:46.000000000 -0400
> > > @@ -1112,19 +1112,25 @@ static struct mempolicy * get_vma_policy
> > >  		struct vm_area_struct *vma, unsigned long addr)
> > >  {
> > >  	struct mempolicy *pol = task->mempolicy;
> > > -	int shared_pol = 0;
> > > +	int pol_needs_ref = (task != current);
> > 
> > If get_vma_policy is called from the numa_maps handler then we have taken 
> > a refcount on the task struct. 
> > 
> > So this should be
> > 	int pol_needs_ref = 0;
> 
> Argh. Refcount is not it. We have taken the mmap_sem lock 
> because we are scanning though the pages. This avoids issues for the vma 
> policies that can only be set when a writelock was taken on mmap_sem.
> 
> However, mmap_sem is not taken when setting task->mempolicy. Taking 
> mmap_sem there would solve the issue (we have discussed this before).
> 
> You cannot reliably take a refcount on a foreign task structs mempolicy 
> since the task may just be in the process of switching policies. You could 
> increment the refcount and then the other task frees the structure.
> 
> I think we need something like this:
> 
> Index: linux-2.6/mm/mempolicy.c
> ===================================================================
> --- linux-2.6.orig/mm/mempolicy.c	2007-10-15 12:32:45.000000000 -0700
> +++ linux-2.6/mm/mempolicy.c	2007-10-15 12:33:56.000000000 -0700
> @@ -468,11 +468,13 @@ long do_set_mempolicy(int mode, nodemask
>  	new = mpol_new(mode, nodes);
>  	if (IS_ERR(new))
>  		return PTR_ERR(new);
> +	down_read(&current->mm->mmap_sem);
>  	mpol_free(current->mempolicy);
>  	current->mempolicy = new;
>  	mpol_set_task_struct_flag();
>  	if (new && new->policy == MPOL_INTERLEAVE)
>  		current->il_next = first_node(new->v.nodes);
> +	up_read(&current->mm->mmap_sem);
>  	return 0;
>  }
>  

Christoph:  just getting back to this.  You sent two messages commented
about this patch.  I'm not sure whether this one supercedes the previous
one or adds to it.   So, I'll address the points in your other comment
separately.

Re:  this patch:  I can see how we need to grab the mmap_sem during
do_set_mempolicy() to coordinate with the numa_maps display.  However,
shouldn't we use {down|up}_write() here to obtain exclusive access with
respect to numa_maps ?

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
