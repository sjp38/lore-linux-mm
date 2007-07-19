Message-ID: <469F7622.6070801@bull.net>
Date: Thu, 19 Jul 2007 16:33:06 +0200
From: Zoltan Menyhart <Zoltan.Menyhart@bull.net>
MIME-Version: 1.0
Subject: Re: [BUGFIX]{PATCH] flush icache on ia64 take2
References: <20070706112901.16bb5f8a.kamezawa.hiroyu@jp.fujitsu.com>	<20070719155632.7dbfb110.kamezawa.hiroyu@jp.fujitsu.com>	<469F5372.7010703@bull.net>	<20070719220118.73f40346.kamezawa.hiroyu@jp.fujitsu.com> <20070719223208.87383731.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070719223208.87383731.kamezawa.hiroyu@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tony.luck@intel.com, nickpiggin@yahoo.com.au, mike@stroyan.net, dmosberger@gmail.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:

> A bit new idea.  How about this ?
> ==
> - Set PG_arch_1 if  "icache is *not* coherent"

page-flags.h:
 * PG_arch_1 is an architecture specific page state bit.  The generic code
 * guarantees that this bit is cleared for a page when it first is entered into
 * the page cache.

I do not think you can easily change it.
I can agree, making nfs_readpage() call an architecture dependent service
is not an easy stuff either. :-)

> - make flush_dcache_page() to be empty func.
> - For Montecito, add kmap_atomic(). This function just set PG_arch1.

kmap_atomic() is used at several places. Do you want to set
PG_arch1, everywhere kmap_atomic() is called?

>   Then, "the page which is copied by the kernel" is marked as "not icache coherent page"
> - icache_flush_page() just flushes a page which has PG_arch_1.
> - Anonymous page is always has PG_arch_1. Tkae care of Copy-On-Write.

You can allocate (even in user mode) an anonymous page, hand-create or
read() in some code from a file, and mprotect(...., EXEC)-it. The page has
to become I-cache coherent.

I am not sure I can really understand your proposal.
I cannot see how the compatibility to the existing code is made sure.

Thanks,

Zoltan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
