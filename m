Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 37ED26B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 10:24:24 -0400 (EDT)
Subject: Re: vmalloc performance
From: Steven Whitehouse <steve@chygwyn.com>
In-Reply-To: <1271249354.7196.66.camel@localhost.localdomain>
References: <1271089672.7196.63.camel@localhost.localdomain>
	 <1271249354.7196.66.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 14 Apr 2010 15:24:13 +0100
Message-Id: <1271255053.7196.89.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Also, what lock should be protecting this code:

        va->flags |= VM_LAZY_FREE;
        atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT,
&vmap_lazy_nr);

in free_unmap_vmap_area_noflush() ? It seem that if
__purge_vmap_area_lazy runs between the two statements above that the
number of pages contained in vmap_lazy_nr will be incorrect. Maybe the
two statements should just be reversed? I can't see any reason that the
flag assignment would be atomic either. In recent tests, including the
patch below, the following has been reported to me:

Apr 13 17:19:57 bigi kernel: ------------[ cut here ]------------
Apr 13 17:19:57 bigi kernel: kernel BUG at mm/vmalloc.c:559!
Apr 13 17:19:57 bigi kernel: invalid opcode: 0000 [#1] SMP 
etc.

as the result of a vfree() and I think that is probably the reason for
it. I'll try and verify whether that really is the issue, but it looks
highly probably at the moment,

Steve.



On Wed, 2010-04-14 at 13:49 +0100, Steven Whitehouse wrote:
> Since this didn't attract much interest the first time around, and at
> the risk of appearing to be talking to myself, here is the patch from
> the bugzilla to better illustrate the issue:
> 
> 
> diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> index ae00746..63c8178 100644
> --- a/mm/vmalloc.c
> +++ b/mm/vmalloc.c
> @@ -605,8 +605,7 @@ static void free_unmap_vmap_area_noflush(struct
> vmap_area *va)
>  {
>  	va->flags |= VM_LAZY_FREE;
>  	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> -	if (unlikely(atomic_read(&vmap_lazy_nr) > lazy_max_pages()))
> -		try_purge_vmap_area_lazy();
> +	try_purge_vmap_area_lazy();
>  }
>  
>  /*
> 
> 
> Steve.
> 
> On Mon, 2010-04-12 at 17:27 +0100, Steven Whitehouse wrote:
> > Hi,
> > 
> > I've noticed that vmalloc seems to be rather slow. I wrote a test kernel
> > module to track down what was going wrong. The kernel module does one
> > million vmalloc/touch mem/vfree in a loop and prints out how long it
> > takes.
> > 
> > The source of the test kernel module can be found as an attachment to
> > this bz: https://bugzilla.redhat.com/show_bug.cgi?id=581459
> > 
> > When this module is run on my x86_64, 8 core, 12 Gb machine, then on an
> > otherwise idle system I get the following results:
> > 
> > vmalloc took 148798983 us
> > vmalloc took 151664529 us
> > vmalloc took 152416398 us
> > vmalloc took 151837733 us
> > 
> > After applying the two line patch (see the same bz) which disabled the
> > delayed removal of the structures, which appears to be intended to
> > improve performance in the smp case by reducing TLB flushes across cpus,
> > I get the following results:
> > 
> > vmalloc took 15363634 us
> > vmalloc took 15358026 us
> > vmalloc took 15240955 us
> > vmalloc took 15402302 us
> > 
> > So thats a speed up of around 10x, which isn't too bad. The question is
> > whether it is possible to come to a compromise where it is possible to
> > retain the benefits of the delayed TLB flushing code, but reduce the
> > overhead for other users. My two line patch basically disables the delay
> > by forcing a removal on each and every vfree.
> > 
> > What is the correct way to fix this I wonder?
> > 
> > Steve.
> > 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
