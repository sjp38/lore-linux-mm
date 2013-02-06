Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id EAF296B002D
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 20:17:24 -0500 (EST)
Date: Wed, 6 Feb 2013 10:17:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zsmalloc: Add Kconfig for enabling PTE method
Message-ID: <20130206011721.GE11197@blaptop>
References: <1359937421-19921-1-git-send-email-minchan@kernel.org>
 <20130204185146.GA31284@kroah.com>
 <20130205000854.GC2610@blaptop>
 <20130205192520.GA8441@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130205192520.GA8441@kroah.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Feb 05, 2013 at 11:25:20AM -0800, Greg Kroah-Hartman wrote:
> On Tue, Feb 05, 2013 at 09:08:54AM +0900, Minchan Kim wrote:
> > Hi Greg,
> > 
> > On Mon, Feb 04, 2013 at 10:51:46AM -0800, Greg Kroah-Hartman wrote:
> > > On Mon, Feb 04, 2013 at 09:23:41AM +0900, Minchan Kim wrote:
> > > > Zsmalloc has two methods 1) copy-based and 2) pte based to access
> > > > allocations that span two pages.
> > > > You can see history why we supported two approach from [1].
> > > > 
> > > > But it was bad choice that adding hard coding to select architecture
> > > > which want to use pte based method. This patch removed it and adds
> > > > new Kconfig to select the approach.
> > > > 
> > > > This patch is based on next-20130202.
> > > > 
> > > > [1] https://lkml.org/lkml/2012/7/11/58
> > > > 
> > > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > > Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>
> > > > Cc: Nitin Gupta <ngupta@vflare.org>
> > > > Cc: Dan Magenheimer <dan.magenheimer@oracle.com>
> > > > Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>
> > > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > > > ---
> > > >  drivers/staging/zsmalloc/Kconfig         |   12 ++++++++++++
> > > >  drivers/staging/zsmalloc/zsmalloc-main.c |   11 -----------
> > > >  2 files changed, 12 insertions(+), 11 deletions(-)
> > > > 
> > > > diff --git a/drivers/staging/zsmalloc/Kconfig b/drivers/staging/zsmalloc/Kconfig
> > > > index 9084565..2359123 100644
> > > > --- a/drivers/staging/zsmalloc/Kconfig
> > > > +++ b/drivers/staging/zsmalloc/Kconfig
> > > > @@ -8,3 +8,15 @@ config ZSMALLOC
> > > >  	  non-standard allocator interface where a handle, not a pointer, is
> > > >  	  returned by an alloc().  This handle must be mapped in order to
> > > >  	  access the allocated space.
> > > > +
> > > > +config ZSMALLOC_PGTABLE_MAPPING
> > > > +        bool "Use page table mapping to access allocations that span two pages"
> > > > +        depends on ZSMALLOC
> > > > +        default n
> > > > +        help
> > > > +	  By default, zsmalloc uses a copy-based object mapping method to access
> > > > +	  allocations that span two pages. However, if a particular architecture
> > > > +	  performs VM mapping faster than copying, then you should select this.
> > > > +	  This causes zsmalloc to use page table mapping rather than copying
> > > > +	  for object mapping. You can check speed with zsmalloc benchmark[1].
> > > > +	  [1] https://github.com/spartacus06/zsmalloc
> > > > diff --git a/drivers/staging/zsmalloc/zsmalloc-main.c b/drivers/staging/zsmalloc/zsmalloc-main.c
> > > > index 06f73a9..b161ca1 100644
> > > > --- a/drivers/staging/zsmalloc/zsmalloc-main.c
> > > > +++ b/drivers/staging/zsmalloc/zsmalloc-main.c
> > > > @@ -218,17 +218,6 @@ struct zs_pool {
> > > >  #define CLASS_IDX_MASK	((1 << CLASS_IDX_BITS) - 1)
> > > >  #define FULLNESS_MASK	((1 << FULLNESS_BITS) - 1)
> > > >  
> > > > -/*
> > > > - * By default, zsmalloc uses a copy-based object mapping method to access
> > > > - * allocations that span two pages. However, if a particular architecture
> > > > - * performs VM mapping faster than copying, then it should be added here
> > > > - * so that USE_PGTABLE_MAPPING is defined. This causes zsmalloc to use
> > > > - * page table mapping rather than copying for object mapping.
> > > > -*/
> > > > -#if defined(CONFIG_ARM)
> > > > -#define USE_PGTABLE_MAPPING
> > > > -#endif
> > > 
> > > Did you test this?  I don't see the new config value you added actually
> > > do anything in this code.  Also, if I select it incorrectly on ARM, or
> > 
> > *slaps self*
> 
> Ok, so I'll drop this patch now.  As for what to do instead, I have no
> idea, sorry, but the others should.

Okay. Then, let's discuss further.
The history we introuced copy-based method is due to portability casused by
set_pte and __flush_tlb_one usage in young zsmalloc age. They are gone now
so there isn't issue any more. But we found copy-based method is 3 times faster
than pte-based in VM so I expect you guys don't want to give up it for just
portability. Of course,
I can't give up pte-based model as you know well, it's 6 times faster than
copy-based model in ARM.

Hard-coding for some arch like now isn't good and Kconfig for selecting choice
was rejected by Greg as you can see above.

Remained thing is new Kconfig ZSMALLOC_SMART_CHOICE and adding
new boot/module paramter. If admin enable it, In booting and module loading time,
zsmalloc start benchmark both model, find best in the system and select it.
If it is different with thing admin selected or default method, zsmalloc can warn
about it so he can select right choice next time without enabling ZSMALLOC_SMART_CHOICE
so he don't lose booting time and code size.

For it, we should add some code for benchamrk and selecting model dynamically.
Frankly speaking, I feel it's overkill. zsmalloc is in staging now so IMHO,
I don't see any problem in my patch.

Anyway, we should conclude agreeement and Andrew, too because he asked to add
Kconfig model to promote zsmalloc.

Andrew, Nitin, Dan, Seth and Konrad?
What do you think about it?

> 
> thanks,
> 
> greg k-h
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
