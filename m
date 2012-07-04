Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id BFF0B6B0073
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 01:32:30 -0400 (EDT)
Message-ID: <4FF3D598.4070708@kernel.org>
Date: Wed, 04 Jul 2012 14:33:12 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH 0/4] zsmalloc improvements
References: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
In-Reply-To: <1341263752-10210-1-git-send-email-sjenning@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjenning@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>, Robert Jennings <rcj@linux.vnet.ibm.com>, linux-mm@kvack.org, devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org

Sorry for not reviewing yet.
By urgent works, I will review this patches on next week.

I hope others can review it.
Thanks.

On 07/03/2012 06:15 AM, Seth Jennings wrote:

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



-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
