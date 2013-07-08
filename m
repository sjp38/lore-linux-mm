Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 8691A6B0037
	for <linux-mm@kvack.org>; Mon,  8 Jul 2013 02:44:42 -0400 (EDT)
Message-ID: <51DA5FA1.1010108@asianux.com>
Date: Mon, 08 Jul 2013 14:43:45 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/vmscan.c: 'lru' may be used without initialized after
 the patch "3abf380..." in next-20130607 tree
References: <51C155D1.3090304@asianux.com> <20130619001029.ee623fae.akpm@linux-foundation.org> <51C15B7B.9060804@asianux.com> <51D6463B.7050207@asianux.com>
In-Reply-To: <51D6463B.7050207@asianux.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, hannes@cmpxchg.org, riel@redhat.com, mhocko@suse.cz, linux-mm@kvack.org, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On 07/05/2013 12:06 PM, Chen Gang wrote:
> On 06/19/2013 03:19 PM, Chen Gang wrote:
>> On 06/19/2013 03:10 PM, Andrew Morton wrote:
>>> On Wed, 19 Jun 2013 14:55:13 +0800 Chen Gang <gang.chen@asianux.com> wrote:
>>>
>>>>>
>>>>> 'lru' may be used without initialized, so need regressing part of the
>>>>> related patch.
>>>>>
>>>>> The related patch:
>>>>>   "3abf380 mm: remove lru parameter from __lru_cache_add and lru_cache_add_lru"
>>>>>
>>>>> ...
>>>>>
>>>>> --- a/mm/vmscan.c
>>>>> +++ b/mm/vmscan.c
>>>>> @@ -595,6 +595,7 @@ redo:
>>>>>  		 * unevictable page on [in]active list.
>>>>>  		 * We know how to handle that.
>>>>>  		 */
>>>>> +		lru = !!TestClearPageActive(page) + page_lru_base_type(page);
>>>>>  		lru_cache_add(page);
>>>>>  	} else {
>>>>>  		/*
>>> That looks right.  Why the heck didn't gcc-4.4.4 (at least) warn about it?
>>>
>>
>> Sorry I don't know either, I find it by reading code, this time.
>>
>> It is really necessary to continue analyzing why. In 2nd half of 2013, I
>> have planned to make some patches outside kernel but related with kernel
>> (e.g. LTP, gcc patches).
>>
>> This kind of issue is a good chance for me to start in 2nd half of 2013
>> (start from next month).
>>
>> So if no others reply for it, I will start analyzing it in the next
>> month, and plan to finish within a month (before 2013-07-31).
>>
>>
>> Welcome additional suggestions or completions.
>>
>> Thanks.
>>

Under the gcc which from the source code in svn. it still has this
issue. I should communicate with gcc mailing list (or their bugzilla)
for it.

I got gcc source code from svn, "configure && make && make install".

[root@gchenlinux linux-next]# which gcc
/usr/local/bin/gcc
[root@gchenlinux linux-next]# gcc -v
Using built-in specs.
COLLECT_GCC=gcc
COLLECT_LTO_WRAPPER=/usr/local/libexec/gcc/x86_64-unknown-linux-gnu/4.9.0/lto-wrapper
Target: x86_64-unknown-linux-gnu
Configured with: ./configure
Thread model: posix
gcc version 4.9.0 20130704 (experimental) (GCC) 


I think, this thread is the end under kernel mailing list. ;-)

Thanks.

> 
> Under gcc 4.7.2 20120921 (Red Hat 4.7.2-2) also cause this issue.
> 
> The root cause is:
> 
>   for putback_lur_page() in mm/vmscan.c for next-20130621 tree.
>   the compiler assumes "lru == LRU_UNEVICTABLE" instead of report warnings (uninitializing lru)
> 
> The details are below, and the related info and warn are in
> attachments, please check, thanks.
> 
> Next, I will compile gcc compiler with the gcc latest code, if also has
> this issue, I should communicate with gcc mailing list for it.
> 
> Thanks.
> 
> ------------------------------analyzing begin---------------------------------
> 
> /* source code in mm/vmscan.c for next-20130621 */
> 
>  580 void putback_lru_page(struct page *page)
>  581 {
>  582         int lru;
>  583         int was_unevictable = PageUnevictable(page);
>  584 
>  585         VM_BUG_ON(PageLRU(page));
>  586 
>  587 redo:
>  588         ClearPageUnevictable(page);
>  589 
>  590         if (page_evictable(page)) {
>  591                 /*
>  592                  * For evictable pages, we can use the cache.
>  593                  * In event of a race, worst case is we end up with an
>  594                  * unevictable page on [in]active list.
>  595                  * We know how to handle that.
>  596                  */
>  597                 lru_cache_add(page);
>  598         } else {
>  599                 /*
>  600                  * Put unevictable pages directly on zone's unevictable
>  601                  * list.
>  602                  */
>  603                 lru = LRU_UNEVICTABLE;
>  604                 add_page_to_unevictable_list(page);
>  605                 /*
>  606                  * When racing with an mlock or AS_UNEVICTABLE clearing
>  607                  * (page is unlocked) make sure that if the other thread
>  608                  * does not observe our setting of PG_lru and fails
>  609                  * isolation/check_move_unevictable_pages,
>  610                  * we see PG_mlocked/AS_UNEVICTABLE cleared below and move
>  611                  * the page back to the evictable list.
>  612                  *
>  613                  * The other side is TestClearPageMlocked() or shmem_lock().
>  614                  */
>  615                 smp_mb();
>  616         }
>  617 
>  618         /*
>  619          * page's status can change while we move it among lru. If an evictable
>  620          * page is on unevictable list, it never be freed. To avoid that,
>  621          * check after we added it to the list, again.
>  622          */
>  623         if (lru == LRU_UNEVICTABLE && page_evictable(page)) {
>  624                 if (!isolate_lru_page(page)) {
>  625                         put_page(page);
>  626                         goto redo;
>  627                 }
>  628                 /* This means someone else dropped this page from LRU
>  629                  * So, it will be freed or putback to LRU again. There is
>  630                  * nothing to do here.
>  631                  */
>  632         }
>  633 
>  634         if (was_unevictable && lru != LRU_UNEVICTABLE)
>  635                 count_vm_event(UNEVICTABLE_PGRESCUED);
>  636         else if (!was_unevictable && lru == LRU_UNEVICTABLE)
>  637                 count_vm_event(UNEVICTABLE_PGCULLED);
>  638 
>  639         put_page(page);         /* drop ref from isolate */
>  640 }
> 
> 
> /*
>  * Related disassemble code:
>  *   make defconfig under x86_64 PC.
>  *   make menuconfig (choose "Automount devtmpfs at /dev..." and KGDB)
>  *   make V=1 EXTRA_CFLAGS=-W (not find related warnings, ref warn.log in attachment)
>  *   objdump -d vmlinux > vmlinux.S
>  *   vi vmlinux.S
>  *
>  * The issue is: compiler assumes "lru == LRU_UNEVICTABLE" instead of report warnings (uninitializing lru)
>  */
> 
> ffffffff810ffda0 <putback_lru_page>:
> ffffffff810ffda0:	55                   	push   %rbp
> ffffffff810ffda1:	48 89 e5             	mov    %rsp,%rbp
> ffffffff810ffda4:	41 55                	push   %r13
> ffffffff810ffda6:	41 54                	push   %r12
> ffffffff810ffda8:	4c 8d 67 02          	lea    0x2(%rdi),%r12		; %r12 for ClearPageUnevictable(page);
> ffffffff810ffdac:	53                   	push   %rbx
> ffffffff810ffdad:	48 89 fb             	mov    %rdi,%rbx		; %rbx = page
> ffffffff810ffdb0:	48 83 ec 08          	sub    $0x8,%rsp		; for lru, was_unevictable, but not used.
> 
> ffffffff810ffdb4:	4c 8b 2f             	mov    (%rdi),%r13		; %r13 = "was_unevictable = PageUnevictable(page);"
> ffffffff810ffdb7:	49 c1 ed 14          	shr    $0x14,%r13
> ffffffff810ffdbb:	41 83e5 01          	and    $0x1,%r13d
> ffffffff810ffdbf:	90                   	nop
> 
> /* redo */
> ffffffff810ffdc0:	f0 41 80 24 24 ef    	lock andb $0xef,(%r12)		; ClearPageUnevictable(page);
> 
> /* if (page_evictable(page)) { */
> ffffffff810ffdc6:	48 89 df             	mov    %rbx,%rdi
> ffffffff810ffdc9:	e8 92 ff ff ff       	callq  ffffffff810ffd60 <page_evictable>
> ffffffff810ffdce:	85 c0                	test   %eax,%eax
> ffffffff810ffdd0:	48 89 df             	mov    %rbx,%rdi
> ffffffff810ffdd3:	74 0b                	je     ffffffff810ffde0 <putback_lru_page+0x40>
> 
> ffffffff810ffdd5:	e8 96 c5 ff ff       	callq  ffffffff810fc370 <lru_cache_add>
> ffffffff810ffdda:	eb 0c                	jmp    ffffffff810ffde8 <putback_lru_page+0x48>
> ffffffff810ffddc:	0f 1f 40 00          	nopl   0x0(%rax)
> 
> /* } else { */
> 						; assume lru == LRU_UNEVICTABLE
> ffffffff810ffde0:	e8 ab c5 ff ff       	callq  ffffffff810fc390 <add_page_to_unevictable_list>
> ffffffff810ffde5:	0f ae f0             	mfence 
> 
> /* } */
> 
> /* if (lru == LRU_UNEVICTABLE && page_evictable(page)) { */
> ffffffff810ffde8:	48 89 df             	mov    %rbx,%rdi
> ffffffff810ffdeb:	0f 1f 44 00 00       	nopl   0x0(%rax,%rax,1)
> ffffffff810ffdf0:	e8 6b ff ff ff       	callq  ffffffff810ffd60 <page_evictable>
> ffffffff810ffdf5:	85 c0                	test   %eax,%eax
> ffffffff810ffdf7:	74 1f                	je     ffffffff810ffe18 <putback_lru_page+0x78>  ; assume lru == LRU_UNEVICTABLE
> 
> ffffffff810ffdf9:	48 89 df             	mov    %rbx,%rdi
> ffffffff810ffdfc:	e8 0f fb ff ff       	callq  ffffffff810ff910 <isolate_lru_page>
> ffffffff810ffe01:	85 c0                	test   %eax,%eax
> ffffffff810ffe03:	75 13                	jne    ffffffff810ffe18 <putback_lru_page+0x78>
> ffffffff810ffe05:	48 89 df             	mov    %rbx,%rdi
> ffffffff810ffe08:	e8 93 c0 ff ff       	callq  ffffffff810fbea0 <put_page>
> ffffffff810ffe0d:	0f 1f 00             	nopl   (%rax)
> ffffffff810ffe10:	eb ae                	jmp    ffffffff810ffdc0 <putback_lru_page+0x20>	; goto redo;
> ffffffff810ffe12:	66 0f 1f 44 00 00    	nopw   0x0(%rax,%rax,1)
> 
> /* } */
> 
> /* if (was_unevictable && lru != LRU_UNEVICTABLE) */
> 	/* skip... */
> 
> /* else if (!was_unevictable && lru == LRU_UNEVICTABLE) */
> ffffffff810ffe18:	4d 85 ed             	test   %r13,%r13		; !was_unevictable, and assume lru == LRU_UNEVICTABLE
> ffffffff810ffe1b:	75 09                	jne    ffffffff810ffe26 <putback_lru_page+0x86>
> ffffffff810ffe1d:	65 48 ff 04 25 68 f0 	incq   %gs:0xf068	; it is for count_vm_event(UNEVICTABLE_PGCULLED)
> 									; and "incq   %gs:0xf078" is for count_vm_event(UNEVICTABLE_PGRESCUED)
> ffffffff810ffe24:	00 00 
> 
> /* put_page(); */
> ffffffff810ffe26:	48 89 df             	mov    %rbx,%rdi
> ffffffff810ffe29:	e8 72 c0 ff ff       	callq  ffffffff810fbea0 <put_page>
> ffffffff810ffe2e:	48 83 c4 08          	add    $0x8,%rsp
> ffffffff810ffe32:	5b                   	pop    %rbx
> ffffffff810ffe33:	41 5c                	pop    %r12
> ffffffff810ffe35:	41 5d                	pop    %r13
> ffffffff810ffe37:	5d                   	pop    %rbp
> ffffffff810ffe38:	c3                   	retq   
> ffffffff810ffe39:	0f 1f 80 00 00 00 00 	nopl   0x0(%rax)
> 
> 
> ------------------------------analyzing end-----------------------------------
> 
> 
> 
> Thanks.
> 


-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
