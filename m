Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 824976B02D8
	for <linux-mm@kvack.org>; Fri, 26 Oct 2018 04:01:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id 14-v6so160034pfk.22
        for <linux-mm@kvack.org>; Fri, 26 Oct 2018 01:01:28 -0700 (PDT)
Received: from mailgw01.mediatek.com ([210.61.82.183])
        by mx.google.com with ESMTPS id m28-v6si10888358pfk.56.2018.10.26.01.01.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Oct 2018 01:01:27 -0700 (PDT)
Message-ID: <1540540867.21297.2.camel@mtkswgap22>
Subject: Re: [PATCH] mm/page_owner: use vmalloc instead of kmalloc
From: Miles Chen <miles.chen@mediatek.com>
Date: Fri, 26 Oct 2018 16:01:07 +0800
In-Reply-To: <e0cd65fdd6afc17b2be9b3ac64d50b95b2c2f32e.camel@perches.com>
References: <1540492481-4144-1-git-send-email-miles.chen@mediatek.com>
	 <e0cd65fdd6afc17b2be9b3ac64d50b95b2c2f32e.camel@perches.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Matthias Brugger <matthias.bgg@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, wsd_upstream@mediatek.com, linux-mediatek@lists.infradead.org, linux-arm-kernel@lists.infradead.org

On Thu, 2018-10-25 at 11:44 -0700, Joe Perches wrote:
> On Fri, 2018-10-26 at 02:34 +0800, miles.chen@mediatek.com wrote:
> > From: Miles Chen <miles.chen@mediatek.com>
> > 
> > The kbuf used by page owner is allocated by kmalloc(),
> > which means it can use only normal memory and there might
> > be a "out of memory" issue when we're out of normal memory.
> > 
> > Use vmalloc() so we can also allocate kbuf from highmem
> > on 32bit kernel.
> 
> If this is really necessary, using kvmalloc/kvfree would
> be better as the vmalloc space is also limited.

thanks for the advise.
kvmalloc/kvfree is better here.

> 
> > diff --git a/mm/page_owner.c b/mm/page_owner.c
> []
> > @@ -1,7 +1,6 @@
> >  // SPDX-License-Identifier: GPL-2.0
> >  #include <linux/debugfs.h>
> >  #include <linux/mm.h>
> > -#include <linux/slab.h>
> >  #include <linux/uaccess.h>
> >  #include <linux/bootmem.h>
> >  #include <linux/stacktrace.h>
> > @@ -10,6 +9,7 @@
> >  #include <linux/migrate.h>
> >  #include <linux/stackdepot.h>
> >  #include <linux/seq_file.h>
> > +#include <linux/vmalloc.h>
> >  
> >  #include "internal.h"
> >  
> > @@ -351,7 +351,7 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
> >  		.skip = 0
> >  	};
> >  
> > -	kbuf = kmalloc(count, GFP_KERNEL);
> > +	kbuf = vmalloc(count);
> >  	if (!kbuf)
> >  		return -ENOMEM;
> >  
> > @@ -397,11 +397,11 @@ print_page_owner(char __user *buf, size_t count, unsigned long pfn,
> >  	if (copy_to_user(buf, kbuf, ret))
> >  		ret = -EFAULT;
> >  
> > -	kfree(kbuf);
> > +	vfree(kbuf);
> >  	return ret;
> >  
> >  err:
> > -	kfree(kbuf);
> > +	vfree(kbuf);
> >  	return -ENOMEM;
> >  }
> >  
> 
