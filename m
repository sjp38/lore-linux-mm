Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com [74.125.82.48])
	by kanga.kvack.org (Postfix) with ESMTP id 476A66B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 08:01:42 -0500 (EST)
Received: by mail-wm0-f48.google.com with SMTP id l65so137269262wmf.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 05:01:42 -0800 (PST)
Received: from mail-wm0-x230.google.com (mail-wm0-x230.google.com. [2a00:1450:400c:c09::230])
        by mx.google.com with ESMTPS id ld9si46054125wjb.130.2016.01.19.05.01.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 05:01:39 -0800 (PST)
Received: by mail-wm0-x230.google.com with SMTP id b14so169816146wmb.1
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 05:01:39 -0800 (PST)
Date: Tue, 19 Jan 2016 15:01:37 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Mlocked pages statistics shows bogus value.
Message-ID: <20160119130137.GA20984@node.shutemov.name>
References: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
 <20160119122101.GA20260@node.shutemov.name>
 <201601192146.IFE86479.VMHLOFtQSOFFJO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201601192146.IFE86479.VMHLOFtQSOFFJO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: walken@google.com, akpm@linux-foundation.org, linux-mm@kvack.org

On Tue, Jan 19, 2016 at 09:46:21PM +0900, Tetsuo Handa wrote:
> Kirill A. Shutemov wrote:
> > Oh. Looks like a bug from 2013...
> > 
> > Thanks for report.
> > 
> > From 6f80a79dc5f65f29899e396942d40f727cd36480 Mon Sep 17 00:00:00 2001
> > From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> > Date: Tue, 19 Jan 2016 14:59:19 +0300
> > Subject: [PATCH] mm: fix mlock accouting
> > 
> > Tetsuo Handa reported underflow of NR_MLOCK on munlock.
> > 
> > Testcase:
> > 	#include <stdio.h>
> > 	#include <stdlib.h>
> > 	#include <sys/mman.h>
> > 
> > 	#define BASE ((void *)0x400000000000)
> > 	#define SIZE (1UL << 21)
> > 
> > 	int main(int argc, char *argv[])
> > 	{
> > 		void *addr;
> > 
> > 		system("grep Mlocked /proc/meminfo");
> > 		addr = mmap(BASE, SIZE, PROT_READ | PROT_WRITE,
> > 				MAP_ANONYMOUS | MAP_PRIVATE | MAP_LOCKED | MAP_FIXED,
> > 				-1, 0);
> > 		if (addr == MAP_FAILED)
> > 			printf("mmap() failed\n"), exit(1);
> > 		munmap(addr, SIZE);
> > 		system("grep Mlocked /proc/meminfo");
> > 		return 0;
> > 	}
> > 
> > It happens on munlock_vma_page() due to unfortunate choice of nr_pages
> > data type:
> > 
> > 	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
> > 
> > For unsigned int nr_pages, implicitly casted to long in
> > __mod_zone_page_state(), it becomes something around UINT_MAX.
> > 
> > munlock_vma_page() usually called for THP as small pages go though
> > pagevec.
> > 
> > Let's make nr_pages singed int.
> > 
> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> > Fixes: ff6a6da60b89 ("mm: accelerate munlock() treatment of THP pages")
> > Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Cc: Michel Lespinasse <walken@google.com>
> > ---
> >  mm/mlock.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/mm/mlock.c b/mm/mlock.c
> > index e1e2b1207bf2..96f001041928 100644
> > --- a/mm/mlock.c
> > +++ b/mm/mlock.c
> > @@ -175,7 +175,7 @@ static void __munlock_isolation_failed(struct page *page)
> >   */
> >  unsigned int munlock_vma_page(struct page *page)
> >  {
> > -	unsigned int nr_pages;
> > +	int nr_pages;
> >  	struct zone *zone = page_zone(page);
> >  
> >  	/* For try_to_munlock() and to serialize with page migration */
> > -- 
> >  Kirill A. Shutemov
> > 
> 
> Don't we want to use "long" than "int" for all variables that count number
> of pages, for recently commit 6cdb18ad98a49f7e9b95d538a0614cde827404b8
> "mm/vmstat: fix overflow in mod_zone_page_state()" changed to use "long" ?

Potentially, yes. But here we count number of small pages in the compound
page. We're far from being able to allocate 8 terabyte pages ;)

Anyway, it's out-of-scope for this bug fix.

My "Fixes:" is probably misleading, since we don't have bug visible until
6cdb18ad98a4.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
