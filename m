Date: Mon, 15 Oct 2007 12:19:43 +0100
Subject: Re: [PATCH 1/2] Mem Policy:  fix mempolicy usage in pci driver
Message-ID: <20071015111943.GC31490@skynet.ie>
References: <20071010205837.7230.42818.sendpatchset@localhost> <20071010205843.7230.31507.sendpatchset@localhost> <Pine.LNX.4.64.0710101412410.32488@schroedinger.engr.sgi.com> <1192129868.5036.27.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1192129868.5036.27.camel@localhost>
From: mel@skynet.ie (Mel Gorman)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, ak@suse.de, gregkh@suse.de, linux-mm@kvack.org, eric.whitney@hp.com, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On (11/10/07 15:11), Lee Schermerhorn didst pronounce:
> On Wed, 2007-10-10 at 14:12 -0700, Christoph Lameter wrote:
> > Acked-by: Christoph Lameter <clameter@sgi.com>
> > 
> 
> Resend with 'RFC' removed.  Please review/consider for merge.
> 
> Note:  this is required BEFORE patch 2 of this series to avoid hitting
> the [VM_]BUG_ON()s added by the second patch.
> 
> Lee
> 
> ====
> PATCH 1/2 Fix memory policy usage in pci driver
> 
> Against:  2.6.23-rc8-mm2
> 
> In an attempt to ensure memory allocation from the local node,
> the pci driver temporarily replaces the current task's memory
> policy with the system default policy.  Trying to be a good
> citizen, the driver then call's mpol_get() on the new policy.
> When it's finished probing, it undoes the '_get by calling
> mpol_free() [on the system default policy] and then restores
> the current task's saved mempolicy.
> 
> A couple of issues here:
> 
> 1) it's never necessary to set a task's mempolicy to the
>    system default policy in order to get system default
>    allocation behavior.  Simply set the current task's
>    mempolicy to NULL and allocations will fall back to
>    system default policy.
> 
> 2) we should never [need to] call mpol_free() on the system
>    default policy.  [I plan on trapping this with a VM_BUG_ON()
>    in a subsequent patch.]
> 
> This patch removes the calls to mpol_get() and mpol_free()
> and uses NULL for the temporary task mempolicy to effect
> default allocation behavior.
> 
> Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Acked-by: Mel Gorman <mel@csn.ul.ie>

> 
>  drivers/pci/pci-driver.c |    4 +---
>  1 file changed, 1 insertion(+), 3 deletions(-)
> 
> Index: Linux/drivers/pci/pci-driver.c
> ===================================================================
> --- Linux.orig/drivers/pci/pci-driver.c	2007-10-09 14:31:57.000000000
> -0400
> +++ Linux/drivers/pci/pci-driver.c	2007-10-09 14:43:57.000000000 -0400
> @@ -177,13 +177,11 @@ static int pci_call_probe(struct pci_dri
>  	    set_cpus_allowed(current, node_to_cpumask(node));
>  	/* And set default memory allocation policy */
>  	oldpol = current->mempolicy;
> -	current->mempolicy = &default_policy;
> -	mpol_get(current->mempolicy);
> +	current->mempolicy = NULL;	/* fall back to system default policy */
>  #endif
>  	error = drv->probe(dev, id);
>  #ifdef CONFIG_NUMA
>  	set_cpus_allowed(current, oldmask);
> -	mpol_free(current->mempolicy);
>  	current->mempolicy = oldpol;
>  #endif
>  	return error;
> 
> 

-- 
-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
