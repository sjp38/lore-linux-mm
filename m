Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 600E86B0032
	for <linux-mm@kvack.org>; Sat, 30 May 2015 17:02:09 -0400 (EDT)
Received: by wicmx19 with SMTP id mx19so44887629wic.0
        for <linux-mm@kvack.org>; Sat, 30 May 2015 14:02:09 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id d8si10601345wiz.107.2015.05.30.14.02.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 May 2015 14:02:08 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH v2 3/4] arch: introduce memremap()
Date: Sat, 30 May 2015 23:00:10 +0200
References: <20150530185425.32590.3190.stgit@dwillia2-desk3.amr.corp.intel.com> <20150530185935.32590.95416.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150530185935.32590.95416.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201505302300.10950.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org, jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, hmh@hmh.eng.br, tj@kernel.org, hch@lst.de

On Saturday 30 May 2015, Dan Williams wrote:
> 
> +/*
> + * memremap() is "ioremap" for cases where it is known that the resource
> + * being mapped does not have i/o side effects and the __iomem
> + * annotation is not applicable.
> + */
> +
> +static inline void *memremap(resource_size_t offset, size_t size)
> +{
> +       return (void __force *) ioremap(offset, size);
> +}
> +
> +static inline void *memremap_nocache(resource_size_t offset, size_t size)
> +{
> +       return (void __force *) ioremap_nocache(offset, size);
> +}
> +
> +static inline void *memremap_cache(resource_size_t offset, size_t size)
> +{
> +       return (void __force *) ioremap_cache(offset, size);
> +}
> +

There are architectures on which the result of ioremap is not necessarily
a pointer, but instead indicates that the access is to be done through
some other indirect access, or require special instructions. I think implementing
the memremap() interfaces is generally helpful, but don't rely on the
ioremap implementation.

Adding both cached an uncached versions is also dangerous, because you
typically get either undefined behavior or a system checkstop when a
single page is mapped both cached and uncached at the same time. This
means that doing memremap() or memremap_nocache() on something that
may be part of the linear kernel mapping is a bug, and we should probably
check for that here.

We can probably avoid having both memremap() and memremap_nocache(),
as all architectures define ioremap() and ioremap_nocache() to be the
same thing.
	
	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
