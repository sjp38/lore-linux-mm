Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 08FD26B004F
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 16:14:07 -0400 (EDT)
Message-ID: <4A983C52.7000803@redhat.com>
Date: Fri, 28 Aug 2009 23:21:38 +0300
From: Izik Eidus <ieidus@redhat.com>
MIME-Version: 1.0
Subject: improving checksum cpu consumption in ksm
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

As you know we are using checksum (jhash) to know if page is changing 
too often, and then if it does we are not inserting it to the unstable 
tree (so it wont get unstable too much at trivial cases)

This is highly needed for ksm in some workloads - I have seen production 
visualization server that had about 74 or so giga of ram, and the way 
ksm was running there it would take ksm about 6 mins to finish one 
memory loop, In such case the hashing make sure that we will insert 
pages that are really not changing (about 6 mins) and we are protecting 
our unstable tree, without it, if we will insert any page we will end up 
with an really really unstable tree that probably wont find much.

(There is a case where we don`t calculate jhash - where we actually find 
two identical pages inside the stable tree)

So after we know why we want to keep this hash/checksum, we want to look 
how we can reduce the cpu cycles that it consume - jhash is very expensive
And not only that it take cpu cycles it also dirty the cache by walking 
over the whole page...

As for now i see 2 trivials ways how to solve it: (All we need to know 
is - what pages have been changed)
1) use the dirty bit of page tables pointing into the page:
     We can walk over the page tables, and keep cleaning the dirty bit - 
we are using anonymous pages so it shouldnt matther anyone if we clean 
the dirty bit,
     With this case we win 2 things - 1) no cpu cycles on the expensive 
jhash, and 2) no dirty of the cache
     the dissadvange of this usage is the PAGE_INVALID we need to call 
of the specific tlbs entries associate with the ptes we are clearing the 
dirty bit:
     Is it worst than dirty the cache?, is it going to really hurt 
applications performence? (note we are just tlb_flush specific entries, 
not the entire tlb)
     If this going to hurt applications pefromence we are better not to 
deal with it, but what do you think about this?

     Taking this further more we can use 'unstable dirty bit tracking' - 
if we look on ksm work loads we can split the memory into three diffrent 
kind of pages:
     a) pages that are identical
     b) pages that are not identical and keep changing all the time
     c) pages that are not identical but doesn't change

     So taking this three type of pages lets assume ksm was using the 
following way to track pages that are changing:

     Each time ksm find page that its page tables pointing to it are dirty,:
       ksm will clean the dirty bits out of the ptes (without 
INVALID_PAGE them),
       and will continue without inserting the page into the unstable tree.

     Each time ksm will find page that the page tables pointing to it 
are clean:
       ksm will calucate jhash to know if the page was changed -
       this is needed due to the fact that we cleaned the dirty bit,
       but we didnt tlb_flush the tlb entry pointing to the page,
       so we have to jhash to make sure if the page was changed.

     Now looking on the three diffrent kind of pages
     a) pages that are identical:
           would get find anyway when comparing them inside the stable tree
     b) pages that are not identical and keep changing all the time:
           Most of the chances that they will appear dirty on the pte, 
even thougth that the tlb entry was not flushed by ksm,
           If they still wont be dirty, the jhash check will be run on 
them to know if the page was changed,
           This meaning that most of the time this optimization will 
save the jhash calcualtion to this kind of pages:
           beacuse when we will see them dirty, we wont need to calcuate 
the jhash.
     c) pages that are not identical but doesn't change:
           This kind of pages will always be clean, so we will clacuate 
jhash on them like before.
  

2) Nehalem cpus with sse 4.1 have crc instruction - the good - it going 
to be faster, the bad - only Nehlem and above cpus will have it
     (Linux already have support for it)

What you think?, Or am i too much think about the cpu cycles we are 
burning with the jhash?


Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
