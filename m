Subject: Re: [RFC][PATCH] tracking dirty pages in shared mappings
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <445CA22B.8030807@cyberone.com.au>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au>
Content-Type: text/plain
Date: Sat, 06 May 2006 15:34:06 +0200
Message-Id: <1146922446.3561.20.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, 2006-05-06 at 23:18 +1000, Nick Piggin wrote:

> 
> Looks pretty good. Christoph and I were looking at ways to improve
> performance impact of this, and skipping the extra work for particular
> (eg. shmem) mappings might be a good idea?
> 
> Attached is a patch with a couple of things I've currently got.

will merge with mine and post a new version shortly.

> In the long run, I'd like to be able to set_page_dirty and
> balance_dirty_pages outside of both ptl and mmap_sem, for performance
> reasons. That will require a reworking of arch code though :(

That would indeed be very nice if possible.

> Index: linux-2.6/include/linux/mm.h
> ===================================================================
> --- linux-2.6.orig/include/linux/mm.h	2006-05-06 23:05:10.000000000 +1000
> +++ linux-2.6/include/linux/mm.h	2006-05-06 23:06:17.000000000 +1000
> @@ -183,8 +183,7 @@ extern unsigned int kobjsize(const void 
>  #define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
>  #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
>  
> -#define VM_SharedWritable(v)		(((v)->vm_flags & (VM_SHARED | VM_MAYSHARE)) && \
> -					 ((v)->vm_flags & VM_WRITE))
> +#define VM_SharedWritable(v)		((v)->vm_flags & (VM_SHARED|VM_WRITE))
>  
>  /*
>   * mapping from the currently active vm_flags protection bits (the

That doesn't look right, your version is true even for unwritable
shared, and writable non-shared VMAs.

PeterZ

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
