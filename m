Date: Mon, 7 Jun 1999 12:44:06 -0700
Message-Id: <199906071944.MAA07363@pizda.davem.net>
From: "David S. Miller" <davem@redhat.com>
In-reply-to: <199906071926.MAA83891@google.engr.sgi.com>
	(kanoj@google.engr.sgi.com)
Subject: Re: Questions on cache flushing in do_wp_page
References: <199906071926.MAA83891@google.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kanoj@google.engr.sgi.com
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu, ralf@uni-koblenz.de
List-ID: <linux-mm.kvack.org>

   I am trying to understand what the primitives flush_page_to_ram and
   flush_cache_page do.

flush_cache_page()

	Remove all "user/tlb view" references to the page in the cache
	(any cache, L1, L2, BCACHE, etc.) for this user virtual mapping
	in address space mm.  It should be back flushed to ram if
	necessary on non-coherent copy-back style caches.

flush_page_to_ram()

	Push kernel address space references to the page in the cache
	(any cache, L1, L2, BCACHE, etc.).  It should be back flushed
	to ram if necessary on non-coherent copy-back style caches
	because we want the user to see the most up to data copy
	in his mapping.

In general the first is used when we tear down or change userspace
mappings of a page and the latter is done when we are making the page
visible to user space.

As per virtual cache aliasing issues we handle them in other ways,
and it is done on a port-by-port basis since most machines need not
handle this brain damage.

For IPC shared memory some ports enforce an alignment.  For other MMU
activities, the update_mmu_cache method can do things like remap a
page as non-cacheable in all user references if an alias has been
created which is unavoidable.  update_mmu_cache is sort of the "catch
all" area for handling stuff like this, you could use it to work
around the MIPS R4x00 "branch at end of page" hardware bug for example.

Later,
David S. Miller
davem@redhat.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
