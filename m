Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4RL0euv032198
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:00:40 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4RL0WF8626844
	for <linux-mm@kvack.org>; Tue, 27 May 2008 17:00:33 -0400
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4RL0V2V017666
	for <linux-mm@kvack.org>; Tue, 27 May 2008 15:00:32 -0600
Subject: Re: [patch 07/23] hugetlb: multi hstate sysctls
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <20080525143452.841211000@nick.local0.net>
References: <20080525142317.965503000@nick.local0.net>
	 <20080525143452.841211000@nick.local0.net>
Content-Type: text/plain; charset=UTF-8
Date: Tue, 27 May 2008 16:00:31 -0500
Message-Id: <1211922031.12036.22.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: npiggin@suse.de
Cc: linux-mm@kvack.org, kniht@us.ibm.com, andi-suse@firstfloor.org, nacc@us.ibm.com, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

On Mon, 2008-05-26 at 00:23 +1000, npiggin@suse.de wrote:
> @@ -614,8 +614,16 @@ void __init hugetlb_add_hstate(unsigned 
> 
>  static int __init hugetlb_setup(char *s)
>  {
> -	if (sscanf(s, "%lu", &default_hstate_max_huge_pages) <= 0)
> -		default_hstate_max_huge_pages = 0;
> +	unsigned long *mhp;
> +

Perhaps a one-liner comment here to remind us that !max_hstate means we
currently have only one huge page size defined, and that it is
considered the default (or compat) size, and that it gets special
treatment by using i>>?default_hstate_max_huge_pages.

> +	if (!max_hstate)
> +		mhp = &default_hstate_max_huge_pages;
> +	else
> +		mhp = &parsed_hstate->max_huge_pages;
> +
> +	if (sscanf(s, "%lu", mhp) <= 0)
> +		*mhp = 0;
> +
>  	return 1;
>  }
>  __setup("hugepages=", hugetlb_setup);

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
