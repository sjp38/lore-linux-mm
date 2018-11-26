Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7526B3E44
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:13:37 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so8766597ede.14
        for <linux-mm@kvack.org>; Sun, 25 Nov 2018 23:13:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id b3-v6si2374744ejj.38.2018.11.25.23.13.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 25 Nov 2018 23:13:35 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAQ78dML071625
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:13:34 -0500
Received: from e06smtp02.uk.ibm.com (e06smtp02.uk.ibm.com [195.75.94.98])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2p09x7d3e2-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Nov 2018 02:13:34 -0500
Received: from localhost
	by e06smtp02.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 26 Nov 2018 07:13:32 -0000
Date: Mon, 26 Nov 2018 09:13:26 +0200
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: Make  __memblock_free_early a wrapper of memblock_free rather
 dup it
References: <C8ECE1B7A767434691FEEFA3A01765D72AFB8E78@MX203CL03.corp.emc.com>
 <20181121212740.84884a0c4532334d81fc6961@linux-foundation.org>
 <20181125102940.GE28634@rapoport-lnx>
 <C8ECE1B7A767434691FEEFA3A01765D72AFB95CA@MX203CL03.corp.emc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <C8ECE1B7A767434691FEEFA3A01765D72AFB95CA@MX203CL03.corp.emc.com>
Message-Id: <20181126071326.GA14863@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Wang, Matt" <Matt.Wang@Dell.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hi,

On Mon, Nov 26, 2018 at 02:25:44AM +0000, Wang, Matt wrote:
> I believe I explained why we choose it to be a wrapper,
> " I noticed that __memblock_free_early and memblock_free has the same
> code. At first I think we can delete __memblock_free_early till
> __memblock_free_late remind me __memblock_free_early is meaningful. It’s
> a note to call this before struct page was initialized."

I've been offline when you've sent your patch, otherwise I would
have commented then.

First of all, thanks for spotting that memblock_free() and
__memblock_free_early() are identical :)

Regarding the choice which one should be removed, the
__memblock_free_early() is never called directly by the memblock users but
rather via memblock_free_early() wrapper. I believe it would be cleaner to
make that wrapper call memblock_free() directly without the additional
nesting. 
 
> Andrew may choose plan as he see fit.
> 
> Regards,
> Matt

--
Sincerely yours,
Mike.

