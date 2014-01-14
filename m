Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 504CB6B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:52:45 -0500 (EST)
Received: by mail-pd0-f169.google.com with SMTP id v10so329402pde.0
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 15:52:44 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id eb3si1865707pbc.326.2014.01.14.15.52.43
        for <linux-mm@kvack.org>;
        Tue, 14 Jan 2014 15:52:44 -0800 (PST)
Date: Tue, 14 Jan 2014 15:52:41 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-Id: <20140114155241.7891fce1fb2b9dfdcde15a8c@linux-foundation.org>
In-Reply-To: <20140114200720.GM4106@localhost.localdomain>
References: <52C5AA61.8060701@intel.com>
	<20140103033303.GB4106@localhost.localdomain>
	<52C6FED2.7070700@intel.com>
	<20140105003501.GC4106@localhost.localdomain>
	<20140106164604.GC27602@dhcp22.suse.cz>
	<20140108101611.GD27937@dhcp22.suse.cz>
	<20140110081744.GC9437@dhcp22.suse.cz>
	<20140114200720.GM4106@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Han Pingtian <hanpt@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Wed, 15 Jan 2014 04:07:20 +0800 Han Pingtian <hanpt@linux.vnet.ibm.com> wrote:

> min_free_kbytes may be raised during THP's initialization. Sometimes,
> this will change the value being set by user. Showing message will
> clarify this confusion.
> 
> Only show this message when changing the value set by user according to
> Michal Hocko's suggestion.
> 
> Showing the old value of min_free_kbytes according to Dave Hansen's
> suggestion. This will give user the chance to restore old value of
> min_free_kbytes.
> 

This is all a bit nasty, isn't it?  THP goes and alters min_free_kbytes
to improve its own reliability, but min_free_kbytes is also
user-modifiable.  And over many years we have trained a *lot* of users
to alter min_free_kbytes.  Often to prevent nasty page allocation
failure warnings from net drivers.

So there are probably quite a lot of people out there who are manually
rubbing out THP's efforts.  And there may also be people who are
setting min_free_kbytes to a value which is unnecessarily high for more
recent kernels.

I don't know what to do about this mess though :(

> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -130,8 +130,14 @@ static int set_recommended_min_free_kbytes(void)
>  			      (unsigned long) nr_free_buffer_pages() / 20);
>  	recommended_min <<= (PAGE_SHIFT-10);
>  
> -	if (recommended_min > min_free_kbytes)
> +	if (recommended_min > min_free_kbytes) {
> +		if (user_min_free_kbytes >= 0)
> +			pr_info("raising min_free_kbytes from %d to %lu "
> +				"to help transparent hugepage allocations\n",
> +				min_free_kbytes, recommended_min);

hm, recommended_min shouldn't have had long type.  Oh well, we've done
worse things.

>  		min_free_kbytes = recommended_min;
> +	}
>  	setup_per_zone_wmarks();
>  	return 0;
>  }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
