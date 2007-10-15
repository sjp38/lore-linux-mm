Date: Mon, 15 Oct 2007 12:34:09 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH/RFC 4/4] Mem Policy: Fixup Fallback for Default Shmem
 Policy
In-Reply-To: <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0710151226330.26753@schroedinger.engr.sgi.com>
References: <20071012154854.8157.51441.sendpatchset@localhost>
 <20071012154918.8157.26655.sendpatchset@localhost>
 <Pine.LNX.4.64.0710121045380.8891@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, ak@suse.de, eric.whitney@hp.com, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Fri, 12 Oct 2007, Christoph Lameter wrote:

> > Index: Linux/mm/mempolicy.c
> > ===================================================================
> > --- Linux.orig/mm/mempolicy.c	2007-10-12 10:50:05.000000000 -0400
> > +++ Linux/mm/mempolicy.c	2007-10-12 10:52:46.000000000 -0400
> > @@ -1112,19 +1112,25 @@ static struct mempolicy * get_vma_policy
> >  		struct vm_area_struct *vma, unsigned long addr)
> >  {
> >  	struct mempolicy *pol = task->mempolicy;
> > -	int shared_pol = 0;
> > +	int pol_needs_ref = (task != current);
> 
> If get_vma_policy is called from the numa_maps handler then we have taken 
> a refcount on the task struct. 
> 
> So this should be
> 	int pol_needs_ref = 0;

Argh. Refcount is not it. We have taken the mmap_sem lock 
because we are scanning though the pages. This avoids issues for the vma 
policies that can only be set when a writelock was taken on mmap_sem.

However, mmap_sem is not taken when setting task->mempolicy. Taking 
mmap_sem there would solve the issue (we have discussed this before).

You cannot reliably take a refcount on a foreign task structs mempolicy 
since the task may just be in the process of switching policies. You could 
increment the refcount and then the other task frees the structure.

I think we need something like this:

Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2007-10-15 12:32:45.000000000 -0700
+++ linux-2.6/mm/mempolicy.c	2007-10-15 12:33:56.000000000 -0700
@@ -468,11 +468,13 @@ long do_set_mempolicy(int mode, nodemask
 	new = mpol_new(mode, nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
+	down_read(&current->mm->mmap_sem);
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	mpol_set_task_struct_flag();
 	if (new && new->policy == MPOL_INTERLEAVE)
 		current->il_next = first_node(new->v.nodes);
+	up_read(&current->mm->mmap_sem);
 	return 0;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
