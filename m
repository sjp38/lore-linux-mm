Date: Thu, 21 Nov 2002 18:04:34 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: hugetlb page patch for 2.5.48-bug fixes
Message-ID: <20021122020434.GV23425@holomorphy.com>
References: <25282B06EFB8D31198BF00508B66D4FA03EA5B12@fmsmsx114.fm.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <25282B06EFB8D31198BF00508B66D4FA03EA5B12@fmsmsx114.fm.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Seth, Rohit" <rohit.seth@intel.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@digeo.com, torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

At some point in the past, I wrote:
>> Okay, first off why are you using a list linked through page->private?
>> page->list is fully available for such tasks.

On Thu, Nov 21, 2002 at 05:54:22PM -0800, Seth, Rohit wrote:
> Don't really need a list_head kind of thing for always inorder complete
> traversal. list_head (slightly) adds fat in data structures as well as
> insertaion/removal. Please le me know if anything that prohibits the use of
> page_private field for internal use.

page->private is also available for internal use. The objection here
was about not using the standardized list macros. I'm not convinced
about the fat since the keyspace is tightly bounded and the back
pointers are in struct page regardless. (And we also just happen to
know page->lru is also available though I'd not suggest using it.)


At some point in the past, I wrote:
>> Third, the hugetlb_release_key() in unmap_hugepage_range() is 
>> the one that should be removed [along with its corresponding 
>> mark_key_busy()], not the one in sys_free_hugepages(). 
>> unmap_hugepage_range() is doing neither setup nor teardown of 
>> the key itself, only the pages and PTE's. I would say 
>> key-level refcounting belongs to sys_free_hugepages().

On Thu, Nov 21, 2002 at 05:54:22PM -0800, Seth, Rohit wrote:
> It is not mandatory that user app calls free_pages.  Or even in case of app
> aborts this call will not be made.  The internal structures are always
> released during the exit (with last ref count) along with free of underlying
> physical pages.  

Hmm, I can understand caution wrt. touching core. I suspect vma->close()
should do hugetlb_key_release() instead of sys_free_hugepages()?

Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
