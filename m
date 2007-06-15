Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l5FFkmeU026549
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 11:46:48 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l5FFkm6r254134
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 09:46:48 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l5FFkldX003260
	for <linux-mm@kvack.org>; Fri, 15 Jun 2007 09:46:47 -0600
Subject: Re: [RFC] memory unplug v5 [4/6] page isolation
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <20070614160321.59314758.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	 <20070614160321.59314758.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 15 Jun 2007 08:46:45 -0700
Message-Id: <1181922406.28189.25.camel@spirit>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, clameter@sgi.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-14 at 16:03 +0900, KAMEZAWA Hiroyuki wrote:
> +#ifdef CONFIG_HOLES_IN_ZONE
> +static inline struct page *
> +__first_valid_page(unsigned long pfn, unsigned long nr_page)
> +{
> +	int i;
> +	struct page *page;
> +	for (i = 0; i < nr_page; i++)
> +		if (pfn_valid_within(pfn + i))
> +			break;
> +	if (unlikely(i == nr_pages))
> +		return NULL;
> +	return pfn_to_page(pfn + i);
> +}
> +#else
> +static inline struct page *
> +__first_valid_page(unsigned long pfn, unsigned long nr_page)
> +{
> +	return pfn_to_page(pfn);
> +}
> +#endif

I think this entire #ifdef is unneeded.  pfn_valid_within() will be
#defined to 1 if CONFIG_HOLES_IN_ZONE=n, so that function will come out
looking like this:

+__first_valid_page(unsigned long pfn, unsigned long nr_page)
> +{
> +	int i;
> +	struct page *page;
> +	for (i = 0; i < nr_page; i++)
> +		if (1)
> +			break;
> +	if (unlikely(i == nr_pages))
> +		return NULL;
> +	return pfn_to_page(pfn + i);
> +}

I think the compiler can optimize that. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
