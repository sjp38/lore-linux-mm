Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 08F186B60C2
	for <linux-mm@kvack.org>; Sun,  2 Sep 2018 02:15:57 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id j17-v6so15330881oii.8
        for <linux-mm@kvack.org>; Sat, 01 Sep 2018 23:15:57 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id j14-v6si9569243oij.86.2018.09.01.23.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 01 Sep 2018 23:15:55 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w826DmNC128063
	for <linux-mm@kvack.org>; Sun, 2 Sep 2018 02:15:54 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2m8899useu-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 02 Sep 2018 02:15:54 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.vnet.ibm.com>;
	Sun, 2 Sep 2018 07:15:52 +0100
Date: Sun, 2 Sep 2018 09:15:45 +0300
From: Mike Rapoport <rppt@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] userfaultfd: allow
 get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) to trigger userfaults
References: <20180831214848.23676-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180831214848.23676-1-aarcange@redhat.com>
Message-Id: <20180902061544.GA5821@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Maxime Coquelin <maxime.coquelin@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

On Fri, Aug 31, 2018 at 05:48:48PM -0400, Andrea Arcangeli wrote:
> get_mempolicy(MPOL_F_NODE|MPOL_F_ADDR) called a get_user_pages that
> would not be waiting for userfaults before failing and it would hit on
> a SIGBUS instead. Using get_user_pages_locked/unlocked instead will
> allow get_mempolicy to allow userfaults to resolve the fault and fill
> the hole, before grabbing the node id of the page.
> 
> Reported-by: Maxime Coquelin <maxime.coquelin@redhat.com>
> Tested-by: Dr. David Alan Gilbert <dgilbert@redhat.com>
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Reviewed-by: Mike Rapoport <rppt@linux.vnet.ibm.com>

> ---
>  mm/mempolicy.c | 24 +++++++++++++++++++-----
>  1 file changed, 19 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 01f1a14facc4..a7f7f5415936 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -797,16 +797,19 @@ static void get_policy_nodemask(struct mempolicy *p, nodemask_t *nodes)
>  	}
>  }
> 
> -static int lookup_node(unsigned long addr)
> +static int lookup_node(struct mm_struct *mm, unsigned long addr)
>  {
>  	struct page *p;
>  	int err;
> 
> -	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
> +	int locked = 1;
> +	err = get_user_pages_locked(addr & PAGE_MASK, 1, 0, &p, &locked);
>  	if (err >= 0) {
>  		err = page_to_nid(p);
>  		put_page(p);
>  	}
> +	if (locked)
> +		up_read(&mm->mmap_sem);
>  	return err;
>  }
> 
> @@ -817,7 +820,7 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>  	int err;
>  	struct mm_struct *mm = current->mm;
>  	struct vm_area_struct *vma = NULL;
> -	struct mempolicy *pol = current->mempolicy;
> +	struct mempolicy *pol = current->mempolicy, *pol_refcount = NULL;
> 
>  	if (flags &
>  		~(unsigned long)(MPOL_F_NODE|MPOL_F_ADDR|MPOL_F_MEMS_ALLOWED))
> @@ -857,7 +860,16 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
> 
>  	if (flags & MPOL_F_NODE) {
>  		if (flags & MPOL_F_ADDR) {
> -			err = lookup_node(addr);
> +			/*
> +			 * Take a refcount on the mpol, lookup_node()
> +			 * wil drop the mmap_sem, so after calling
> +			 * lookup_node() only "pol" remains valid, "vma"
> +			 * is stale.
> +			 */
> +			pol_refcount = pol;
> +			vma = NULL;
> +			mpol_get(pol);
> +			err = lookup_node(mm, addr);
>  			if (err < 0)
>  				goto out;
>  			*policy = err;
> @@ -892,7 +904,9 @@ static long do_get_mempolicy(int *policy, nodemask_t *nmask,
>   out:
>  	mpol_cond_put(pol);
>  	if (vma)
> -		up_read(&current->mm->mmap_sem);
> +		up_read(&mm->mmap_sem);
> +	if (pol_refcount)
> +		mpol_put(pol_refcount);
>  	return err;
>  }
> 
> 

-- 
Sincerely yours,
Mike.
