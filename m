Date: Tue, 17 Aug 1999 10:52:03 +0200
From: Jakub Jelinek <jj@sunsite.ms.mff.cuni.cz>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
Message-ID: <19990817105203.F548@mff.cuni.cz>
References: <Pine.LNX.4.10.9908162235570.4139-100000@laser.random> <Pine.LNX.4.10.9908162358590.9951-100000@laser.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.9908162358590.9951-100000@laser.random>; from Andrea Arcangeli on Tue, Aug 17, 1999 at 12:47:50AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 17, 1999 at 12:47:50AM +0200, Andrea Arcangeli wrote:
> This incremental (against bigmem-2.3.13-L) patch will fix the ptrace and
> /proc/*/mem read/writes to other process VM inside the kernel.

Isn't it cleaner to provided asm/bigmem.h on all platforms and even on
asm-i386 do something like

#ifndef CONFIG_BIGMEM
#define PageBIGMEM(map) 0
#define kmap(x,y) x
#define kunmap(x,y)
#else
...
#endif
?
> 
> diff -urN 2.3.13-bigmem-L/fs/proc/mem.c tmp/fs/proc/mem.c
> --- 2.3.13-bigmem-L/fs/proc/mem.c	Tue Jul 13 02:02:09 1999
> +++ tmp/fs/proc/mem.c	Tue Aug 17 00:02:48 1999
> @@ -15,6 +15,9 @@
>  #include <asm/uaccess.h>
>  #include <asm/io.h>
>  #include <asm/pgtable.h>
> +#ifdef CONFIG_BIGMEM
> +#include <asm/bigmem.h>
> +#endif
>  
>  /*
>   * mem_write isn't really a good idea right now. It needs
> @@ -120,7 +123,13 @@
>  		i = PAGE_SIZE-(addr & ~PAGE_MASK);
>  		if (i > scount)
>  			i = scount;
> +#ifdef CONFIG_BIGMEM
> +		page = (char *) kmap((unsigned long) page, KM_READ);
> +#endif
>  		copy_to_user(tmp, page, i);
> +#ifdef CONFIG_BIGMEM
> +		kunmap((unsigned long) page, KM_READ);
> +#endif
>  		addr += i;
>  		tmp += i;
>  		scount -= i;
> @@ -177,7 +186,13 @@
>  		i = PAGE_SIZE-(addr & ~PAGE_MASK);
>  		if (i > count)
>  			i = count;
> +#ifdef CONFIG_BIGMEM
> +		page = (unsigned long) kmap((unsigned long) page, KM_WRITE);
> +#endif
>  		copy_from_user(page, tmp, i);
> +#ifdef CONFIG_BIGMEM
> +		kunmap((unsigned long) page, KM_WRITE);
> +#endif
>  		addr += i;
>  		tmp += i;
>  		count -= i;
> diff -urN 2.3.13-bigmem-L/kernel/ptrace.c tmp/kernel/ptrace.c
> --- 2.3.13-bigmem-L/kernel/ptrace.c	Thu Jul 22 01:07:28 1999
> +++ tmp/kernel/ptrace.c	Tue Aug 17 00:02:40 1999
> @@ -13,6 +13,9 @@
>  
>  #include <asm/pgtable.h>
>  #include <asm/uaccess.h>
> +#ifdef CONFIG_BIGMEM
> +#include <asm/bigmem.h>
> +#endif
>  
>  /*
>   * Access another process' address space, one page at a time.
> @@ -52,7 +55,15 @@
>  			dst = src;
>  			src = buf;
>  		}
> +#ifdef CONFIG_BIGMEM
> +		src = (void *) kmap((unsigned long) src, KM_READ);
> +		dst = (void *) kmap((unsigned long) dst, KM_WRITE);
> +#endif
>  		memcpy(dst, src, len);
> +#ifdef CONFIG_BIGMEM
> +		kunmap((unsigned long) src, KM_READ);
> +		kunmap((unsigned long) dst, KM_WRITE);
> +#endif
>  	}
>  	flush_page_to_ram(page);
>  	return len;
> 
> The /proc/*/mem read/write seems to not work though (maybe I am doing
> something wrong...).
> 
> black:/home/andrea# cat /proc/1/mem 
> cat: /proc/1/mem: No such process
> 
> The same happens also on 2.2.11.
> 
> Andrea
> 
> 
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.rutgers.edu
> Please read the FAQ at http://www.tux.org/lkml/

Cheers,
    Jakub
___________________________________________________________________
Jakub Jelinek | jj@sunsite.mff.cuni.cz | http://sunsite.mff.cuni.cz
Administrator of SunSITE Czech Republic, MFF, Charles University
___________________________________________________________________
UltraLinux  |  http://ultra.linux.cz/  |  http://ultra.penguin.cz/
Linux version 2.3.13 on a sparc64 machine (1343.49 BogoMips)
___________________________________________________________________
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
