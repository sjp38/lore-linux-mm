Message-ID: <4794C2E1.8040607@qumranet.com>
Date: Mon, 21 Jan 2008 18:05:53 +0200
From: Izik Eidus <izike@qumranet.com>
MIME-Version: 1.0
Subject: [RFC][PATCH 0/5] Memory merging driver for Linux
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kvm-devel <kvm-devel@lists.sourceforge.net>, andrea@qumranet.com, avi@qumranet.com, dor.laor@qumranet.com, linux-mm@kvack.org, yaniv@qumranet.com
List-ID: <linux-mm.kvack.org>

when kvm is used in production servers, many times it run the same 
guests operation systems more than once
the idea of this module is to find the identical pages in diffrent 
guests and to share them so we can save memory,
due to the fact that many guests run identical operation systems, alot 
of data in the ram is equal between the guests

this module find this identical data (pages) and merge them into one 
single page
this new page is write protected so in any case the guest will try to 
write to it do_wp_page will duplicate the page

this module simply go over a list of pages that were registered, and 
find the identical pages (using hash table)
the pages that it scan are anonymous, each time that it find an 
identical pages it create a file mapped
(right now it is just kernel allocated) page that will be the shared page,

as for now i am missing swapping support (will add soon using non-linear 
vmas)
 
this module can be used for every other purpuse and work without kvm
(i used it for qemu)
to make it work for kvm, the mmu notifers sent by andrea should be used

i added 2 new functions to the kernel
one:
page_wrprotect() make the page as read only by setting the ptes point to
it as read only.
second:
replace_page() - replace the pte mapping related to vm area between two 
pages

few numbers:
for started windows i can share almost the whole memory (as it zero all 
the pages),
so i can start much much more windows guests than i have memory (as long 
as no one touch it)

for linux guests i was able to share 800mb+ for 4 centos guests that 
each had 512mb memory allocated to
(again it was without work load, and they ran X)

-- 
woof.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
