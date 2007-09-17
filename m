Message-ID: <46EEB532.3060804@redhat.com>
Date: Mon, 17 Sep 2007 13:11:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: VM/VFS bug with large amount of memory and file systems?
References: <C2A8AED2-363F-4131-863C-918465C1F4E1@cam.ac.uk>	<1189850897.21778.301.camel@twins>	<20070915035228.8b8a7d6d.akpm@linux-foundation.org>	<13126578-A4F8-43EA-9B0D-A3BCBFB41FEC@cam.ac.uk> <20070917163257.331c7605@twins>
In-Reply-To: <20070917163257.331c7605@twins>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Anton Altaparmakov <aia21@cam.ac.uk>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, marc.smith@esmail.mcc.edu
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:
> On Mon, 17 Sep 2007 15:04:05 +0100 Anton Altaparmakov <aia21@cam.ac.uk>
> wrote:
> 
>> They files  
>> are attached this time rather than inlined so people don't complain  
>> about line wrapping!  (No doubt people will not complain about them  
>> being attached!  )-:)
> 
> I switched mailer after I learnt about flowed stuffs. Still,
> appreciated.
> 
>> If I read it correctly it appears all of low memory is eaten up by  
>> buffer_heads.
>>
>> <quote>
>> # name            <active_objs> <num_objs> <objsize> <objperslab>  
>> <pagesperslab>
>> : tunables <limit> <batchcount> <sharedfactor> : slabdata  
>> <active_slabs> <num_s
>> labs> <sharedavail>
>> buffer_head       12569528 12569535     56   67    1 : tunables   
>> 120   60    8 :
>> slabdata 187605 187605      0
>> </quote>
>>
>> That is 671MiB of low memory in buffer_heads.
>>
>> But why is the kernel not reclaiming them by getting rid of the page  
>> cache pages they are attached to or even leaving the pages around but  
>> killing their buffers?
> 
> Well, you see, you have this very odd configuration where:
> 
> 11GB highmem
>  1GB normal
> 
> pagecache pages go into highmem
> buggerheads go into normal
> 
> I'm guessing there is no pressure at all on zone_highmem so the
> kernel will not try to reclaim pagecache. And because the pagecache
> pages are happily sitting there, the buggerheads are pinned and do not
> get reclaimed.

I've got code for this in RHEL 3, but never bothered to
merge it upstream since I thought people with large memory
systems would be running 64 bit kernels by now.

Obviously I was wrong.  Andrew, are you interested in a
fix for this problem?

IIRC I simply kept a list of all buffer heads and walked
that to reclaim pages when the number of buffer heads is
too high (and we need memory).  This list can be maintained
in places where we already hold the lock for the buffer head
freelist, so there should be no additional locking overhead
(again, IIRC).

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
