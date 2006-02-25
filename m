Date: Sat, 25 Feb 2006 10:24:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] [RFC] for_each_page_in_zone [1/1]
Message-Id: <20060225102443.22b5727e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1140795826.8697.86.camel@localhost.localdomain>
References: <20060224171518.29bae84b.kamezawa.hiroyu@jp.fujitsu.com>
	<1140795826.8697.86.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linux-mm@kvack.org, pavel@suse.cz, kravetz@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Fri, 24 Feb 2006 07:43:45 -0800
Dave Hansen <haveblue@us.ibm.com> wrote:

> On Fri, 2006-02-24 at 17:15 +0900, KAMEZAWA Hiroyuki wrote:
> > +struct page *next_page_in_zone(struct page *page, struct zone *zone)
> > +{
> > +       unsigned long pfn = page_to_pfn(page);
> > +
> > +       if (!populated_zone(zone))
> > +               return NULL;
> > +
> > +       pfn = next_valid_pfn(pfn, zone->zone_start_pfn + zone->spanned_pages);
> > +
> > +       if (pfn == END_PFN)
> > +               return NULL;
> > +
> > +       return pfn_to_page(pfn);
> > +} 
> 
> If there can be a case where a node spans other nodes, then I don't
> think this patch will work.  The next_valid_pfn() could be a pfn in
> another zone.  I believe that you may have to do a pfn_to_page() and
> check the zone on each one.  
> 
Oh......maybe this code is ok?
--
do {
	pfn = next_valid_pfn(pfn, zone->zone_start_pfn + zone->zone->spanned_pages);
}while(page_zone(pfn_to_page(pfn)) !-= zone);
--
I think powerpc uses SPARSEMEM when NUMA, so pfn is efficientlly skipped.


> There are some ppc64 machines which have memory laid out like this:
> 
>   0-100 MB Node0
> 100-200 MB Node1
> 200-300 MB Node0
> 
Interesting....

--Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
