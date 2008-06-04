Message-ID: <484662E3.40902@brontes3d.com>
Date: Wed, 04 Jun 2008 10:39:47 +0100
From: Daniel Drake <ddrake@brontes3d.com>
MIME-Version: 1.0
Subject: Re: faulting kmalloced buffers into userspace through mmap()
References: <4842B4C3.1070506@brontes3d.com> <87mym4tmz0.fsf@saeurebad.de>
In-Reply-To: <87mym4tmz0.fsf@saeurebad.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Johannes Weiner <hannes@saeurebad.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Johannes,

Johannes Weiner wrote:
> You broke the abstraction here.  There are no pages from kmalloc(), it
> gives you other memory objects.  And on munmapping the region, the
> kmalloc objects are passed back to the buddy allocator which then blows
> the whistle with bad_page() on it.

Thanks for the explanation, I attempted to document this here:
http://linux-mm.org/DeviceDriverMmap
Comments/edits are welcome!

One more quick question: if pages that were mapped are "passed back to 
the buddy allocator" during munmap() does that mean that the pages get 
freed too?

i.e. if I allocate some pages with alloc_pages(), remap them into 
userspace in my VM .fault handler, and then userspace munmaps them, is 
it still legal for my driver to use those pages internally after the 
munmap? Do I still need to call __free_pages() on them when done?


Also, it is possible to get the physical address of a kmalloc region 
with virt_to_phys(). Is it also illegal to pass this physical address to 
remap_pfn_range() to implement mmap in that fashion? Can't find any 
in-kernel code that does this, but google brings up a few hits such as 
http://www.opentech.at/papers/embedded_resources/node21.html

Thanks!
-- 
Daniel Drake
Brontes Technologies, A 3M Company
http://www.brontes3d.com/opensource/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
