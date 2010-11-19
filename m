Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 062D36B0071
	for <linux-mm@kvack.org>; Fri, 19 Nov 2010 11:12:56 -0500 (EST)
Received: by wwi18 with SMTP id 18so1672328wwi.26
        for <linux-mm@kvack.org>; Fri, 19 Nov 2010 08:12:50 -0800 (PST)
Subject: Re: percpu: Implement this_cpu_add,sub,dec,inc_return
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011190958230.2360@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>
	 <alpine.DEB.2.00.1011100939530.23566@router.home>
	 <1290018527.2687.108.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011190941380.32655@router.home>
	 <1290181870.3034.136.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011190958230.2360@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 19 Nov 2010 17:12:38 +0100
Message-ID: <1290183158.3034.145.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Le vendredi 19 novembre 2010 A  09:59 -0600, Christoph Lameter a A(C)crit :
> On Fri, 19 Nov 2010, Eric Dumazet wrote:
> 
> > > This isnt a use case for this_cpu_dec right? Seems that your message was
> > > cut off?
> > I wanted to show you the file were it was possible to use this_cpu_{dec|
> > inc}_return()
> >
> > My patch on kmap_atomic_idx() doesnt need your new functions ;)
> 
> Oh ok you mean this:
> 
> ---
>  include/linux/highmem.h |    8 +++++---
>  1 file changed, 5 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/include/linux/highmem.h
> ===================================================================
> --- linux-2.6.orig/include/linux/highmem.h	2010-11-19 09:55:24.000000000 -0600
> +++ linux-2.6/include/linux/highmem.h	2010-11-19 09:57:54.000000000 -0600
> @@ -81,7 +81,9 @@ DECLARE_PER_CPU(int, __kmap_atomic_idx);
> 
>  static inline int kmap_atomic_idx_push(void)
>  {
> -	int idx = __get_cpu_var(__kmap_atomic_idx)++;
> +	int idx = __this_cpu_read(__kmap_atomic_idx);
> +
> +	__this_cpu_inc(__kmap_atomic_idx);
>  #ifdef CONFIG_DEBUG_HIGHMEM
>  	WARN_ON_ONCE(in_irq() && !irqs_disabled());
>  	BUG_ON(idx > KM_TYPE_NR);
> @@ -91,12 +93,12 @@ static inline int kmap_atomic_idx_push(v
> 
>  static inline int kmap_atomic_idx(void)
>  {
> -	return __get_cpu_var(__kmap_atomic_idx) - 1;
> +	return __this_cpu_read(__kmap_atomic_idx) - 1;
>  }
> 
>  static inline int kmap_atomic_idx_pop(void)
>  {
> -	int idx = --__get_cpu_var(__kmap_atomic_idx);
> +	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
>  #ifdef CONFIG_DEBUG_HIGHMEM
>  	BUG_ON(idx < 0);
>  #endif


Yes, absolutely.

By the way, is your patch really ok ?

xadd %0,foo   returns in %0 the previous value of the memory, not the
value _after_ the operation.

This is why we do in arch/x86/include/asm/atomic.h :

static inline int atomic_add_return(int i, atomic_t *v)
...
       
        __i = i;
        asm volatile(LOCK_PREFIX "xaddl %0, %1"
                     : "+r" (i), "+m" (v->counter)
                     : : "memory");
        return i + __i;
...





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
