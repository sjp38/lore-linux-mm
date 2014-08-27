Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 981876B0039
	for <linux-mm@kvack.org>; Wed, 27 Aug 2014 19:18:57 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so141397pac.5
        for <linux-mm@kvack.org>; Wed, 27 Aug 2014 16:18:57 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id ss8si3439805pab.0.2014.08.27.16.18.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Aug 2014 16:18:56 -0700 (PDT)
Date: Wed, 27 Aug 2014 16:18:54 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] x86: Optimize resource lookups for ioremap
Message-Id: <20140827161854.0619a04653b336d3adc755f3@linux-foundation.org>
In-Reply-To: <53FE6515.6050102@sgi.com>
References: <20140827225927.364537333@asylum.americas.sgi.com>
	<20140827225927.602319674@asylum.americas.sgi.com>
	<20140827160515.c59f1c191fde5f788a7c42f6@linux-foundation.org>
	<53FE6515.6050102@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Travis <travis@sgi.com>
Cc: mingo@redhat.com, tglx@linutronix.de, hpa@zytor.com, msalter@redhat.com, dyoung@redhat.com, riel@redhat.com, peterz@infradead.org, mgorman@suse.de, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, Alex Thorlton <athorlton@sgi.com>

On Wed, 27 Aug 2014 16:09:09 -0700 Mike Travis <travis@sgi.com> wrote:

> 
> >>
> >> ...
> >>
> >> --- linux.orig/kernel/resource.c
> >> +++ linux/kernel/resource.c
> >> @@ -494,6 +494,43 @@ int __weak page_is_ram(unsigned long pfn
> >>  }
> >>  EXPORT_SYMBOL_GPL(page_is_ram);
> >>  
> >> +/*
> >> + * Search for a resouce entry that fully contains the specified region.
> >> + * If found, return 1 if it is RAM, 0 if not.
> >> + * If not found, or region is not fully contained, return -1
> >> + *
> >> + * Used by the ioremap functions to insure user not remapping RAM and is as
> >> + * vast speed up over walking through the resource table page by page.
> >> + */
> >> +int __weak region_is_ram(resource_size_t start, unsigned long size)
> >> +{
> >> +	struct resource *p;
> >> +	resource_size_t end = start + size - 1;
> >> +	int flags = IORESOURCE_MEM | IORESOURCE_BUSY;
> >> +	const char *name = "System RAM";
> >> +	int ret = -1;
> >> +
> >> +	read_lock(&resource_lock);
> >> +	for (p = iomem_resource.child; p ; p = p->sibling) {
> >> +		if (end < p->start)
> >> +			continue;
> >> +
> >> +		if (p->start <= start && end <= p->end) {
> >> +			/* resource fully contains region */
> >> +			if ((p->flags != flags) || strcmp(p->name, name))
> >> +				ret = 0;
> >> +			else
> >> +				ret = 1;
> >> +			break;
> >> +		}
> >> +		if (p->end < start)
> >> +			break;	/* not found */
> >> +	}
> >> +	read_unlock(&resource_lock);
> >> +	return ret;
> >> +}
> >> +EXPORT_SYMBOL_GPL(region_is_ram);
> > 
> > Exporting a __weak symbol is strange.  I guess it works, but neither
> > the __weak nor the export are actually needed?
> > 
> 
> I mainly used 'weak' and export because that was what the page_is_ram
> function was using.  Most likely this won't be used anywhere else but
> I wasn't sure.  I can certainly remove the weak and export, at least
> until it's actually needed?

Several architectures implement custom page_is_ram(), so they need the
__weak.  region_is_ram() needs neither so yes, they should be removed.

<looks at the code>

Doing strcmp("System RAM") is rather a hack.  Is there nothing in
resource.flags which can be used?  Or added otherwise?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
