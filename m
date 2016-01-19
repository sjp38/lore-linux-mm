Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id 3516C6B0009
	for <linux-mm@kvack.org>; Tue, 19 Jan 2016 13:32:52 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id r129so102003963wmr.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 10:32:52 -0800 (PST)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id d132si34913168wmf.70.2016.01.19.10.32.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Jan 2016 10:32:50 -0800 (PST)
Received: by mail-wm0-f65.google.com with SMTP id u188so25091120wmu.0
        for <linux-mm@kvack.org>; Tue, 19 Jan 2016 10:32:50 -0800 (PST)
Date: Tue, 19 Jan 2016 19:32:49 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Mlocked pages statistics shows bogus value.
Message-ID: <20160119183249.GA2011@dhcp22.suse.cz>
References: <201601191936.HAI26031.HOtJQLOMFFFVOS@I-love.SAKURA.ne.jp>
 <20160119122101.GA20260@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160119122101.GA20260@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue 19-01-16 14:21:01, Kirill A. Shutemov wrote:
[...]
> >From 6f80a79dc5f65f29899e396942d40f727cd36480 Mon Sep 17 00:00:00 2001
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Date: Tue, 19 Jan 2016 14:59:19 +0300
> Subject: [PATCH] mm: fix mlock accouting
> 
> Tetsuo Handa reported underflow of NR_MLOCK on munlock.
> 
> Testcase:
> 	#include <stdio.h>
> 	#include <stdlib.h>
> 	#include <sys/mman.h>
> 
> 	#define BASE ((void *)0x400000000000)
> 	#define SIZE (1UL << 21)
> 
> 	int main(int argc, char *argv[])
> 	{
> 		void *addr;
> 
> 		system("grep Mlocked /proc/meminfo");
> 		addr = mmap(BASE, SIZE, PROT_READ | PROT_WRITE,
> 				MAP_ANONYMOUS | MAP_PRIVATE | MAP_LOCKED | MAP_FIXED,
> 				-1, 0);
> 		if (addr == MAP_FAILED)
> 			printf("mmap() failed\n"), exit(1);
> 		munmap(addr, SIZE);
> 		system("grep Mlocked /proc/meminfo");
> 		return 0;
> 	}
> 
> It happens on munlock_vma_page() due to unfortunate choice of nr_pages
> data type:
> 
> 	__mod_zone_page_state(zone, NR_MLOCK, -nr_pages);
> 
> For unsigned int nr_pages, implicitly casted to long in
> __mod_zone_page_state(), it becomes something around UINT_MAX.
> 
> munlock_vma_page() usually called for THP as small pages go though
> pagevec.
> 
> Let's make nr_pages singed int.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Fixes: ff6a6da60b89 ("mm: accelerate munlock() treatment of THP pages")
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Cc: Michel Lespinasse <walken@google.com>

$ grep Mlocked /proc/meminfo 
Mlocked:        10840497455108 kB

I've started seeing the same issue recently but was too busy to track it
down. Thanks! Mentioning 6cdb18ad98a4 ("mm/vmstat: fix overflow in
mod_zone_page_state()") would be really helpful here.

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mlock.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index e1e2b1207bf2..96f001041928 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -175,7 +175,7 @@ static void __munlock_isolation_failed(struct page *page)
>   */
>  unsigned int munlock_vma_page(struct page *page)
>  {
> -	unsigned int nr_pages;
> +	int nr_pages;
>  	struct zone *zone = page_zone(page);
>  
>  	/* For try_to_munlock() and to serialize with page migration */
> -- 
>  Kirill A. Shutemov
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
