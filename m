Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id EF7306B0253
	for <linux-mm@kvack.org>; Mon, 23 May 2016 03:32:01 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id q17so8079868lbn.3
        for <linux-mm@kvack.org>; Mon, 23 May 2016 00:32:01 -0700 (PDT)
Received: from mail-wm0-f68.google.com (mail-wm0-f68.google.com. [74.125.82.68])
        by mx.google.com with ESMTPS id w202si14222681wmd.67.2016.05.23.00.32.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 00:32:00 -0700 (PDT)
Received: by mail-wm0-f68.google.com with SMTP id 67so12284443wmg.0
        for <linux-mm@kvack.org>; Mon, 23 May 2016 00:32:00 -0700 (PDT)
Date: Mon, 23 May 2016 09:31:58 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [v2 PATCH] mm: move page_ext_init after all struct pages are
 initialized
Message-ID: <20160523073157.GD2278@dhcp22.suse.cz>
References: <1463696006-31360-1-git-send-email-yang.shi@linaro.org>
 <20160520131649.GC5197@dhcp22.suse.cz>
 <f0c27d67-3735-300b-76eb-e49d56ab7a10@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f0c27d67-3735-300b-76eb-e49d56ab7a10@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, iamjoonsoo.kim@lge.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org

On Fri 20-05-16 08:41:09, Shi, Yang wrote:
> On 5/20/2016 6:16 AM, Michal Hocko wrote:
> > On Thu 19-05-16 15:13:26, Yang Shi wrote:
> > [...]
> > > diff --git a/init/main.c b/init/main.c
> > > index b3c6e36..2075faf 100644
> > > --- a/init/main.c
> > > +++ b/init/main.c
> > > @@ -606,7 +606,6 @@ asmlinkage __visible void __init start_kernel(void)
> > >  		initrd_start = 0;
> > >  	}
> > >  #endif
> > > -	page_ext_init();
> > >  	debug_objects_mem_init();
> > >  	kmemleak_init();
> > >  	setup_per_cpu_pageset();
> > > @@ -1004,6 +1003,8 @@ static noinline void __init kernel_init_freeable(void)
> > >  	sched_init_smp();
> > > 
> > >  	page_alloc_init_late();
> > > +	/* Initialize page ext after all struct pages are initializaed */
> > > +	page_ext_init();
> > > 
> > >  	do_basic_setup();
> > 
> > I might be missing something but don't we have the same problem with
> > CONFIG_FLATMEM? page_ext_init_flatmem is called way earlier. Or
> > CONFIG_DEFERRED_STRUCT_PAGE_INIT is never enabled for CONFIG_FLATMEM?
> 
> Yes, CONFIG_DEFERRED_STRUCT_PAGE_INIT depends on MEMORY_HOTPLUG which
> depends on SPARSEMEM. So, this config is not valid for FLATMEM at all.

Well
config MEMORY_HOTPLUG
        bool "Allow for memory hot-add"
	depends on SPARSEMEM || X86_64_ACPI_NUMA
	depends on ARCH_ENABLE_MEMORY_HOTPLUG

I wasn't really sure about X86_64_ACPI_NUMA dependency branch which
depends on X86_64 && NUMA && ACPI && PCI and that didn't sound like
SPARSEMEM only. If the FLATMEM shouldn't exist with
CONFIG_DEFERRED_STRUCT_PAGE_INIT can we make that explicit please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
