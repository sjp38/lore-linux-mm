Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA8B6B0033
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 05:30:27 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id w105so9568383wrc.20
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 02:30:27 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l15si1157228wmg.129.2017.10.31.02.30.25
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 02:30:25 -0700 (PDT)
Subject: Re: [PATCH RFC v2 3/4] mm/mempolicy: fix the check of nodemask from
 user
References: <1509099265-30868-1-git-send-email-xieyisheng1@huawei.com>
 <1509099265-30868-4-git-send-email-xieyisheng1@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <56c4cdbf-c228-6203-285c-15f19a841538@suse.cz>
Date: Tue, 31 Oct 2017 10:30:24 +0100
MIME-Version: 1.0
In-Reply-To: <1509099265-30868-4-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yisheng Xie <xieyisheng1@huawei.com>, akpm@linux-foundation.org, mhocko@suse.com, mingo@kernel.org, rientjes@google.com, n-horiguchi@ah.jp.nec.com, salls@cs.ucsb.edu
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, tanxiaojun@huawei.com, linux-api@vger.kernel.org

On 10/27/2017 12:14 PM, Yisheng Xie wrote:
> As Xiaojun reported the ltp of migrate_pages01 will failed on ARCH arm64
> system which has 4 nodes[0...3], all have memory and CONFIG_NODES_SHIFT=2:
> 
> migrate_pages01    0  TINFO  :  test_invalid_nodes
> migrate_pages01   14  TFAIL  :  migrate_pages_common.c:45: unexpected failure - returned value = 0, expected: -1
> migrate_pages01   15  TFAIL  :  migrate_pages_common.c:55: call succeeded unexpectedly
> 
> In this case the test_invalid_nodes of migrate_pages01 will call:
> SYSC_migrate_pages as:
> 
> migrate_pages(0, , {0x0000000000000001}, 64, , {0x0000000000000010}, 64) = 0
> 
> The new nodes specifies one or more node IDs that are greater than the
> maximum supported node ID, however, the errno is not set to EINVAL as
> expected.
> 
> As man pages of set_mempolicy[1], mbind[2], and migrate_pages[3] memtioned,
> when nodemask specifies one or more node IDs that are greater than the
> maximum supported node ID, the errno should set to EINVAL. However, get_nodes
> only check whether the part of bits [BITS_PER_LONG*BITS_TO_LONGS(MAX_NUMNODES),
> maxnode) is zero or not,  and remain [MAX_NUMNODES, BITS_PER_LONG*BITS_TO_LONGS(MAX_NUMNODES)
> unchecked.
> 
> This patch is to check the bits of [MAX_NUMNODES, maxnode) in get_nodes to
> let migrate_pages set the errno to EINVAL when nodemask specifies one or
> more node IDs that are greater than the maximum supported node ID, which
> follows the manpage's guide.
> 
> [1] http://man7.org/linux/man-pages/man2/set_mempolicy.2.html
> [2] http://man7.org/linux/man-pages/man2/mbind.2.html
> [3] http://man7.org/linux/man-pages/man2/migrate_pages.2.html
> 
> Reported-by: Tan Xiaojun <tanxiaojun@huawei.com>
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  mm/mempolicy.c | 23 ++++++++++++++++++++---
>  1 file changed, 20 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 3b51bb3..8798ecb 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -1262,6 +1262,7 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
>  		     unsigned long maxnode)
>  {
>  	unsigned long k;
> +	unsigned long t;
>  	unsigned long nlongs;
>  	unsigned long endmask;
>  
> @@ -1277,11 +1278,17 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
>  	else
>  		endmask = (1UL << (maxnode % BITS_PER_LONG)) - 1;
>  
> -	/* When the user specified more nodes than supported just check
> -	   if the non supported part is all zero. */
> +	/*
> +	 * When the user specified more nodes than supported just check
> +	 * if the non supported part is all zero.
> +	 *
> +	 * If maxnode have more longs than MAX_NUMNODES, check
> +	 * the bits in that area first. And then go through to
> +	 * check the rest bits which equal or bigger than MAX_NUMNODES.
> +	 * Otherwise, just check bits [MAX_NUMNODES, maxnode).
> +	 */
>  	if (nlongs > BITS_TO_LONGS(MAX_NUMNODES)) {
>  		for (k = BITS_TO_LONGS(MAX_NUMNODES); k < nlongs; k++) {
> -			unsigned long t;
>  			if (get_user(t, nmask + k))
>  				return -EFAULT;
>  			if (k == nlongs - 1) {
> @@ -1294,6 +1301,16 @@ static int get_nodes(nodemask_t *nodes, const unsigned long __user *nmask,
>  		endmask = ~0UL;
>  	}
>  
> +	if (maxnode > MAX_NUMNODES && MAX_NUMNODES % BITS_PER_LONG != 0) {
> +		unsigned long valid_mask = endmask;
> +
> +		valid_mask &= ~((1UL << (MAX_NUMNODES % BITS_PER_LONG)) - 1);

I'm not sure if the combination with endmask works in this case:

0      BITS_PER_LONG  2xBITS_PER_LONG
|____________|____________|
       |             |
  MAX_NUMNODES      maxnode

endmask will contain bits between 0 and maxnode
but here we want to check bits between MAX_NUMNODES and BITS_PER_LONG
and endmask should not be mixed up with that?


Vlastimil

> +		if (get_user(t, nmask + nlongs - 1))
> +			return -EFAULT;
> +		if (t & valid_mask)
> +			return -EINVAL;
> +	}
> +
>  	if (copy_from_user(nodes_addr(*nodes), nmask, nlongs*sizeof(unsigned long)))
>  		return -EFAULT;
>  	nodes_addr(*nodes)[nlongs-1] &= endmask;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
