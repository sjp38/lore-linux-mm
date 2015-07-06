Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f50.google.com (mail-qg0-f50.google.com [209.85.192.50])
	by kanga.kvack.org (Postfix) with ESMTP id E70D62802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 18:18:33 -0400 (EDT)
Received: by qgeg89 with SMTP id g89so76197930qge.3
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 15:18:33 -0700 (PDT)
Received: from relay4-d.mail.gandi.net (relay4-d.mail.gandi.net. [2001:4b98:c:538::196])
        by mx.google.com with ESMTPS id l35si22549776qgd.62.2015.07.06.15.18.32
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 15:18:32 -0700 (PDT)
Date: Mon, 6 Jul 2015 15:18:29 -0700
From: josh@joshtriplett.org
Subject: Re: kernel/uid16.c:184:2: error: implicit declaration of function
 'groups_alloc'
Message-ID: <20150706221829.GA14527@cloud>
References: <201507050734.RcWSMvjj%fengguang.wu@intel.com>
 <20150706135601.bd75127ce72297e70a396bd3@linux-foundation.org>
 <20150706214705.GA14305@cloud>
 <20150706145902.67ab73c637a5fce19d8da9e9@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150706145902.67ab73c637a5fce19d8da9e9@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild test robot <fengguang.wu@intel.com>, Iulia Manda <iulia.manda21@gmail.com>, kbuild-all@01.org, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Linux Memory Management List <linux-mm@kvack.org>

On Mon, Jul 06, 2015 at 02:59:02PM -0700, Andrew Morton wrote:
> On Mon, 6 Jul 2015 14:47:05 -0700 josh@joshtriplett.org wrote:
> 
> > Andrew,
> > 
> > On Mon, Jul 06, 2015 at 01:56:01PM -0700, Andrew Morton wrote:
> > > On Sun, 5 Jul 2015 07:30:38 +0800 kbuild test robot <fengguang.wu@intel.com> wrote:
> > > 
> > > > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > > > head:   5c755fe142b421d295e7dd64a9833c12abbfd28e
> > > > commit: 2813893f8b197a14f1e1ddb04d99bce46817c84a kernel: conditionally support non-root users, groups and capabilities
> > > > date:   3 months ago
> > > > config: openrisc-allnoconfig (attached as .config)
> > > > reproduce:
> > > >   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
> > > >   chmod +x ~/bin/make.cross
> > > >   git checkout 2813893f8b197a14f1e1ddb04d99bce46817c84a
> > > >   # save the attached .config to linux build tree
> > > >   make.cross ARCH=openrisc 
> > > > 
> > > > All error/warnings (new ones prefixed by >>):
> > > > 
> > > >    kernel/uid16.c: In function 'SYSC_setgroups16':
> > > > >> kernel/uid16.c:184:2: error: implicit declaration of function 'groups_alloc'
> > > >    kernel/uid16.c:184:13: warning: assignment makes pointer from integer without a cast
> > > 
> > > 
> > > Iulia, does the below look corect?  It will make setgroups16() return
> > > -ENOMEM, which seems inappropriate.
> > 
> > [...snip...]
> > 
> > How is the .config valid, given that UID16 *depends* on MULTIUSER?  This
> > shouldn't be possible, and I know Iulia specifically addressed this case
> > by adding that dependency (without which this *exact* error would
> > occur).
> > 
> > Is something doing "select UID16" and missing its dependency?  I don't
> > see any selects for UID16 anywhere in-tree.
> 
> Good point.  I guess this?
> 
> --- a/arch/openrisc/Kconfig~a
> +++ a/arch/openrisc/Kconfig
> @@ -17,6 +17,7 @@ config OPENRISC
>  	select GENERIC_IRQ_SHOW
>  	select GENERIC_IOMAP
>  	select GENERIC_CPU_DEVICES
> +	select HAVE_UID16
>  	select GENERIC_ATOMIC64
>  	select GENERIC_CLOCKEVENTS
>  	select GENERIC_STRNCPY_FROM_USER
> @@ -31,9 +32,6 @@ config MMU
>  config HAVE_DMA_ATTRS
>  	def_bool y
>  
> -config UID16
> -	def_bool y
> -
>  config RWSEM_GENERIC_SPINLOCK
>  	def_bool y

Gah.  Redefining core Kconfig symbols from init/Kconfig in an arch
Kconfig file would do it, yeah.  That looks like a sensible fix.

> I don't have an openrisc build system but with the above change and
> CONFIG_MULTIUSER=n, CONFIG_UID16 gets turned off by `make oldconfig'. 
> Then I set CONFIG_MULTIUSER=y and CONFIG_UID16 gets turned on, so we
> should be good?

Makes sense.

- Josh Triplett

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
