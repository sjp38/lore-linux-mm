Message-ID: <41D9A7DB.2020306@sgi.com>
Date: Mon, 03 Jan 2005 14:15:23 -0600
From: Ray Bryant <raybry@sgi.com>
MIME-Version: 1.0
Subject: Re: page migration
References: <41D98556.8050605@sgi.com> <1104776733.25994.11.camel@localhost>	 <41D99743.5000601@sgi.com> <1104781061.25994.19.camel@localhost>
In-Reply-To: <1104781061.25994.19.camel@localhost>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Dave Hansen wrote:

> 
> I was going to do hotplug first only because it created a requirement
> for migration.  Since you have a separate requirement for it, I have no
> objection to doing migration first.  
>

Cool.

> 
>>Of course, the "standalone" memory migration stuff makes most sense on NUMA, 
>>and there is some minor interface changes there to support that (i. e. consider:
>>
>>migrate_onepage(page);
>>
>>vs
>>
>>migrate_onepage_node(page, node);
>>
>>what the latter does is to call alloc_pages_node() instead of
>>page_cache_alloc() to get the new page.)
> 
> 
> We might as well just change all of the users over to the NUMA version
> from the start.  Having 2 different functions just causes confusion.  
> 

Yes, especially since alloc_pages_node() is defined regardless of whether
NUMA is defined (I've found out by some code inspection).  So in the
non-DISCONTIGMEM cases, the node argument would just be ignored.  I'll
put together a patch that moves the interface over to

migrate_onepage(page, node)

and fixes up the callers in the memory hotplug patches.

> 
>>This is all to support NUMA process and memory migration, where the
>>required function is to move a process >>and<< its memory from one
>>set of nodes to another.  (I should have a patch for these initial
>>interface changes later this week.)
> 
> 
> Well, moving the process itself isn't very hard, right?  That's just a
> schedule().  
> 

Yes, that's the easy part.  :-)

<snip>
> 
> 
> Anyway, I'd love to see a simpler version if it's possible.  I'd just
> keep Marcello and Hirokazu in the loop if you're going to try. 
> 
> -- Dave
> 
> 

If the consensus is that the correct way to go is to propose the
memory migration patches as they are, then that is fine by me.  I will
get my "NUMA process and memory migration" patch working on top of that
(so that we have a user) and then work with Andrew to get them into -mm
and then see what happens from there.

-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
