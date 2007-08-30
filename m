Message-ID: <46D67426.606@yahoo.com.au>
Date: Thu, 30 Aug 2007 17:39:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: + memory-controller-memory-accounting-v7.patch added to -mm tree
References: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org> <46D3C244.7070709@yahoo.com.au> <46D3CE29.3030703@linux.vnet.ibm.com> <46D3EADE.3080001@yahoo.com.au> <46D4097A.7070301@linux.vnet.ibm.com> <46D52030.9080605@yahoo.com.au> <46D52B07.6050809@linux.vnet.ibm.com>
In-Reply-To: <46D52B07.6050809@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dev@sw.ru, ebiederm@xmission.com, herbert@13thfloor.at, menage@google.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Nick Piggin wrote:

>>Oh yeah, I understand all _those_ uncharging calls you do. But let me
>>just quote the code again:
>>
>>diff -puN mm/rmap.c~memory-controller-memory-accounting-v7 mm/rmap.c
>>--- a/mm/rmap.c~memory-controller-memory-accounting-v7
>>+++ a/mm/rmap.c
>>@@ -48,6 +48,7 @@
>> #include <linux/rcupdate.h>
>> #include <linux/module.h>
>> #include <linux/kallsyms.h>
>>+#include <linux/memcontrol.h>
>>
>> #include <asm/tlbflush.h>
>>
>>@@ -550,8 +551,14 @@ void page_add_anon_rmap(struct page *pag
>>     VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
>>     if (atomic_inc_and_test(&page->_mapcount))
>>         __page_set_anon_rmap(page, vma, address);
>>-    else
>>+    else {
>>         __page_check_anon_rmap(page, vma, address);
>>+        /*
>>+         * We unconditionally charged during prepare, we uncharge here
>>+         * This takes care of balancing the reference counts
>>+         */
>>+        mem_container_uncharge_page(page);
>>+    }
>> }
>>
>>At the point you are uncharging here, the pte has been updated and
>>the page is in the pagetables of the process. I guess this uncharging
>>works on the presumption that you are not the first container to map
>>the page, but I thought that you already check for that in your
>>accounting implementation.
>>
>>Now how does it take care of the refcounts? I guess it is because your
>>rmap removal function also takes care of refcounts by only uncharging
>>if mapcount has gone to zero... however that's polluting the VM with
>>knowledge that your accounting scheme is a first-touch one, isn't it?
>>
>>Aside, I'm slightly suspicious of whether this is correct against
>>mapcount races, but I didn't look closely yet. I remember you bringing
>>that up with me, so I guess you've been careful there...
>>
> 
> 
> Very good review comment. Here's what we see
> 
> 1. Page comes in through page cache, we increment the reference ount
> 2. Page comes into rmap, we increment the refcount again
> 3. We race in page_add.*rmap(), the problem we have is that for
>    the same page, for rmap(), step 2 would have taken place more than
>    once
> 4. That's why we uncharge
> 
> I think I need to add a big fat comment in the ref_cnt member. ref_cnt
> is held once for the page in the page cache and once for the page mapped
> anywhere in the page tables.
> 
> reference counting helps us correctly determine when to take the page
> of the LRU (it moves from page tables to swap cache, but it's still
> on the LRU).

Still don't understand. You increment the refcount once when you put
the page in the pagecache, then again when the first process maps the
page, then again while subsequent processes map the page but you soon
drop it afterwards. That's fine, I don't pretend to understand why
you're doing it, but presumably the controller has a good reason for
that.

But my point is, why should the VM know or care about that? You should
handle all those details in your controller. If, in order to do that,
you need to differentiate between when a process puts a page in
pagecache and when it maps a page, that's fine, just use different
hooks for those events.

The situation now is that your one hook is not actually a "this page
was mapped" hook, or a "this page was added to pagecache", or "we are
about to map this page". These are easy for VM maintainers to maintain
because they're simple VM concepts.

But your hook is "increment ref_cnt and do some other stuff". So now
the VM needs to know about when and why your container implementation
needs to increment and decrement this ref_cnt. I don't know this, and
I don't want to know this ;)

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
