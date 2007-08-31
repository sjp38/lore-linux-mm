Message-ID: <46D76255.7000008@yahoo.com.au>
Date: Fri, 31 Aug 2007 10:35:33 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: + memory-controller-memory-accounting-v7.patch added to -mm tree
References: <200708272119.l7RLJoOD028582@imap1.linux-foundation.org> <46D3C244.7070709@yahoo.com.au> <46D3CE29.3030703@linux.vnet.ibm.com> <46D3EADE.3080001@yahoo.com.au> <46D4097A.7070301@linux.vnet.ibm.com> <46D52030.9080605@yahoo.com.au> <46D52B07.6050809@linux.vnet.ibm.com> <46D67426.606@yahoo.com.au> <46D68833.2030405@linux.vnet.ibm.com>
In-Reply-To: <46D68833.2030405@linux.vnet.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: akpm@linux-foundation.org, a.p.zijlstra@chello.nl, dev@sw.ru, ebiederm@xmission.com, herbert@13thfloor.at, menage@google.com, rientjes@google.com, svaidy@linux.vnet.ibm.com, xemul@openvz.org, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Nick Piggin wrote:
> 
>>Balbir Singh wrote:
>>
>>>Nick Piggin wrote:
>>
>>>Very good review comment. Here's what we see
>>>
>>>1. Page comes in through page cache, we increment the reference ount
>>>2. Page comes into rmap, we increment the refcount again
>>>3. We race in page_add.*rmap(), the problem we have is that for
>>>   the same page, for rmap(), step 2 would have taken place more than
>>>   once
>>>4. That's why we uncharge
>>>
>>>I think I need to add a big fat comment in the ref_cnt member. ref_cnt
>>>is held once for the page in the page cache and once for the page mapped
>>>anywhere in the page tables.
>>>
>>>reference counting helps us correctly determine when to take the page
>>>of the LRU (it moves from page tables to swap cache, but it's still
>>>on the LRU).
>>
>>Still don't understand. You increment the refcount once when you put
>>the page in the pagecache, then again when the first process maps the
>>page, then again while subsequent processes map the page but you soon
>>drop it afterwards. That's fine, I don't pretend to understand why
>>you're doing it, but presumably the controller has a good reason for
>>that.
>>
>>But my point is, why should the VM know or care about that? You should
>>handle all those details in your controller. If, in order to do that,
>>you need to differentiate between when a process puts a page in
>>pagecache and when it maps a page, that's fine, just use different
>>hooks for those events.
>>
>>The situation now is that your one hook is not actually a "this page
>>was mapped" hook, or a "this page was added to pagecache", or "we are
>>about to map this page". These are easy for VM maintainers to maintain
>>because they're simple VM concepts.
>>
>>But your hook is "increment ref_cnt and do some other stuff". So now
>>the VM needs to know about when and why your container implementation
>>needs to increment and decrement this ref_cnt. I don't know this, and
>>I don't want to know this ;)
>>
> 
> 
> My hook really is -- there was a race, there is no rmap lock to prevent
> several independent processes from mapping the same page into their
> page tables. I want to increment the reference count just once (apart from
> it being accounted in the page cache), since we account the page once.
> 
> I'll revisit this hook to see if it can be made cleaner

If you just have a different hook for mapping a page into the page
tables, your controller can take care of any races, no?

-- 
SUSE Labs, Novell Inc.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
