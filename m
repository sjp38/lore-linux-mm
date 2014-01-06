Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 4D99C6B0031
	for <linux-mm@kvack.org>; Mon,  6 Jan 2014 11:46:12 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so7894163eek.35
        for <linux-mm@kvack.org>; Mon, 06 Jan 2014 08:46:11 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l2si84742352een.83.2014.01.06.08.46.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jan 2014 08:46:07 -0800 (PST)
Date: Mon, 6 Jan 2014 17:46:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140106164604.GC27602@dhcp22.suse.cz>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140105003501.GC4106@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Sun 05-01-14 08:35:01, Han Pingtian wrote:
[...]
> From f4d085a880dfae7638b33c242554efb0afc0852b Mon Sep 17 00:00:00 2001
> From: Han Pingtian <hanpt@linux.vnet.ibm.com>
> Date: Fri, 3 Jan 2014 11:10:49 +0800
> Subject: [PATCH] mm: show message when raising min_free_kbytes in THP
> 
> min_free_kbytes may be raised during THP's initialization. Sometimes,
> this will change the value being set by user. Showing message will
> clarify this confusion.

I do not have anything against informing about changing value
set by user but this will inform also when the default value is
updated. Is this what you want? Don't you want to check against
user_min_free_kbytes? (0 if not set by user)

Btw. Do we want to restore the original value when khugepaged is
disabled?

> Showing the old value of min_free_kbytes according to Dave Hansen's
> suggestion. This will give user the chance to restore old value of
> min_free_kbytes.
> 
> Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>
> ---
>  mm/huge_memory.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 7de1bf8..7910360 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -130,8 +130,12 @@ static int set_recommended_min_free_kbytes(void)
>  			      (unsigned long) nr_free_buffer_pages() / 20);
>  	recommended_min <<= (PAGE_SHIFT-10);
>  
> -	if (recommended_min > min_free_kbytes)
> +	if (recommended_min > min_free_kbytes) {
> +		pr_info("raising min_free_kbytes from %d to %d "
> +			"to help transparent hugepage allocations\n",
> +			min_free_kbytes, recommended_min);
>  		min_free_kbytes = recommended_min;
> +	}
>  	setup_per_zone_wmarks();
>  	return 0;
>  }
> -- 
> 1.7.7.6
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
