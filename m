Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp01.au.ibm.com (8.13.1/8.13.1) with ESMTP id l8HJD88a018679
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 05:13:09 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l8HJD66l4034724
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 05:13:06 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l8HJCoua027704
	for <linux-mm@kvack.org>; Tue, 18 Sep 2007 05:12:50 +1000
Message-ID: <46EED1A7.5080606@linux.vnet.ibm.com>
Date: Tue, 18 Sep 2007 00:42:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH mm] fix swapoff breakage; however...
References: <Pine.LNX.4.64.0709171947130.15413@blonde.wat.veritas.com>
In-Reply-To: <Pine.LNX.4.64.0709171947130.15413@blonde.wat.veritas.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> rc4-mm1's memory-controller-memory-accounting-v7.patch broke swapoff:
> it extended unuse_pte_range's boolean "found" return code to allow an
> error return too; but ended up returning found (1) as an error.
> Replace that by success (0) before it gets to the upper level.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> More fundamentally, it looks like any container brought over its limit in
> unuse_pte will abort swapoff: that doesn't doesn't seem "contained" to me.
> Maybe unuse_pte should just let containers go over their limits without
> error?  Or swap should be counted along with RSS?  Needs reconsideration.
> 
>  mm/swapfile.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- 2.6.23-rc4-mm1/mm/swapfile.c	2007-09-07 13:09:42.000000000 +0100
> +++ linux/mm/swapfile.c	2007-09-17 15:14:47.000000000 +0100
> @@ -642,7 +642,7 @@ static int unuse_mm(struct mm_struct *mm
>  			break;
>  	}
>  	up_read(&mm->mmap_sem);
> -	return ret;
> +	return (ret < 0)? ret: 0;

Thanks, for the catching this. There are three possible solutions

1. Account each RSS page with a probable swap cache page, double
   the RSS accounting to ensure that swapoff will not fail.
2. Account for the RSS page just once, do not account swap cache
   pages
3. Follow your suggestion and let containers go over their limits
   without error

With the current approach, a container over it's limit will not
be able to call swapoff successfully, is that bad?

We plan to implement per container/per cpuset swap in the future.
Given that, isn't this expected functionality. You are over it's
limit cannot really swapoff a swap device. If we allow pages to
be unused, we could end up with a container that could exceed
it's limit by a significant amount by calling swapoff.


>  }
> 
>  /*


-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
