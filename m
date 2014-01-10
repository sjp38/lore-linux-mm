Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 810646B0035
	for <linux-mm@kvack.org>; Fri, 10 Jan 2014 03:05:06 -0500 (EST)
Received: by mail-ee0-f53.google.com with SMTP id b57so1756447eek.12
        for <linux-mm@kvack.org>; Fri, 10 Jan 2014 00:05:05 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id b44si8423026eez.119.2014.01.10.00.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 Jan 2014 00:05:05 -0800 (PST)
Date: Fri, 10 Jan 2014 09:05:04 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC] mm: show message when updating min_free_kbytes in thp
Message-ID: <20140110080504.GA9437@dhcp22.suse.cz>
References: <20140101002935.GA15683@localhost.localdomain>
 <52C5AA61.8060701@intel.com>
 <20140103033303.GB4106@localhost.localdomain>
 <52C6FED2.7070700@intel.com>
 <20140105003501.GC4106@localhost.localdomain>
 <20140106164604.GC27602@dhcp22.suse.cz>
 <20140108101611.GD27937@dhcp22.suse.cz>
 <20140109073259.GK4106@localhost.localdomain>
 <alpine.DEB.2.02.1401091310510.31538@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1401091310510.31538@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>

On Thu 09-01-14 13:15:54, David Rientjes wrote:
> On Thu, 9 Jan 2014, Han Pingtian wrote:
> 
> > min_free_kbytes may be raised during THP's initialization. Sometimes,
> > this will change the value being set by user. Showing message will
> > clarify this confusion.
> > 
> > Only show this message when changing the value set by user according to
> > Michal Hocko's suggestion.
> > 
> > Showing the old value of min_free_kbytes according to Dave Hansen's
> > suggestion. This will give user the chance to restore old value of
> > min_free_kbytes.
> > 
> > Signed-off-by: Han Pingtian <hanpt@linux.vnet.ibm.com>
> > ---
> >  mm/huge_memory.c |    9 ++++++++-
> >  mm/page_alloc.c  |    2 +-
> >  2 files changed, 9 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> > index 7de1bf8..e0e4e29 100644
> > --- a/mm/huge_memory.c
> > +++ b/mm/huge_memory.c
> > @@ -100,6 +100,7 @@ static struct khugepaged_scan khugepaged_scan = {
> >  	.mm_head = LIST_HEAD_INIT(khugepaged_scan.mm_head),
> >  };
> >  
> > +extern int user_min_free_kbytes;
> >  
> 
> We don't add extern declarations to .c files.  How many other examples of 
> this can you find in mm/?

I have suggested this because general visibility is not needed. But if
you think that it should then include/linux/mm.h sounds like a proper
place.

> >  static int set_recommended_min_free_kbytes(void)
> >  {
> > @@ -130,8 +131,14 @@ static int set_recommended_min_free_kbytes(void)
> >  			      (unsigned long) nr_free_buffer_pages() / 20);
> >  	recommended_min <<= (PAGE_SHIFT-10);
> >  
> > -	if (recommended_min > min_free_kbytes)
> > +	if (recommended_min > min_free_kbytes) {
> > +		if (user_min_free_kbytes >= 0)
> > +			pr_info("raising min_free_kbytes from %d to %lu "
> > +				"to help transparent hugepage allocations\n",
> > +				min_free_kbytes, recommended_min);
> > +
> >  		min_free_kbytes = recommended_min;
> > +	}
> >  	setup_per_zone_wmarks();
> >  	return 0;
> >  }
> 
> Does this even ever trigger since set_recommended_min_free_kbytes() is 
> called via late_initcall()?

This is called whenever THP is enabled so it might be called later after
boot. The point is AFAIU to warn user that the admin decision about
min_free_kbytes is overridden.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
