Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 020CA6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 16:52:56 -0500 (EST)
Received: by mail-ig0-f178.google.com with SMTP id ph11so163443555igc.1
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 13:52:55 -0800 (PST)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id c19si2805449ioj.142.2015.12.16.13.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 13:52:55 -0800 (PST)
Message-ID: <1450302758.20148.75.camel@hpe.com>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
From: Toshi Kani <toshi.kani@hpe.com>
Date: Wed, 16 Dec 2015 14:52:38 -0700
In-Reply-To: <20151216181712.GJ29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
	 <20151216122642.GE29775@pd.tnic> <1450280642.29051.76.camel@hpe.com>
	 <20151216154916.GF29775@pd.tnic> <1450283759.20148.11.camel@hpe.com>
	 <20151216174523.GH29775@pd.tnic>
	 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
	 <20151216181712.GJ29775@pd.tnic>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, Dan Williams <dan.j.williams@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Wed, 2015-12-16 at 19:17 +0100, Borislav Petkov wrote:
> On Wed, Dec 16, 2015 at 09:52:37AM -0800, Dan Williams wrote:
> > It's possible that as far as the resource table is concerned the
> > resource type might just be "reserved".  It may not be until after a
> > driver loads that we discover the memory range type.  The identifying
> > string is driver specific at that point.
> 
> So how many types are we talking about here? Because I don't find a whole
> lot:
> 
> $ git grep -E "(walk_iomem_res|find_next_iomem_res|region_intersects)" --
> *.c | grep -Eo '\".*\"'
> "GART"
> "ACPI Tables"
> "ACPI Non-volatile Storage"
> "Crash kernel"
> "System RAM"
> "System RAM"
> "System RAM"
> 
> An int type could contain 2^32 different types.

In this approach, as I understand, we add a new field to 'struct resource',
i.e. 'type' in this example.

 struct resource crashk_res = {
        .name  = "Crash kernel",
        .start = 0,
        .end   = 0,
        .flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+ 	.type  = RES_TYPE_CRASH_KERNEL,
 };

And we change the callers, such as "kernel/kexec_file.c" to search with
this RES_TYPE.

 ret = walk_iomem_res(RES_TYPE_CRASH_KERNEL,
		IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY, ...);

We only change the resource entries that support the search interfaces to:
 - Assign RES_TYPE_XXX.
 - Initialize 'type' in its 'struct resource' with the type.

This avoids changing all drivers.  When we have a new search for "foo", we
will then need to:
 - Define RES_TYPE_FOO.
 - Add '.type = RES_TYPE_FOO' to the code where it initializes the "foo"
entry.

This scheme may have a problem, though.  For instance, when someone writes
a loadable module that searches for "foo", but the "foo" entry may be
initialized in a distro kernel/driver that cannot be modified.  Since this
search is only necessary to obtain a range initialized by other module,
this scenario is likely to happen.  We no longer have ability to search for
a new entry unless we modify the code that initializes the entry first.

> > All this to say that with strcmp we can search for any custom type .
> > Otherwise I think we're looking at updating the request_region()
> > interface to take a type parameter.  That makes strcmp capability more
> > attractive compared to updating a potentially large number of
> > request_region() call sites.
> 
> Right, but I don't think that @name param to request_region() was ever
> meant to be mis-used as a matching attribute when iterating over the
> resource types.

Even if we avoid strcmp() with @name in the kernel, user applications will
continue to use @name since that is the only type available in /proc/iomem.
 For instance, kexec has its own search function with a string name.

 https://github.com/Tasssadar/kexec-tools/blob/master/kexec/kexec-iomem.c

> Now, imagine you have to do this pretty often. Which is faster: a
> strcmp() or an int comparison...?
> 
> Even if this cannot be changed easily/in one go, maybe we should at
> least think about starting doing it right so that the strcmp() "fun" is
> phased out gradually...

When a new commonly-used search name comes up, we can define it as a new
extended I/O resource type similar to IORESOURCE_SYSTEM_RAM.  For the
current remaining cases, i.e. crash, kexec, and einj, they have no impact
to performance.  Leaving these special cases aside will keep the ability to
search for any entry without changing the kernel, and save some memory
space from adding the new 'type'.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