> -----Original Message-----
> From: Mike Rapoport [mailto:rppt@linux.ibm.com] 
> Sent: 2018年11月25日 18:30
> To: Andrew Morton
> Cc: Wang, Matt; linux-mm@kvack.org
> Subject: Re: Make __memblock_free_early a wrapper of memblock_free rather dup it
> 
> 
> [EXTERNAL EMAIL] 
> 
> On Wed, Nov 21, 2018 at 09:27:40PM -0800, Andrew Morton wrote:
> > On Thu, 22 Nov 2018 04:01:53 +0000 "Wang, Matt" <Matt.Wang@Dell.com> wrote:
> > 
> > > Subject: [PATCH] Make __memblock_free_early a wrapper of 
> > > memblock_free rather  than dup it
> > > 
> > > Signed-off-by: Wentao Wang <witallwang@gmail.com>
> > > ---
> > >  mm/memblock.c | 7 +------
> > >  1 file changed, 1 insertion(+), 6 deletions(-)
> > > 
> > > diff --git a/mm/memblock.c b/mm/memblock.c index 9a2d5ae..08bf136 
> > > 100644
> > > --- a/mm/memblock.c
> > > +++ b/mm/memblock.c
> > > @@ -1546,12 +1546,7 @@ void * __init memblock_alloc_try_nid(
> > >   */
> > >  void __init __memblock_free_early(phys_addr_t base, phys_addr_t 
> > > size)  {
> > > -	phys_addr_t end = base + size - 1;
> > > -
> > > -	memblock_dbg("%s: [%pa-%pa] %pF\n",
> > > -		     __func__, &base, &end, (void *)_RET_IP_);
> > > -	kmemleak_free_part_phys(base, size);
> > > -	memblock_remove_range(&memblock.reserved, base, size);
> > > +	memblock_free(base, size);
> > >  }
> > 
> > hm, I suppose so.  The debug messaging becomes less informative but 
> > the duplication is indeed irritating and if we really want to show the 
> > different caller info in the messages, we could do it in a smarter 
> > fashion.
> 
> Sorry for jumping late, but I believe the better way would be simply replace the only two calls to __memblock_free_early() with calls to memblock_free().
> 
> The patch below is based on the current mmots.
> 
> From 4de5a2aabb0b898c6b4add6bf91175fc55725362 Mon Sep 17 00:00:00 2001
> From: Mike Rapoport <rppt@linux.ibm.com>
> Date: Sun, 25 Nov 2018 12:20:46 +0200
> Subject: [PATCH] memblock: replace usage of __memblock_free_early() with
>  memblock_free()
> 
> The __memblock_free_early() function is only used by the convinince wrappers, so essentially we wrap a call to memblock_free() twice.
> Replace calls of __memblock_free_early() with calls to memblock_free() and drop the former.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.ibm.com>
> ---
>  include/linux/memblock.h |  5 ++---
>  mm/memblock.c            | 22 ++++++++--------------
>  2 files changed, 10 insertions(+), 17 deletions(-)
> 
> diff --git a/include/linux/memblock.h b/include/linux/memblock.h index 5ba52a7..e9e4017 100644
> --- a/include/linux/memblock.h
> +++ b/include/linux/memblock.h
> @@ -154,7 +154,6 @@ void __next_mem_range_rev(u64 *idx, int nid, enum memblock_flags flags,  void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
>  				phys_addr_t *out_end);
>  
> -void __memblock_free_early(phys_addr_t base, phys_addr_t size);  void __memblock_free_late(phys_addr_t base, phys_addr_t size);
>  
>  /**
> @@ -452,13 +451,13 @@ static inline void * __init memblock_alloc_node_nopanic(phys_addr_t size,  static inline void __init memblock_free_early(phys_addr_t base,
>  					      phys_addr_t size)
>  {
> -	__memblock_free_early(base, size);
> +	memblock_free(base, size);
>  }
>  
>  static inline void __init memblock_free_early_nid(phys_addr_t base,
>  						  phys_addr_t size, int nid)
>  {
> -	__memblock_free_early(base, size);
> +	memblock_free(base, size);
>  }
>  
>  static inline void __init memblock_free_late(phys_addr_t base, phys_addr_t size) diff --git a/mm/memblock.c b/mm/memblock.c index 0559979..b842ce1 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -800,7 +800,14 @@ int __init_memblock memblock_remove(phys_addr_t base, phys_addr_t size)
>  	return memblock_remove_range(&memblock.memory, base, size);  }
>  
> -
> +/**
> + * memblock_free - free boot memory block
> + * @base: phys starting address of the  boot memory block
> + * @size: size of the boot memory block in bytes
> + *
> + * Free boot memory block previously allocated by memblock_alloc_xx() API.
> + * The freeing memory will not be released to the buddy allocator.
> + */
>  int __init_memblock memblock_free(phys_addr_t base, phys_addr_t size)  {
>  	phys_addr_t end = base + size - 1;
> @@ -1600,19 +1607,6 @@ void * __init memblock_alloc_try_nid(  }
>  
>  /**
> - * __memblock_free_early - free boot memory block
> - * @base: phys starting address of the  boot memory block
> - * @size: size of the boot memory block in bytes
> - *
> - * Free boot memory block previously allocated by memblock_alloc_xx() API.
> - * The freeing memory will not be released to the buddy allocator.
> - */
> -void __init __memblock_free_early(phys_addr_t base, phys_addr_t size) -{
> -	memblock_free(base, size);
> -}
> -
> -/**
>   * __memblock_free_late - free bootmem block pages directly to buddy allocator
>   * @base: phys starting address of the  boot memory block
>   * @size: size of the boot memory block in bytes
> --
> 2.7.4
> 
> 
> -- 
> Sincerely yours,
> Mike.
> 
