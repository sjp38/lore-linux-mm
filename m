Message-ID: <19990817111350.B296@bug.ucw.cz>
Date: Tue, 17 Aug 1999 11:13:50 +0200
From: Pavel Machek <pavel@bug.ucw.cz>
Subject: Re: [bigmem-patch] 4GB with Linux on IA32
References: <Pine.LNX.4.10.9908162235570.4139-100000@laser.random> <Pine.LNX.4.10.9908162358590.9951-100000@laser.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.10.9908162358590.9951-100000@laser.random>; from Andrea Arcangeli on Tue, Aug 17, 1999 at 12:47:50AM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Kanoj Sarcar <kanoj@google.engr.sgi.com>, torvalds@transmeta.com, sct@redhat.com, Gerhard.Wichert@pdb.siemens.de, Winfried.Gerhard@pdb.siemens.de, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi!

> This incremental (against bigmem-2.3.13-L) patch will fix the ptrace and
> /proc/*/mem read/writes to other process VM inside the kernel.

Your patches start to contain more ifdefs than code. That's bad.

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

These ifdefs are probably not needed. Few unused symbols can not hurt,
can they? And if you are worried, put #ifdef pair into asm/bigmem.h,
not into every file.

> @@ -120,7 +123,13 @@
>  		i = PAGE_SIZE-(addr & ~PAGE_MASK);
>  		if (i > scount)
>  			i = scount;
> +#ifdef CONFIG_BIGMEM
> +		page = (char *) kmap((unsigned long) page, KM_READ);
> +#endif

What about kmap existing uncoditionaly, but (inside bigmem.h)

#ifdef CONFIG_BIGMEM
#define kmap(a,b) real_kmap(a,b)
#else
#define kmap(a,b) a
#endif

? Doing this and same for kunmap would save lots of painfull #ifdefs
otherwhere.

								Pavel
-- 
I'm really pavel@ucw.cz. Look at http://195.113.31.123/~pavel.  Pavel
Hi! I'm a .signature virus! Copy me into your ~/.signature, please!
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
