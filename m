Received: from fujitsu2.fujitsu.com (localhost [127.0.0.1])
	by fujitsu2.fujitsu.com (8.12.10/8.12.9) with ESMTP id i5O35CNv003624
	for <linux-mm@kvack.org>; Wed, 23 Jun 2004 20:05:12 -0700 (PDT)
Date: Wed, 23 Jun 2004 20:04:48 -0700
From: Yasunori Goto <ygoto@us.fujitsu.com>
Subject: Re: [Lhns-devel] Merging Nonlinear and Numa style memory hotplug
In-Reply-To: <1088029973.28102.269.camel@nighthawk>
References: <20040622114733.30A6.YGOTO@us.fujitsu.com> <1088029973.28102.269.camel@nighthawk>
Message-Id: <20040623184303.25D9.YGOTO@us.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel ML <linux-kernel@vger.kernel.org>, Linux Hotplug Memory Support <lhms-devel@lists.sourceforge.net>, Linux-Node-Hotplug <lhns-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, "BRADLEY CHRISTIANSEN [imap]" <bradc1@us.ibm.com>
List-ID: <linux-mm.kvack.org>

> This quadruples the size of the mem_section[] array, and makes each
> mem_section entry take up a whole cache line.  Are you sure all of these
> structure members are needed?  

No, I'm not sure. Especially, I don't find whether hotremovable
attribute is necessary or not in the mem_section yet.

> Can they be allocated elsewhere, instead
> of directly inside the translation tables, or otherwise derived?  Also,
> why does the booked/free_count have to be kept here?  Can't that be
> determined by simply looping through and looking at all the pages'
> flags?

It might be OK. But there might be some other influence by it 
(for example, new lock will be necessary in alloc_pages()...).
I think measurement is necessary to find which implementation
is the fastest. If I will have a time, I would like to try it.

> Also, can you provide a patch which is just your modifications to Dave's
> original nonlinear patch?

No, I don't have it (at least now).
Base of my patches is Iwamoto-san's patch which is for 2.6.5.
But Dave-san's patch is for linux-2.6.5-mm. So, I had to change
Dave-san's patch for it.

And, other difference thing is about mem_map.
Dave-san's patch divides virtual address of mem_map per mem_section.
But it is cause of increasing steps at 'buddy allocator' like this.
  
  - buddy1 = base + (page_idx ^ -mask);
  - buddy2 = base + page_idx;
  + buddy1 = pfn_to_page(base + (page_idx ^ -mask);
  + buddy2 = pfn_to_page(base + page_idx);

So, I would like to try contiguous virtual mem_map yet,
if it is possible.

> Instead of remove_from_freelist(unsigned int section), I'd hope that we
> could support a much more generic interface in the page allocator:
> allocate by physical address.  remove_from_freelist() has some intimate
> knowledge of the buddy allocator that I think is a bit complex.  

I don't think I understand your idea at this point.
If booked pages remain in free_list, page allocator has to
search many pages which include booked pages.
remove_from_reelist() is to avoid this.

Thank you for your responce.

Bye.

-- 
Yasunori Goto <ygoto at us.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
