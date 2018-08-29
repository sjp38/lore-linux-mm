Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 22AE56B4C5A
	for <linux-mm@kvack.org>; Wed, 29 Aug 2018 11:47:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id z56-v6so2463305edz.10
        for <linux-mm@kvack.org>; Wed, 29 Aug 2018 08:47:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r9-v6si891944edp.9.2018.08.29.08.47.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Aug 2018 08:47:46 -0700 (PDT)
Date: Wed, 29 Aug 2018 17:47:44 +0200
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH 2/2] mm: thp: fix transparent_hugepage/defrag = madvise
 || always
Message-ID: <20180829154744.GC10223@dhcp22.suse.cz>
References: <20180821214049.GG13047@redhat.com>
 <20180822090214.GF29735@dhcp22.suse.cz>
 <20180822155250.GP13047@redhat.com>
 <20180823105253.GB29735@dhcp22.suse.cz>
 <20180828075321.GD10223@dhcp22.suse.cz>
 <20180828081837.GG10223@dhcp22.suse.cz>
 <D5F4A33C-0A37-495C-9468-D6866A862097@cs.rutgers.edu>
 <20180829142816.GX10223@dhcp22.suse.cz>
 <20180829143545.GY10223@dhcp22.suse.cz>
 <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <82CA00EB-BF8E-4137-953B-8BC4B74B99AF@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Alex Williamson <alex.williamson@redhat.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Stefan Priebe - Profihost AG <s.priebe@profihost.ag>

On Wed 29-08-18 11:22:35, Zi Yan wrote:
> On 29 Aug 2018, at 10:35, Michal Hocko wrote:
> 
> > On Wed 29-08-18 16:28:16, Michal Hocko wrote:
> >> On Wed 29-08-18 09:28:21, Zi Yan wrote:
> >> [...]
> >>> This patch triggers WARN_ON_ONCE() in policy_node() when MPOL_BIND is used and THP is on.
> >>> Should this WARN_ON_ONCE be removed?
> >>>
> >>>
> >>> /*
> >>> * __GFP_THISNODE shouldn't even be used with the bind policy
> >>> * because we might easily break the expectation to stay on the
> >>> * requested node and not break the policy.
> >>> */
> >>> WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> >>
> >> This is really interesting. It seems to be me who added this warning but
> >> I cannot simply make any sense of it. Let me try to dig some more.
> >
> > OK, I get it now. The warning seems to be incomplete. It is right to
> > complain when __GFP_THISNODE disagrees with MPOL_BIND policy but that is
> > not what we check here. Does this heal the warning?
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index da858f794eb6..7bb9354b1e4c 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -1728,7 +1728,10 @@ static int policy_node(gfp_t gfp, struct mempolicy *policy,
> >  		 * because we might easily break the expectation to stay on the
> >  		 * requested node and not break the policy.
> >  		 */
> > -		WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> > +		if (policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE)) {
> > +			nodemask_t *nmask = policy_nodemask(gfp, policy);
> > +			WARN_ON_ONCE(!node_isset(nd, *nmask));
> > +		}
> >  	}
> >
> >  	return nd;
> 
> Unfortunately no. I simply ran a??memhog -r3 1g membind 1a?? to test and the warning still showed up.
> 
> The reason is that nd is just a hint about which node to prefer for allocation and
> can be ignored if it does not conform to mempolicy.
>
> Taking my test as an example, if an application is only memory bound to node 1 but can run on any CPU
> nodes and it launches on node 0, alloc_pages_vma() will see 0 as its node parameter
> and passes 0 to policy_node()a??s nd parameter. This should be OK, but your patches
> would give a warning, because nd=0 is not set in nmask=1.
> 
> Now I get your comment a??__GFP_THISNODE shouldn't even be used with the bind policya??,
> since they are indeed incompatible. __GFP_THISNODE wants to use the node,
> which can be ignored by MPOL_BIND policy.

Well, the assumption was that you do not run on a remote cpu to your
memory policy. But that seems a wrong assumption.

> IMHO, we could get rid of __GFP_THISNODE when MPOL_BIND is set, like
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 0d2be5786b0c..a0fcb998d277 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1722,14 +1722,6 @@ static int policy_node(gfp_t gfp, struct mempolicy *policy,
>  {
>         if (policy->mode == MPOL_PREFERRED && !(policy->flags & MPOL_F_LOCAL))
>                 nd = policy->v.preferred_node;
> -       else {
> -               /*
> -                * __GFP_THISNODE shouldn't even be used with the bind policy
> -                * because we might easily break the expectation to stay on the
> -                * requested node and not break the policy.
> -                */
> -               WARN_ON_ONCE(policy->mode == MPOL_BIND && (gfp & __GFP_THISNODE));
> -       }
> 
>         return nd;
>  }
> @@ -2026,6 +2018,13 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
>                 goto out;
>         }
> 
> +       /*
> +        * __GFP_THISNODE shouldn't even be used with the bind policy
> +        * because we might easily break the expectation to stay on the
> +        * requested node and not break the policy.
> +        */
> +       if (pol->mode == MPOL_BIND)
> +               gfp &= ~__GFP_THISNODE;
> 
>         nmask = policy_nodemask(gfp, pol);
>         preferred_nid = policy_node(gfp, pol, node);
> 
> What do you think?

