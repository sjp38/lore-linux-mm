Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 866C96B01AC
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 02:12:43 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o666CdKX030891
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 6 Jul 2010 15:12:40 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E66245DE6F
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:12:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 508EE45DE6E
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:12:39 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 34E301DB803E
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:12:39 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D28CF1DB803A
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 15:12:38 +0900 (JST)
Date: Tue, 6 Jul 2010 15:07:46 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Need some help in understanding sparsemem.
Message-Id: <20100706150746.bc3daa86.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
References: <AANLkTil6go0otCsBkG_detjptXX_i_mNkkCMawLVIz82@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: naren.mehra@gmail.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 6 Jul 2010 10:41:06 +0530
naren.mehra@gmail.com wrote:

> Hi,
> 
> I am trying to understand the sparsemem implementation in linux for
> NUMA/multiple node systems.
> 
> From the available documentation and the sparsemem patches, I am able
> to make out that sparsemem divides memory into different sections and
> if the whole section contains a hole then its marked as invalid
> section and if some pages in a section form a hole then those pages
> are marked reserved. My issue is that this classification, I am not
> able to map it to the code.
> 
> e.g. from arch specific code, we call memory_present()  to prepare a
> list of sections in a particular node. but unable to find where
> exactly some sections are marked invalid because they contain a hole.
> 
> Can somebody tell me where in the code are we identifying sections as
> invalid and where we are marking pages as reserved.
> 

As you wrote, memory_present() is just for setting flags 
"SECTION_MARKED_PRESENT". If a section contains both of valid pages and
holes, the section itself is marked as SECTION_MARKED_PRESENT.

This memory_present() is called in very early stage. The function which allocates
mem_map(array of struct page) is sparse_init(). It's called somewhere after
memory_present().
(In x86, it's called by paging_init(), in ARM, it's called by bootmem_init()).

After sparse_init(), mem_maps are allocated. (depends on config..plz see codes.)
But, here, mem_map is not initialized.
This is because initialization logic of memmap doesn't depend on
FLATMEM/DISCONTIGMEM/SPARSEMEM.

After sprase_init(), mem_map is allocated. It's not encouraged to detect a section
is valid or invalid but you can use pfn_valid() to check there are memmap or not.
(*) pfn_valid(pfn) is not for detecting there is memory but for detecting
    there is memmap.

Initializing mem_map is done by free_area_init_node(). This function initializes
memory range regitered by add_active_range() (see mm/page_alloc.c)
(*)There are architecutures which doesn't use add_active_range(), but this function
   is for generic use.

After free_area_init_node(), all mem_map are initialized as PG_reserved and
NODE_DATA(nid)->star_pfn, etc..are available.

When PG_reserved is cleared is at free_all_bootmem(). If you want to keep pages
as Reserved (because of holes), OR, don't register memory hole as bootmem.
Then, pages will be kept as Reserved.

clarification:
 memory_present().... prepare for section[] and mark up PRESENT.
 sparse_init()   .... allocates mem_map. but just allocates it.
 free_area_init_node() .... initizalize mem_map at el.
 free_all_bootmem() .... make pages available and put into buddy allocator.

 pfn_valid() ... useful for checking there are mem_map.
 
 How to make pages kept as Reserved ....
                         reserve bootmem or not register to bootmem.

All aboves may depend on CONFIG, I hope this can be a hint for you.

Hmm. unexpectedly long..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
