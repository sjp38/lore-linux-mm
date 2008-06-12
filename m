Date: Thu, 12 Jun 2008 02:02:35 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
Message-Id: <20080612020235.29a81d7c.akpm@linux-foundation.org>
In-Reply-To: <4850E3BC.308@gmail.com>
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>
	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>
	<4850070F.6060305@gmail.com>
	<20080611121510.d91841a3.akpm@linux-foundation.org>
	<485032C8.4010001@gmail.com>
	<20080611134323.936063d3.akpm@linux-foundation.org>
	<485055FF.9020500@gmail.com>
	<20080611155530.099a54d6.akpm@linux-foundation.org>
	<4850BE9B.5030504@linux.vnet.ibm.com>
	<4850E3BC.308@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: righi.andrea@gmail.com
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 12 Jun 2008 10:52:13 +0200 (MEST) Andrea Righi <righi.andrea@gmail.com> wrote:

> Balbir Singh wrote:
> > Andrew Morton wrote:
> >> #define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
> >>
> >> ?
> >>
> >> afaict ALIGN() tries to do the right thing, and if it doesn't, we
> >> should fix ALIGN().
> >>
> > 
> > That should do the right thing, provided there are no duplicate ALIGN defintions
> > elsewhere
> > 
> > kernel.h has
> > 
> > 
> > #define ALIGN(x,a)              __ALIGN_MASK(x,(typeof(x))(a)-1)
> > #define __ALIGN_MASK(x,mask)    (((x)+(mask))&~(mask))
> > 
> > Which seems like the correct thing, since we use typeof(x) for (a) - 1.
> 
> OK, I'm going to do some builds and tests on my i386 and x86_64 boxes
> with the following patch. I'm sure this will break something and I don't
> know if moving PAGE_ALIGN() out of asm-*/page.h is the right way.

Thanks.  Looks good from here.

>
> ...
>
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -9,6 +9,7 @@
>  #include <linux/list.h>
>  #include <linux/mmzone.h>
>  #include <linux/rbtree.h>
> +#include <linux/kernel.h>
>  #include <linux/prio_tree.h>
>  #include <linux/debug_locks.h>
>  #include <linux/mm_types.h>
> @@ -41,6 +42,9 @@ extern unsigned long mmap_min_addr;
>  
>  #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
>  
> +/* to align the pointer to the (next) page boundary */
> +#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
> +
>  /*
>   * Linux kernel virtual memory manager primitives.
>   * The idea being to have a "virtual" mm in the same way

You don't really need the #include <linux/kernel.h> there.  As long as
all callsites which _use_ PAGE_ALIGN are including kernel.h via some
means (and they surely will be) then things will work OK.

But it won't hurt.  We're already picking up kernel.h there via
mmzone.h->spinlock.h and probably 100 other routes.  One more won't
make a lot of difference ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