I do not like overwriting gfp flags like that. It is just ugly and error
prone. A more proper way would be to handle that at the layer we play
with __GFP_THISNODE. The resulting diff is larger though.

If there is a general concensus that this is growing too complicated
then Andrea's patch (the second variant to overwrite gfp mask) is much
simpler of course but I really detest the subtle gfp rewriting. I still
believe that all the nasty details should be covered at the single
place.


diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 5228c62af416..bac395f1d00a 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -139,6 +139,8 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 struct mempolicy *get_task_policy(struct task_struct *p);
 struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
 		unsigned long addr);
+struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
+						unsigned long addr);
 bool vma_policy_mof(struct vm_area_struct *vma);
 
 extern void numa_default_policy(void);
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index a703c23f8bab..94472bf9a31b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -629,21 +629,30 @@ static vm_fault_t __do_huge_pmd_anonymous_page(struct vm_fault *vmf,
  *	    available
  * never: never stall for any thp allocation
  */
-static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma)
+static inline gfp_t alloc_hugepage_direct_gfpmask(struct vm_area_struct *vma, unsigned long addr)
 {
 	const bool vma_madvised = !!(vma->vm_flags & VM_HUGEPAGE);
+	gfp_t this_node = 0;
+	struct mempolicy *pol;
+
+#ifdef CONFIG_NUMA
+	/* __GFP_THISNODE makes sense only if there is no explicit binding */
+	pol = get_vma_policy(vma, addr);
+	if (pol->mode != MPOL_BIND)
+		this_node = __GFP_THISNODE;
+#endif
 
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_DIRECT_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | __GFP_THISNODE);
+		return GFP_TRANSHUGE | (vma_madvised ? 0 : __GFP_NORETRY | this_node);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_FLAG, &transparent_hugepage_flags))
-		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | __GFP_THISNODE;
+		return GFP_TRANSHUGE_LIGHT | __GFP_KSWAPD_RECLAIM | this_node;
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_KSWAPD_OR_MADV_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     __GFP_KSWAPD_RECLAIM | __GFP_THISNODE);
+							     __GFP_KSWAPD_RECLAIM | this_node);
 	if (test_bit(TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG, &transparent_hugepage_flags))
 		return GFP_TRANSHUGE_LIGHT | (vma_madvised ? __GFP_DIRECT_RECLAIM :
-							     __GFP_THISNODE);
-	return GFP_TRANSHUGE_LIGHT | __GFP_THISNODE;
+							     this_node);
+	return GFP_TRANSHUGE_LIGHT | this_node;
 }
 
 /* Caller must hold page table lock. */
@@ -715,7 +724,7 @@ vm_fault_t do_huge_pmd_anonymous_page(struct vm_fault *vmf)
 			pte_free(vma->vm_mm, pgtable);
 		return ret;
 	}
-	gfp = alloc_hugepage_direct_gfpmask(vma);
+	gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
 	page = alloc_hugepage_vma(gfp, vma, haddr, HPAGE_PMD_ORDER);
 	if (unlikely(!page)) {
 		count_vm_event(THP_FAULT_FALLBACK);
@@ -1290,7 +1299,7 @@ vm_fault_t do_huge_pmd_wp_page(struct vm_fault *vmf, pmd_t orig_pmd)
 alloc:
 	if (transparent_hugepage_enabled(vma) &&
 	    !transparent_hugepage_debug_cow()) {
-		huge_gfp = alloc_hugepage_direct_gfpmask(vma);
+		huge_gfp = alloc_hugepage_direct_gfpmask(vma, haddr);
 		new_page = alloc_hugepage_vma(huge_gfp, vma, haddr, HPAGE_PMD_ORDER);
 	} else
 		new_page = NULL;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 9f0800885613..75bbfc3d6233 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1648,7 +1648,7 @@ struct mempolicy *__get_vma_policy(struct vm_area_struct *vma,
  * freeing by another task.  It is the caller's responsibility to free the
  * extra reference for shared policies.
  */
-static struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
+struct mempolicy *get_vma_policy(struct vm_area_struct *vma,
 						unsigned long addr)
 {
 	struct mempolicy *pol = __get_vma_policy(vma, addr);
-- 
Michal Hocko
SUSE Labs
