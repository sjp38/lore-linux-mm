Message-ID: <38F048F5.1FABC033@colorfullife.com>
Date: Sun, 09 Apr 2000 11:10:13 +0200
From: Manfred Spraul <manfreds@colorfullife.com>
MIME-Version: 1.0
Subject: Re: zap_page_range(): TLB flush race
References: <E12e4mo-0003Pn-00@the-village.bc.nu>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, torvalds@transmeta.com, davem@redhat.com
List-ID: <linux-mm.kvack.org>

Alan Cox wrote:
> 
> 
> Basically establish_pte() has to be architecture specific, as some processors
> need different orders either to avoid races or to handle cpu specific
> limitations.
> 
I don't know: IMHO we have far to many architecture specific functions
in that area:

set_pte()
establish_pte()

flush_tlb()
update_mmu_cache();
flush_cache();
flush_icache();

Can't we merge them? 

<< 1)
set_pte(vma,pte,new_val);
	* flushes the cache, changes one pte, updates the tlb.
<< 2)
set_pte_new(vma,pte,new_val);
	* sets the pte, the old value was non-present. Most cpu
	  don't need to flush the tlb. (2.3.99 never flushes the tlb)
<< 3)
prepare_ptechange_{range,mm}(vma,start,end);
for()
	__set_pte(vma,pte,new_val);
commit_ptechange_{range,mm}(vma,start,end);
	*  should be used if you change multiple pages.
<<<<<<<<<
	
I don't understand the purpose of flush_page_to_ram():
filemap_sync_pte() calls it if MS_INVALIDATE is not set, it's not called
if MS_INVALIDATE is set.
In both cases, the kernel pointer is accessed in filemap_write_page().

--
	Manfred

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
