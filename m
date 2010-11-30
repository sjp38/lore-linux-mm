Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 07C896B0089
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:29:57 -0500 (EST)
Received: by wwb29 with SMTP id 29so24818wwb.26
        for <linux-mm@kvack.org>; Tue, 30 Nov 2010 11:29:55 -0800 (PST)
Subject: Re: [thisops uV3 07/18] highmem: Use this_cpu_xx_return()
 operations
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <alpine.DEB.2.00.1011301325180.3134@router.home>
References: <20101130190707.457099608@linux.com>
	 <20101130190845.216537525@linux.com>
	 <1291144408.2904.232.camel@edumazet-laptop>
	 <alpine.DEB.2.00.1011301325180.3134@router.home>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 30 Nov 2010 20:29:51 +0100
Message-ID: <1291145391.2904.247.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Catalin Marinas <catalin.marinas@arm.com>, linux-kernel@vger.kernel.org, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Le mardi 30 novembre 2010 A  13:26 -0600, Christoph Lameter a A(C)crit :
> On Tue, 30 Nov 2010, Eric Dumazet wrote:
> 
> > >  {
> > > -	int idx = --__get_cpu_var(__kmap_atomic_idx);
> > > +	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
> >
> > __this_cpu_dec_return() is only needed if CONFIG_DEBUG_HIGHMEM
> >
> > >  #ifdef CONFIG_DEBUG_HIGHMEM
> > >  	BUG_ON(idx < 0);
> > >  #endif
> > >
> >
> > You could change kmap_atomic_idx_pop() to return void, and use
> > __this_cpu_dec(__kmap_atomic_idx)
> 
> The following would do?
> 
> 
> Subject: highmem: Use this_cpu_dec instead of __this_cpu_dec_return if !DEBUG_HIGHMEM
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>
> 
> ---
>  include/linux/highmem.h |    9 +++++++--
>  1 file changed, 7 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/include/linux/highmem.h
> ===================================================================
> --- linux-2.6.orig/include/linux/highmem.h	2010-11-30 13:23:44.000000000 -0600
> +++ linux-2.6/include/linux/highmem.h	2010-11-30 13:24:54.000000000 -0600
> @@ -95,14 +95,19 @@ static inline int kmap_atomic_idx(void)
>  	return __this_cpu_read(__kmap_atomic_idx) - 1;
>  }
> 
> +#ifdef CONFIG_DEBUG_HIGHMEM
>  static inline int kmap_atomic_idx_pop(void)
>  {
>  	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
> -#ifdef CONFIG_DEBUG_HIGHMEM
>  	BUG_ON(idx < 0);
> -#endif
>  	return idx;
>  }
> +#else
> +static inline void kmap_atomic_idx_pop(void)
> +{
> +	__this_cpu_dec(__kmap_atomic_idx);
> +}
> +#endif
> 
>  #endif
> 


well maybe a single prototype ;)

static inline void kmap_atomic_idx_pop(void)
{
#ifdef CONFIG_DEBUG_HIGHMEM
	int idx = __this_cpu_dec_return(__kmap_atomic_idx);
	BUG_ON(idx < 0);
#else
      __this_cpu_dec(__kmap_atomic_idx);
#endif
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
