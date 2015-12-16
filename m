Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 27E9E6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 13:17:22 -0500 (EST)
Received: by mail-lf0-f43.google.com with SMTP id z124so30535403lfa.3
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 10:17:22 -0800 (PST)
Received: from mail.skyhub.de (mail.skyhub.de. [2a01:4f8:120:8448::d00d])
        by mx.google.com with ESMTP id 4si4741009lfk.182.2015.12.16.10.17.20
        for <linux-mm@kvack.org>;
        Wed, 16 Dec 2015 10:17:20 -0800 (PST)
Date: Wed, 16 Dec 2015 19:17:12 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH 01/11] resource: Add System RAM resource type
Message-ID: <20151216181712.GJ29775@pd.tnic>
References: <1450136246-17053-1-git-send-email-toshi.kani@hpe.com>
 <20151216122642.GE29775@pd.tnic>
 <1450280642.29051.76.camel@hpe.com>
 <20151216154916.GF29775@pd.tnic>
 <1450283759.20148.11.camel@hpe.com>
 <20151216174523.GH29775@pd.tnic>
 <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <CAPcyv4h+n51Z2hskP2+PX44OB47OQwrKcqVr3nrvMzG++qjC+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Toshi Kani <toshi.kani@hpe.com>, Andrew Morton <akpm@linux-foundation.org>, linux-arch@vger.kernel.org, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, "Rafael J. Wysocki" <rafael.j.wysocki@intel.com>

On Wed, Dec 16, 2015 at 09:52:37AM -0800, Dan Williams wrote:
> It's possible that as far as the resource table is concerned the
> resource type might just be "reserved".  It may not be until after a
> driver loads that we discover the memory range type.  The identifying
> string is driver specific at that point.

So how many types are we talking about here? Because I don't find a whole lot:

$ git grep -E "(walk_iomem_res|find_next_iomem_res|region_intersects)" -- *.c | grep -Eo '\".*\"'
"GART"
"ACPI Tables"
"ACPI Non-volatile Storage"
"Crash kernel"
"System RAM"
"System RAM"
"System RAM"

An int type could contain 2^32 different types.

> All this to say that with strcmp we can search for any custom type .
> Otherwise I think we're looking at updating the request_region()
> interface to take a type parameter.  That makes strcmp capability more
> attractive compared to updating a potentially large number of
> request_region() call sites.

Right, but I don't think that @name param to request_region() was ever
meant to be mis-used as a matching attribute when iterating over the
resource types.

Now, imagine you have to do this pretty often. Which is faster: a
strcmp() or an int comparison...?

Even if this cannot be changed easily/in one go, maybe we should at
least think about starting doing it right so that the strcmp() "fun" is
phased out gradually...

-- 
Regards/Gruss,
    Boris.

ECO tip #101: Trim your mails when you reply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
