Message-ID: <47E9CE00.7060106@fc.hp.com>
Date: Tue, 25 Mar 2008 22:16:00 -0600
From: John Marvin <jsm@fc.hp.com>
MIME-Version: 1.0
Subject: Re: larger default page sizes...
References: <Pine.LNX.4.64.0803241402060.7762@schroedinger.engr.sgi.com>	<20080324.144356.104645106.davem@davemloft.net>	<Pine.LNX.4.64.0803251045510.16206@schroedinger.engr.sgi.com>	<20080325.162244.61337214.davem@davemloft.net>	<87tziu5q37.wl%peter@chubb.wattle.id.au>	<ed5aea430803251734u70f199w10951bc4f0db6262@mail.gmail.com> <87lk465mks.wl%peter@chubb.wattle.id.au>
In-Reply-To: <87lk465mks.wl%peter@chubb.wattle.id.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-ia64@vger.kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Peter Chubb wrote:

> 
> You end up having to repeat PTEs to fit into Linux's page table
> structure *anyway* (unless we can change Linux's page table).  But
> there's no place in the short format hardware-walked page table (that
> reuses the leaf entries in Linux's table) for a page size.  And if you
> use some of the holes in the format, the hardware walker doesn't
> understand it --- so you have to turn off the hardware walker for
> *any* regions where there might be a superpage.  

No, you can set an illegal memory attribute in the pte for any superpage entry, 
and leave the hardware walker enabled for the base page size. The software tlb 
miss handler can then install the superpage tlb entry. I posted a working 
prototype of Shimizu superpages working on ia64 using short format vhpt's to the 
linux kernel list a while back.

> 
> If you use the long format VHPT, you have a choice:  load the
> hash table with just the translation that caused the miss, load all
> possible hash entries that could have caused the miss for the page, or
> preload the hash table when the page is instantiated, with all
> possible entries that could hash to the huge page.  I don't remember
> the details, but I seem to remember all these being bad choices for
> one reason or other ... Ian, can you elaborate?

When I was doing measurements of long format vs. short format, the two main 
problems with long format (and why I eventually chose to stick with short 
format) were:

1) There was no easy way of determining what size the long format vhpt cache 
should be automatically, and changing it dynamically would be too painful. 
Different workloads performed better with different size vhpt caches.

2) Regardless of the size, the vhpt cache is duplicated information. Using long 
format vhpt's significantly increased the number of cache misses for some 
workloads. Theoretically there should have been some cases where the long format 
solution would have performed better than the short format solution, but I was 
never able to create such a case. In many cases the performance difference 
between the long format solution and the short format solution was essentially 
the same. In other cases the short format vhpt solution outperformed the long 
format solution, and in those cases there was a significant difference in cache 
misses that I believe explained the performance difference.

John

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
