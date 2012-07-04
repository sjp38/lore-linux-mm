Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id F34C36B0070
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 16:43:30 -0400 (EDT)
Received: by qabg27 with SMTP id g27so3737364qab.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 13:43:29 -0700 (PDT)
Date: Wed, 4 Jul 2012 16:43:26 -0400
From: Konrad Rzeszutek Wilk <konrad@darnok.org>
Subject: Re: [PATCH 0/4] zsmalloc improvements
Message-ID: <20120704204325.GB2924@localhost.localdomain>
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Minchan Kim <minchan@kernel.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

On Mon, Jul 02, 2012 at 04:15:48PM -0500, Seth Jennings wrote:
> This patchset removes the current x86 dependency for zsmalloc
> and introduces some performance improvements in the object
> mapping paths.
> 
> It was meant to be a follow-on to my previous patchest
> 
> https://lkml.org/lkml/2012/6/26/540
> 
> However, this patchset differed so much in light of new performance
> information that I mostly started over.
> 
> In the past, I attempted to compare different mapping methods
> via the use of zcache and frontswap.  However, the nature of those
> two features makes comparing mapping method efficiency difficult
> since the mapping is a very small part of the overall code path.
> 
> In an effort to get more useful statistics on the mapping speed,
> I wrote a microbenchmark module named zsmapbench, designed to
> measure mapping speed by calling straight into the zsmalloc
> paths.
> 
> https://github.com/spartacus06/zsmapbench
> 
> This exposed an interesting and unexpected result: in all
> cases that I tried, copying the objects that span pages instead
> of using the page table to map them, was _always_ faster.  I could
> not find a case in which the page table mapping method was faster.

Which architecture was this under? It sounds x86-ish? Is this on
Westmere and more modern machines? What about Core2 architecture?

Oh how did it work on AMD Phenom boxes?
> 
> zsmapbench measures the copy-based mapping at ~560 cycles for a
> map/unmap operation on spanned object for both KVM guest and bare-metal,
> while the page table mapping was ~1500 cycles on a VM and ~760 cycles
> bare-metal.  The cycles for the copy method will vary with
> allocation size, however, it is still faster even for the largest
> allocation that zsmalloc supports.
> 
> The result is convenient though, as mempcy is very portable :)
> 
> This patchset replaces the x86-only page table mapping code with
> copy-based mapping code. It also makes changes to optimize this
> new method further.
> 
> There are no changes in arch/x86 required.
> 
> Patchset is based on greg's staging-next.
> 
> Seth Jennings (4):
>   zsmalloc: remove x86 dependency
>   zsmalloc: add single-page object fastpath in unmap
>   zsmalloc: add details to zs_map_object boiler plate
>   zsmalloc: add mapping modes
> 
>  drivers/staging/zcache/zcache-main.c     |    6 +-
>  drivers/staging/zram/zram_drv.c          |    7 +-
>  drivers/staging/zsmalloc/Kconfig         |    4 -
>  drivers/staging/zsmalloc/zsmalloc-main.c |  124 ++++++++++++++++++++++--------
>  drivers/staging/zsmalloc/zsmalloc.h      |   14 +++-
>  drivers/staging/zsmalloc/zsmalloc_int.h  |    6 +-
>  6 files changed, 114 insertions(+), 47 deletions(-)
> 
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
