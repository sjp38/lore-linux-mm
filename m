Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 6E4456B0002
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 17:13:40 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id n34so507246dal.26
        for <linux-mm@kvack.org>; Wed, 27 Feb 2013 14:13:39 -0800 (PST)
Date: Wed, 27 Feb 2013 14:13:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] mm, show_mem: suppress page counts in non-blockable
 contexts
In-Reply-To: <512E2B91.6000506@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.02.1302271410230.7155@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1302261642520.11109@chino.kir.corp.google.com> <512E2B91.6000506@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, 27 Feb 2013, Dave Hansen wrote:

> On 02/26/2013 04:46 PM, David Rientjes wrote:
> > diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
> > --- a/arch/arm/mm/init.c
> > +++ b/arch/arm/mm/init.c
> > @@ -99,6 +99,9 @@ void show_mem(unsigned int filter)
> >  	printk("Mem-info:\n");
> >  	show_free_areas(filter);
> > 
> > +	if (filter & SHOW_MEM_FILTER_PAGE_COUNT)
> > +		return;
> > +
> 
> Won't this just look like a funky truncated warning to the end user?
> 

No, because of the uninhibited call to show_free_areas() above.  This 
still dumps the pcp state, global and per-node page type breakdown, and 
free pages at given order.  The only things suppresses are the total 
pages, pages reserved, pages shared, and pages non-shared counts that are 
quite expensive to determine because it walks all memory while irqs are 
disabled and increases with the amount of RAM a system has.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
