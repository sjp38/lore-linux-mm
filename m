Message-ID: <4463EA16.5090208@cyberone.com.au>
Date: Fri, 12 May 2006 11:51:18 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/3] tracking dirty pages in shared mappings -V4
References: <1146861313.3561.13.camel@lappy>	<445CA22B.8030807@cyberone.com.au>	<1146922446.3561.20.camel@lappy>	<445CA907.9060002@cyberone.com.au>	<1146929357.3561.28.camel@lappy>	<Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>	<1147116034.16600.2.camel@lappy>	<Pine.LNX.4.64.0605082234180.23795@schroedinger.engr.sgi.com>	<1147207458.27680.19.camel@lappy> <20060511080220.48688b40.akpm@osdl.org>
In-Reply-To: <20060511080220.48688b40.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, clameter@sgi.com, torvalds@osdl.org, ak@suse.de, rohitseth@google.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Andrew Morton wrote:

>Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
>>
>>From: Peter Zijlstra <a.p.zijlstra@chello.nl>
>>
>>People expressed the need to track dirty pages in shared mappings.
>>
>>Linus outlined the general idea of doing that through making clean
>>writable pages write-protected and taking the write fault.
>>
>>This patch does exactly that, it makes pages in a shared writable
>>mapping write-protected. On write-fault the pages are marked dirty and
>>made writable. When the pages get synced with their backing store, the
>>write-protection is re-instated.
>>
>>It survives a simple test and shows the dirty pages in /proc/vmstat.
>>
>
>It'd be nice to have more that a "simple test" done.  Bugs in this area
>will be subtle and will manifest in unpleasant ways.  That goes for both
>correctness and performance bugs.
>
>
>>Index: linux-2.6/mm/memory.c
>>===================================================================
>>--- linux-2.6.orig/mm/memory.c	2006-05-08 18:49:39.000000000 +0200
>>+++ linux-2.6/mm/memory.c	2006-05-09 09:15:11.000000000 +0200
>>@@ -49,6 +49,7 @@
>> #include <linux/module.h>
>> #include <linux/init.h>
>> #include <linux/mm_page_replace.h>
>>+#include <linux/backing-dev.h>
>> 
>> #include <asm/pgalloc.h>
>> #include <asm/uaccess.h>
>>@@ -2077,6 +2078,7 @@ static int do_no_page(struct mm_struct *
>> 	unsigned int sequence = 0;
>> 	int ret = VM_FAULT_MINOR;
>> 	int anon = 0;
>>+	struct page *dirty_page = NULL;
>> 
>> 	pte_unmap(page_table);
>> 	BUG_ON(vma->vm_flags & VM_PFNMAP);
>>@@ -2150,6 +2152,11 @@ retry:
>> 		entry = mk_pte(new_page, vma->vm_page_prot);
>> 		if (write_access)
>> 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
>>+		else if (VM_SharedWritable(vma)) {
>>+			struct address_space *mapping = page_mapping(new_page);
>>+			if (mapping && mapping_cap_account_dirty(mapping))
>>+				entry = pte_wrprotect(entry);
>>+		}
>> 		set_pte_at(mm, address, page_table, entry);
>> 		if (anon) {
>> 			inc_mm_counter(mm, anon_rss);
>>@@ -2159,6 +2166,10 @@ retry:
>> 		} else {
>> 			inc_mm_counter(mm, file_rss);
>> 			page_add_file_rmap(new_page);
>>+			if (write_access) {
>>+				dirty_page = new_page;
>>+				get_page(dirty_page);
>>+			}
>>
>
>So let's see.  We take a write fault, we mark the page dirty then we return
>to userspace which will proceed with the write and will mark the pte dirty.
>
>Later, the VM will write the page out.
>
>Later still, the pte will get cleaned by reclaim or by munmap or whatever
>and the page will be marked dirty and the page will again be written out. 
>Potentially needlessly.
>

page_wrprotect also marks the page clean, so this window is very small.
The window is that the fault path might set_page_dirty, then throttle
on writeout, and the page gets written out before it really gets dirtied
by the application (which then has to fault again).

>
>How much extra IO will we be doing because of this change?
>

Of course it can do potentially quite a lot more IO in some cases, if
an application likes to dirty a working set larger than the writeout
thresholds... the same scenario as write(2) has now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
