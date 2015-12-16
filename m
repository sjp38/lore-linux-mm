Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id EBAAA6B0269
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 07:26:52 -0500 (EST)
Received: by mail-lb0-f175.google.com with SMTP id u9so24293440lbp.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 04:26:52 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id k185si3543571lfd.28.2015.12.16.04.26.51
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 04:26:51 -0800 (PST)
Date: Wed, 16 Dec 2015 13:26:42 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
Message-ID: <20151216122642.GE29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Mon, Dec 14, 2015 at 04:37:16PM -0700, Toshi Kani wrote:
> I/O resource type, IORESOURCE_MEM, is used for all types of
> memory-mapped ranges, ex. System RAM, System ROM, Video RAM,
> Persistent Memory, PCI Bus, PCI MMCONFIG, ACPI Tables, IOAPIC,
> reserved, and so on.  This requires walk_system_ram_range(),
> walk_system_ram_res(), and region_intersects() to use strcmp()
> against string "System RAM" to search System RAM ranges in the
> iomem table, which is inefficient.  __ioremap_caller() and
> reserve_memtype() on x86, for instance, call walk_system_ram_range()
> for every request to check if a given range is in System RAM ranges.
> 
> However, adding a new I/O resource type for System RAM is not
> a viable option [1].

I think you should explain here why it isn't a viable option instead of
quoting some flaky reference which might or might not be there in the
future.

> Instead, this patch adds a new modifier
> flag IORESOURCE_SYSRAM to IORESOURCE_MEM, which introduces an
> extended I/O resource type, IORESOURCE_SYSTEM_RAM [2].
> 
> To keep the code 'if (resource_type(r) == IORESOURCE_MEM)' to
> work continuously for System RAM, resource_ext_type() is added
> for extracting extended type bit(s).
> 
> Cc: Linus Torvalds <torvalds@linux-foundation.org>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Borislav Petkov <bp@alien8.de>
> Cc: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> Cc: Dan Williams <dan.j.williams@intel.com>
> Reference[1]: https://lkml.org/lkml/2015/12/3/540
> Reference[2]: https://lkml.org/lkml/2015/12/3/582

References should look something like this:

Link: http://lkml.kernel.org/r/<Message-ID>

> Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
> ---
>  include/linux/ioport.h |   11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/include/linux/ioport.h b/include/linux/ioport.h
> index 24bea08..4b65d94 100644
> --- a/include/linux/ioport.h
> +++ b/include/linux/ioport.h
> @@ -49,12 +49,19 @@ struct resource {
>  #define IORESOURCE_WINDOW	0x00200000	/* forwarded by bridge */
>  #define IORESOURCE_MUXED	0x00400000	/* Resource is software muxed */
>  
> +#define IORESOURCE_EXT_TYPE_BITS 0x01000000	/* Resource extended types */

Should this be 0x07000000 so that we make all there bits belong to the
extended types? Are we going to need so many?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
