Message-ID: <394C0A09.CD2CBF62@norran.net>
Date: Sun, 18 Jun 2000 01:30:17 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: PATCH: Improvements in shrink_mmap and kswapd
References: <ytt3dmcyli7.fsf@serpe.mitica>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Juan J. Quintela" <quintela@fi.udc.es>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, lkml <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org, linux-fsdevel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

> diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/include/asm-i386/bitops.h working/include/asm-i386/bitops.h
> --- base/include/asm-i386/bitops.h      Sat Jun 17 23:37:03 2000
> +++ working/include/asm-i386/bitops.h   Sat Jun 17 23:52:49 2000
> @@ -29,6 +29,7 @@
>  extern void change_bit(int nr, volatile void * addr);
>  extern int test_and_set_bit(int nr, volatile void * addr);
>  extern int test_and_clear_bit(int nr, volatile void * addr);
> +extern int test_and_test_and_clear_bit(int nr, volatile void * addr);
>  extern int test_and_change_bit(int nr, volatile void * addr);
>  extern int __constant_test_bit(int nr, const volatile void * addr);
>  extern int __test_bit(int nr, volatile void * addr);
> @@ -87,6 +88,13 @@
>                 :"=r" (oldbit),"=m" (ADDR)
>                 :"Ir" (nr));
>         return oldbit;
> +}
> +
> +extern __inline__ int test_and_test_and_clear_bit(int nr, volatile void *addr)
> +{
> +       if(!(((unsigned long)addr) & (1<<nr)))
> +               return 0;
> +       return test_and_clear_bit(nr,addr);
>  }


This does not look correct. It basically tests if the ADDRESS has bit
#nr set...

Shouldn't it be
+       if(!(((unsigned long)*addr) & (1<<nr)))


/RogerL

--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
