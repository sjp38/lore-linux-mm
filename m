Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 266E76B01B2
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 15:24:24 -0400 (EDT)
Received: from wpaz24.hot.corp.google.com (wpaz24.hot.corp.google.com [172.24.198.88])
	by smtp-out.google.com with ESMTP id o5RJOK3h013161
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 12:24:20 -0700
Received: from pva18 (pva18.prod.google.com [10.241.209.18])
	by wpaz24.hot.corp.google.com with ESMTP id o5RJOJNH006445
	for <linux-mm@kvack.org>; Sun, 27 Jun 2010 12:24:19 -0700
Received: by pva18 with SMTP id 18so1560986pva.39
        for <linux-mm@kvack.org>; Sun, 27 Jun 2010 12:24:19 -0700 (PDT)
Date: Sun, 27 Jun 2010 12:24:15 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [S+Q 02/16] [PATCH 1/2] percpu: make @dyn_size always mean min
 dyn_size in first chunk init functions
In-Reply-To: <4C270A09.3070305@kernel.org>
Message-ID: <alpine.DEB.2.00.1006271220050.7487@chino.kir.corp.google.com>
References: <20100625212026.810557229@quilx.com> <20100625212102.196049458@quilx.com> <alpine.DEB.2.00.1006262155260.12531@chino.kir.corp.google.com> <4C270A09.3070305@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Matt Mackall <mpm@selenic.com>
List-ID: <linux-mm.kvack.org>

On Sun, 27 Jun 2010, Tejun Heo wrote:

> >>  struct pcpu_alloc_info * __init pcpu_build_alloc_info(
> >> -				size_t reserved_size, ssize_t dyn_size,
> >> +				size_t reserved_size, size_t dyn_size,
> >>  				size_t atom_size,
> >>  				pcpu_fc_cpu_distance_fn_t cpu_distance_fn)
> >>  {
> >> @@ -1098,13 +1084,15 @@ struct pcpu_alloc_info * __init pcpu_bui
> >>  	memset(group_map, 0, sizeof(group_map));
> >>  	memset(group_cnt, 0, sizeof(group_map));
> >>  
> >> +	size_sum = PFN_ALIGN(static_size + reserved_size + dyn_size);
> >> +	dyn_size = size_sum - static_size - reserved_size;
> > 
> > Ok, so the only purpose of "dyn_size" is to store in the struct 
> > pcpu_alloc_info later.  Before this patch, ai->dyn_size would always be 0 
> > if that's what was passed to pcpu_build_alloc_info(), but due to this 
> > arithmetic it now requires that static_size + reserved_size to be pfn 
> > aligned.  Where is that enforced or do we not care?
> 
> I'm not really following you, but
> 
> * Nobody called pcpu_build_alloc_info() w/ zero dyn_size.  It was
>   either -1 or positive minimum size.
> 

Ok, the commit description said that passing pcpu_build_alloc_info() a 
dyn_size of 0 would force it to be 0, although the arithmetic introduced 
by this patch would not have necessarily set ai->dyn_size to be 0 when 
passed if static_size + reserved_size was not page aligned (size_sum 
could be greater than static_size + reserved_size).  Since there are no 
users passing a dyn_size of 0, my concern is addressed.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
