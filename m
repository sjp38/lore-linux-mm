Date: Mon, 23 Jun 2008 04:48:25 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 05/21] hugetlb: new sysfs interface
Message-ID: <20080623024825.GE29413@wotan.suse.de>
References: <20080604112939.789444496@amd.local0.net> <20080604113111.647714612@amd.local0.net> <1213975138.7512.33.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1213975138.7512.33.camel@nimitz>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, "Serge E. Hallyn" <serue@us.ibm.com>, kathys <kathys@au1.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 20, 2008 at 08:18:58AM -0700, Dave Hansen wrote:
> This one seems to be causing some compilation errors with SYSFS=n.
> 
> >> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c: In  
> >> function 'hugetlb_exit':
> >> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1234:  
> >> error: 'hstate_kobjs' undeclared (first use in this function)
> >> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1234:  
> >> error: (Each undeclared identifier is reported only once
> >> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1234:  
> >> error: for each function it appears in.)
> >> /scratch/kathys/containers/kernel_trees/upstream/mm/hugetlb.c:1237:  
> >> error: 'hugepages_kobj' undeclared (first use in this function)
> >> make[2]: *** [mm/hugetlb.o] Error 1
> >> make[1]: *** [mm] Error 2
> >> make: *** [sub-make] Error 2
> 
> Should we just move hugetlb_exit() inside the sysfs #ifdef with
> everything else?

Yeah, thanks for testing that (I always forget to testall permutations
of these things...)

I think the patch looks fine. Andrew, can you queue it?


> 
> --- linux-2.6.git-mm//mm/hugetlb.c.orig	2008-06-20 08:07:39.000000000 -0700
> +++ linux-2.6.git-mm//mm/hugetlb.c	2008-06-20 08:14:36.000000000 -0700
> @@ -1193,6 +1193,19 @@
>  								h->name);
>  	}
>  }
> +
> +static void __exit hugetlb_exit(void)
> +{
> +	struct hstate *h;
> +
> +	for_each_hstate(h) {
> +		kobject_put(hstate_kobjs[h - hstates]);
> +	}
> +
> +	kobject_put(hugepages_kobj);
> +}
> +module_exit(hugetlb_exit);
> +
>  #else
>  static void __init hugetlb_sysfs_init(void)
>  {
> @@ -1226,18 +1239,6 @@
>  }
>  module_init(hugetlb_init);
>  
> -static void __exit hugetlb_exit(void)
> -{
> -	struct hstate *h;
> -
> -	for_each_hstate(h) {
> -		kobject_put(hstate_kobjs[h - hstates]);
> -	}
> -
> -	kobject_put(hugepages_kobj);
> -}
> -module_exit(hugetlb_exit);
> -
>  /* Should be called on processing a hugepagesz=... option */
>  void __init hugetlb_add_hstate(unsigned order)
>  {
> 
> 
> -- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
