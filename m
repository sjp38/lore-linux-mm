Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E32D86B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 12:53:29 -0500 (EST)
Date: Fri, 19 Dec 2008 09:55:13 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [rfc][patch] unlock_page speedup
In-Reply-To: <alpine.LFD.2.00.0812190926000.14014@localhost.localdomain>
Message-ID: <alpine.LFD.2.00.0812190941120.14014@localhost.localdomain>
References: <20081219072909.GC26419@wotan.suse.de> <20081218233549.cb451bc8.akpm@linux-foundation.org> <alpine.LFD.2.00.0812190926000.14014@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: 8BIT
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>



On Fri, 19 Dec 2008, Linus Torvalds wrote:
> 
> Hmm. Do we ever use lock_page() on anything but page-cache pages and the 
> buffer cache?

Looking closer, I don't think we do. 

The issue with using the low bits in page->mapping is that sometimes that 
field doesn't exist, and we use other members of that union:

 - spinlock_t ptr	 	- page table pages
 - struct kmem_cache *slab	- slab allocations
 - struct page *first_page	- compound tail pages

but I cannot see how lock_page() could ever be valid for any of them. We 
use lock_page() for things that we do IO on, or that are mapped into user 
space. And while we can map compound pages into user space, we'd better 
not be locking random parts of it - we have to lock the whole thing (ie 
the first one, not the tails).

And we even have a way to verify it - we can make lock_page() verify the 
page flags for at least things like "not a slab page or a compound tail". 
I guess we don't mark page table pages any special way, so I don't see how 
we can add an assert for that use, but verifying that we never do 
lock_page() on a page table page should be trivial.

So it should work.

That said, I did notice a problem. Namely that while the VM code is good 
about looking at ->mapping (because it doesn't know whether the page is 
anonymous or a true mapping), much of the filesystem code is _not_ careful 
about page->mapping, since the filesystem code knows a-priori that the 
mapping pointer must be an inode mapping (or we'd not have called it).

So filesystems do tend to do things like

	struct inode *inode = page->mapping->host;

and while the low bit of mapping is magic, those code-paths don't care 
because they depend on it being zero.

So hiding the lock bit there would involve a lot more work than I naively 
expected before looking closer. We'd have to change the name (to 
"_mapping", presumably), and make all users use an accessor function to 
make code like the above do

	struct inode *inode = page_mapping(page)->host;

or something (we migth want to have a "page_host_inode()" helper to do it, 
it seems to be the most common reason for accessing "->mapping" that 
there is.

So it could be done pretty mechanically, but it's still a _big_ change. 
Maybe not worth it, unless we can really translate it into some other 
advantage (ie real simplification of page flag access)

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
