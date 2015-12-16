Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f172.google.com (mail-qk0-f172.google.com [209.85.220.172])
	by kanga.kvack.org (Postfix) with ESMTP id 5BF656B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 11:36:15 -0500 (EST)
Received: by mail-qk0-f172.google.com with SMTP id p187so72199150qkd.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 08:36:15 -0800 (PST)
Received: from g4t3428.houston.hp.com (g4t3428.houston.hp.com. [15.201.208.56])
        by mx.google.com with ESMTPS id n10si5030599ywb.310.2015.12.16.08.36.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 08:36:14 -0800 (PST)
Message-ID: <1450283759.20148.11.camel@hpe.com>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 16 Dec 2015 09:35:59 -0700
In-Reply-To: <20151216154916.GF29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
	 <20151216122642.GE29775@pd.tnic> <1450280642.29051.76.camel@hpe.com>
	 <20151216154916.GF29775@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: akpm@linux-foundation.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>, Dan Williams <dan.j.williams@intel.com>

On Wed, 2015-12-16 at 16:49 +0100, Borislav Petkov wrote:
> On Wed, Dec 16, 2015 at 08:44:02AM -0700, Toshi Kani wrote:
> > Besides "System RAM", which is commonly searched by multiple callers,
> > we
> > only have a few other uncommon cases:
> >  - crash.c searches for "GART", "ACPI Tables", and "ACPI Non-volatile
> > Storage".
> >  - kexec_file.c searches for "Crash kernel".
> >  - einj.c will search for "Persistent Memory".
> 
> Right, about those other types: your patchset improves the situation
> but doesn't really get rid of the strcmp() and the strings. And using
> strings to find resource types still looks yucky to me, even a week
> later. :)
> 
> So how hard is it to do:
> 
> 	region_intersects(base_addr, size, IORESOURCE_SYSTEM_RAM);
> 	region_intersects(base_addr, size, IORESOURCE_MEM,
> RES_TYPE_PERSISTENT);
> 	walk_iomem_res(RES_TYPE_GART, IORESOURCE_MEM, 0, -1, ced,
> get_gart_ranges_callback);
> 	...
> 
> and so on instead of using those silly strings?

We do not have enough bits left to cover any potential future use-cases
with other strings if we are going to get rid of strcmp() completely. 
 Since the searches from crash and kexec are one-time thing, and einj is a
R&D tool, I think we can leave the strcmp() check for these special cases,
and keep the interface flexible with any strings.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
