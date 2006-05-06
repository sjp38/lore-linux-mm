Message-ID: <445CA907.9060002@cyberone.com.au>
Date: Sat, 06 May 2006 23:47:51 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] tracking dirty pages in shared mappings
References: <1146861313.3561.13.camel@lappy>	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
In-Reply-To: <1146922446.3561.20.camel@lappy>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Peter Zijlstra wrote:

>On Sat, 2006-05-06 at 23:18 +1000, Nick Piggin wrote:
>
>
>>Looks pretty good. Christoph and I were looking at ways to improve
>>performance impact of this, and skipping the extra work for particular
>>(eg. shmem) mappings might be a good idea?
>>
>>Attached is a patch with a couple of things I've currently got.
>>
>
>will merge with mine and post a new version shortly.
>

Thanks.

>>In the long run, I'd like to be able to set_page_dirty and
>>balance_dirty_pages outside of both ptl and mmap_sem, for performance
>>reasons. That will require a reworking of arch code though :(
>>
>
>That would indeed be very nice if possible.
>

Yep. Let's not distract from getting the basic mechanism working though.
balance_dirty_pages would be patch 2..n ;)

>>Index: linux-2.6/include/linux/mm.h
>>===================================================================
>>--- linux-2.6.orig/include/linux/mm.h	2006-05-06 23:05:10.000000000 +1000
>>+++ linux-2.6/include/linux/mm.h	2006-05-06 23:06:17.000000000 +1000
>>@@ -183,8 +183,7 @@ extern unsigned int kobjsize(const void 
>> #define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
>> #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
>> 
>>-#define VM_SharedWritable(v)		(((v)->vm_flags & (VM_SHARED | VM_MAYSHARE)) && \
>>-					 ((v)->vm_flags & VM_WRITE))
>>+#define VM_SharedWritable(v)		((v)->vm_flags & (VM_SHARED|VM_WRITE))
>> 
>> /*
>>  * mapping from the currently active vm_flags protection bits (the
>>
>
>That doesn't look right, your version is true even for unwritable
>shared, and writable non-shared VMAs.
>

Of course, thanks. I guess that should be

#define VM_SharedWritable(v) ((v)->vm_flags & (VM_SHARED|VM_WRITE) == (VM_SHARED|VM_WRITE))

BTW. It is unconventional (outside the read hints stuff) to use macros like
this. I guess real VM hackers have to know what is intended by any given esoteric
combination of flags in any given context.

Not that I hate it.

But if we're going to start using it, we should work out a sane convention and
stick to it. "StudlyCaps" seem to be out of favour, and using a vma_ prefix would
be more sensible.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
