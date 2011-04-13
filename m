Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 85F42900086
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 15:05:10 -0400 (EDT)
Received: from hpaq12.eem.corp.google.com (hpaq12.eem.corp.google.com [172.25.149.12])
	by smtp-out.google.com with ESMTP id p3DJ53A3021607
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:05:03 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by hpaq12.eem.corp.google.com with ESMTP id p3DJ2xvF008602
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:05:02 -0700
Received: by pvg13 with SMTP id 13so456172pvg.40
        for <linux-mm@kvack.org>; Wed, 13 Apr 2011 12:05:01 -0700 (PDT)
Date: Wed, 13 Apr 2011 12:04:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/thp: Use conventional format for boolean attributes
In-Reply-To: <1300772711.26693.473.camel@localhost>
Message-ID: <alpine.DEB.2.00.1104131202230.5563@chino.kir.corp.google.com>
References: <1300772711.26693.473.camel@localhost>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Ben Hutchings <ben@decadent.org.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

On Tue, 22 Mar 2011, Ben Hutchings wrote:

> The conventional format for boolean attributes in sysfs is numeric
> ("0" or "1" followed by new-line).  Any boolean attribute can then be
> read and written using a generic function.  Using the strings
> "yes [no]", "[yes] no" (read), "yes" and "no" (write) will frustrate
> this.
> 
> Cc'd to stable in order to change this before many scripts depend on
> the current strings.
> 

I agree with this in general, it's certainly the standard way of altering 
a boolean tunable throughout the kernel so it would be nice to use the 
same userspace libraries with THP.

Let's cc Andrew on this since it will go through the -mm tree if it's 
merged.

> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> Cc: stable@kernel.org [2.6.38]
> ---
>  mm/huge_memory.c |   21 +++++++++++----------
>  1 files changed, 11 insertions(+), 10 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 113e35c..dc0b3f0 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -244,24 +244,25 @@ static ssize_t single_flag_show(struct kobject *kobj,
>  				struct kobj_attribute *attr, char *buf,
>  				enum transparent_hugepage_flag flag)
>  {
> -	if (test_bit(flag, &transparent_hugepage_flags))
> -		return sprintf(buf, "[yes] no\n");
> -	else
> -		return sprintf(buf, "yes [no]\n");
> +	return sprintf(buf, "%d\n",
> +		       test_bit(flag, &transparent_hugepage_flags));
>  }
>  static ssize_t single_flag_store(struct kobject *kobj,
>  				 struct kobj_attribute *attr,
>  				 const char *buf, size_t count,
>  				 enum transparent_hugepage_flag flag)
>  {
> -	if (!memcmp("yes", buf,
> -		    min(sizeof("yes")-1, count))) {
> +	unsigned long value;
> +	char *endp;
> +
> +	value = simple_strtoul(buf, &endp, 0);
> +	if (endp == buf || value > 1)
> +		return -EINVAL;
> +
> +	if (value)
>  		set_bit(flag, &transparent_hugepage_flags);
> -	} else if (!memcmp("no", buf,
> -			   min(sizeof("no")-1, count))) {
> +	else
>  		clear_bit(flag, &transparent_hugepage_flags);
> -	} else
> -		return -EINVAL;
>  
>  	return count;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
