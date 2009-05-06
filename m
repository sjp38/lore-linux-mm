Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8B14E6B003D
	for <linux-mm@kvack.org>; Wed,  6 May 2009 02:43:38 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so3965908qwk.44
        for <linux-mm@kvack.org>; Tue, 05 May 2009 23:44:17 -0700 (PDT)
Date: Wed, 6 May 2009 10:44:10 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH -mmotm] mm: init_per_zone_pages_min - get rid of sqrt
	call on small machines
Message-ID: <20090506064410.GB4865@lenovo>
References: <20090506061953.GA16057@lenovo> <alpine.DEB.2.00.0905052334391.9824@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0905052334391.9824@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LMMML <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

[David Rientjes - Tue, May 05, 2009 at 11:36:38PM -0700]
| On Wed, 6 May 2009, Cyrill Gorcunov wrote:
| 
| > Index: linux-2.6.git/mm/page_alloc.c
| > =====================================================================
| > --- linux-2.6.git.orig/mm/page_alloc.c
| > +++ linux-2.6.git/mm/page_alloc.c
| > @@ -4610,11 +4610,15 @@ static int __init init_per_zone_pages_mi
| >  
| >  	lowmem_kbytes = nr_free_buffer_pages() * (PAGE_SIZE >> 10);
| >  
| > -	min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
| > -	if (min_free_kbytes < 128)
| > +	/* for small values we may eliminate sqrt operation completely */
| > +	if (lowmem_kbytes < 1024)
| >  		min_free_kbytes = 128;
| > -	if (min_free_kbytes > 65536)
| > -		min_free_kbytes = 65536;
| > +	else {
| > +		min_free_kbytes = int_sqrt(lowmem_kbytes * 16);
| > +		if (min_free_kbytes > 65536)
| > +			min_free_kbytes = 65536;
| > +	}
| > +
| >  	setup_per_zone_pages_min();
| >  	setup_per_zone_lowmem_reserve();
| >  	setup_per_zone_inactive_ratio();
| 
| For a function that's called once, this just isn't worth it.  int_sqrt() 
| isn't expensive enough to warrant the assault on the readability of the 
| code.
| 

ok, then we could just drop it.

	-- Cyrill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
