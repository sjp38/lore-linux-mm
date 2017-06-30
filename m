Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CDBFE6B0279
	for <linux-mm@kvack.org>; Thu, 29 Jun 2017 22:13:40 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u126so46868362qka.9
        for <linux-mm@kvack.org>; Thu, 29 Jun 2017 19:13:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z188si3330451qke.98.2017.06.29.19.13.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Jun 2017 19:13:38 -0700 (PDT)
Date: Thu, 29 Jun 2017 22:13:26 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: [PATCH] mm: convert three more cases to kvmalloc
In-Reply-To: <20170629071046.GA31603@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1706292205110.21823@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1706282317480.11892@file01.intranet.prod.int.rdu2.redhat.com> <20170629071046.GA31603@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Vlastimil Babka <vbabka@suse.cz>, Andreas Dilger <adilger@dilger.ca>, John Hubbard <jhubbard@nvidia.com>, David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org



On Thu, 29 Jun 2017, Michal Hocko wrote:

> On Wed 28-06-17 23:24:10, Mikulas Patocka wrote:
> [...]
> > From: Mikulas Patocka <mpatocka@redhat.com>
> > 
> > The patch a7c3e901 ("mm: introduce kv[mz]alloc helpers") converted a lot 
> > of kernel code to kvmalloc. This patch converts three more forgotten 
> > cases.
> 
> Thanks! I have two remarks below but other than that feel free to add
> 
> > Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
> 
> Acked-by: Michal Hocko <mhocko@suse.com>
> [...]
> > Index: linux-2.6/kernel/bpf/syscall.c
> > ===================================================================
> > --- linux-2.6.orig/kernel/bpf/syscall.c
> > +++ linux-2.6/kernel/bpf/syscall.c
> > @@ -58,16 +58,7 @@ void *bpf_map_area_alloc(size_t size)
> >  	 * trigger under memory pressure as we really just want to
> >  	 * fail instead.
> >  	 */
> > -	const gfp_t flags = __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO;
> > -	void *area;
> > -
> > -	if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
> > -		area = kmalloc(size, GFP_USER | flags);
> > -		if (area != NULL)
> > -			return area;
> > -	}
> > -
> > -	return __vmalloc(size, GFP_KERNEL | flags, PAGE_KERNEL);
> > +	return kvmalloc(size, GFP_USER | __GFP_NOWARN | __GFP_NORETRY | __GFP_ZERO);
> 
> kvzalloc without additional flags would be more appropriate.
> __GFP_NORETRY is explicitly documented as non-supported

How is __GFP_NORETRY non-supported?

> and NOWARN wouldn't be applied everywhere in the vmalloc path.

__GFP_NORETRY and __GFP_NOWARN wouldn't be applied in the page-table 
allocation and they would be applied in the page allocation - that seems 
acceptable.

But the problem here is that if the system is under memory stress, 
__GFP_NORETRY allocations would randomly fail (they would fail for example 
if there's a plenty of free swap space and the system is busy swapping) 
and that would make the BFP creation code randomly fail.

BPF maintainers, please explain, how are you dealing with the random 
memory allocation failures? Is there some other code in the BPF stack that 
retries the failed allocations?

> >  }
> >  
> >  void bpf_map_area_free(void *area)
> > Index: linux-2.6/kernel/cgroup/cgroup-v1.c
> > ===================================================================
> > --- linux-2.6.orig/kernel/cgroup/cgroup-v1.c
> > +++ linux-2.6/kernel/cgroup/cgroup-v1.c
> > @@ -184,15 +184,10 @@ struct cgroup_pidlist {
> >  /*
> >   * The following two functions "fix" the issue where there are more pids
> >   * than kmalloc will give memory for; in such cases, we use vmalloc/vfree.
> > - * TODO: replace with a kernel-wide solution to this problem
> >   */
> > -#define PIDLIST_TOO_LARGE(c) ((c) * sizeof(pid_t) > (PAGE_SIZE * 2))
> >  static void *pidlist_allocate(int count)
> >  {
> > -	if (PIDLIST_TOO_LARGE(count))
> > -		return vmalloc(count * sizeof(pid_t));
> > -	else
> > -		return kmalloc(count * sizeof(pid_t), GFP_KERNEL);
> > +	return kvmalloc(count * sizeof(pid_t), GFP_KERNEL);
> >  }
> 
> I would rather use kvmalloc_array to have an overflow protection as
> well.

Yes.

Mikulas

> >  
> >  static void pidlist_free(void *p)
> 
> -- 
> Michal Hocko
> SUSE Labs
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
