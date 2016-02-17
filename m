Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0456B0253
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 19:23:04 -0500 (EST)
Received: by mail-io0-f173.google.com with SMTP id g203so10175305iof.2
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 16:23:04 -0800 (PST)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id kl7si8779632oeb.81.2016.02.16.16.23.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 16 Feb 2016 16:23:03 -0800 (PST)
Message-ID: <1455671761.2925.174.camel@hpe.com>
Subject: Re: [PATCH] devm_memremap_release: fix memremap'd addr handling
From: Toshi Kani <toshi.kani@hpe.com>
Date: Tue, 16 Feb 2016 18:16:01 -0700
In-Reply-To: <20160216161843.25aaac7046c7a79e1713c8a2@linux-foundation.org>
References: <1455640227-21459-1-git-send-email-toshi.kani@hpe.com>
	 <20160216161843.25aaac7046c7a79e1713c8a2@linux-foundation.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: dan.j.williams@intel.com, linux-nvdimm@ml01.01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@lst.de>

On Tue, 2016-02-16 at 16:18 -0800, Andrew Morton wrote:
> On Tue, 16 Feb 2016 09:30:27 -0700 Toshi Kani <toshi.kani@hpe.com> wrote:
> 
> > The pmem driver calls devm_memremap() to map a persistent memory
> > range.A A When the pmem driver is unloaded, this memremap'd range
> > is not released.
> > 
> > Fix devm_memremap_release() to handle a given memremap'd address
> > properly.
> > 
> > ...
> > 
> > --- a/kernel/memremap.c
> > +++ b/kernel/memremap.c
> > @@ -114,7 +114,7 @@ EXPORT_SYMBOL(memunmap);
> > A 
> > A static void devm_memremap_release(struct device *dev, void *res)
> > A {
> > -	memunmap(res);
> > +	memunmap(*(void **)res);
> > A }
> > A 
> 
> Huh.A A So what happens?A A memunmap() decides it isn't a vmalloc address
> and we leak a vma?

Yes, that's right.

> I'll add a cc:stable to this.

Agreed.

Thanks!
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
