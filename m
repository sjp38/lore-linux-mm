Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f47.google.com (mail-pb0-f47.google.com [209.85.160.47])
	by kanga.kvack.org (Postfix) with ESMTP id 7D5AC6B0031
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 00:50:11 -0500 (EST)
Received: by mail-pb0-f47.google.com with SMTP id um1so24949564pbc.6
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 21:50:11 -0800 (PST)
Received: from e28smtp03.in.ibm.com (e28smtp03.in.ibm.com. [122.248.162.3])
        by mx.google.com with ESMTPS id hb3si56858948pac.123.2013.12.04.21.50.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 21:50:10 -0800 (PST)
Received: from /spool/local
	by e28smtp03.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <raghavendra.kt@linux.vnet.ibm.com>;
	Thu, 5 Dec 2013 11:20:06 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 70A4BE0059
	for <linux-mm@kvack.org>; Thu,  5 Dec 2013 11:22:13 +0530 (IST)
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB55nuhU35061954
	for <linux-mm@kvack.org>; Thu, 5 Dec 2013 11:19:56 +0530
Received: from d28av05.in.ibm.com (localhost [127.0.0.1])
	by d28av05.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id rB55nxbj031839
	for <linux-mm@kvack.org>; Thu, 5 Dec 2013 11:19:59 +0530
Message-ID: <52A015E1.50005@linux.vnet.ibm.com>
Date: Thu, 05 Dec 2013 11:27:53 +0530
From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH RFC] mm readahead: Fix the readahead fail in case of empty
 numa node
References: <1386066977-17368-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com> <20131203143841.11b71e387dc1db3a8ab0974c@linux-foundation.org> <529EE811.5050306@linux.vnet.ibm.com> <20131204004125.a06f7dfc.akpm@linux-foundation.org> <529EF0FB.2050808@linux.vnet.ibm.com> <20131204134838.a048880a1db9e9acd14a39e4@linux-foundation.org>
In-Reply-To: <20131204134838.a048880a1db9e9acd14a39e4@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, David Cohen <david.a.cohen@linux.intel.com>, Al Viro <viro@zeniv.linux.org.uk>, Damien Ramonda <damien.ramonda@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>

On 12/05/2013 03:18 AM, Andrew Morton wrote:
> On Wed, 04 Dec 2013 14:38:11 +0530 Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com> wrote:
>
>> On 12/04/2013 02:11 PM, Andrew Morton wrote:
> :
> :     This patch takes it all out and applies the same upper limit as is used in
> :     sys_readahead() - half the inactive list.
> :
> : +/*
> : + * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> : + * sensible upper limit.
> : + */
> : +unsigned long max_sane_readahead(unsigned long nr)
> : +{
> : +       unsigned long active;
> : +       unsigned long inactive;
> : +
> : +       get_zone_counts(&active, &inactive);
> : +       return min(nr, inactive / 2);
> : +}
>

Hi Andrew, Thanks for digging out. So it seems like earlier we had not
even considered free pages?

> And one would need to go back further still to understand the rationale
> for the sys_readahead() decision and that even predates the BK repo.
>
> iirc the thinking was that we need _some_ limit on readahead size so
> the user can't go and do ridiculously large amounts of readahead via
> sys_readahead().  But that doesn't make a lot of sense because the user
> could do the same thing with plain old read().
>

True.

> So for argument's sake I'm thinking we just kill it altogether and
> permit arbitrarily large readahead:
>
> --- a/mm/readahead.c~a
> +++ a/mm/readahead.c
> @@ -238,13 +238,12 @@ int force_page_cache_readahead(struct ad
>   }
>
>   /*
> - * Given a desired number of PAGE_CACHE_SIZE readahead pages, return a
> - * sensible upper limit.
> + * max_sane_readahead() is disabled.  It can later be removed altogether, but
> + * let's keep a skeleton in place for now, in case disabling was the wrong call.
>    */
>   unsigned long max_sane_readahead(unsigned long nr)
>   {
> -	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
> -		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
> +	return nr;
>   }
>

I had something like below in mind for posting.  But it looks
simple now with your patch.


  unsigned long max_sane_readahead(unsigned long nr)
  {
	int nid;
	unsigned long free_page = 0;

	for_each_node_state(nid, N_MEMORY)
		free_page += node_page_state(nid, NR_INACTIVE_FILE)
				+ node_page_state(nid, NR_FREE_PAGES);

	/*
	 * Readahead onto remote memory is better than no readahead when local
	 * numa node does not have memory. We sanitize readahead size depending
	 * on potential free memory in the whole system.
	 */
	return min(nr, free_page / (2 * nr_node_ids));

Or if we wanted to avoid iteration on nodes simply returning

something like nr/8  or something like that for remote numa fault cases.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
