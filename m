Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3PNZhOP032704
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 19:35:43 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3PNZb0k196444
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 17:35:43 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3PNZbD5016891
	for <linux-mm@kvack.org>; Fri, 25 Apr 2008 17:35:37 -0600
Date: Fri, 25 Apr 2008 16:35:36 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: Re: [patch 08/18] hugetlb: multi hstate sysctls
Message-ID: <20080425233536.GA31226@us.ibm.com>
References: <20080423015302.745723000@nick.local0.net> <20080423015430.487393000@nick.local0.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080423015430.487393000@nick.local0.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, andi@firstfloor.org, kniht@linux.vnet.ibm.com, abh@cray.com, wli@holomorphy.com
List-ID: <linux-mm.kvack.org>

On 23.04.2008 [11:53:10 +1000], npiggin@suse.de wrote:
> Expand the hugetlbfs sysctls to handle arrays for all hstates. This
> now allows the removal of global_hstate -- everything is now hstate
> aware.
> 
> - I didn't bother with hugetlb_shm_group and treat_as_movable,
> these are still single global.
> - Also improve error propagation for the sysctl handlers a bit

<snip>

> @@ -707,10 +717,25 @@ int hugetlb_sysctl_handler(struct ctl_ta
>  			   struct file *file, void __user *buffer,
>  			   size_t *length, loff_t *ppos)
>  {
> -	proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> -	max_huge_pages = set_max_huge_pages(max_huge_pages);
> -	global_hstate.max_huge_pages = max_huge_pages;
> -	return 0;
> +	int err = 0;
> +	struct hstate *h;
> +
> +	err = proc_doulongvec_minmax(table, write, file, buffer, length, ppos);
> +	if (err)
> +		return err;
> +
> +	if (write) {
> +		for_each_hstate (h) {
> +			int tmp;
> +
> +			h->max_huge_pages = set_max_huge_pages(h,
> +					max_huge_pages[h - hstates], &tmp);
> +			max_huge_pages[h - hstates] = h->max_huge_pages;
> +			if (tmp && !err)
> +				err = tmp;
> +		}
> +	}

Could this same condition be added to the overcommit handler, please?

Thanks,
Nish

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
