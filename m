Subject: Re: [PATCH] Mempolicy:  make dequeue_huge_page_vma() obey
	MPOL_BIND nodemask rework
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20080307173537.GA24778@us.ibm.com>
References: <20080227214734.6858.9968.sendpatchset@localhost>
	 <20080228133247.6a7b626f.akpm@linux-foundation.org>
	 <20080229145030.GD6045@csn.ul.ie> <1204300094.5311.50.camel@localhost>
	 <20080304180145.GB9051@csn.ul.ie> <1204733195.5026.20.camel@localhost>
	 <20080305180322.GA9795@us.ibm.com> <1204743774.6244.6.camel@localhost>
	 <20080306010440.GE28746@us.ibm.com> <1204838693.5294.102.camel@localhost>
	 <20080307173537.GA24778@us.ibm.com>
Content-Type: text/plain
Date: Fri, 07 Mar 2008 13:31:44 -0500
Message-Id: <1204914705.5340.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, agl@us.ibm.com, wli@holomorphy.com, clameter@sgi.com, ak@suse.de, kamezawa.hiroyu@jp.fujitsu.com, rientjes@google.com, linux-mm@kvack.org, eric.whitney@hp.com
List-ID: <linux-mm.kvack.org>

On Fri, 2008-03-07 at 09:35 -0800, Nishanth Aravamudan wrote:
> On 06.03.2008 [16:24:53 -0500], Lee Schermerhorn wrote:
> > 
> > Fix for earlier patch:
> > "mempolicy-make-dequeue_huge_page_vma-obey-bind-policy"
> > 
> > Against: 2.6.25-rc3-mm1 atop the above patch.
> > 
> > As suggested by Nish Aravamudan, remove the mpol_bind_nodemask()
> > helper and return a pointer to the policy node mask from
> > huge_zonelist for MPOL_BIND.  This hides more of the mempolicy
> > quirks from hugetlb.
> > 
> > In making this change, I noticed that the huge_zonelist() stub
> > for !NUMA wasn't nulling out the mpol.  Added that as well.
> 
> Hrm, I was thinking more of the following (on top of this patch):
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 4c5d41d..3790f5a 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1298,9 +1298,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
>  
>  	*mpol = NULL;		/* probably no unref needed */
>  	*nodemask = NULL;	/* assume !MPOL_BIND */
> -	if (pol->policy == MPOL_BIND) {
> -			*nodemask = &pol->v.nodes;
> -	} else if (pol->policy == MPOL_INTERLEAVE) {
> +	if (pol->policy == MPOL_INTERLEAVE) {
>  		unsigned nid;
>  
>  		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> @@ -1310,10 +1308,12 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
>  
>  	zl = zonelist_policy(GFP_HIGHUSER, pol);
>  	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
> -		if (pol->policy != MPOL_BIND)
> +		if (pol->policy != MPOL_BIND) {
>  			__mpol_free(pol);	/* finished with pol */
> -		else
> +		} else {
>  			*mpol = pol;	/* unref needed after allocation */
> +			*nodemask = &pol->v.nodes;
> +		}
>  	}
>  	return zl;
>  }
> 
> but perhaps that won't do the right thing if pol == current->mempolicy
> and pol->policy == MPOL_BIND. 

Right, you won't return the nodemask for current task policy == MBIND.

> So something like:
> 
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 4c5d41d..7eb77e0 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1298,9 +1298,7 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
>  
>  	*mpol = NULL;		/* probably no unref needed */
>  	*nodemask = NULL;	/* assume !MPOL_BIND */
> -	if (pol->policy == MPOL_BIND) {
> -			*nodemask = &pol->v.nodes;
> -	} else if (pol->policy == MPOL_INTERLEAVE) {
> +	if (pol->policy == MPOL_INTERLEAVE) {
>  		unsigned nid;
>  
>  		nid = interleave_nid(pol, vma, addr, HPAGE_SHIFT);
> @@ -1309,11 +1307,12 @@ struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
>  	}
>  
>  	zl = zonelist_policy(GFP_HIGHUSER, pol);
> -	if (unlikely(pol != &default_policy && pol != current->mempolicy)) {
> -		if (pol->policy != MPOL_BIND)
> -			__mpol_free(pol);	/* finished with pol */
> -		else
> +	if (unlikely(pol != &default_policy && pol != current->mempolicy
> +						&& pol->policy != MPOL_BIND))
> +		__mpol_free(pol);	/* finished with pol */
> +	if (pol->policy == MPOL_BIND) {
>  			*mpol = pol;	/* unref needed after allocation */
> +			*nodemask = &pol->v.nodes;
>  	}
>  	return zl;
>  }
> 
> Still not quite as clean, but I think it's best to keep the *mpol and
> *nodemask assignments together, as if *mpol is being assigned, that's
> the only time we should need to set *nodemask, right?

Well, as you've noted, we do have to test MPOL_BIND twice:  once to
return the nodemask for any 'BIND policy and once to return a non-NULL
mpol ONLY if it's MPOL_BIND and we need an unref.  However, I wanted to
avoid checking the policies twice as well, or storing *nodemask 3rd
time.

I think that your second change above is not quite right, either.
You're unconditionally returning the policy when the 'mode' == MBIND,
even if it does not need a deref.  This could result in prematurely
freeing the task policy, causing a "use after free" error on next
allocation; or even decrementing the reference on the system_default
policy, which is probably benign, but not "nice".  [Also, check your
parentheses...]

Anyway you slice it, it's pretty ugly.

So, for now, I'd like to keep it the way I have it.  I'll be sending out
a set of patches to rework the reference counting after mempolicy
settles down--i.e., Mel's and David's patches, which I'm testing now.
That will clean this area up quite a bit, IMO.  

Lee


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
