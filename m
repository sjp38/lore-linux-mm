Date: Wed, 12 Sep 2007 22:28:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] overwride page->mapping [0/3] intro
Message-Id: <20070912222809.3c972cb3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <46E7A666.7080409@linux.vnet.ibm.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
	<46E7A666.7080409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, nickpiggin@yahoo.com.au, clameter@sgi.com, Lee.Schermerhorn@hp.com, akpm@linux-foundation.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Sep 2007 14:12:14 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > In general, we cannot inclease size of 'struct page'. So, overriding and
> > adding prural meanings to page struct's member is done in many situation.
> > 
> 
> Hi, Kamezawa,
> 
> We discussed the struct page size issue at VM summit. If I remember
> correctly, Linus suggested that we consider using pfn's instead of
> pointers for pointer members in struct page.
> 
Hmm, define something like this ?
==
#define page_cointainer_for_pfn(pfn)      some_routine
==

> > But to do some kind of precise VM mamangement, page struct itself seems to be
> > too small. This patchset overrides page->mapping and add on-demand page
> > information.
> > 
> > like this:
> > 
> > ==
> > page->mapping points to address_space or anon_vma or mapping_info
> > 
> 
> Could you elaborate a little here, on what is the basis to decide
> what page->mapping should point to?

- page->mapping & 0x3 == 0   -> address_space
- page->mapping & 0x3 == 0x2 -> mapping_info (points to address_space)
- page->mapping & 0x3 == 0x1 -> anon_vma
- page->mapping & 0x3 == 0x3 -> mapping_info (points to anon_vma)



> 
> > mapping_info is strucutured as 
> > 
> > struct mapping_info {
> > 	union {
> > 		anon_vma;
> > 		address_space;
> > 	};
> > 	/* Additional Information to this page */
> > };
> > 
> > ==
> > This works based on "adding page->mapping interface" patch set, I posted.
> > 
> > My main target is move page_container information to this mapping_info.
> > By this, we can avoid increasing size of struct page when container is used.
> > 
> 
> I am not against this goal, but wouldn't we end up with too many
> dereferences to get to the container?
> i.e, page->mapping->page_container->mem_container.
> 
I'm now thinling like this.
==
>From : page->container -> mem_contnainer.
To   : page->mapping_info.container -> mem_container
==                     ^^^^^


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
