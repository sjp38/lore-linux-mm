Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f41.google.com (mail-lf0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 386E36B0255
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 10:49:27 -0500 (EST)
Received: by mail-lf0-f41.google.com with SMTP id p203so32497312lfa.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 07:49:27 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id o23si4243795lfi.65.2015.12.16.07.49.25
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 07:49:25 -0800 (PST)
Date: Wed, 16 Dec 2015 16:49:16 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
Message-ID: <20151216154916.GF29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
 <20151216122642.GE29775@pd.tnic>
 <1450280642.29051.76.camel@hpe.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1450280642.29051.76.camel@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Toshi Kani <toshi.kani@hpe.com>
Cc: akpm@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, Dec 16, 2015 at 08:44:02AM -0700, Toshi Kani wrote:
> Besides "System RAM", which is commonly searched by multiple callers, we
> only have a few other uncommon cases:
>  - crash.c searches for "GART", "ACPI Tables", and "ACPI Non-volatile
> Storage".
>  - kexec_file.c searches for "Crash kernel".
>  - einj.c will search for "Persistent Memory".

Right, about those other types: your patchset improves the situation
but doesn't really get rid of the strcmp() and the strings. And using
strings to find resource types still looks yucky to me, even a week
later. :)

So how hard is it to do:

	region_intersects(base_addr, size, IORESOURCE_SYSTEM_RAM);
	region_intersects(base_addr, size, IORESOURCE_MEM, RES_TYPE_PERSISTENT);
	walk_iomem_res(RES_TYPE_GART, IORESOURCE_MEM, 0, -1, ced, get_gart_ranges_callback);
	...

and so on instead of using those silly strings?

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
