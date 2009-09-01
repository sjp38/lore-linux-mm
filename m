Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C6F3F6B004D
	for <linux-mm@kvack.org>; Tue,  1 Sep 2009 08:04:58 -0400 (EDT)
Message-ID: <4A9D0FA4.8030808@redhat.com>
Date: Tue, 01 Sep 2009 15:12:20 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: Re: improving checksum cpu consumption in ksm
References: <4A983C52.7000803@redhat.com> <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
In-Reply-To: <Pine.LNX.4.64.0908312233340.23516@sister.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
>
> But the first thing to try (measure) would be Jozsef's patch, updating
> jhash.h from the 1996 Jenkins lookup2 to the 2006 Jenkins lookup3,
> which is supposed to be a considerable improvement from all angles.
>
> See http://lkml.org/lkml/2009/2/12/65
>   

I will check this one.

>
> Three, that if we go in this direction, might it be even better to make
> the unstable tree stable? i.e. write protect its contents so that we're
> sure a node cannot be poisoned with modified data.  It may be
> immediately obvious to you that that's a terrible suggestion (all the
> overhead of the write faults), but it's not quite obvious to me yet.
>   

It was one of the early thoughts about how to write the new ksm -
checking if page checksum was not changed, and if it didn't - write 
protect it and insert it to the tree.
The problem is: every kvm guest that would be idle all its memory will 
become read only,
In such cases performance of kvm guests will get hurt, when they are 
using ksm.
(I believe it better to burn more cpu cycles from the ksm side, than 
hurting the users of it.)

> I expect a lot depends on the proportions of pages_shared, pages_sharing,
> pages_unshared, pages_volatile.  But as I've said before, I've no
> feeling yet (or ever?) for the behaviour of the unstable tree: for
> example, I've no grasp of whether a large unstable tree is inherently
> less stable (more likely to be seriously poisoned) than a small one,
> or not.
>   

Yesterday I logged into account that had 94gigas of ram to ksm to scan,
It seems like it performed very well there, the trick is this:

the bigger the memory is, the more time it take ksm to finish the memory 
scanning loop - we will insert pages that didnt changed for about 8 mins 
in such systems...

So from this side we are quite safe, (and we have the stable tree 
exactly to solve the left issues of the unstable tree , the only task of 
the unstable tree is to build the stable tree)
(It is exactly the same proportion for small systems and big systems, in 
unstable tree that have 1 giga of ram there are 1/2 pages to get 
corrupted than in unstable tree that have 2 giga of ram, however the 
pages inside the unstable tree that have 2 giga of ram have 1/2 less 
chances to get corrupted (because their jhash content was left the same 
for x2 the time)

The worst case for big unstable tree is - if node near the root become 
invalid - the chances for this are 2 ^ n - 1, and this is exactly why we 
keep rebuilding it (for such bad lucks)

Actually another nice thing to note is: when page is changed only 50% it 
will become invalid, beacuse in sorted tree we are just care if "page 1" 
is bigger than "page 2"
so if "page 2" was bigger than "page 1" and then "page 2" was changed 
but is still bigger than "page 1" then the unstable tree is still valid...

As for now I dont think I found workload the the hash table version 
found more pages in it.

>   
>>     Taking this further more we can use 'unstable dirty bit tracking' - if we
>> look on ksm work loads we can split the memory into three diffrent kind of
>> pages:
>>     a) pages that are identical
>>     b) pages that are not identical and keep changing all the time
>>     c) pages that are not identical but doesn't change
>>
>>     So taking this three type of pages lets assume ksm was using the following
>> way to track pages that are changing:
>>
>>     Each time ksm find page that its page tables pointing to it are dirty,:
>>       ksm will clean the dirty bits out of the ptes (without INVALID_PAGE
>> them),
>>       and will continue without inserting the page into the unstable tree.
>>
>>     Each time ksm will find page that the page tables pointing to it are
>> clean:
>>       ksm will calucate jhash to know if the page was changed -
>>       this is needed due to the fact that we cleaned the dirty bit,
>>       but we didnt tlb_flush the tlb entry pointing to the page,
>>       so we have to jhash to make sure if the page was changed.
>>     
>
> Interesting.  At first I thought that sounded like a worst of all
> worlds solution, but perhaps not: the proportions might make that
> a very sensible approach.
>
> But playing with the pte dirty bit without flushing TLB is a dangerous
> game: you run the risk that MM will catch it at a moment when it looks
> clean and free it.  We could, I suppose, change MM to assume that anon
> pages are dirty in VM_MERGEABLE areas; but it feels too early for the
> KSM tail to be wagging the MM dog in such a way.
>   

Agree.


>> ot flushed by ksm,
>>           If they still wont be dirty, the jhash check will be run on them to
>> know if the page was changed,
>>           This meaning that most of the time this optimization will save the
>> jhash calcualtion to this kind of pages:
>>           beacuse when we will see them dirty, we wont need to calcuate the
>> jhash.
>>     c) pages that are not identical but doesn't change:
>>           This kind of pages will always be clean, so we will clacuate jhash
>> on them like before.
>>  
>>
>> 2) Nehalem cpus with sse 4.1 have crc instruction - the good - it going to be
>> faster, the bad - only Nehlem and above cpus will have it
>>     (Linux already have support for it)
>>     
>
> Sounds perfectly sensible to use hardware CRC where it's available;
> I expect other architectures have models which support CRC too.
>
> Assuming the characteristics of the hardware CRC are superior to
> or close enough to the characteristics of the jhash - I'm entirely
> ignorant of CRCs and hashing matters, perhaps nobody would put a 
> CRC into their hardware unless it was good enough (but good enough
> for what purpose?).
>   

I did test it with CRC, simple naive test showed no difference from the 
point of "how unstable the unstable tree is.
I will look on it after 2.6.32

>   
>> What you think?, Or am i too much think about the cpu cycles we are burning
>> with the jhash?
>>     
>
> I do think KSM burns a lot of CPU; but whether it's the jhash or
> whether it's all the other stuff (page table walking, radix tree
> walking, memcmping) I've not looked.
>   

Jhash is just one of the problem agree, there is a way to make the trees 
memcping faster and less cpu intensive as well, but i will keep it for 
another mail (not in the near future...).

Thanks for the response Hugh.

> Hugh
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
