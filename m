Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id D145B6007DB
	for <linux-mm@kvack.org>; Wed,  2 Dec 2009 10:24:55 -0500 (EST)
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id nB2FNb0e009671
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 08:23:37 -0700
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nB2FOcIp037118
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 08:24:38 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nB29FQl6009563
	for <linux-mm@kvack.org>; Wed, 2 Dec 2009 02:15:26 -0700
Subject: Re: [PATCH] hugetlb: Abort a hugepage pool resize if a signal is
 pending
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20091202141504.GE1457@csn.ul.ie>
References: <20091202141504.GE1457@csn.ul.ie>
Content-Type: text/plain
Date: Wed, 02 Dec 2009 07:24:35 -0800
Message-Id: <1259767475.24696.2368.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2009-12-02 at 14:15 +0000, Mel Gorman wrote:
> If a user asks for a hugepage pool resize but specified a large number, the
> machine can begin trashing. In response, they might hit ctrl-c but signals
> are ignored and the pool resize continues until it fails an allocation. This
> can take a considerable amount of time so this patch aborts a pool resize
> if a signal is pending.
> 
> [dave@linux.vnet.ibm.com: His idea]
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> ---
>  mm/hugetlb.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index af02ee8..a952cb8 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1238,6 +1238,9 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count)
>  		if (!ret)
>  			goto out;
> 
> +		/* Bail for signals. Probably ctrl-c from user */
> +		if (signal_pending(current))
> +			goto out;

Thanks, Mel!

This will help m unwedge my system the next time I fat-finger an extra
zero or two into my hugepage pool size.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
